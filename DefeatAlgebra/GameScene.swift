//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
    case AddEnemy, EnemyMoving, EnemyPunching
}

enum Direction: Int {
    case front = 1, back, left, right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var wall: SKShapeNode!
    
    /* Game constants */
    /* enemy property */
    var moveTimer: CFTimeInterval = 0
    var singleMoveTime: CFTimeInterval = 0.75
    let attackTime: TimeInterval = 0.5
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Game buttons */
    var test: MSButtonNode!
    var test2: MSButtonNode!
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var punchUndoneFlag = true
    var attackFlag = false
    var allPunchDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        
        /* Connect game buttons */
        test = childNode(withName: "test") as! MSButtonNode
        test2 = childNode(withName: "test2") as! MSButtonNode
        
        test.selectedHandler = {
            
            /* Remove wall */
            self.removeChildren(in: [self.wall])
            
            let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(3) })
            let wait = SKAction.wait(forDuration: 1.0)
            let addDone = SKAction.run({ self.addEnemyDoneFlag = true })
            let seq = SKAction.sequence([addEnemy, wait, addDone])
            self.run(seq)
            
            self.gameState = .EnemyMoving
        }
        
        test2.selectedHandler = {
            self.gameState = .EnemyPunching
        }
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self

        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set hero */
        hero = Hero()
        hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+gridNode.size.height/2)
        addChild(hero)
        
        /* Set invisible wall */
        setWall()

    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            break;
        case .EnemyMoving:
            if self.addEnemyDoneFlag {
                /* Set invisible wall */
                setWall()
                self.addEnemyDoneFlag = false
            }
            allPunchDoneFlag = false
            punchUndoneFlag = true
            enemyMoveAround()
        case .EnemyPunching:
            /* Make sure execute punch once */
            if punchUndoneFlag {
                /* Do punch */
                let punch = SKAction.run({ self.enemyPunch() })
                let wait = SKAction.wait(forDuration: TimeInterval(gridNode.maxDuration))
                let onFlag = SKAction.run({ self.allPunchDoneFlag = true })
                let seq = SKAction.sequence([punch, wait, onFlag])
                self.run(seq)
                
                /* punch is done */
                punchUndoneFlag = false
            }
            
            /* Make sure enemy start to move again after all punches finish */
            if allPunchDoneFlag {
                gameState = .EnemyMoving
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!              // Get the first touch
        beganPos = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        /* Move hero */
        moveHeroBySwipe(diffPos)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Player is hit by something */
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            /* If player step on during attack time, enemy will be destoried */
            if attackFlag {
                if contactA.categoryBitMask == 1 {
                    if contactB.categoryBitMask == 8 {
                        let nodeB = contactB.node as! EnemyFist
                        nodeB.parent?.removeFromParent()
                    }
                } else if contactB.categoryBitMask == 1 {
                    if contactA.categoryBitMask == 8 {
                        let nodeA = contactA.node as! EnemyFist
                        nodeA.parent?.removeFromParent()
                    }
                }
            } else {
                print("Game Over")
            }
        }
        
        /* Enemy's arm or fist hits wall */
        if contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16 {
            
            if contactA.categoryBitMask == 16 {
                /* Arm hits wall */
                if contactB.categoryBitMask == 4 {
                    /* Get enemy arm */
                    let nodeB = contactB.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeB.removeAllActions()
                    
                    /* Get parent of arm */
                    let enemy = nodeB.parent as! Enemy
                    
                    /* Create new same arm without animation */
                    let createNewArm = SKAction.run({
                        let size = nodeB.size
                        let newArm1 = EnemyArm(direction: enemy.direction)
                        let newArm2 = EnemyArm(direction: enemy.direction)
                        newArm1.yScale = (size.height-3)/newArm1.size.height
                        newArm2.yScale = (size.height-3)/newArm2.size.height
                        enemy.setArm(arm: [newArm1, newArm2], direction: enemy.direction)
                        enemy.addChild(newArm1)
                        enemy.addChild(newArm2)
                        
                        /* For use later */
                        enemy.armHitWallArray.append(newArm1)
                        enemy.armHitWallArray.append(newArm2)
                        
                        /* Get rid of old arm */
                        nodeB.removeFromParent()
                    })
                    
                    let wait = SKAction.wait(forDuration: 0.1)
                    
                    /* Go around punch */
                    let goAround = SKAction.run({
                        /* Calculate left length of punch */
                        let leftLength = enemy.punchLength-nodeB.size.height
                        /* Go around punch */
                        self.goAroundPunch(enemy: enemy, length: leftLength)
                    })
                    
                    let seq = SKAction.sequence([createNewArm, wait, goAround])
                    self.run(seq)
                    
                /* Fist hits wall */
                } else if contactB.categoryBitMask == 8 {
                    /* Get enemy fist */
                    let nodeB = contactB.node as! EnemyFist
                    
                    /* Get rid of fist */
                    nodeB.removeFromParent()
                    
                }
            }
            if contactB.categoryBitMask == 16 {
                /* In case arm hit wall */
                if contactA.categoryBitMask == 4 {
                    /* Get enemy arm */
                    let nodeA = contactA.node as! EnemyArm
                    /* Stop extending arm */
                    nodeA.removeAllActions()
                    
                /* In case fist hit wall */
                } else if contactA.categoryBitMask == 8 {
                    /* Get enemy fist */
                    let nodeA = contactA.node as! EnemyFist
                    
                    /* Go around punch */
                    self.goAroundPunch(enemy: nodeA.parent as! Enemy, length: 10)
                    
                    /* Get rid of fist */
                    nodeA.removeFromParent()
                    
                }
            }
        }
    }
    
    func moveHeroBySwipe(_ diffPos: CGPoint) {
        
        var degree:Int
        
        if diffPos.x != 0 {
            /* horizontal move */
            let radian = atan(diffPos.y/fabs(diffPos.x)) // calculate radian by arctan
            degree = Int(radian * CGFloat(180 * M_1_PI)) // convert radian to degree
        } else {
            /* just touch */
            if diffPos.y == 0 {
                degree = 1000
            } else {
                /* vertical move */
                degree = diffPos.y < 0 ? -90:90;
            }
        }
        
        switch degree {
        case -90 ..< -45:
            /* Reset movement */
            hero.removeAllActions()
            
            hero.direction = .front
            hero.setTexture()
            hero.setMovingAnimation()
            
            /* Move hero forward */
            let moveOne = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
            let move = SKAction.repeatForever(moveOne)
            hero.run(move)
            
        case -45 ..< 45:
            if diffPos.x >= 0 {
                /* Reset movement */
                hero.removeAllActions()
                
                hero.direction = .right
                hero.setTexture()
                hero.setMovingAnimation()
                
                /* Move hero right */
                let moveOne = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                let move = SKAction.repeatForever(moveOne)
                hero.run(move)
                
            } else {
                /* Reset movement */
                hero.removeAllActions()
                
                hero.direction = .left
                hero.setTexture()
                hero.setMovingAnimation()
                
                /* Move hero left */
                let moveOne = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                let move = SKAction.repeatForever(moveOne)
                hero.run(move)
                
            }
        case 45 ... 90:
            /* Reset movement */
            hero.removeAllActions()
            
            hero.direction = .back
            hero.setTexture()
            hero.setMovingAnimation()
            
            /* Move hero backward */
            let moveOne = SKAction.moveBy(x: 0, y: CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
            let move = SKAction.repeatForever(moveOne)
            hero.run(move)
            
        default:
            /* Stop movement */
            hero.removeAllActions()
            hero.setTexture()
            break;
        }
        
    }
    
    func enemyMoveAround() {
        /* Time to move enemy */
        if moveTimer >= singleMoveTime {
            
            /* move Enemy */
            for enemy in gridNode.enemyArray {
                let directionIndex = arc4random_uniform(4)+1
                enemy.direction = Direction(rawValue: Int(directionIndex))!
                enemy.setMovingAnimation()
                enemy.enemyMove(lengthX: gridNode.cellWidth, lengthY: gridNode.cellHeight)
            }
            
            // Reset spawn timer
            moveTimer = 0
        }
        
        moveTimer += fixedDelta
    }
    
    func setWall() {
        
        /* Calculate size of wall */
        let size = CGSize(width: gridNode.cellWidth*10, height: gridNode.cellHeight*10)
        
        /* Calculate position of wall */
        let position = CGPoint(x: self.size.width/2, y: gridNode.size.height/2+gridNode.position.y)
        
        wall = SKShapeNode(rectOf: size)
        wall.strokeColor = SKColor.blue
        wall.lineWidth = 2.0
        wall.alpha = CGFloat(0)
        wall.physicsBody = SKPhysicsBody(edgeLoopFrom: wall.frame)
        wall.physicsBody?.categoryBitMask = 16
        wall.physicsBody?.collisionBitMask = 3
        wall.physicsBody?.contactTestBitMask = 12
        wall.position = position
        self.addChild(wall)
    }
    
    /* Excute panch */
    func enemyPunch() {
        for enemy in self.gridNode.enemyArray {
            
            /* Off punchDoneFlag */
            enemy.punchDoneFlag = false
            
            /* Stop animation of enemy */
            enemy.removeAllActions()
            
            /* Set texture according to direction of enemy */
            enemy.setTextureInPunch()
            
            /* Do punch */
            let armAndFist = enemy.punch()
            
            /* Wait untill enemy punch streach out */
            let wait = SKAction.wait(forDuration: TimeInterval(enemy.punchLength*enemy.punchSpeed))

            /* Make sure player can kill by stepping on enemy's fist during attack time */
            let attackFlagOn = SKAction.run({ self.attackFlag = true })
            let attackTime = SKAction.wait(forDuration: self.attackTime)
            let attackFlagOff = SKAction.run({ self.attackFlag = false })
            
            /* Draw punch */
            let drawPunch = SKAction.run({ enemy.drawPunch(arms: armAndFist.arm, fists: armAndFist.fist, length: enemy.punchLength) })
            
            /* Make sure delete arms & fists after finishing punch drawing */
            let drawWait = SKAction.wait(forDuration: TimeInterval(enemy.punchLength*enemy.punchSpeed-0.1))
            
            /* Get rid of all arms and fists */
            let punchDone = SKAction.run({
                enemy.removeAllChildren()
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, attackFlagOn, attackTime, attackFlagOff, drawPunch, drawWait, punchDone])
            self.run(seq)
        }
    }
    
    /* Generate punch from opposite side when reaching the edge of grid */
    func goAroundPunch(enemy: Enemy, length: CGFloat) {
        
        /*==*/
        /*== Set arm and fist the other side and punch and draw ==*/
        /*==*/
        
        /* Set arm */
        let arm1 = EnemyArm(direction: enemy.direction)
        let arm2 = EnemyArm(direction: enemy.direction)
        
        /* Set fist */
        let fist1 = EnemyFist(direction: enemy.direction)
        let fist2 = EnemyFist(direction: enemy.direction)
        
        /* Set position according to enemy's direction */
        switch enemy.direction {
        case .front:
            /* Calculate position y */
            let posY = gridNode.size.height-enemy.position.y-CGFloat(gridNode.cellHeight)-5

            /* Arm */
            let armPos1 = CGPoint(x: -13, y: posY)
            let armPos2 = CGPoint(x: 13, y: posY)
            arm1.position = armPos1
            arm2.position = armPos2
            
            /* Fist */
            let fistPos1 = CGPoint(x: -13, y: posY-15)
            let fistPos2 = CGPoint(x: 13, y: posY-15)
            fist1.position = fistPos1
            fist2.position = fistPos2
        case .back:
            /* Calculate position y */
            let posY = -enemy.position.y+CGFloat(gridNode.cellHeight)+13
            
            /* Arm */
            let armPos1 = CGPoint(x: -13, y: posY)
            let armPos2 = CGPoint(x: 13, y: posY)
            arm1.zPosition = -1
            arm2.zPosition = -1
            arm1.position = armPos1
            arm2.position = armPos2
            
            /* Fist */
            let fistPos1 = CGPoint(x: -13, y: posY+5)
            let fistPos2 = CGPoint(x: 13, y: posY+5)
            fist1.position = fistPos1
            fist2.position = fistPos2
            
        case .left:
            /* Calculate position x */
            let posX = gridNode.size.width-enemy.position.x-CGFloat(gridNode.cellWidth)-5
            
            /* Arm */
            let armPos1 = CGPoint(x: posX, y: 3)
            let armPos2 = CGPoint(x: posX, y: -10)
            arm2.zPosition = -1
            arm1.position = armPos1
            arm2.position = armPos2
            
            /* Fist */
            let fistPos1 = CGPoint(x: posX-15, y: 3)
            let fistPos2 = CGPoint(x: posX-15, y: -10)
            fist1.position = fistPos1
            fist2.position = fistPos2
            
        case .right:
            /* Calculate position x */
            let posX = -enemy.position.x+CGFloat(gridNode.cellWidth)+5
            
            /* Arm */
            let armPos1 = CGPoint(x: posX, y: 3)
            let armPos2 = CGPoint(x: posX, y: -10)
            arm2.zPosition = -1
            arm1.position = armPos1
            arm2.position = armPos2
            
            /* Fist */
            let fistPos1 = CGPoint(x: posX+15, y: 3)
            let fistPos2 = CGPoint(x: posX+15, y: -10)
            fist1.position = fistPos1
            fist2.position = fistPos2
            
        }
        
        /* Add arm as enemy child */
        enemy.addChild(arm1)
        enemy.addChild(arm2)
        
        /* Add arm as fist child */
        enemy.addChild(fist1)
        enemy.addChild(fist2)
        
        /* Move Fist */
        fist1.moveFistForward(length: length, speed: enemy.punchSpeed)
        fist2.moveFistForward(length: length, speed: enemy.punchSpeed)
        
        /* Extend arm */
        arm1.extendArm(length: length, speed: enemy.punchSpeed)
        arm2.extendArm(length: length, speed: enemy.punchSpeed)
        
        /* Wait untill enemy punch streach out */
        let extendWait = SKAction.wait(forDuration: TimeInterval(length*enemy.punchSpeed))
        
        /* Make sure player can kill by stepping on enemy's fist during attack time */
        let attackFlagOn = SKAction.run({ self.attackFlag = true })
        let attackTime = SKAction.wait(forDuration: self.attackTime)
        let attackFlagOff = SKAction.run({ self.attackFlag = false })
        
        /* Draw punch */
        let drawPunch = SKAction.run({
            enemy.drawPunch(arms: [arm1, arm2], fists: [fist1, fist2], length: length)
            /* Make sure delete fise */
            fist1.moveFistBackward(length: 20, speed: enemy.punchSpeed)
            fist2.moveFistBackward(length: 20, speed: enemy.punchSpeed)
        })
        
        /* Make sure delete arms after amr shrink back completely */
        let drawWait1 = SKAction.wait(forDuration: TimeInterval(length*enemy.punchSpeed))
        
        /* Get rid of arms and fists */
        let deleteArmAndFist = SKAction.run({
            arm1.removeFromParent()
            arm2.removeFromParent()
        })
        
        /*==*/
        /*== Set arm and fist the forward side and draw punch ==*/
        /*==*/
        
        /* Create new fist */
        /* Set fist */
        let newFist1 = EnemyFist(direction: enemy.direction)
        let newFist2 = EnemyFist(direction: enemy.direction)
        
        /* Set position of new fist according to enemy's direction */
        switch enemy.direction {
        case .front:
            /* Calculate position y */
            let posY = -enemy.position.y+CGFloat(gridNode.cellHeight)+13
            
            /* Fist */
            let fistPos1 = CGPoint(x: -13, y: posY+5)
            let fistPos2 = CGPoint(x: 13, y: posY+5)
            newFist1.position = fistPos1
            newFist2.position = fistPos2
        case .back:
            /* Calculate position y */
            let posY = gridNode.size.height-enemy.position.y-CGFloat(gridNode.cellHeight)-5
            
            /* Fist */
            let fistPos1 = CGPoint(x: -13, y: posY-15)
            let fistPos2 = CGPoint(x: 13, y: posY-15)
            newFist1.position = fistPos1
            newFist2.position = fistPos2
            
        case .left:
            /* Calculate position x */
            let posX = -enemy.position.x+CGFloat(gridNode.cellWidth)+5
            
            /* Fist */
            let fistPos1 = CGPoint(x: posX+15, y: 3)
            let fistPos2 = CGPoint(x: posX+15, y: -10)
            newFist1.position = fistPos1
            newFist2.position = fistPos2
            
        case .right:
            /* Calculate position x */
            let posX = gridNode.size.width-enemy.position.x-CGFloat(gridNode.cellWidth)-5
            
            /* Fist */
            let fistPos1 = CGPoint(x: posX-15, y: 3)
            let fistPos2 = CGPoint(x: posX-15, y: -10)
            newFist1.position = fistPos1
            newFist2.position = fistPos2
            
        }
        
        /* Add arm as enemy child */
        let showUpNewFist = SKAction.run({
            enemy.addChild(newFist1)
            enemy.addChild(newFist2)
        })
        
        /* Draw left punch */
        let drawLeftPunch = SKAction.run({
            /* Calculate left length */
            if enemy.armHitWallArray.count > 0 {
                let leftLength = enemy.armHitWallArray[0].size.height
                /* Draw punch */
                enemy.drawPunch(arms: enemy.armHitWallArray, fists: [newFist1, newFist2], length: leftLength)
            } else {
                let leftLength = CGFloat(1.0)
                /* Draw punch */
                enemy.drawPunch(arms: enemy.armHitWallArray, fists: [newFist1, newFist2], length: leftLength)
            }
        })
        
        /* Make sure delete arms & fists after finishing punch drawing */
        let drawWait2 = SKAction.wait(forDuration: TimeInterval(enemy.armHitWallArray[0].size.height*enemy.punchSpeed-0.1))
        
        /* Get rid of all arms and fists */
        let punchDone = SKAction.run({
            enemy.removeAllChildren()
            enemy.armHitWallArray.removeAll()
        })
        
        /* excute drawPunch */
        let seq = SKAction.sequence([extendWait, attackFlagOn, attackTime, attackFlagOff, drawPunch, drawWait1, deleteArmAndFist, showUpNewFist, drawLeftPunch, drawWait2, punchDone])
        self.run(seq)
    }
}
