//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

/* Index of categryBitMask of game objects */
/*
 1: Hero
 2: Enemy
 4: EnemyArm
 8: EnemyFist
 16: GameConsole
 32: Mine
 64: HitPoint
 128: MineToGet
 1024: Wall
*/

import SpriteKit
import GameplayKit

//enum GameSceneState {
//    case AddEnemy, PropagateEnemy, EnemyMoving, GridFlashing, EnemyPunching, GameOver
//}
//
//enum Direction: Int {
//    case front = 1, back, left, right
//}

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var wall: SKShapeNode!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Enemy property */
    var moveTimer: CFTimeInterval = 0
    var singleMoveTime: CFTimeInterval = 0.5 /* the duration when enemy move by one cell */
    let attackTime: TimeInterval = 0.5  /* the duration when player can destroy enemy */
    let singlePunchStayTime: CGFloat = 2.0
    var punchStayTime: TimeInterval = 0  /* the duration between finishing flash and starting punch. It will be fixed according to number of enemy */
    
    /* Add enemy */
    var numOfAddEnemy = 3
    var numOfPropagateEnemy = 2
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 20 /* Add enemy after enemy move 10 times */
    
    /* Flash grid */
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    
    /* Game console as point to gather */
    var numOfGameConsole = 1
    
    /* Game buttons */
    var retryButton: MSButtonNode!
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var propagateEnemyDoneFlag = false
    var punchDoneFlag = false 
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    
    /* Store longest duration punch will take to confirm all punches finish */
    var numOfFlash: Int = 0
    var longestPunchLength: CGFloat = 0
    var maxDuration: CGFloat = 6
    
    /* Game Score */
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        
        /* Connect game buttons */
        retryButton = childNode(withName: "retryButton") as! MSButtonNode
        retryButton.state = .msButtonNodeStateHidden
        
        retryButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Game Over label */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Score label */
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode        
        
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
        
        /* Set first game console */
//        self.gridNode.addGameConsole(1)

        /* Set first mine to get */
        self.gridNode.addMineToGet(1)

    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            
            /* Make sure call addEnemy only once */
            if addEnemyDoneFlag == false {
                self.addEnemyDoneFlag = true
                
                /* Add enemy on grid */
                let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(self.numOfAddEnemy) })
                let wait = SKAction.wait(forDuration: 3.0)
                let addDone = SKAction.run({ self.gameState = .EnemyMoving })
                let seq = SKAction.sequence([addEnemy, wait, addDone])
                self.run(seq)
                
                /* Reset count turn */
                countTurnForAddEnemy = 0
            }
        case .PropagateEnemy:
            /* Make sure call PropagateEnemy only once */
            if propagateEnemyDoneFlag == false {
                self.propagateEnemyDoneFlag = true
                
                /* Add enemy on grid */
                let addEnemy = SKAction.run({ self.gridNode.propagateEnemy(enemyArray: self.gridNode.enemyArray, numberOfEnemy: self.numOfPropagateEnemy) })
                let wait = SKAction.wait(forDuration: 1.5)
                let addDone = SKAction.run({ self.gameState = .EnemyMoving })
                let seq = SKAction.sequence([addEnemy, wait, addDone])
                self.run(seq)
            }
        case .EnemyMoving:
            
            /* When fixed truns passes, add new enemy */
