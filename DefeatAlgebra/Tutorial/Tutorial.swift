//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

/* Index of categryBitMask of game objects */
/*
 1: Hero - 4294967258(MAX-4-32-1)
 2: Enemy - 5(1,4)
 4: castleNode - 24(8,16)
 8: EnemyArm - 4
 16: EnemyFist - 5(1,4)
 32: setItems - wall-26(2,8,16)
 64: getItems(Boots,timeBomb,Heart,callHero,catapult,multiAttack) - 1
 128:
 1024:
 */

import SpriteKit
import GameplayKit

enum TutorialState {
    case T1, T2, T3, T4
}

class Tutorial: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: GridForTutorial!
    var activeHero = HeroForTutorial()
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    
    /* Game buttons */
    var buttonRetry: MSButtonNode!
    var buttonPlay: MSButtonNode!
    var buttonSkip: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let turnEndWait: TimeInterval = 1.0
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var tutorialState: TutorialState = .T1
    var itemType: ItemType = .None
    var stageLevel: Int = 0
    var moveLevelArray: [Int] = [1]
    var totalNumOfEnemy: Int = 3
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var playerTurnDoneFlag = false
    var enemyTurnDoneFlag = false
    var heroMovingFlag = false
    var punchDoneFlag = false
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    var initialAddEnemyFlag = true
    var showPlayerDiscriptionDone = false
    var showEnemyDiscriptionDone = false
    var enemyPhaseLabelDoneFlag = false
    var bombExplodeDoneFlag = false
    var timeBombDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    var heroArray = [HeroForTutorial]()
    var numOfTurnDoneHero = 0
    
    /* Keep track turn */
    var countTurn = 0
    
    var tutorialLabelArray = [SKNode]()
    
    
    /* Flash grid */
    var numOfFlashArray = [3, 1, 2, 3, 1, 3]
    //    var numOfFlashArray = [1, 1, 1, 1, 1, 1]
    var xValue: Int = 0
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    
    
    /* Castle life */
    var lifeLabel: SKLabelNode!
    var maxLife = 6
    var life: Int = 6 {
        willSet {
            lifeLabel.text = String(life)
        }
        didSet {
            lifeLabel.text = String(life)
        }
    }
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! GridForTutorial
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
        /* Labels */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonPlay = childNode(withName: "buttonPlay") as! MSButtonNode
        buttonPlay.state = .msButtonNodeStateHidden
        buttonSkip = childNode(withName: "buttonSkip") as! MSButtonNode
        
        /* Retry button */
        buttonRetry.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Play button */
        buttonPlay.selectedHandler = {
            
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
        
        /* Skip button */
        buttonSkip.selectedHandler = {
            
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
        
        
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Life label */
        lifeLabel = childNode(withName: "lifeLabel") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set hero */
        activeHero.position = CGPoint(x: self.size.width/2, y: self.gridNode.position.y+CGFloat(self.gridNode.cellHeight)*3.5)
        activeHero.positionX = 4
        activeHero.positionY = 3
        addChild(activeHero)
        self.heroArray.append(activeHero)
        
        /* Set boots */
        let boots = Boots()
        self.gridNode.addObjectAtGrid(object: boots, x: 3, y: 4)
        let boots2 = Boots()
        self.gridNode.addObjectAtGrid(object: boots2, x: 5, y: 4)
        
        /* Set timeBomb */
        let timeBomb = TimeBomb()
        self.gridNode.addObjectAtGrid(object: timeBomb, x: 0, y: 5)
        let timeBomb2 = TimeBomb()
        self.gridNode.addObjectAtGrid(object: timeBomb2, x: 8, y: 5)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        print(buttonSkip)
        switch gameState {
        case .AddEnemy:
            /* Add enemy */
            if addEnemyDoneFlag == false {
                addEnemyDoneFlag = true
                let addEnemy = SKAction.run({ self.gridNode.addInitialEnemyAtGrid(enemyPosArray: [[4, 8], [2, 10], [6, 10]], variableExpressionSource: [[0, 1, 0, 0]]) })
                let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                let moveState = SKAction.run({
                    /* Update enemy position */
                    self.gridNode.updateEnemyPositon()
                    
                    /* Move to next state */
                    self.gameState = .GridFlashing
                    
                })
                let seq = SKAction.sequence([addEnemy, wait, moveState])
                self.run(seq)
            }
            break;
        case .PlayerTurn:
            //            print("player turn")
            /* Check if all enemies are defeated or not */
            if totalNumOfEnemy <= 0 {
                gameState = .StageClear
            }
            
            switch playerTurnState {
            case .DisplayPhase:
                //                print("DisplayPhase")
                playerPhaseLabel.isHidden = false
                let wait = SKAction.wait(forDuration: 1.0)
                let moveState = SKAction.run({ self.playerTurnState = .ItemOn })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                break;
            case .ItemOn:
                //                print("itemOn")
                
                playerPhaseLabel.isHidden = true
                
                if countTurn == 6 {
                    /* Show tutorial */
                    if showPlayerDiscriptionDone == false {
                        showPlayerDiscriptionDone = true
                        tutorialManagementForPlayer()
                    }
                }
                
                /* timeBomb */
                if self.gridNode.timeBombSetArray.count > 0 {
                    if bombExplodeDoneFlag == false {
                        bombExplodeDoneFlag = true
                        for (i, timeBombPos) in self.gridNode.timeBombSetPosArray.enumerated() {
                            /* Look for the enemy to destroy  if any */
                            for enemy in self.gridNode.enemyArray {
                                /* Hit enemy! */
                                if enemy.positionX == timeBombPos[0] && enemy.positionY == timeBombPos[1] {
                                    /* Effect */
                                    self.gridNode.enemyDestroyEffect(enemy: enemy)
                                    
                                    /* Enemy */
                                    let waitEffectRemove = SKAction.wait(forDuration: 1.0)
                                    let removeEnemy = SKAction.run({ enemy.removeFromParent() })
                                    let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                                    self.run(seqEnemy)
                                    enemy.aliveFlag = false
                                    /* Count defeated enemy */
                                    totalNumOfEnemy -= 1
                                }
                            }
                            if i == self.gridNode.timeBombSetArray.count-1 {
                                /* Reset timeBomb array */
                                self.gridNode.timeBombSetPosArray.removeAll()
                                for timeBomb in self.gridNode.timeBombSetArray {
                                    /* time bomb effect */
                                    timeBombEffect(timeBomb: timeBomb)
                                    timeBomb.removeFromParent()
                                }
                            }
                        }
                    }
                } else {
                    timeBombDoneFlag = true
                }
                
                
                if timeBombDoneFlag {
                    playerTurnState = .MoveState
                }
                
                
            case .MoveState:
                //                print("MoveState")
                
                timeBombDoneFlag = false
                bombExplodeDoneFlag = false
                
                /* Show tutorial */
                if showPlayerDiscriptionDone == false {
                    showPlayerDiscriptionDone = true
                    tutorialManagementForPlayer()
                }
                
                if activeHero.moveDoneFlag == false {
                    /* Display move area */
                    self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                }
                
                /* Display action buttons */
                buttonAttack.isHidden = false
                buttonItem.isHidden = false
                
                /* Wait for player touch to move */
                
                break;
            case .AttackState:
                /* Show tutorial */
                if showPlayerDiscriptionDone == false {
                    showPlayerDiscriptionDone = true
                    tutorialManagementForPlayer()
                }
                /* Wait for player touch to attack */
                break;
            case .UsingItem:
                /* Show tutorial */
                if showPlayerDiscriptionDone == false {
                    showPlayerDiscriptionDone = true
                    tutorialManagementForPlayer()
                }
                switch itemType {
                case .None:
                    break;
                case .timeBomb:
                    self.gridNode.showtimeBombSettingArea()
                    break;
                default:
                    break;
                }
                /* Wait for player touch to point position to use item at */
                break;
            case .TurnEnd:
                /* Remove dead hero from heroArray */
                self.heroArray = self.heroArray.filter({ $0.aliveFlag == true })
                
                //                print(heroArray)
                
                /* Remove tutorial discription */
                removeTutorial()
                showPlayerDiscriptionDone = false
                tutorialState = .T1
                
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                for hero in heroArray {
                    hero.attackDoneFlag = false
                    hero.moveDoneFlag = false
                }
                
                numOfTurnDoneHero = 0
                
                /* Remove action buttons */
                buttonAttack.isHidden = true
                buttonItem.isHidden = true
                
                /* Remove move area */
                gridNode.resetSquareArray(color: "blue")
                gridNode.resetSquareArray(color: "red")
                gridNode.resetSquareArray(color: "green")
                
                /* Remove dead enemy from enemyArray */
                self.gridNode.enemyArray = self.gridNode.enemyArray.filter({ $0.aliveFlag == true })
                
                if gridNode.enemyArray.count > 0 {
                    gridNode.enemyArray[0].myTurnFlag = true
                }
                
                /* Display enemy phase label */
                if enemyPhaseLabelDoneFlag == false {
                    enemyPhaseLabelDoneFlag = true
                    enemyPhaseLabel.isHidden = false
                    let wait = SKAction.wait(forDuration: 1.0)
                    let moveState = SKAction.run({ self.gameState = .EnemyTurn })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                }
                break;
            }
            break;
        case .EnemyTurn:
            //                        print("EnemyTurn")
            /* Reset Flags */
            addEnemyDoneFlag = false
            playerTurnDoneFlag = false
            flashGridDoneFlag = false
            enemyPhaseLabelDoneFlag = false
            enemyPhaseLabel.isHidden = true
            
            
            if showEnemyDiscriptionDone == false {
                showEnemyDiscriptionDone = true
                tutorialManagementForEnemy()
                enemyTurnDoneFlag = true
                print("tutorial show")
                let wait = SKAction.wait(forDuration: 9.0)
                let tutorialDone = SKAction.run({
                    self.removeTutorial()
                    self.tutorialState = .T1
                    self.enemyTurnDoneFlag = false
                })
                let seq = SKAction.sequence([wait, tutorialDone])
                self.run(seq)
            }
            
            
            if enemyTurnDoneFlag == false {
                
                /* Reset enemy position */
                gridNode.resetEnemyPositon()
                
                for enemy in self.gridNode.enemyArray {
                    /* Enemy reach to castle */
                    if enemy.reachCastleFlag {
                        enemy.punchToCastle()
                        /* Enemy move */
                    } else if enemy.punchIntervalForCount > 0 {
                        enemy.enemyMove()
                        /* Enemy punch */
                    } else {
                        enemy.punchAndMove()
                    }
                }
                
                /* If life is 0, GameOver */
                if self.life < 1 {
                    gameState = .GameOver
                }
            }
            
            /* All enemies finish their actions */
            if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
                /* Remove dead hero from heroArray */
                self.heroArray = self.heroArray.filter({ $0.aliveFlag == true })
                
                enemyTurnDoneFlag = true
                /* Reset all stuffs */
                gridNode.turnIndex = 0
                gridNode.numOfTurnEndEnemy = 0
                for enemy in gridNode.enemyArray {
                    enemy.turnDoneFlag = false
                    enemy.myTurnFlag = false
                }
                
                /* Update enemy position */
                gridNode.updateEnemyPositon()
                
                /* Check if enemy reach to castle */
                for enemy in self.gridNode.enemyArray {
                    if enemy.positionY == 0 {
                        enemy.reachCastleFlag = true
                    }
                }
                
                gameState = .GridFlashing
                playerTurnState = .DisplayPhase
            }
        case .GridFlashing:
            //                        print("GridFlashing")
            
            /* Make sure to call once */
            if flashGridDoneFlag == false {
                flashGridDoneFlag = true
                
                /* Make grid flash */
                if countTurn < numOfFlashArray.count {
                    xValue = self.gridNode.flashGrid(labelNode: valueOfX, numOfFlash: numOfFlashArray[countTurn])
                } else {
                    let rand = Int(arc4random_uniform(2)+1)
                    xValue = self.gridNode.flashGrid(labelNode: valueOfX, numOfFlash: rand)
                }
                
                
                /* Calculate each enemy's variable expression */
                for enemy in self.gridNode.enemyArray {
                    enemy.calculatePunchLength(value: xValue)
                }
                
                let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
                let moveState = SKAction.run({
                    self.removeTutorial()
                    self.gameState = .PlayerTurn
                    self.countTurn += 1
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
            }
            break;
        case .StageClear:
            gridNode.resetSquareArray(color: "blue")
            setDiscriptionStageClear()
            break;
            
        case .GameOver:
            gameOverLabel.isHidden = false
            buttonRetry.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print("scene touchBegan")
        
        guard gameState == .PlayerTurn else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        
        /* Manage flow for tutorial */
        guard countTurn != 1 else { return }
        if countTurn == 2 {
            guard tutorialState == .T1 else { return }
            if tutorialState == .T1 {
                guard nodeAtPoint.name == "buttonAttack" else { return }
                showPlayerDiscriptionDone = false
                tutorialState = .T2
            }
        }
        guard countTurn != 3 else { return }
        guard countTurn != 4 else { return }
        if countTurn == 5 {
            guard tutorialState != .T3 else { return }
            guard tutorialState != .T4 else { return }
            if tutorialState == .T2 {
                guard nodeAtPoint.name == "timeBomb" else { return }
                showPlayerDiscriptionDone = false
                tutorialState = .T3
            } else if tutorialState == .T1 {
                guard nodeAtPoint.name == "buttonItem" else { return }
                showPlayerDiscriptionDone = false
                tutorialState = .T2
            }
        }
        guard countTurn != 6 else { return }
        
        if playerTurnState == .MoveState {
            /* Touch attack button */
            if nodeAtPoint.name == "buttonAttack" {
                guard self.heroMovingFlag == false else { return }
                
                if self.activeHero.attackDoneFlag {
                    return
                } else {
                    /* Reset item type */
                    self.itemType = .None
                    
                    /* Reset active area */
                    self.gridNode.resetSquareArray(color: "blue")
                    self.gridNode.resetSquareArray(color: "green")
                    
                    /* Set item area cover */
                    self.itemAreaCover.isHidden = false
                    
                    self.gridNode.showAttackArea(posX: self.activeHero.positionX, posY: self.activeHero.positionY, attackType: self.activeHero.attackType)
                    self.playerTurnState = .AttackState
                }
                /* Touch item button */
            } else if nodeAtPoint.name == "buttonItem" {
                guard self.heroMovingFlag == false else { return }
                
                /* Reset active area */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "blue")
                
                /* Remove item area cover */
                self.itemAreaCover.isHidden = true
                
                /* Change state to UsingItem */
                self.playerTurnState = .UsingItem
            }
            
            /* Select attack position */
        } else if playerTurnState == .AttackState {
            /* Touch item button */
            if nodeAtPoint.name == "buttonItem" {
                guard self.heroMovingFlag == false else { return }
                
                /* Reset active area */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "blue")
                
                /* Remove item area cover */
                self.itemAreaCover.isHidden = true
                
                /* Change state to UsingItem */
                self.playerTurnState = .UsingItem
                
                /* If touch anywhere but activeArea, back to MoveState  */
            } else if nodeAtPoint.name != "activeArea" {
                self.gridNode.resetSquareArray(color: "red")
                self.playerTurnState = .MoveState
            }
            
            /* Use item from itemArea */
        } else if playerTurnState == .UsingItem {
            /* Touch attack button */
            if nodeAtPoint.name == "buttonAttack" {
                guard self.heroMovingFlag == false else { return }
                
                if self.activeHero.attackDoneFlag {
                    return
                } else {
                    /* Reset item type */
                    self.itemType = .None
                    
                    /* Reset active area */
                    self.gridNode.resetSquareArray(color: "blue")
                    self.gridNode.resetSquareArray(color: "green")
                    
                    /* Set item area cover */
                    self.itemAreaCover.isHidden = false
                    
                    self.gridNode.showAttackArea(posX: self.activeHero.positionX, posY: self.activeHero.positionY, attackType: self.activeHero.attackType)
                    self.playerTurnState = .AttackState
                }
                
                /* Use timeBomb */
            } else if nodeAtPoint.name == "timeBomb" {
                /* Remove activeArea for catapult */
                self.gridNode.resetSquareArray(color: "red")
                
                /* Set timeBomb using state */
                itemType = .timeBomb
                
                /* Get index of game using */
                usingItemIndex = Int((Double(nodeAtPoint.position.x)-56.5)/91)
                //                print("Now item index is \(usingItemIndex)")
                
                
                /* If player touch other place than item icons, back to MoveState */
            } else {
                
                /* Show attack and item buttons */
                buttonAttack.isHidden = false
                buttonItem.isHidden = false
                
                playerTurnState = .MoveState
                /* Set item area cover */
                itemAreaCover.isHidden = false
                
                /* Reset item type */
                self.itemType = .None
                
                /* Remove active area */
                self.gridNode.resetSquareArray(color: "green")
                self.gridNode.resetSquareArray(color: "red")
            }
        }
        
        //        /* just for debug */
        //        if nodeAtPoint.name == "hero" {
        //            let hero = nodeAtPoint as! Hero
        //            print("(\(hero.positionX), \(hero.positionY))")
        //        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
            /* Get item */
            if contactA.categoryBitMask == 64 || contactB.categoryBitMask == 64 {
                /* A is hero */
                if contactA.categoryBitMask == 1 {
                    let item = contactB.node as! SKSpriteNode
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
                        /* Get heart */
                    } else if item.name == "heart" {
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        /* Get spear */
                    } else if item.name == "spear" {
                        item.removeFromParent()
                        if self.activeHero.attackType < 1 {
                            self.activeHero.attackType += 1
                        }
                        /* Other items */
                    } else {
                        item.removeFromParent()
                        displayitem(name: item.name!)
                    }
                }
                /* B is hero */
                if contactB.categoryBitMask == 1 {
                    let item = contactA.node as! SKSpriteNode
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
                        /* Get heart */
                    } else if item.name == "heart" {
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        /* Get spear */
                    } else if item.name == "spear" {
                        item.removeFromParent()
                        if self.activeHero.attackType < 1 {
                            self.activeHero.attackType += 1
                        }
                        /* Other items */
                    } else {
                        item.removeFromParent()
                        displayitem(name: item.name!)
                    }
                }
                
                /* Be hitten by enemy */
            } else {
                if contactA.categoryBitMask == 1 {
                    let hero = contactA.node as! HeroForTutorial
                    hero.removeFromParent()
                    /* Still hero turn undone left */
                    if numOfTurnDoneHero < heroArray.count-1 {
                        /* On dead flag */
                        hero.aliveFlag = false
                        
                        /* Move to next hero turn */
                        activeHero = heroArray[numOfTurnDoneHero+1]
                        /* The last turn hero is killed */
                    } else {
                        /* Remove dead hero */
                        heroArray = heroArray.filter({ $0.aliveFlag == true })
                        /* The last hero is killed? */
                        if heroArray.count == 1 {
                            self.gameState = .GameOver
                        } else {
                            /* On dead flag */
                            hero.aliveFlag = false
                            playerTurnState = .TurnEnd
                        }
                    }
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! Hero
                    hero.removeFromParent()
                    /* Still hero turn undone left */
                    if numOfTurnDoneHero < heroArray.count-1 {
                        /* On dead flag */
                        hero.aliveFlag = false
                        
                        /* Move to next hero turn */
                        activeHero = heroArray[numOfTurnDoneHero+1]
                        /* The last turn hero is killed */
                    } else {
                        /* Remove dead hero */
                        heroArray = heroArray.filter({ $0.aliveFlag == true })
                        /* The last hero is killed? */
                        if heroArray.count == 1 {
                            self.gameState = .GameOver
                        } else {
                            /* On dead flag */
                            hero.aliveFlag = false
                            playerTurnState = .TurnEnd
                        }
                    }
                }
            }
        }
        
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            setDiscriptionForLife()
            
            if contactA.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeB = contactB.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeB.removeAllActions()
            }
            
            if contactB.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeB = contactB.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeB.removeAllActions()
            }
        }
    }
    
    /* Create item icons to display when you get items */
    func displayitem(name: String) {
        let index = self.itemArray.count
        let item = SKSpriteNode(imageNamed: name)
        item.size = CGSize(width: 69, height: 69)
        item.position = CGPoint(x: Double(index)*91+56.5, y: 47.5)
        item.zPosition = 2
        item.name = name
        self.itemArray.append(item)
        addChild(item)
    }
    
    /* Reset position of item when use any */
    func resetDisplayItem(index: Int) {
        itemArray[index].removeFromParent()
        itemArray.remove(at: index)
        for (i, item) in itemArray.enumerated() {
            item.position = CGPoint(x: Double(i)*91+56.5, y: 47.5)
        }
    }
    
    /* Create object blanketting item area */
    func setItemAreaCover() {
        itemAreaCover = SKShapeNode(rectOf: itemAreaNode.size)
        itemAreaCover.fillColor = UIColor.black
        itemAreaCover.alpha = 0.6
        itemAreaCover.position = itemAreaNode.position
        itemAreaCover.zPosition = 100
        addChild(itemAreaCover)
    }
    
    /* Create label for tutorial */
    func createTutorialLabel(text: String, posY: Int) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set text */
        label.text = text
        
        /* Set name */
        label.name = "tutorialLabel"
        
        /* Set font size */
        label.fontSize = 35
        
        /* Set zPosition */
        label.zPosition = 50
        
        /* Set position */
        label.position = CGPoint(x: self.size.width/2, y: CGFloat(posY))
        
        tutorialLabelArray.append(label)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    func createTutorialLabel2(text: String, posX: CGFloat, posY: Int, color: UIColor, size: CGFloat) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set text */
        label.text = text
        
        /* Set name */
        label.name = "tutorialLabel"
        
        /* Set font size */
        label.fontSize = size
        
        /* Set font color */
        label.fontColor = color
        
        /* Set zPosition */
        label.zPosition = 50
        
        /* Set position */
        label.position = CGPoint(x: posX, y: CGFloat(posY))
        
        tutorialLabelArray.append(label)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    /* Set pointing icon */
    func setPointingIcon(position: CGPoint) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.position = position
        icon.zPosition = 100
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        tutorialLabelArray.append(icon)
        addChild(icon)
    }
    
    /* Set pointing icon another angle */
    func setPointingIcon2(position: CGPoint, size: CGSize) -> SKSpriteNode {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.position = position
        icon.zRotation = -.pi
        icon.zPosition = 100
        icon.size = size
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        tutorialLabelArray.append(icon)
        return icon
    }
    
    /* Set pointing icon for swiping */
    func setMovePointingIcon(position: CGPoint) {
        let single = SKAction.run({
            let icon = SKSpriteNode(imageNamed: "pointing")
            icon.position = position
            icon.zPosition = 5
            icon.name = "movingPoint"
            self.tutorialLabelArray.append(icon)
            self.addChild(icon)
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat(self.gridNode.cellHeight), duration: 1.0)
            let moveLeft = SKAction.moveBy(x: -CGFloat(self.gridNode.cellWidth), y: 0, duration: 1.0)
            let seq = SKAction.sequence([moveUp, moveLeft])
            icon.run(seq)
        })
        
        let wait2 = SKAction.wait(forDuration: 2.2)
        let remove = SKAction.run({
            if let node = self.childNode(withName: "movingPoint") {
                node.removeFromParent()
            }
        })
        
        let seq2 = SKAction.sequence([single, wait2, remove])
        let repeatAction = SKAction.repeatForever(seq2)
        self.run(repeatAction)
    }
    
    /* Set pointing icon for cancell swiping */
    func setMovePointingIcon2(position: CGPoint) {
        let single = SKAction.run({
            let icon = SKSpriteNode(imageNamed: "pointing")
            icon.position = position
            icon.zPosition = 5
            icon.name = "movingPoint"
            self.tutorialLabelArray.append(icon)
            self.addChild(icon)
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat(self.gridNode.cellHeight)*3, duration: 2.0)
            icon.run(moveUp)
        })
        
        let wait2 = SKAction.wait(forDuration: 2.2)
        let remove = SKAction.run({
            if let node = self.childNode(withName: "movingPoint") {
                node.removeFromParent()
            }
        })
        
        let seq2 = SKAction.sequence([single, wait2, remove])
        let repeatAction = SKAction.repeatForever(seq2)
        self.run(repeatAction)
    }
    
    /* Tutorial management */
    func tutorialManagementForPlayer() {
        let basePosX = gridNode.position.x
        let basePosY = gridNode.position.y
        
        switch countTurn {
        case 1:
            switch tutorialState {
            case .T1:
                createTutorialLabel(text: "You can move by touching blue areas!", posY: 810)
                createTutorialLabel(text: "Let's touch here!!", posY: 750)
                setPointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*5+20, y: basePosY+CGFloat(gridNode.cellHeight)*5+20))
            default:
                break;
            }
        case 2:
            switch tutorialState {
            case .T1:
                createTutorialLabel(text: "You can kill an enemy next to you!", posY: 430)
                createTutorialLabel(text: "Let's touch attack icon!!", posY: 370)
                setPointingIcon(position: CGPoint(x: self.buttonAttack.position.x+55, y: self.buttonAttack.position.y+65))
            case .T2:
                removeTutorial()
                createTutorialLabel(text: "You can attack by touching red areas!", posY: 890)
                createTutorialLabel(text: "Let's touch the red area!!", posY: 830)
                setPointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*5+20, y: basePosY+CGFloat(gridNode.cellHeight)*6+20))
            case .T3:
                createTutorialLabel(text: "Great!! Try to get items, next!", posY: 890)
                createTutorialLabel(text: "Let's touch here!!", posY: 830)
                setPointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*4+20, y: basePosY+CGFloat(gridNode.cellHeight)*5+20))
            default:
                break;
            }
        case 3:
            switch tutorialState {
            case .T1:
                let showDiscription = SKAction.run({
                    self.createTutorialLabel(text: "Since you got Boots", posY: 1150)
                    self.createTutorialLabel(text: "Now your move area expands!", posY: 1090)
                })
                let wait = SKAction.wait(forDuration: 3.0)
                let moveState = SKAction.run({
                    self.tutorialState = .T2
                    self.showPlayerDiscriptionDone = false
                })
                let seq = SKAction.sequence([showDiscription, wait, moveState])
                self.run(seq)
            case .T2:
                removeTutorial()
                self.createTutorialLabel(text: "You can also move by swiping", posY: 1150)
                self.createTutorialLabel(text: "Let's swipe like bellow!!", posY: 1090)
                setMovePointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*3.5+20, y: basePosY+CGFloat(gridNode.cellHeight)*4.5+20))
            default:
                break;
            }
        case 4:
            switch tutorialState {
            case .T1:
                self.createTutorialLabel(text: "Let's try to use an item", posY: 1100)
                self.createTutorialLabel(text: "Get a timeBomb!!", posY: 1040)
                setPointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*1+20, y: basePosY+CGFloat(gridNode.cellHeight)*6+20))
            default:
                break;
            }
        case 5:
            switch tutorialState {
            case .T1:
                self.createTutorialLabel(text: "Time to set a timeBomb!", posY: 430)
                self.createTutorialLabel(text: "Touch item icon!!", posY: 370)
                setPointingIcon(position: CGPoint(x: self.buttonItem.position.x+55, y: self.buttonItem.position.y+65))
            case .T2:
                removeTutorial()
                self.createTutorialLabel(text: "Touch timeBomb icon!!", posY: 430)
                setPointingIcon(position: CGPoint(x: self.itemArray[0].position.x+55, y: self.itemArray[0].position.y+65))
            case .T3:
                removeTutorial()
                self.createTutorialLabel2(text: "You can set a timeBomb", posX: self.size.width/2, posY: 1100, color: UIColor.yellow, size: 35)
                self.createTutorialLabel2(text: "by touching green areas", posX: self.size.width/2, posY: 1040, color: UIColor.yellow, size: 35)
                self.createTutorialLabel2(text: "Let's set a timeBomb here!!",posX: self.size.width/2+100, posY: 650, color: UIColor.yellow, size: 35)
                setPointingIcon(position: CGPoint(x: basePosX+CGFloat(gridNode.cellWidth)*3+20, y: basePosY+CGFloat(gridNode.cellHeight)*4+20))
            case .T4:
                removeTutorial()
                self.createTutorialLabel(text: "The timeBomb will explode next Player Phase!", posY: 1100)
                self.createTutorialLabel(text: "Move somewhere!", posY: 1040)
            }
        case 6:
            switch tutorialState {
            case .T1:
                let showDiscription = SKAction.run({
                    self.createTutorialLabel(text: "Awesome!!", posY: 1100)
                    self.createTutorialLabel(text: "You destroy enemy with a timeBomb!", posY: 1040)
                })
                let wait = SKAction.wait(forDuration: 3.0)
                let moveState = SKAction.run({
                    self.tutorialState = .T2
                    self.showPlayerDiscriptionDone = false
                })
                let seq = SKAction.sequence([showDiscription, wait, moveState])
                self.run(seq)
            case .T2:
                removeTutorial()
                self.createTutorialLabel(text: "If you want to cancel", posY: 1100)
                self.createTutorialLabel(text: "Just swipe out of the blue area!", posY: 1040)
                setMovePointingIcon2(position: CGPoint(x: self.activeHero.position.x+20, y: self.activeHero.position.y+20))
            case .T3:
                removeTutorial()
                self.createTutorialLabel(text: "If you want to stay", posY: 1100)
                self.createTutorialLabel(text: "Just touch where you are!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.activeHero.position.x+50, y: self.activeHero.position.y+50))
            default:
                break;
            }
        case 7:
            switch tutorialState {
            case .T1:
                self.createTutorialLabel(text: "Let's try to defeat the last enemy!!", posY: 1100)
            default:
                break;
            }
        default:
            break;
        }
    }
    
    /* Tutorial management */
    func tutorialManagementForEnemy() {
        
        switch countTurn {
        case 1:
            switch tutorialState {
            case .T1:
                let showDiscription = SKAction.run({
                    for enemy in self.gridNode.enemyArray {
                        let icon = self.setPointingIcon2(position: CGPoint(x: -15, y: -45), size: CGSize(width: 35, height: 35))
                        enemy.addChild(icon)
                    }
                    self.createTutorialLabel(text: "These numbers indicates how many", posY: 810)
                    self.createTutorialLabel(text: "turns left untill each enemy attacks", posY: 750)
                })
                let wait = SKAction.wait(forDuration: 4.0)
                let moveState = SKAction.run({
                    self.tutorialState = .T2
                    self.showEnemyDiscriptionDone = false
                })
                let seq = SKAction.sequence([showDiscription, wait, moveState])
                self.run(seq)
            case .T2:
                removeTutorial()
                createTutorialLabel(text: "The value of 'X' will be enemys' energy", posY: 810)
                createTutorialLabel(text: "When they attack!", posY: 750)
                let icon = self.setPointingIcon2(position: CGPoint(x: self.valueOfX.position.x-40, y: self.valueOfX.position.y-30), size: CGSize(width: 80, height: 80))
                self.addChild(icon)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+self.gridNode.enemyArray[0].position.x+50, y: self.gridNode.position.y+self.gridNode.enemyArray[0].position.y+50))
            default:
                break;
            }
        default:
            break;
        }
    }
    
    /* Dicription for life */
    func setDiscriptionForLife() {
        self.createTutorialLabel(text: "enemy's punch could damage", posY: 540)
        self.createTutorialLabel(text: "the life of the castle wall!", posY: 480)
        setPointingIcon(position: CGPoint(x: self.lifeLabel.position.x+55, y: self.lifeLabel.position.y+65))
        
    }
    
    /* Discription at stage clear */
    func setDiscriptionStageClear() {
        switch tutorialState {
        case .T1:
            let showDiscription = SKAction.run({
                self.createTutorialLabel(text: "Your mission is", posY: 910)
                self.createTutorialLabel(text: "Defeat all enemies,", posY: 850)
                self.createTutorialLabel(text: "Protecting your castle!!", posY: 790)
            })
            let wait = SKAction.wait(forDuration: 4.0)
            let moveState = SKAction.run({
                self.tutorialState = .T2
                self.showEnemyDiscriptionDone = false
            })
            let seq = SKAction.sequence([showDiscription, wait, moveState])
            self.run(seq)
        case .T2:
            removeTutorial()
            self.createTutorialLabel2(text: "Are you ready?", posX: self.size.width/2, posY: 810, color: UIColor.white, size: 60)
            self.buttonPlay.state = .msButtonNodeStateActive
        default:
            break;
        }
    }
    
    /* Remove tutorial */
    func removeTutorial() {
        for (i, label) in tutorialLabelArray.enumerated() {
            label.removeFromParent()
            if i == tutorialLabelArray.count-1 {
                tutorialLabelArray.removeAll()
            }
        }
    }
    
    /*== Time bomb ==*/
    /* Effect */
    func timeBombEffect(timeBomb: TimeBomb) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "TimeBombExplode")!
        let particles2 = SKEmitterNode(fileNamed: "TimeBombSmoke")!
        particles.position = CGPoint(x: timeBomb.position.x+gridNode.position.x, y: timeBomb.position.y+gridNode.position.y)
        particles2.position = CGPoint(x: timeBomb.position.x+gridNode.position.x, y: timeBomb.position.y+gridNode.position.y)
        /* Add particles to scene */
        self.addChild(particles)
        self.addChild(particles2)
        let waitRemoveExplode = SKAction.wait(forDuration: 0.5)
        let waitRemoveSmoke = SKAction.wait(forDuration: 3.0)
        let removeParticles = SKAction.removeFromParent()
        let onFlag = SKAction.run({
            self.timeBombDoneFlag = true
            /* Reset itemSet arrays */
            self.gridNode.timeBombSetArray.removeAll()
        })
        let seqEffect = SKAction.sequence([waitRemoveExplode, removeParticles])
        let seqEffect2 = SKAction.sequence([waitRemoveSmoke, removeParticles, onFlag])
        particles.run(seqEffect)
        particles2.run(seqEffect2)
    }
}
