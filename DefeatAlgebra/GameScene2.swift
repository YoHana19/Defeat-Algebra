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

enum GameSceneState {
    case AddEnemy, PlayerTurn, EnemyTurn, GridFlashing, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case SelectAction, SelectDirection, TurnEnd
}

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var castleNode: SKSpriteNode!
    
    /* Game labels */
//    var valueOfX: SKLabelNode!
    
    /* Game buttons */
    var buttonAttack: MSButtonNode!
    var buttonMove: MSButtonNode!
    var buttonBack: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Enemy property */
    
    /* Add enemy */
    var numOfAddEnemy = 5
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 20 /* Add enemy after enemy move 10 times */
    
    /* Flash grid */
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .SelectAction
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var playerTurnDoneFlag = false
    var enemyTurnDoneFlag = false
    var selectDirectionDone = false
    var punchDoneFlag = false 
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    
    /* Game Score */
//    var scoreLabel: SKLabelNode!
//    var score: Int = 0 {
//        didSet {
//            scoreLabel.text = String(score)
//        }
//    }
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        
        /* Connect game buttons */
        buttonAttack = childNode(withName: "buttonAttack") as! MSButtonNode
        buttonMove = childNode(withName: "buttonMove") as! MSButtonNode
        buttonBack = childNode(withName: "buttonBack") as! MSButtonNode
        buttonAttack.state = .msButtonNodeStateHidden
        buttonMove.state = .msButtonNodeStateHidden
        buttonBack.state = .msButtonNodeStateHidden
        
        buttonAttack.selectedHandler = {
            self.hero.heroState = .Attack
            self.hero.removeAllActions()
            self.playerTurnState = .SelectDirection
        }
        
        buttonMove.selectedHandler = {
            self.hero.heroState = .Move
            self.playerTurnState = .SelectDirection
        }
        
        buttonBack.selectedHandler = {
            self.playerTurnState = .SelectAction
        }
        
        /* Game Over label */
        
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height)
        
        /* Display value of x */