//            self.addEnemy()
            
            /* After adding Enemy, set enemy's collision to wall */
            if addEnemyDoneFlag {
                for enemy in self.gridNode.enemyArray {
                    enemy.setEnemyCollisionToWall()
                }
                addEnemyDoneFlag = false
            }
            
            /* If no enemy, no flash and add enemies */
            if self.gridNode.enemyArray.count > 0 {
                /* When fixed truns passes, make grid flash */
                self.flashGrid()
            } else {
                gameState = .AddEnemy
            }
            
            /* Reset propagateEnemyDoneFlag */
            if propagateEnemyDoneFlag {
                propagateEnemyDoneFlag = false
            }
            
            /* Reset flashGridDoneFlag */
            if flashGridDoneFlag {
                flashGridDoneFlag = false
            }
            
            /* Reset punchDoneFlag */
            if punchDoneFlag {
                punchDoneFlag = false
            }
            
            /* Reset allPunchDoneFlag */
            if allPunchDoneFlag {
                allPunchDoneFlag = false
            }
            
            /* Make enemy move aorund automatically */
            enemyMoveAround()
            break;
            
        case .GridFlashing:
            
            /* Make sure call flashGrid only once */
            if flashGridDoneFlag == false {
                self.flashGridDoneFlag = true
                
                /* Remove mine to get on grid */
                if let theNode = self.gridNode.childNode(withName: "mineToGet") {
                    theNode.removeFromParent()
                }
                
                /* Make grid flash */
                numOfFlash = self.gridNode.flashGrid(labelNode: self.valueOfX)
            
                /* Caluculate punch length of enemy */
                for (i, enemy) in self.gridNode.enemyArray.enumerated() {
                    enemy.calculatePunchLength(value: numOfFlash)
                    if longestPunchLength < enemy.punchLength {
                        longestPunchLength = enemy.punchLength
                        maxDuration = 2*longestPunchLength*enemy.punchSpeed+CGFloat(attackTime)
                    }
                    /* Make sure to calculate maxDuration properly */
                    if i == self.gridNode.enemyArray.count-1 {
                        self.punchStayTime = TimeInterval(self.singlePunchStayTime*CGFloat(self.gridNode.enemyArray.count))
                        calPunchLengthDoneFlag = true
                    }
                }
            }
            
            /* Make sure to calculate maxDuration properly */
            if calPunchLengthDoneFlag {
                calPunchLengthDoneFlag = false
                
                /* Set wait time for player to caluculate variable expression */
                let waitTime = Double(numOfFlash) * self.gridNode.flashSpeed + self.punchStayTime
                let wait = SKAction.wait(forDuration: TimeInterval(waitTime))
                
                /* Display vaue of x on screen */
                let displayValueX = SKAction.run({
                    self.valueOfX.text = "\(self.numOfFlash)"
                    self.valueOfX.position = CGPoint(x: 111, y: self.valueOfX.position.y)
                })
                
                /* Move state to excute punch */
                let moveState = SKAction.run({ self.gameState = .EnemyPunching })
                let seq = SKAction.sequence([wait, displayValueX, moveState])
                self.run(seq)
                
                /* Reset count turn */
                countTurnForFlashGrid = 0
            }
            break;
            
        case .EnemyPunching:
            
            /* Make sure to execute punch once */
            if punchDoneFlag == false {
                punchDoneFlag = true
                
                /* Do punch */
                let punch = SKAction.run({ self.enemyPunch() })
                
                /* Wait untill all punch done */
                let wait = SKAction.wait(forDuration: TimeInterval(self.maxDuration+0.3)) /* 0.3 is buffer */
                let onFlag = SKAction.run({ self.allPunchDoneFlag = true })
                
                /* Reset value of x label */
                let undoValueX = SKAction.run({
                    self.valueOfX.text = "Flash Times"
                    self.valueOfX.position = CGPoint(x: 200, y: self.valueOfX.position.y)
                })

                let seq = SKAction.sequence([punch, wait, undoValueX, onFlag])
                self.run(seq)
            }
            
            /* Make sure enemy start to move again after all punches finish */
            if allPunchDoneFlag {
                /* Change game state */
                if self.gridNode.enemyArray.count > 0 {
                    gameState = .PropagateEnemy
                } else {
                    gameState = .EnemyMoving
                }
                
                /* Remove dead enemy from enemyArray */
                self.gridNode.enemyArray = self.gridNode.enemyArray.filter({ $0.aliveFlag == true })
                
                /* Remove all mine */
                for _ in 0...self.gridNode.numOfMineOnGrid {
                    if let theNode = self.gridNode.childNode(withName: "mine") {
                        theNode.removeFromParent()
                    }
                }
                
                /* Reset number of mine on grid */
                self.gridNode.numOfMineOnGrid = 0
                
                /* Set first mine to get */
                self.gridNode.addMineToGet(1)
            }
            break;
        case .GameOver:
            /* Display Game over */
            gameOverLabel.isHidden = false
            
            /* Activate retryButton */
            retryButton.state = .msButtonNodeStateActive
            break;
        
        default:
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Make sure to stop if game over */
        guard gameState != .GameOver else { return }
        
        let touch = touches.first!              // Get the first touch
        beganPos = touch.location(in: self)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Make sure to stop if game over */
        guard gameState != .GameOver else { return }
        
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        /* Move hero */
        moveHeroBySwipe(diffPos)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Make sure to stop if game over */
        guard gameState != .GameOver else { return }
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Player hit something */
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            
            /* Player hit hitPoint */
            if contactA.categoryBitMask == 64 || contactB.categoryBitMask == 64 {
                if contactA.categoryBitMask == 1 {
                    /* Get node as hitPoint */
                    let nodeB = contactB.node as! SKShapeNode
                    /* Get parent as enemy */
                    let enemy = nodeB.parent as! Enemy
                    /* Change enemy state to dead to remove from enemyArray */
                    enemy.aliveFlag = false
                    /*  Destroy enemy */
                    enemy.removeFromParent()
                    self.score += 1
                
                } else if contactB.categoryBitMask == 1 {
                    /* Get node as hitPoint */
                    let nodeA = contactA.node as! SKShapeNode
                    /* Get parent as enemy */
                    let enemy = nodeA.parent as! Enemy
                    /* Change enemy state to dead to remove from enemyArray */
                    enemy.aliveFlag = false
                    /*  Destroy enemy */
                    enemy.removeFromParent()
                    self.score += 1
                }
            /* Player hit fist */
            } else if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
                if contactA.categoryBitMask == 1 {
                    /* Get node as fist */
                    let nodeB = contactB.node as! EnemyFist
                    /* Get parent as parent */
                    let enemy = nodeB.parent as! Enemy
                    /* If player step on during enemy's punch streaching out, plyer will survive */
                    if enemy.punchState == .streachOut {
                        return
                   /* Game Over */
                    } else {
                        contactA.node?.removeFromParent()
                    }
                } else if contactB.categoryBitMask == 1 {
                    /* Get node as fist */
                    let nodeA = contactA.node as! EnemyFist
                    /* Get parent as parent */
                    let enemy = nodeA.parent as! Enemy
                    /* If player step on during enemy's punch streaching out, player will survive */
                    if enemy.punchState == .streachOut {
                        return
                    /* Game Over */
                    } else {
                        contactB.node?.removeFromParent()
                    }
                }
            
            /* Get game console */
            } else if contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16 {
                if contactA.categoryBitMask == 1 { contactB.node?.removeFromParent() }
                if contactB.categoryBitMask == 1 { contactA.node?.removeFromParent() }
                self.gridNode.addGameConsole(self.numOfGameConsole)
//                self.score += 1
            
            /* Get mine to get */
            } else if contactA.categoryBitMask == 128 || contactB.categoryBitMask == 128 {
                /* Make sure to display mine to get only when gameState is EnemyMoving or AddEnemy */
                guard self.gameState == .EnemyMoving || self.gameState == .AddEnemy || self.gameState == .PropagateEnemy else { return }
                
                if contactA.categoryBitMask == 1 { contactB.node?.removeFromParent() }
                if contactB.categoryBitMask == 1 { contactA.node?.removeFromParent() }
                self.gridNode.addMineToGet(1)
                self.gridNode.numOfMine += 1
                    
            /* Game over */
            } else {
                if contactA.categoryBitMask == 1 {
                    print("\(contactB.categoryBitMask)")
                    contactA.node?.removeFromParent() }
                if contactB.categoryBitMask == 1 {
                    print("\(contactA.categoryBitMask)")
                    contactB.node?.removeFromParent()
                }
                self.gameState = .GameOver
            }
        }
        
        /* Mine hit enemy's fist */
        if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32 {
            
            if contactA.categoryBitMask == 32 {
                if contactB.categoryBitMask == 64 {
                    /* Get node as hitPoint */
                    let nodeB = contactB.node as! SKShapeNode
                    /* Get parent as enemy */
                    let enemy = nodeB.parent as! Enemy
                    /* Change enemy state to dead to remove from enemyArray */
                    enemy.aliveFlag = false
                    /*  Destroy enemy */
                    enemy.removeFromParent()
                    self.score += 1
                    /* Remove mine */
                    contactA.node?.removeFromParent()
                }
            } else if contactB.categoryBitMask == 32 {
                if contactA.categoryBitMask == 64 {
                    /* Get node as hitPoint */
                    let nodeA = contactA.node as! SKShapeNode
                    /* Get parent as enemy */
                    let enemy = nodeA.parent as! Enemy
                    /* Change enemy state to dead to remove from enemyArray */
                    enemy.aliveFlag = false
                    /*  Destroy enemy */
                    enemy.removeFromParent()
                    self.score += 1
                    /* Remove mine */
                    contactB.node?.removeFromParent()
                }
            }
            
        }
        
        /* Enemy's arm or fist hits wall */
        if contactA.categoryBitMask == 1024 || contactB.categoryBitMask == 1024 {
            
            if contactA.categoryBitMask == 1024 {
                /* Arm hits wall */
                if contactB.categoryBitMask == 4 {
                    /* Get enemy arm */
                    let nodeB = contactB.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeB.removeAllActions()
                    
                    /* Get parent of arm */
                    let enemy = nodeB.parent as! Enemy
                    
                    /* Create new same arm without animation */
                    let size = nodeB.size
                    let originPosition = nodeB.position
                    let newArm = EnemyArm(direction: enemy.direction)
                    newArm.yScale = (size.height-3)/newArm.size.height
                    newArm.position = originPosition
                    enemy.addChild(newArm)
                        
                    /* For use later when making it shrink */
                    enemy.armHitWallArray.append(newArm)
                    
                    /* Calculate left length of punch */
                    let leftLength = enemy.punchLength-size.height
                    
                    /* Go around punch */
                    self.goAroundPunch(enemy: enemy, position: originPosition, length: leftLength, lastArm: newArm)
                    
                    /* Get rid of old arm */
                    nodeB.removeFromParent()
                    
                /* Fist hits wall */
                } else if contactB.categoryBitMask == 8 {
                    /* Get enemy fist */
                    let nodeB = contactB.node as! EnemyFist
                    
                    /* Get rid of fist */
                    nodeB.removeFromParent()
                    
                }
            }
            if contactB.categoryBitMask == 1024 {
                /* In case arm hit wall */
                if contactA.categoryBitMask == 4 {
                    /* Get enemy arm */
                    let nodeA = contactA.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeA.removeAllActions()
                    
                    /* Get parent of arm */
                    let enemy = nodeA.parent as! Enemy
                    
                    /* Create new same arm without animation */
                    let size = nodeA.size
                    let originPosition = nodeA.position
                    let newArm = EnemyArm(direction: enemy.direction)
                    newArm.yScale = (size.height-3)/newArm.size.height
                    newArm.position = originPosition
                    enemy.addChild(newArm)
                        
                    /* For use later when making it shrink */
                    enemy.armHitWallArray.append(newArm)
                        
                    /* Get rid of old arm */
                    nodeA.removeFromParent()
                    
                    /* Calculate left length of punch */
                    let leftLength = enemy.punchLength-nodeA.size.height
                    /* Go around punch */
                    self.goAroundPunch(enemy: enemy, position: originPosition, length: leftLength, lastArm: newArm)
                    
                    
                /* In case fist hit wall */
                } else if contactA.categoryBitMask == 8 {
                    /* Get enemy fist */
                    let nodeA = contactA.node as! EnemyFist
                    
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
    
    /* Add enemy in fixed interval */
    func addEnemy() {
        /* Time to add enemy */
        if countTurnForAddEnemy > addInterval {
            
            /* Stop all enemy's movement */
            for enemy in self.gridNode.enemyArray {
                enemy.removeAllActions()
                enemy.setStandingtexture()
            }
            
            /* Make sure to stop all enemy before move to addEnemy state */
            let wait = SKAction.wait(forDuration: 1.0)
            let moveState = SKAction.run({ self.gameState = .AddEnemy })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
            
        }
    }
    
    /* Make grid flash in fixed interval */
    func flashGrid() {
        /* Time to flash grid */
        if countTurnForFlashGrid > flashInterval {
            
            /* Stop all enemy's movement */
            for enemy in self.gridNode.enemyArray {
                enemy.removeAllActions()
                enemy.setStandingtexture()
            }
            
            /* Make sure to stop all enemy before move to GridFlashing state */
            let wait = SKAction.wait(forDuration: 1.0)
            let moveState = SKAction.run({ self.gameState = .GridFlashing })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
            
        }
    }
    
    /* Make enemy move around */
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
            
            /* Count number of times of move to add enemy */
            countTurnForAddEnemy += 1
            countTurnForFlashGrid += 1
        }
        
        moveTimer += fixedDelta
    }
    
    /* Set invisible wall */
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
        wall.physicsBody?.categoryBitMask = 1024
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

            /* Make sure player can kill during attack time */
            let attackFlagOn = SKAction.run({
                enemy.punchState = .streachOut
                enemy.setHitPoint(length: enemy.punchLength)
            })
            /* Colorize fist to show attack time */
            let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.01)
            let attackTime = SKAction.wait(forDuration: self.attackTime)
            /* Remove color of fist */
            let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: 0.01)
            let attackFlagOff = SKAction.run({
                enemy.punchState = .punching
                enemy.circle.removeFromParent()
            })
            
            /* Draw punch */
            let drawPunch = SKAction.run({ enemy.drawPunch(arms: armAndFist.arm, fists: armAndFist.fist, length: enemy.punchLength) })
            
            /* Make sure delete arms & fists after finishing punch drawing */
            let drawWait = SKAction.wait(forDuration: TimeInterval(enemy.punchLength*enemy.punchSpeed-0.1)) /* 0.1 is buffer */
            
            /* Get rid of all arms and fists */
            let punchDone = SKAction.run({
                enemy.removeAllChildren()
            })
            
            /* Set variable expression */
            let setVariableExpression = SKAction.run({
                enemy.makeTriangle()
                enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, attackFlagOn, fadeInColorlize, attackTime, fadeOutColorlize, attackFlagOff, drawPunch, drawWait, punchDone, setVariableExpression])
            self.run(seq)
        }
    }
    
    /* Generate punch from opposite side when reaching the edge of grid */
    func goAroundPunch(enemy: Enemy, position: CGPoint, length: CGFloat, lastArm: EnemyArm) {
        
        /*==*/
        /*== Set arm and fist the other side and punch and draw ==*/
        /*==*/
        
        /* Set arm */
        let arm = EnemyArm(direction: enemy.direction)
        
        /* Set fist */
        let fist = EnemyFist(direction: enemy.direction)
        
        /* Set position according to enemy's direction */
        switch enemy.direction {
        case .front:
            /* Calculate position y */
            let posY = gridNode.size.height-enemy.position.y-CGFloat(gridNode.cellHeight)-5

            /* Arm */
            let armPos = CGPoint(x: position.x, y: posY)
            arm.position = armPos
            
            /* Fist */
            let fistPos = CGPoint(x: position.x, y: posY-15)
            fist.position = fistPos
            
        case .back:
            /* Calculate position y */
            let posY = -enemy.position.y+CGFloat(gridNode.cellHeight)+13
            
            /* Arm */
            let armPos = CGPoint(x: position.x, y: posY)
            arm.zPosition = -1
            arm.position = armPos
            
            /* Fist */
            let fistPos = CGPoint(x: position.x, y: posY+5)
            fist.position = fistPos
            
        case .left:
            /* Calculate position x */
            let posX = gridNode.size.width-enemy.position.x-CGFloat(gridNode.cellWidth)-5
            
            /* Arm */
            let armPos = CGPoint(x: posX, y: position.y)
            arm.position = armPos
            
            /* Fist */
            let fistPos = CGPoint(x: posX-15, y: position.y)
            fist.position = fistPos
            
        case .right:
            /* Calculate position x */
            let posX = -enemy.position.x+CGFloat(gridNode.cellWidth)+5
            
            /* Arm */
            let armPos = CGPoint(x: posX, y: position.y)
            arm.position = armPos
            
            /* Fist */
            let fistPos = CGPoint(x: posX+15, y: position.y)
            fist.position = fistPos
            
        }
        
        /* Add arm as enemy child */
        enemy.addChild(arm)
        
        /* Add arm as fist child */
        enemy.addChild(fist)
        
        /* Move Fist */
        fist.moveFistForward(length: length, speed: enemy.punchSpeed)
        
        /* Extend arm */
        arm.extendArm(length: length, speed: enemy.punchSpeed)
        
        /* Wait untill enemy punch streach out */
        let extendWait = SKAction.wait(forDuration: TimeInterval(length*enemy.punchSpeed))
        
        /* Make sure player can kill by stepping on enemy's fist during attack time */
        let attackFlagOn = SKAction.run({
            enemy.punchState = .streachOut
            fist.setHitPoint()
        })
        let attackTime = SKAction.wait(forDuration: self.attackTime)
        let attackFlagOff = SKAction.run({
            enemy.punchState = .punching
            fist.circle.removeFromParent()
        })
        
        /* Draw punch */
        let drawPunch = SKAction.run({
            arm.ShrinkArm(length: length, speed: enemy.punchSpeed)
            /* Make sure delete fist by making it hit wall (for adding 20) */
            fist.moveFistBackward(length: arm.size.height+20, speed: enemy.punchSpeed)
        })
        
        /* Make sure delete arms after amr shrink back completely */
        let drawWait1 = SKAction.wait(forDuration: TimeInterval(length*enemy.punchSpeed))
        
        /* Get rid of arms and fists */
        let deleteArmAndFist = SKAction.run({
            arm.removeFromParent()
        })
        
        /*==*/
        /*== Set arm and fist the forward side and draw punch ==*/
        /*==*/
        
        /* Create new fist */
        /* Set fist */
        let newFist = EnemyFist(direction: enemy.direction)
        
        /* Set position of new fist according to enemy's direction */
        switch enemy.direction {
        case .front:
            /* Calculate position y */
            let posY = -enemy.position.y+CGFloat(gridNode.cellHeight)+13
            
            /* Fist */
            let fistPos = CGPoint(x: position.x, y: posY+5)
            newFist.position = fistPos
            
        case .back:
            /* Calculate position y */
            let posY = gridNode.size.height-enemy.position.y-CGFloat(gridNode.cellHeight)-5
            
            /* Fist */
            let fistPos = CGPoint(x: position.x, y: posY-15)
            newFist.position = fistPos
            
        case .left:
            /* Calculate position x */
            let posX = -enemy.position.x+CGFloat(gridNode.cellWidth)+5
            
            /* Fist */
            let fistPos = CGPoint(x: posX+15, y: position.y)
            newFist.position = fistPos
            
        case .right:
            /* Calculate position x */
            let posX = gridNode.size.width-enemy.position.x-CGFloat(gridNode.cellWidth)-5
            
            /* Fist */
            let fistPos = CGPoint(x: posX-15, y: position.y)
            newFist.position = fistPos
            
        }
        
        /* Add arm as enemy child */
        let showUpNewFist = SKAction.run({
            enemy.addChild(newFist)
        })
        
        /* Draw left punch */
        let drawLeftPunch = SKAction.run({
            /* Calculate left length */
            let leftLength = lastArm.size.height
            lastArm.ShrinkArm(length: leftLength, speed: enemy.punchSpeed)
            newFist.moveFistBackward(length: leftLength, speed: enemy.punchSpeed)
        })
        
        /* Make sure delete arms & fists after finishing punch drawing */
        let drawWait2 = SKAction.wait(forDuration: TimeInterval(lastArm.size.height*enemy.punchSpeed-0.1))
        
        /* Get rid of all arms and fists */
        let punchDone = SKAction.run({
            enemy.removeAllChildren()
        })
        
        /* Set variable expression */
        let setVariableExpression = SKAction.run({
            enemy.makeTriangle()
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
        })
        
        /* excute drawPunch */
        let seq = SKAction.sequence([extendWait, attackFlagOn, attackTime, attackFlagOff, drawPunch, drawWait1, deleteArmAndFist, showUpNewFist, drawLeftPunch, drawWait2, punchDone, setVariableExpression])
        self.run(seq)
    }
}
