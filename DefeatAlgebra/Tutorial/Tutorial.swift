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
    case T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16
}

class Tutorial: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: GridForTutorial!
    var activeHero = HeroForTutorial()
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    var pauseScreen: PauseScreenForTutorial!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var touchScreenLabel: SKLabelNode!
    var gameOverLabel: SKNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    
    /* Game buttons */
    var buttonRetry: MSButtonNode!
    var buttonSkip: MSButtonNode!
    var buttonNext: MSButtonNode!
    var buttonAgain: MSButtonNode!
    var buttonPause: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let turnEndWait: TimeInterval = 1.0
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var tutorialState: TutorialState = .T0
    static var tutorialPhase = 0
    var itemType: ItemType = .None
    var stageLevel: Int = 0
    var moveLevelArray: [Int] = [1]
    var totalNumOfEnemy: Int = 3
    var tutorialDone = false
    var gameOverDoneFlag = false
    
    /*== Game Sounds ==*/
    var main = BGM(bgm: 0)
    var stageClear = BGM(bgm: 2)
    var gameOver = BGM(bgm: 4)
    var gameOverSoundDone = false
    var stageClearSoundDone = false
    var hitCastleWallSoundDone = false

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
    var enemyTurnEndFlag = false
    var pauseFlag = false
    
    /* Tuotrial temp stuff */
    var tutorial1T7Done = false
    var tutorial1T9Arm = [EnemyArm]()
    var tutorial1T9Fist = [EnemyFist]()
    var tutorial1T9Done = false
    var tutorial1T11Done = false
    var tutorial1T13Index = 0
    var hitByEnemyFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    var heroArray = [HeroForTutorial]()
    var numOfTurnDoneHero = 0
    
    var tutorialLabelArray = [SKNode]()
    
    
    /* Flash grid */
    var numOfFlashArray = [3, 1, 2, 3, 1, 3]
    //    var numOfFlashArray = [1, 1, 1, 1, 1, 1]
    var xValue: Int = 3
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    
    
    /* Castle life */
    var maxLife = 3
    var life: Int = 3
    
    
    override func didMove(to view: SKView) {
        
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! GridForTutorial
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
        /* Sound */
        if MainMenu.soundOnFlag {
            main.play()
            main.numberOfLoops = -1
        }
        
        /* Labels */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        touchScreenLabel = childNode(withName: "touchScreenLabel") as! SKLabelNode
        touchScreenLabel.isHidden = true
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonNext = childNode(withName: "buttonNext") as! MSButtonNode
        buttonNext.state = .msButtonNodeStateHidden
        buttonAgain = childNode(withName: "buttonAgain") as! MSButtonNode
        buttonAgain.state = .msButtonNodeStateHidden
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        buttonSkip = childNode(withName: "buttonSkip") as! MSButtonNode
        
        
        /* Make sure to show skip button when player done once */
        if Tutorial.tutorialPhase == 0 {
            if MainMenu.tutorialHeroDone {
                buttonSkip.state = .msButtonNodeStateActive
            } else {
                buttonSkip.state = .msButtonNodeStateHidden
            }
        } else if Tutorial.tutorialPhase == 1 {
            if MainMenu.tutorialEnemyDone {
                buttonSkip.state = .msButtonNodeStateActive
            } else {
                buttonSkip.state = .msButtonNodeStateHidden
            }
        } else if Tutorial.tutorialPhase == 2 {
            if MainMenu.tutorialAttackDone {
                buttonSkip.state = .msButtonNodeStateActive
            } else {
                buttonSkip.state = .msButtonNodeStateHidden
            }
        }
        
        /* Retry button */
        buttonRetry.selectedHandler = { [weak self] in
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Skip button */
        buttonSkip.selectedHandler = { [weak self] in
            
            /* Stop sound */
            self?.main.stop()
            
            if Tutorial.tutorialPhase == 2 {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase += 1
                
                /* Load Game scene */
                guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
                
            } else {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase += 1
                
                /* Load Game scene */
                guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
        }
        
        /* Next button */
        buttonNext.selectedHandler = { [weak self] in
            
            /* Stop sound */
            self?.stageClear.stop()
            
            /* Store flag of this tutorial done */
            let ud = UserDefaults.standard
            if Tutorial.tutorialPhase == 0 {
                ud.set(true, forKey: "tutorialHeroDone")
            } else if Tutorial.tutorialPhase == 1 {
                ud.set(true, forKey: "tutorialEnemyDone")
            } else if Tutorial.tutorialPhase == 2 {
                ud.set(true, forKey: "tutorialAttackDone")
            }
            
            if Tutorial.tutorialPhase == 2 {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase += 1
                
                /* Load Game scene */
                guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            } else {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase += 1
                
                /* Load Game scene */
                guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
        }
        
        /* Again button */
        buttonAgain.selectedHandler = { [weak self] in
            
            /* Stop sound */
            self?.stageClear.stop()
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Pause button */
        buttonPause.selectedHandler = { [weak self] in
            self?.pauseFlag = true
            self?.pauseScreen.isHidden = false
        }
        
        /* Set puase screen */
        pauseScreen = PauseScreenForTutorial()
        addChild(pauseScreen)
        
        /* Set initial objects */
        setInitialObjects()
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set life */
        setLife(numOflife: maxLife)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        switch Tutorial.tutorialPhase {
        case 0:
            /* Make sure to call once at each tutorial state */
            if tutorialDone == false {
                tutorialDone = true
                tutorialFlow()
            }
            break;
        case 1:
            if tutorialDone == false {
                tutorialDone = true
                tutorialFlow()
            }
            if tutorialState == .T12 {
                switch gameState {
                case .EnemyTurn:
                    flashGridDoneFlag = false
                    
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
                            tutorialDone = false
                            tutorialState = .T15
                        }
                    }
                    
                    /* All enemies finish their actions */
                    if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
                        
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
                                enemy.punchIntervalForCount = 0
                                if let node = enemy.childNode(withName:"punchInterval") {
                                    node.removeFromParent()
                                }
                                enemy.setPunchIntervalLabel()
                            }
                        }
                        
                        gameState = .GridFlashing
                    }
                case .GridFlashing:
                    
                    /* Make sure to call once */
                    if flashGridDoneFlag == false {
                        flashGridDoneFlag = true
                        
                        /* Make grid flash */
                        xValue = self.gridNode.flashGrid(labelNode: valueOfX)
                        
                        /* Calculate each enemy's variable expression */
                        for enemy in self.gridNode.enemyArray {
                            enemy.calculatePunchLength(value: xValue)
                        }
                        
                        if xValue == 3 {
                            let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)+0.7))
                            let moveState = SKAction.run({
                                self.removeTutorial()
                                self.enemyTurnDoneFlag = false
                                self.gridNode.enemyArray[0].myTurnFlag = true
                                self.gameState = .EnemyTurn
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        } else {
                            let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
                            let moveState = SKAction.run({
                                self.removeTutorial()
                                self.enemyTurnDoneFlag = false
                                self.gridNode.enemyArray[0].myTurnFlag = true
                                self.gameState = .EnemyTurn
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        }
                    }
                    break;
                default:
                    break;
                }
            }
            break;
        case 2:

            if tutorialDone == false {
                tutorialDone = true
                tutorialFlow()
            }
            if tutorialState == .T5 {

                switch gameState {
                case .PlayerTurn:
                    
                    /* Check if all enemies are defeated or not */
                    if totalNumOfEnemy <= 0 {
                        gameState = .StageClear
                    }
                    
                    switch playerTurnState {
                    case .DisplayPhase:
                        
                        playerPhaseLabel.isHidden = false
                        let wait = SKAction.wait(forDuration: 1.0)
                        let moveState = SKAction.run({ self.playerTurnState = .ItemOn })
                        let seq = SKAction.sequence([wait, moveState])
                        self.run(seq)
                        break;
                    case .ItemOn:
                        
                        
                        playerPhaseLabel.isHidden = true
                        
                        let hitSpotArray = checkWithinGrid()
                        
                        /* Make it to next to enemy! */
                        if self.gridNode.positionEnemyAtGrid[hitSpotArray.0][activeHero.positionY] || self.gridNode.positionEnemyAtGrid[hitSpotArray.1][activeHero.positionY] || self.gridNode.positionEnemyAtGrid[activeHero.positionX][hitSpotArray.2] || self.gridNode.positionEnemyAtGrid[activeHero.positionX][hitSpotArray.3] {
                            tutorialDone = false
                            tutorialState = .T6
                        } else {
                            playerTurnState = .MoveState
                        }
                        
                    case .MoveState:
                        
                        
                        timeBombDoneFlag = false
                        bombExplodeDoneFlag = false
                        
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
                        /* Wait for player touch to attack */
                        break;
                    case .UsingItem:
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
                        
                        /* Reset Flags */
                        addEnemyDoneFlag = false
                        enemyTurnDoneFlag = false
                        activeHero.attackDoneFlag = false
                        activeHero.moveDoneFlag = false
                        
                        
                        numOfTurnDoneHero = 0
                        
                        /* Remove action buttons */
                        buttonAttack.isHidden = true
                        buttonItem.isHidden = true
                        
                        /* Remove move area */
                        gridNode.resetSquareArray(color: "blue")
                        gridNode.resetSquareArray(color: "red")
                        gridNode.resetSquareArray(color: "purple")
                        
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
                    default:
                        break;
                    }
                    break;
                case .EnemyTurn:
                    
                    /* Reset Flags */
                    addEnemyDoneFlag = false
                    playerTurnDoneFlag = false
                    flashGridDoneFlag = false
                    enemyPhaseLabelDoneFlag = false
                    enemyPhaseLabel.isHidden = true
                    
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
                    
                    /* Make sure to call once */
                    if flashGridDoneFlag == false {
                        flashGridDoneFlag = true
                        
                        xValue = self.gridNode.flashGrid(labelNode: valueOfX)
                        
                        
                        /* Calculate each enemy's variable expression */
                        for enemy in self.gridNode.enemyArray {
                            enemy.calculatePunchLength(value: xValue)
                        }
                        
                        if xValue == 3 {
                            let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)+0.7))
                            let moveState = SKAction.run({
                                self.removeTutorial()
                                self.gameState = .PlayerTurn
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        } else {
                            let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
                            let moveState = SKAction.run({
                                self.removeTutorial()
                                self.gameState = .PlayerTurn
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        }
                        
                    }
                    break;
                case .GameOver:
                    gameOverLabel.isHidden = false
                    if gameOverDoneFlag == false {
                        gameOverDoneFlag = true
                        /* Play Sound */
                        if MainMenu.soundOnFlag {
                            if gameOverSoundDone == false {
                                gameOverSoundDone = true
                                main.stop()
                                let sound = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: true)
                                self.run(sound)
                            }
                        }
                        if hitByEnemyFlag {
                            self.createTutorialLabel(text: "If a hero hits enemy, he'll die!", posY: 720)
                            buttonRetry.state = .msButtonNodeStateActive
                        } else {
                            self.createTutorialLabel(text: "If the town wall life comes to 0", posY: 750)
                            self.createTutorialLabel(text: "Game over", posY: 690)
                            buttonRetry.state = .msButtonNodeStateActive
                        }
                    }
                    break;
                default:
                    break;
                }
                
                break;

            }
        default:
            break;
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pauseFlag == false else { return }
        
        switch Tutorial.tutorialPhase {
        case 0:
            switch tutorialState {
            case .T1:
                tutorialDone = false
                tutorialState = .T2
                break;
            case .T4:
                tutorialDone = false
                tutorialState = .T5
                break;
            case .T5:
                tutorialDone = false
                tutorialState = .T6
                break;
            case .T9:
                tutorialDone = false
                tutorialState = .T10
            default:
                break;
            }
            break;
        case 1:
            switch tutorialState {
            case .T1:
                tutorialDone = false
                tutorialState = .T2
                break;
            case .T5:
                tutorialDone = false
                tutorialState = .T6
                break;
            case .T6:
                tutorialDone = false
                tutorialState = .T7
                break;
            case .T7:
                if tutorial1T7Done {
                    tutorialDone = false
                    tutorialState = .T8
                }
                break;
            case .T8:
                tutorialDone = false
                tutorialState = .T9
                break;
            case .T9:
                if tutorial1T9Done {
                    tutorialDone = false
                    tutorialState = .T10
                }
                break;
            case .T11:
                if tutorial1T11Done {
                    tutorialDone = false
                    tutorialState = .T12
                }
                break;
            case .T13:
                tutorialDone = false
                tutorialState = .T14
                break;
            case .T15:
                tutorialDone = false
                tutorialState = .T16
                break;
            default:
                break;
            }
            break;
        case 2:
            switch tutorialState {
            case .T1:
                tutorialDone = false
                tutorialState = .T2
                break;
            case .T2:
                tutorialDone = false
                tutorialState = .T3
                break;
            case .T3:
                tutorialDone = false
                tutorialState = .T4
                break;
            case .T4:
                tutorialDone = false
                tutorialState = .T5
                break;
            case .T5:
                guard gameState == .PlayerTurn else { return }
                
                /* Get touch point */
                let touch = touches.first!              // Get the first touch
                let location = touch.location(in: self) // Find the location of that touch in this view
                let nodeAtPoint = atPoint(location)     // Find the node at that location
                
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
                            self.gridNode.resetSquareArray(color: "purple")
                            
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
                            self.gridNode.resetSquareArray(color: "purple")
                            
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
                        self.gridNode.resetSquareArray(color: "purple")
                        self.gridNode.resetSquareArray(color: "red")
                    }
                }
                break;
            case .T6:
                /* Get touch point */
                let touch = touches.first!              // Get the first touch
                let location = touch.location(in: self) // Find the location of that touch in this view
                let nodeAtPoint = atPoint(location)     // Find the node at that location
                /* Touch attack button */
                if nodeAtPoint.name == "buttonAttack" {
                    self.gridNode.showAttackArea(posX: self.activeHero.positionX, posY: self.activeHero.positionY, attackType: self.activeHero.attackType)
                    self.playerTurnState = .AttackState
                    tutorialDone = false
                    tutorialState = .T7
                }
                break;
            case .T8:
                tutorialDone = false
                tutorialState = .T9
                break;
            default:
                break;
            }
        default:
            break;
        }
        
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
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let get = SKAction.playSoundFileNamed("ItemGet.wav", waitForCompletion: true)
                    self.run(get)
                }
                /* A is hero */
                if contactA.categoryBitMask == 1 {
                    let item = contactB.node as! SKSpriteNode
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        self.activeHero.moveLevel += 1
                        if Tutorial.tutorialPhase == 0 && tutorialState == .T3 {
                            let wait = SKAction.wait(forDuration: 0.5)
                            let moveState = SKAction.run({
                                self.tutorialDone = false
                                self.tutorialState = .T4
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        }
                        
                        /* Store game property */
                        let ud = UserDefaults.standard
                        /* user flag */
                        GameScene.firstGetItemFlagArray[0] = true
                        ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
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
                        self.activeHero.moveLevel += 1
                        
                        if Tutorial.tutorialPhase == 0 && tutorialState == .T3 {
                            let wait = SKAction.wait(forDuration: 0.5)
                            let moveState = SKAction.run({
                                self.tutorialDone = false
                                self.tutorialState = .T4
                            })
                            let seq = SKAction.sequence([wait, moveState])
                            self.run(seq)
                        }
                        /* Store game property */
                        let ud = UserDefaults.standard
                        /* user flag */
                        GameScene.firstGetItemFlagArray[0] = true
                        ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
                    /* Other items */
                    } else {
                        item.removeFromParent()
                        displayitem(name: item.name!)
                    }
                }
                
                /* Be hitten by enemy */
            } else {
                hitByEnemyFlag = true
                activeHero.removeFromParent()
                gameState = .GameOver
            }
        }
        
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("castleWallHit.mp3", waitForCompletion: true)
                self.run(sound)
            }
            
            if contactA.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeB = contactB.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeB.removeAllActions()
                
                if Tutorial.tutorialPhase == 1 {
                    if life <= 1 {
                        self.removeAllActions()
                    } else {
                        let enemy = nodeB.parent as! EnemyForTutorial
                        self.removeAllActions()
                        tutorialDone = false
                        tutorialState = .T13
                        tutorial1T13Index = enemy.indexOfArray
                    }
                }
                
            }
            
            if contactB.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeA = contactA.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeA.removeAllActions()
                
                if Tutorial.tutorialPhase == 1 {
                    if life <= 1 {
                        self.removeAllActions()
                    } else {
                        let enemy = nodeA.parent as! EnemyForTutorial
                        self.removeAllActions()
                        tutorialDone = false
                        tutorialState = .T13
                        tutorial1T13Index = enemy.indexOfArray
                    }
                }
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
    func setPointingIcon(position: CGPoint, size: CGSize) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.size = size
        icon.position = position
        icon.zPosition = 120
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
        icon.zPosition = 120
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
            let moveUp = SKAction.moveBy(x: 0, y: -CGFloat(self.gridNode.cellHeight), duration: 1.0)
            let moveLeft = SKAction.moveBy(x: CGFloat(self.gridNode.cellWidth), y: 0, duration: 1.0)
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
            let moveUp = SKAction.moveBy(x: -3*CGFloat(self.gridNode.cellWidth), y: 0, duration: 2.0)
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
    
    /* Show touch screen popUp */
    func showTouchScreen(waitTime: TimeInterval) {
        let wait = SKAction.wait(forDuration: waitTime)
        let show = SKAction.run({ self.touchScreenLabel.isHidden = false })
        let seq = SKAction.sequence([wait, show])
        self.run(seq)
    }
    
    /* Reset stuff when moving next discription */
    func resetDiscription() {
        removeTutorial()
        self.removeAllActions()
        touchScreenLabel.isHidden = true
    }
    
    /* Tutorial flow of setting initial objects */
    func setInitialObjects() {
        switch Tutorial.tutorialPhase {
        case 0:
            /* Hero */
            activeHero = HeroForTutorial()
            activeHero.position = CGPoint(x: self.size.width/2, y: self.castleNode.position.y)
            activeHero.positionX = 4
            activeHero.positionY = 2
            addChild(activeHero)
            let iniMove = SKAction.moveTo(y: self.gridNode.position.y+CGFloat(2.5*Double(self.gridNode.cellHeight)), duration: 2.0)
            self.activeHero.run(iniMove)
            break;
        case 1:
            /* Enemy */
            self.gridNode.addInitialEnemyAtGrid(enemyPosArray: [[1,8],[4,6],[7,8]], variableExpressionSource: [[0,1,0,0]])
            break;
        case 2:
            /* Hero */
            activeHero = HeroForTutorial()
            activeHero.position = CGPoint(x: self.size.width/2, y: self.castleNode.position.y)
            activeHero.positionX = 4
            activeHero.positionY = 3
            addChild(activeHero)
            let iniMove = SKAction.moveTo(y: self.gridNode.position.y+CGFloat(3.5*Double(self.gridNode.cellHeight)), duration: 2.0)
            self.activeHero.run(iniMove)
            /* Enemy */
            self.gridNode.addInitialEnemyAtGrid(enemyPosArray: [[4,8]], variableExpressionSource: [[0,1,0,0]])
            break;
        default:
            break;
        }
    }
    
    /* Tutorial flow */
    func tutorialFlow() {
        switch Tutorial.tutorialPhase {
        case 0:
            switch tutorialState {
            case .T0:
                let wait1 = SKAction.wait(forDuration: 2.0)
                let showDisc = SKAction.run({ self.createTutorialLabel(text: "He is a hero protecting the town!", posY: 1100) })
                let wait2 = SKAction.wait(forDuration: 0.5)
                let moveState = SKAction.run({
                    self.tutorialDone = false
                    self.tutorialState = .T1
                })
                let seq = SKAction.sequence([wait1, showDisc, wait2, moveState])
                self.run(seq)
                break;
            case .T1:
                showTouchScreen(waitTime: 1.5)
                break;
            case .T2:
                resetDiscription()
                createTutorialLabel(text: "Let's move him!", posY: 1100)
                createTutorialLabel(text: "Touch the blue area", posY: 1040)
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                break;
            case .T3:
                removeTutorial()
                createTutorialLabel(text: "Great!", posY: 1100)
                createTutorialLabel(text: "Get the boots, next!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+CGFloat(self.gridNode.cellWidth*4.5)+55, y: self.gridNode.position.y+CGFloat(self.gridNode.cellHeight*6.5)+55), size: CGSize(width: 60, height: 52))
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                break;
            case .T4:
                removeTutorial()
                showItemCard(item: "cardBoots")
                showTouchScreen(waitTime: 2.0)
                break;
            case .T5:
                resetDiscription()
                if let card = childNode(withName: "itemCard") {
                    card.removeFromParent()
                }
                createTutorialLabel(text: "Since you got boots", posY: 1100)
                createTutorialLabel(text: "Your move area expands!", posY: 1040)
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T6:
                resetDiscription()
                createTutorialLabel(text: "You can also set an exact path to move", posY: 1100)
                createTutorialLabel(text: "by swiping within the blue area", posY: 1040)
                setMovePointingIcon(position: CGPoint(x: activeHero.position.x+20, y: activeHero.position.y+20))
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                break;
            case .T7:
                removeTutorial()
                createTutorialLabel(text: "If you want to cancel setting a path", posY: 1100)
                createTutorialLabel(text: "Just swipe out of the blue area", posY: 1040)
                setMovePointingIcon2(position: CGPoint(x: self.activeHero.position.x+20, y: self.activeHero.position.y+20))
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                break;
            case .T8:
                removeTutorial()
                self.createTutorialLabel(text: "If you want to stay", posY: 1100)
                self.createTutorialLabel(text: "Just touch where you are!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.activeHero.position.x+50, y: self.activeHero.position.y+50), size: CGSize(width: 60, height: 52))
                /* Show move area */
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                break;
            case .T9:
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    if stageClearSoundDone == false {
                        stageClearSoundDone = true
                        stageClear.play()
                        main.stop()
                    }
                }
                removeTutorial()
                self.createTutorialLabel(text: "Now,", posY: 1100)
                self.createTutorialLabel(text: "You master how to move a hero!!", posY: 1040)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T10:
                resetDiscription()
                buttonNext.state = .msButtonNodeStateActive
                buttonAgain.state = .msButtonNodeStateActive
                break;
            default:
                break;
            }
            break;
        case 1:
            switch tutorialState {
            case .T0:
                let wait1 = SKAction.wait(forDuration: 3.0)
                let showDisc = SKAction.run({ self.createTutorialLabel(text: "They are 'Algebra Robot'!!", posY: 1100) })
                let wait2 = SKAction.wait(forDuration: 0.5)
                let moveState = SKAction.run({
                    self.tutorialDone = false
                    self.tutorialState = .T1
                })
                let seq = SKAction.sequence([wait1, showDisc, wait2, moveState])
                self.run(seq)
                break;
            case .T1:
                showTouchScreen(waitTime: 1.5)
                break;
            case .T2:
                resetDiscription()
                self.createTutorialLabel(text: "They are heading to the town", posY: 1100)
                self.createTutorialLabel(text: "To destroy!", posY: 1040)
                gridNode.enemyArray[0].myTurnFlag = true
                tutorialState = .T3
                tutorialDone = false
                break;
            case .T3:
                enemyActionForTutorial1(nextState: .T4)
                break;
            case .T4:
                enemyActionForTutorial1(nextState: .T5)
                break;
            case .T5:
                resetDiscription()
                for enemy in self.gridNode.enemyArray {
                    let icon = self.setPointingIcon2(position: CGPoint(x: -15, y: -45), size: CGSize(width: 35, height: 35))
                    enemy.addChild(icon)
                }
                self.createTutorialLabel(text: "These numbers indicate", posY: 1100)
                self.createTutorialLabel(text: "when each enemy attacks", posY: 1040)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T6:
                resetDiscription()
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+self.gridNode.enemyArray[0].position.x+55, y: self.gridNode.position.y+self.gridNode.enemyArray[0].position.y+80), size: CGSize(width: 60, height: 52))
                self.createTutorialLabel(text: "If it says 0,", posY: 1100)
                self.createTutorialLabel(text: "The enemy attacks", posY: 1040)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T7:
                resetDiscription()
                self.valueOfX.text = "3"
                self.createTutorialLabel(text: "'Algebra Robot' attacks by punching", posY: 1100)
                self.createTutorialLabel(text: "according to its 'variable expression'!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+self.gridNode.enemyArray[0].position.x+40, y: self.gridNode.position.y+self.gridNode.enemyArray[0].position.y+85), size: CGSize(width: 35, height: 35))
                self.gridNode.enemyArray[0].calculatePunchLength(value: xValue)
                let armAndFist = self.gridNode.enemyArray[0].punch()
                self.tutorial1T9Arm = armAndFist.arm
                self.tutorial1T9Fist = armAndFist.fist
                let wait = SKAction.wait(forDuration: 2.0)
                let moveState = SKAction.run({
                    self.tutorial1T7Done = true
                    self.showTouchScreen(waitTime: 0.1)
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                break;
            case .T8:
                resetDiscription()
                self.createTutorialLabel(text: "In this case, since the value of 'X' is 3", posY: 1100)
                self.createTutorialLabel(text: "The 'Algebera Robot' punches for 3!", posY: 1040)
                let icon = self.setPointingIcon2(position: CGPoint(x: self.valueOfX.position.x-150, y: self.valueOfX.position.y-25), size: CGSize(width: 60, height: 52))
                addChild(icon)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+self.gridNode.enemyArray[0].position.x+80, y: self.gridNode.position.y+self.gridNode.enemyArray[0].position.y-50), size: CGSize(width: 60, height: 52))
                self.gridNode.squareRedArray[self.gridNode.enemyArray[0].positionX][self.gridNode.enemyArray[0].positionY-1].isHidden = false
                self.gridNode.squareRedArray[self.gridNode.enemyArray[0].positionX][self.gridNode.enemyArray[0].positionY-2].isHidden = false
                self.gridNode.squareRedArray[self.gridNode.enemyArray[0].positionX][self.gridNode.enemyArray[0].positionY-3].isHidden = false
                showTouchScreen(waitTime: 2.0)
                break;
            case .T9:
                resetDiscription()
                self.gridNode.resetSquareArray(color: "red")
                self.createTutorialLabel(text: "After attacking,", posY: 1100)
                self.createTutorialLabel(text: "An enemy also moves forward!", posY: 1040)
                /* Keep track enemy position */
                self.gridNode.enemyArray[0].positionY -= self.gridNode.enemyArray[0].valueOfEnemy

                /* Subsutitute arm with opposite direction arm for shrink it the other way around */
                let subSetArm = SKAction.run({
                    for arm in self.tutorial1T9Arm {
                        let size = arm.size
                        let posX = arm.position.x
                        let posY = arm.position.y-size.height
                        let newArm = EnemyArm(direction: self.gridNode.enemyArray[0].direction)
                        newArm.yScale = (size.height)/newArm.size.height
                        newArm.position = CGPoint(x: posX, y: posY)
                        newArm.anchorPoint = CGPoint(x: 0.5, y: 1)
                        newArm.physicsBody = nil
                        self.gridNode.enemyArray[0].addChild(newArm)
                        self.gridNode.enemyArray[0].armArrayForSubSet.append(newArm)
                    }
                })
                
                /* Make sure to remove old arm after setting new arm done */
                let waitForSubSet = SKAction.wait(forDuration: 0.1)
                
                /* Remove old arms */
                let removeArm = SKAction.run({
                    for arm in self.tutorial1T9Arm {
                        arm.removeFromParent()
                    }
                })
                
                /* Move self's body to punch position */
                let moveForward = SKAction.run({
                    let moveBody = SKAction.moveBy(x: 0, y: -CGFloat(Double(self.gridNode.enemyArray[0].valueOfEnemy)*self.gridNode.cellHeight), duration: TimeInterval(self.gridNode.enemyArray[0].punchLength*self.gridNode.enemyArray[0].punchSpeed))
                    self.gridNode.enemyArray[0].run(moveBody)
                    for arm in self.gridNode.enemyArray[0].armArrayForSubSet {
                        let moveArm = SKAction.moveBy(x: 0, y: CGFloat(Double(self.gridNode.enemyArray[0].valueOfEnemy)*self.gridNode.cellHeight), duration:
                            TimeInterval(self.gridNode.enemyArray[0].punchLength*self.gridNode.enemyArray[0].punchSpeed))
                        arm.run(moveArm)
                    }
                    for fist in self.tutorial1T9Fist {
                        let moveFist = SKAction.moveBy(x: 0, y: CGFloat(Double(self.gridNode.enemyArray[0].valueOfEnemy)*self.gridNode.cellHeight), duration:
                            TimeInterval(self.gridNode.enemyArray[0].punchLength*self.gridNode.enemyArray[0].punchSpeed))
                        fist.run(moveFist)
                    }
                })
                
                
                /* Shrink arms */
                let shrinkArm = SKAction.run({
                    for arm in self.gridNode.enemyArray[0].armArrayForSubSet {
                        arm.ShrinkArm(length: self.gridNode.enemyArray[0].punchLength, speed: self.gridNode.enemyArray[0].punchSpeed)
                    }
                })
                
                /* Make sure delete arms & fists after finishing punch drawing */
                let drawWait = SKAction.wait(forDuration: TimeInterval(self.gridNode.enemyArray[0].punchLength*self.gridNode.enemyArray[0].punchSpeed-0.1)) /* 0.1 is buffer */
                
                /* Get rid of all arms and fists */
                let punchDone = SKAction.run({
                    self.gridNode.enemyArray[0].removeAllChildren()
                })
                
                /* Set variable expression */
                let setVariableExpression = SKAction.run({
                    /* Reset count down punchInterval */
                    self.gridNode.enemyArray[0].punchIntervalForCount = self.gridNode.enemyArray[0].punchInterval
                    /* Create variable expression */
                    self.gridNode.enemyArray[0].setVariableExpressionLabel(text: self.gridNode.enemyArray[0].variableExpressionForLabel)
                    self.gridNode.enemyArray[0].setMovingAnimation()
                    /* Display left trun till punch */
                    self.gridNode.enemyArray[0].setPunchIntervalLabel()
                })
                
                let showTouch = SKAction.run({
                    self.tutorial1T9Done = true
                    self.showTouchScreen(waitTime: 0.5)
                    self.gridNode.enemyArray[0].myTurnFlag = false
                    self.gridNode.enemyArray[1].myTurnFlag = true
                    self.gridNode.turnIndex = 1
                    self.gridNode.numOfTurnEndEnemy = 1
                })
                
                /* excute drawPunch */
                let seq = SKAction.sequence([subSetArm, waitForSubSet, removeArm, moveForward, shrinkArm, drawWait, punchDone, setVariableExpression, showTouch])
                self.gridNode.enemyArray[0].run(seq)
                break;
            case .T10:
                resetDiscription()
                enemyActionForTutorial1(nextState: .T11)
                break;
            case .T11:
                resetDiscription()
                self.createTutorialLabel(text: "The value of 'X' is changed", posY: 1100)
                self.createTutorialLabel(text: "by the number of times of flashing!", posY: 1040)
                let icon = self.setPointingIcon2(position: CGPoint(x: self.valueOfX.position.x-150, y: self.valueOfX.position.y-25), size: CGSize(width: 60, height: 52))
                self.addChild(icon)
                let wait1 = SKAction.wait(forDuration: 1.0)
                let flash = SKAction.run({
                    self.xValue = self.gridNode.flashGrid(labelNode: self.valueOfX)
                    /* Calculate each enemy's variable expression */
                    for enemy in self.gridNode.enemyArray {
                        enemy.calculatePunchLength(value: self.xValue)
                    }
                })
                let wait2 = SKAction.wait(forDuration: 1.5)
                let onFlag = SKAction.run({ self.tutorial1T11Done = true })
                let seq = SKAction.sequence([wait1, flash, wait2, onFlag])
                self.run(seq)
                showTouchScreen(waitTime: 4.5)
                break;
            case .T12:
                resetDiscription()
                gameState = .EnemyTurn
                break;
            case .T13:
                self.createTutorialLabel(text: "Enemy's punch could damage", posY: 1100)
                self.createTutorialLabel(text: "the town wall life!", posY: 1040)
                setPointingIcon(position: CGPoint(x: 170, y: 215), size: CGSize(width: 60, height: 52))
                showTouchScreen(waitTime: 2.0)
                for i in 0..<tutorial1T13Index {
                    self.gridNode.enemyArray[i].myTurnFlag = false
                }
                self.gridNode.enemyArray[tutorial1T13Index].myTurnFlag = true
                self.gridNode.turnIndex = tutorial1T13Index
                self.gridNode.numOfTurnEndEnemy = tutorial1T13Index
                break;
            case .T14:
                resetDiscription()
                enemyActionForTutorial1(nextState: .T12)
                break;
            case .T15:
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    if gameOverSoundDone == false {
                        gameOverSoundDone = true
                        main.stop()
                        gameOver.play()
                    }
                }
                resetDiscription()
                self.createTutorialLabel(text: "If the town wall life comes to 0", posY: 1100)
                self.createTutorialLabel(text: "Game over", posY: 1040)
                gameOverLabel.isHidden = false
                showTouchScreen(waitTime: 2.0)
                break;
            case .T16:
                resetDiscription()
                gameOverLabel.isHidden = true
                buttonNext.state = .msButtonNodeStateActive
                buttonAgain.state = .msButtonNodeStateActive
                break;
            }
            break;
        case 2:
            switch tutorialState {
            case .T0:
                let wait1 = SKAction.wait(forDuration: 2.0)
                let showDisc = SKAction.run({
                    self.createTutorialLabel(text: "An enemy is approaching!!", posY: 780)
                    self.createTutorialLabel(text: "Defeat the enemy to protect the town!", posY: 720)
                })
                let wait2 = SKAction.wait(forDuration: 0.5)
                let moveState = SKAction.run({
                    self.tutorialDone = false
                    self.tutorialState = .T1
                })
                let seq = SKAction.sequence([wait1, showDisc, wait2, moveState])
                self.run(seq)
                break;
            case .T1:
                showTouchScreen(waitTime: 1.5)
                break;
            case .T2:
                resetDiscription()
                self.createTutorialLabel(text: "You can attack the red area next to you!", posY: 750)
                gridNode.showAttackArea(posX: activeHero.positionX, posY: activeHero.positionY, attackType: 0)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T3:
                resetDiscription()
                self.createTutorialLabel(text: "So you must be next to enemies", posY: 780)
                self.createTutorialLabel(text: "When you want to attack them!", posY: 720)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T4:
                resetDiscription()
                gridNode.resetSquareArray(color: "red")
                self.createTutorialLabel(text: "Move next to the enemy to attack!!", posY: 750)
                gameState = .PlayerTurn
                showTouchScreen(waitTime: 2.0)
                break;
            case .T5:
                resetDiscription()
                break;
            case .T6:
                /* Display action buttons */
                buttonAttack.isHidden = false
                buttonItem.isHidden = false
                self.createTutorialLabel(text: "Now, you can attack the enemy!", posY: 1100)
                self.createTutorialLabel(text: "Touch attack icon!!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.buttonAttack.position.x+55, y: self.buttonAttack.position.y+65), size: CGSize(width: 60, height: 52))
                break;
            case .T7:
                resetDiscription()
                createTutorialLabel(text: "You can attack by touching red areas!", posY: 1100)
                createTutorialLabel(text: "Touch the red area!!", posY: 1040)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+self.gridNode.enemyArray[0].position.x+55, y: self.gridNode.position.y+self.gridNode.enemyArray[0].position.y+80), size: CGSize(width: 60, height: 52))
                break;
            case .T8:
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    if stageClearSoundDone == false {
                        stageClearSoundDone = true
                        stageClear.play()
                        main.stop()
                    }
                }
                resetDiscription()
                createTutorialLabel(text: "Great!", posY: 1100)
                createTutorialLabel(text: "Now, you are ready to", posY: 1000)
                createTutorialLabel(text: "Protect the town!!", posY: 940)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T9:
                resetDiscription()
                buttonNext.state = .msButtonNodeStateActive
                buttonAgain.state = .msButtonNodeStateActive
                break;
            default:
                break;
            }
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
    
    /* Life */
    func setLife(numOflife: Int) {
        for i in 0..<maxLife {
            if let node = childNode(withName: "life") {
                node.removeFromParent()
            }
            if i == maxLife-1 {
                for i in 0..<numOflife {
                    let life = SKSpriteNode(imageNamed: "heart")
                    life.size = CGSize(width: 50, height: 50)
                    life.position = CGPoint(x: Double(i)*60+45, y: 140)
                    life.name = "life"
                    life.zPosition = 90
                    addChild(life)
                }
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
    
    /* Show item card when get it */
    func showItemCard(item: String) {
        let card = SKSpriteNode(imageNamed: item)
        card.size = CGSize(width: 550, height: 769)
        card.position = CGPoint(x: self.size.width/2, y: self.size.height/2+100)
        card.name = "itemCard"
        card.zPosition = 10
        addChild(card)
    }
    
    /* Enemy action for tutorial1 */
    func enemyActionForTutorial1(nextState: TutorialState) {
        if enemyTurnDoneFlag == false {
            
            enemyTurnEndFlag = false
            tutorialDone = false
            /* Reset enemy position */
            gridNode.resetEnemyPositon()
            
            for enemy in self.gridNode.enemyArray {
                enemy.calculatePunchLength(value: xValue)
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
                tutorialDone = false
                tutorialState = .T15
            }
        }
        
        /* All enemies finish their actions */
        if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
            enemyTurnDoneFlag = true
            /* Reset all stuffs */
            gridNode.turnIndex = 0
            gridNode.numOfTurnEndEnemy = 0
            for (i, enemy) in gridNode.enemyArray.enumerated() {
                enemy.turnDoneFlag = false
                enemy.myTurnFlag = false
                if i == gridNode.enemyArray.count-1 {
                    tutorialState = nextState
                    enemyTurnDoneFlag = false
                    gridNode.enemyArray[0].myTurnFlag = true
                }
            }
                    
            /* Update enemy position */
            gridNode.updateEnemyPositon()
            
            /* Check if enemy reach to castle */
            for enemy in self.gridNode.enemyArray {
                if enemy.positionY == 0 {
                    enemy.reachCastleFlag = true
                }
            }
        }
    }
    
    /* Check within grid for catapult */
    func checkWithinGrid() -> (Int, Int, Int, Int) {
        /* Calculate hit spots */
        /* Make sure hit spots within grid */
        if activeHero.positionX == 0 {
            let hitSpotXLeft = 0
            let hitSpotXRight = activeHero.positionX+1
            if activeHero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if activeHero.positionX == 8 {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else if activeHero.positionX == 8 {
            let hitSpotXLeft = activeHero.positionX-1
            let hitSpotXRight = 8
            if activeHero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if activeHero.positionX == 8 {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else {
            let hitSpotXLeft = activeHero.positionX-1
            let hitSpotXRight = activeHero.positionX+1
            if activeHero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if activeHero.positionX == 8 {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = activeHero.positionY-1
                let hitSpotYUp = activeHero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        }
    }
}