//        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Score label */
//        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode 
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) 
        
        /* Set hero */
        hero = Hero()
        hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2))
        addChild(hero)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            /* Make sure to call addEnemy once */
            if addEnemyDoneFlag == false {
                addEnemyDoneFlag = true
                
                /* Add enemy */
                let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(3) })
                let wait = SKAction.wait(forDuration: 2.0)
                let moveState = SKAction.run({ self.gameState = .PlayerTurn })
                let seq = SKAction.sequence([addEnemy, wait, moveState])
                self.run(seq)
            }
            break;
        case .PlayerTurn:
            switch playerTurnState {
            case .SelectAction:
                buttonAttack.state = .msButtonNodeStateActive
                buttonMove.state = .msButtonNodeStateActive
                buttonBack.state = .msButtonNodeStateHidden
                break;
            case .SelectDirection:
                buttonAttack.state = .msButtonNodeStateHidden
                buttonMove.state = .msButtonNodeStateHidden
                
                if selectDirectionDone {
                    buttonBack.state = .msButtonNodeStateHidden
                } else {
                    buttonBack.state = .msButtonNodeStateActive
                }
                
                /* In case move */
                if hero.heroState == .Move {
                    
                /* In case attack */
                } else if hero.heroState == .Attack {
                    
                }
                
                break;
            case .TurnEnd:
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                selectDirectionDone = false
                
                hero.resetHero()
                
                gridNode.enemyArray[0].myTurnFlag = true
                gameState = .EnemyTurn
                break;
            }
            break;
        case .EnemyTurn:
            /* Reset Flags */
            addEnemyDoneFlag = false
            playerTurnDoneFlag = false
                
            if enemyTurnDoneFlag == false {

                for enemy in self.gridNode.enemyArray {
                    /* Enemy move */
                    if enemy.punchIntervalForCount >= 0 {
                        enemy.enemyMove()
                    /* Enemy punch */
                    } else {
                        enemy.punchAndMove()
                    }
                }
            }
            
            if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
                enemyTurnDoneFlag = true
                /* Reset all stuffs */
                gridNode.turnIndex = 0
                gridNode.numOfTurnEndEnemy = 0
                for enemy in gridNode.enemyArray {
                    enemy.turnDoneFlag = false
                    enemy.myTurnFlag = false
                }
                gameState = .PlayerTurn
                playerTurnState = .SelectAction
            }
            break;
        case .GridFlashing:
            break;
        case .GameOver:
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
        
        /* Swipe is available only at the time of selectDirection */
        guard playerTurnState == .SelectDirection else { return }
        
        /* Make sure to be able to swipe once */
        guard selectDirectionDone == false else { return }
        
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        /* Move hero */
        heroActionBySwipe(diffPos)
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
            
            if contactA.categoryBitMask == 1 {
                print("\(contactB.categoryBitMask)")
                contactA.node?.removeFromParent()
            } else if contactB.categoryBitMask == 1 {
                print("\(contactA.categoryBitMask)")
                contactB.node?.removeFromParent()
            }
            self.gameState = .GameOver
        }
    
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            if contactA.categoryBitMask == 4 {
                /* Arm hits wall */
                if contactB.categoryBitMask == 8 {
                    print("arm hit with wall")
                    /* Get enemy arm */
                    let nodeB = contactB.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeB.removeAllActions()
                    
                /* Fist hits wall */
                } else if contactB.categoryBitMask == 16 {
                    /* Get enemy fist */
                    let nodeB = contactB.node as! EnemyFist
                    
                    /* Stop fist */
                    nodeB.removeAllActions()
                    
                }
            }
    
            if contactB.categoryBitMask == 4 {
                /* In case arm hit wall */
                if contactA.categoryBitMask == 8 {
                print("arm hit with wall")
                    /* Get enemy arm */
                    let nodeA = contactA.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeA.removeAllActions()
                    
                /* In case fist hit wall */
                } else if contactA.categoryBitMask == 16 {
                    /* Get enemy fist */
                    let nodeA = contactA.node as! EnemyFist
                    
                    /* Stop of fist */
                    nodeA.removeAllActions()
                    
                }
            }
        }
    }

    
    func heroActionBySwipe(_ diffPos: CGPoint) {
        
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
            hero.direction = .front
            if hero.heroState == .Move {
                hero.setTexture()
                hero.setMovingAnimation()
                
                /* Move hero forward */
                let move = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
                hero.run(move)
            } else if hero.heroState == .Attack {
                self.hero.setSwordAnimation()
            }
            
            selectDirectionDone = true
            let wait = SKAction.wait(forDuration: 2.0)
            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
        case -45 ..< 45:
            if diffPos.x >= 0 {
                hero.direction = .right
                if hero.heroState == .Move {
                    hero.setTexture()
                    hero.setMovingAnimation()
                
                    /* Move hero right */
                    let move = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                    hero.run(move)
                } else if hero.heroState == .Attack {
                    self.hero.setSwordAnimation()
                }
                
            } else {
                hero.direction = .left
                if hero.heroState == .Move {
                    hero.setTexture()
                    hero.setMovingAnimation()
                
                    /* Move hero left */
                    let move = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                    hero.run(move)
                } else if hero.heroState == .Attack {
                    self.hero.setSwordAnimation()
                }
            }
            selectDirectionDone = true
            let wait = SKAction.wait(forDuration: 2.0)
            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
        case 45 ... 90:
            hero.direction = .back
            if hero.heroState == .Move {
                hero.setTexture()
                hero.setMovingAnimation()
            
                /* Move hero backward */
                let move = SKAction.moveBy(x: 0, y: CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
                hero.run(move)
            } else if hero.heroState == .Attack {
                self.hero.setSwordAnimation()
            }
            selectDirectionDone = true
            let wait = SKAction.wait(forDuration: 2.0)
            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
        default:
            /* Stop movement */
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
    
}
