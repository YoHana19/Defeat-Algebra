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
 2: Enemy - 1
 4: castleNode - 24(8,16)
 8: EnemyArm - 4
 16: EnemyFist - 5(1,4)
 32: setItems - 3.wall-26(2,8,16), bullet-2
 64: getItems(0.Boots,1.timeBomb,2.Heart,callHero,6.catapult,4.multiAttack,5.battleShip,7.resetCatapult,8.cane,9.magicsword,10.teleport,11.spear,12.callHero) - 1
 128:
 1024:
 */

import SpriteKit
import GameplayKit

class Tutorial2: SKScene, SKPhysicsContactDelegate {
    
    /*== Game objects ==*/
    var activeHero = HeroForTutorial2()
    var gridNode: GridForTutorial2!
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
     var pauseScreen: PauseScreenForTutorial2!
    
    /*== Game labels ==*/
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    var clearLabel: SKNode!
    var levelLabel: SKLabelNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    var touchScreenLabel: SKLabelNode!
    
    /*== Game buttons ==*/
    var buttonRetry: MSButtonNode!
    var buttonPlay: MSButtonNode!
    var buttonNextLevel: MSButtonNode!
    var buttonNext: MSButtonNode!
    var buttonAgain: MSButtonNode!
    var buttonSkip: MSButtonNode!
    var buttonPause: MSButtonNode!
    
    /*== Game constants ==*/
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    /* Game Management */
    var tutorialState: TutorialState = .T0
    var tutorialDone = false
    var tutorialLabelArray = [SKNode]()
    var tutorial4T8Done = false
    var gameOverDoneFlag = false
    var stageClearDoneFlag = false
    var hitByEnemyFlag = false
    var pauseFlag = false
    /* Game Speed */
    let turnEndWait: TimeInterval = 1.0
    let phaseLabelTime: TimeInterval = 0.3
    /* State cotrol */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var itemType: ItemType = .None
    /* Game level */
    var stageLevel: Int = 0
    var moveLevelArray: [Int] = [1]
    var totalNumOfEnemy: Int = 0
    
    /*===========*/
    /*== Hero ==*/
    /*===========*/
    
    /*== Hero Management ==*/
    var heroArray = [HeroForTutorial2]()
    var heroMovingFlag = false
    /* Hero turn */
    var numOfTurnDoneHero = 0
    var playerTurnDoneFlag = false
    
    
    /*===========*/
    /*== Enemy ==*/
    /*===========*/
    
    /*== Resource of variable expression ==*/
    /* 1st element decides wihich is coefficiet or constant term, last elment indicates equivarence of variable expression */
    /* 1st element 0:x+1, 1:1+x, 2:1×x, 3:x×1, 4:2x-1, 5:3-x, 6:X+1+2;2x-3+1, 7:2+1-x, 8:x+x+1;2x-x;x+x-1, 9:x+x+2+1 */
    /* 8th: 01origin, 9th: 45origin, 10th: 01to6, 11th: 45to67, 12th: 01to8, 13th: 45to8, 14th: 01to9, 15th: 45to9 */
    let variableExpressionSource = [[0, 1, 0, 0],[0, 1, 0, 0]]
    var variableExpressionSourceRandom = [[Int]]()
    
    /*== Add enemy management ==*/
    var initialEnemyPosArray = [[Int]]()
    var initialAddEnemyFlag = true
    /* [0: number of adding enemy, 1: inteval of adding enemy, 2: number of times of adding enemy, 3: range of start yPos] */
    var addEnemyManagement = [[0, 0, 0, 1], [0, 0, 0, 1]]
    var numOfAddEnemy: Int = 0
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 0
    var addYRange: Int = 0
    var countTurnForCompAddEnemy: Int = 0
    var numOfTimeAddEnemy: Int = 0
    var CompAddEnemyFlag = false
    var addEnemyDoneFlag = false
    
    /*== Enemy Turn management ==*/
    var enemyTurnDoneFlag = false
    var enemyPhaseLabelDoneFlag = false
    
    /*===========*/
    /*== Items ==*/
    /*===========*/
    
    /*== Item Management ==*/
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    var itemSpot = [[Int]]()
    var showinCardFlag = false
    static var firstGetItemFlagArray: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false]
    /* Time bomb */
    var bombExplodeDoneFlag = false
    /* Catapult */
    var activeCatapult = Catapult()
    var setCatapultArray = [Catapult]()
    var inputBoard: InputVariableExpression!
    var activeAreaForCatapult = [SKShapeNode]()
    var setCatapultDoneFlag = false
    var catapultFireReady = false
    var catapultDoneFlag = false
    var activateCatapultDone = false
    var catapultOnceFlag = false
    /* Reset catapult */
    var usingResetCatapultFlag = false
    var selecttingCatapultFlag = false
    var selectCatapultDoneFlag = false
    var resettingCatapultFlag = false
    var selectedCatapult = Catapult()
    /* Magic sword */
    var magicSwordAttackDone = false
    /* timeBomb */
    var timeBombDoneFlag = false
    /* Wall */
    var wallDoneFlag = false
    /* Battle ship */
    var battleShipDoneFlag = false
    var battleShipOnceFlag = false
    /* cane */
    var inputBoardForCane: InputVariable!
    
    /*================*/
    /*== Grid Flash ==*/
    /*================*/
    
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    var xValue: Int = 0
    var flashGridDoneFlag = false
    
    /*=================*/
    /*== Castle life ==*/
    /*=================*/
    
    var maxLife = 3
    var life: Int = 3
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! GridForTutorial2
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
        /* Labels */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
//        clearLabel = childNode(withName: "clearLabel")
//        clearLabel.isHidden = true
        levelLabel = childNode(withName: "levelLabel") as! SKLabelNode
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        touchScreenLabel = childNode(withName: "touchScreenLabel") as! SKLabelNode
        touchScreenLabel.isHidden = true
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonPlay = childNode(withName: "buttonPlay") as! MSButtonNode
        buttonPlay.state = .msButtonNodeStateHidden
        buttonNext = childNode(withName: "buttonNext") as! MSButtonNode
        buttonNext.state = .msButtonNodeStateHidden
        buttonAgain = childNode(withName: "buttonAgain") as! MSButtonNode
        buttonAgain.state = .msButtonNodeStateHidden
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        buttonSkip = childNode(withName: "buttonSkip") as! MSButtonNode
        
        /* Make sure to show skip button when player done once */
        if Tutorial.tutorialPhase == 3 {
            if MainMenu.tutorialPracticeDone {
                buttonSkip.state = .msButtonNodeStateActive
            } else {
                buttonSkip.state = .msButtonNodeStateHidden
            }
        } else if Tutorial.tutorialPhase == 4 {
            if MainMenu.tutorialTimeBombDone {
                buttonSkip.state = .msButtonNodeStateActive
            } else {
                buttonSkip.state = .msButtonNodeStateHidden
            }
        }
            
        /* Skip button */
        buttonSkip.selectedHandler = { [weak self] in
            if Tutorial.tutorialPhase < 4 {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase += 1
                
                /* Load Game scene */
                guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFill
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            } else {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                Tutorial.tutorialPhase = 0
                
                /* Load Game scene */
                guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFill
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
        }
        
        /* Retry button */
        buttonRetry.selectedHandler = { [weak self] in
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Next button */
        buttonNext.selectedHandler = { [weak self] in
            
            /* Store flag of this tutorial done */
            let ud = UserDefaults.standard
            ud.set(true, forKey: "tutorialPracticeDone")
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
                
            Tutorial.tutorialPhase += 1
                
            /* Load Game scene */
            guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                return
            }
                
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
                
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Again button */
        buttonAgain.selectedHandler = { [weak self] in
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial2(fileNamed:"Tutorial2") as Tutorial2! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Play button */
        buttonPlay.selectedHandler = { [weak self] in
            
            /* Store flag of this tutorial done */
            let ud = UserDefaults.standard
            ud.set(true, forKey: "tutorialTimeBombDone")
            ud.set(true, forKey: "tutorialAllDone")
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            Tutorial.tutorialPhase = 0
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Pause button */
        buttonPause.selectedHandler = { [weak self] in
            self?.pauseFlag = true
            self?.pauseScreen.isHidden = false
        }
        
        /* Set puase screen */
        pauseScreen = PauseScreenForTutorial2()
        addChild(pauseScreen)
        
        GameScene.firstGetItemFlagArray = [true, false, false, false, false, false, false, false, false, false, false, false, false]
        
        if Tutorial.tutorialPhase == 4 {
            stageLevel = 1
            self.moveLevelArray = [2]
        }

        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Set hero */
        setHero()
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set item spot */
        setItemSpot()
        
        /* Set initial objects */
        setInitialObj(level: self.stageLevel)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set each value of adding enemy management */
        SetAddEnemyMng()
                
        /* Set active area for catapult */
        setActiveAreaForCatapult()
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set life */
        setLife(numOflife: maxLife)
        
        print(stageLevel)
        print(Tutorial.tutorialPhase)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if showinCardFlag {
            gameState = .PlayerTurn
            playerTurnState = .ShowingCard
        }
        
        switch Tutorial.tutorialPhase {
        case 3:
            if tutorialDone == false {
                print(tutorialState)
                print("hey11")
                tutorialDone = true
                tutorialFlow()
            }
            break;
        case 4:
            if tutorialDone == false {
                print(tutorialState)
                print("hey15")
                tutorialDone = true
                tutorialFlow()
            }
            break;
        default:
            break;
        }
//        print(gameState)
        switch gameState {
        case .AddEnemy:
            if Tutorial.tutorialPhase == 3 {
                /* Make sure to call addEnemy once */
                if addEnemyDoneFlag == false {
                    addEnemyDoneFlag = true
                    
                    /* Initial add or add on the way */
                    if initialAddEnemyFlag {
                        initialAddEnemyFlag = false
                        print("call2")
                        /* Add enemy */
                        let addEnemy = SKAction.run({
                            self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSource)
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            self.gridNode.updateEnemyPositon()
                        
                            self.tutorialState = .T1
                            self.tutorialDone = false
                            
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                    } else {
                        /* Move to next state */
                        self.gameState = .GridFlashing
                    }
                }
            } else if Tutorial.tutorialPhase == 4 {
                /* Make sure to call addEnemy once */
                if addEnemyDoneFlag == false {
                    addEnemyDoneFlag = true
                    
                    /* Initial add or add on the way */
                    if initialAddEnemyFlag {
                        initialAddEnemyFlag = false
                        print("call2")
                        /* Add enemy */
                        let addEnemy = SKAction.run({
                            self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSource)
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            self.gridNode.updateEnemyPositon()
                            
                            self.tutorialState = .T1
                            self.tutorialDone = false
                            
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                    } else {
                        /* Move to next state */
                        self.gameState = .GridFlashing
                    }
                }
            }
            break;
        case .PlayerTurn:
            //            print(itemArray)
            //            print(playerTurnState)
            //            print("\(heroArray.count), \(numOfTurnDoneHero)")
            //            print(totalNumOfEnemy)
            /* Check if all enemies are defeated or not */
            if totalNumOfEnemy <= 0 {
                gameState = .StageClear
            }
            
            switch playerTurnState {
            case .DisplayPhase:
                playerPhaseLabel.isHidden = false
                let wait = SKAction.wait(forDuration: self.phaseLabelTime)
                let moveState = SKAction.run({ self.playerTurnState = .ItemOn })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                break;
            case .ItemOn:
                /* Check game over */
                if heroArray.count < 1 {
                    gameState = .GameOver
                } else {
                    /* Activate initial hero */
                    activeHero = heroArray[0]
                }
                
                playerPhaseLabel.isHidden = true
                
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
                    if Tutorial.tutorialPhase == 3 {
                        playerTurnState = .MoveState
                    } else if Tutorial.tutorialPhase == 4 && tutorialState == .T8 {
                        tutorialDone = false
                        tutorialState = .T9
                    } else if tutorialState == .T12 {
                        playerTurnState = .MoveState
                    }
                    timeBombDoneFlag = false
                    bombExplodeDoneFlag = false
                }
            case .MoveState:
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
                    setCatapultDoneFlag = false
                    magicSwordAttackDone = false
                    catapultFireReady = false
                    catapultDoneFlag = false
                    break;
                case .timeBomb:
                    self.gridNode.showtimeBombSettingArea()
                    break;
                case .Catapult:
                    if setCatapultDoneFlag == false {
                        self.showActiveAreaForCatapult()
                    } else if catapultFireReady {
                        /* Make sure to call this once */
                        if catapultDoneFlag == false {
                            catapultDoneFlag = true
                            /* Set animation of catapult */
                            let catapultAni = SKAction(named: "catapult")
                            activeCatapult.run(catapultAni!)
                            
                            /* Set Catapult variable expression label */
                            activeCatapult.setCatapultVELabel(vE: activeCatapult.variableExpression)
                            /* Throw stone */
                            throwBomb(value: inputBoard.outputValue, setCatapult: activeCatapult)
                            
                        }
                        break;
                    }
                    break;
                case .Wall:
                    self.gridNode.showWallSettingArea()
                    break;
                case .MagicSword:
                    if magicSwordAttackDone == false {
                        self.gridNode.showAttackArea(posX: activeHero.positionX, posY: activeHero.positionY, attackType: activeHero.attackType)
                    }
                    break;
                case .BattleShip:
                    self.gridNode.showBttleShipSettingArea()
                    break;
                case .Teleport:
                    self.gridNode.showTeleportSettingArea()
                    break;
                case .ResetCatapult:
                    /* Make sure to call once */
                    if usingResetCatapultFlag {
                        usingResetCatapultFlag = false
                        /* Make red tiriangle pointing catapult */
                        for catapult in setCatapultArray {
                            catapult.makeTriangle()
                        }
                        /* On flag selecttingCatapult */
                        selecttingCatapultFlag = true
                    }
                    if selectCatapultDoneFlag {
                        self.showActiveAreaForCatapult()
                    }
                    break;
                case .Cane:
                    inputBoardForCane.isHidden = false
                    break;
                }
                
                /* Wait for player touch to point position to use item at */
                break;
            case .TurnEnd:
                /* Remove dead hero from heroArray */
                self.heroArray = self.heroArray.filter({ $0.aliveFlag == true })
                
                //                print(heroArray)
                
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
                    let wait = SKAction.wait(forDuration: self.phaseLabelTime)
                    let moveState = SKAction.run({ self.gameState = .EnemyTurn })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                }
                
                /* Remove unactive cataapult from setCatapultArray */
                self.setCatapultArray = self.setCatapultArray.filter({ $0.activeFlag == true })
                
                break;
            case .ShowingCard:
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
            
            if enemyTurnDoneFlag == false {
                //                print("\(self.gridNode.enemyArray.count), \(gridNode.numOfTurnEndEnemy)")
                
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
                        if let node = enemy.childNode(withName: "punchInterval") {
                            node.removeFromParent()
                        }
                        enemy.punchIntervalForCount = 0
                        enemy.setPunchIntervalLabel()
                    }
                }
                
                gameState = .AddEnemy
                playerTurnState = .DisplayPhase
                
            }
            break;
        case .GridFlashing:
            //                        print("GridFlashing")
            /* Make sure to call once */
            if flashGridDoneFlag == false {
                flashGridDoneFlag = true
                
                gridNode.numOfTurnEndEnemy = 0
                
                /* Make grid flash */
                xValue = self.gridNode.flashGrid(labelNode: valueOfX)
                
                /* Calculate each enemy's variable expression */
                for enemy in self.gridNode.enemyArray {
                    enemy.calculatePunchLength(value: xValue)
                }
                
                let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
                let moveState = SKAction.run({ self.gameState = .PlayerTurn })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
            }
            break;
        case .StageClear:
            if stageClearDoneFlag == false {
                stageClearDoneFlag = true
                gridNode.resetSquareArray(color: "blue")
                if Tutorial.tutorialPhase == 3 {
                    createTutorialLabel(text: "Great!!", posY: 1100)
                    createTutorialLabel(text: "You defeated all enemies!", posY: 1040)
                    buttonNext.state = .msButtonNodeStateActive
                    buttonAgain.state = .msButtonNodeStateActive
                } else {
                    createTutorialLabel(text: "Great!!", posY: 1100)
                    createTutorialLabel(text: "Now, You are ready to play!", posY: 1040)
                    buttonPlay.state = .msButtonNodeStateActive
                    buttonAgain.state = .msButtonNodeStateActive
                }
            }
            break;
            
        case .GameOver:
            if gameOverDoneFlag == false {
                gameOverDoneFlag = true
                if hitByEnemyFlag {
                    self.createTutorialLabel(text: "If a hero hits enemy, he'll die!", posY: 720)
                    gameOverLabel.isHidden = false
                    buttonRetry.state = .msButtonNodeStateActive
                } else {
                    self.createTutorialLabel(text: "If the town wall life comes to 0", posY: 750)
                    self.createTutorialLabel(text: "Game over", posY: 690)
                    gameOverLabel.isHidden = false
                    buttonRetry.state = .msButtonNodeStateActive
                }
            }
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print("scene touchBegan")
        
        guard pauseFlag == false else { return }
        
        if Tutorial.tutorialPhase == 3 && tutorialState == .T1 {
            gameState = .GridFlashing
            tutorialState = .T2
            resetDiscription()
            return
        }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if Tutorial.tutorialPhase == 4 {
            if tutorialState == .T2 {
                tutorialDone = false
                tutorialState = .T3
                return
            } else if tutorialState == .T3 {
                tutorialDone = false
                tutorialState = .T4
                return
            } else if tutorialState == .T4 {
                guard nodeAtPoint.name == "buttonItem" else { return }
                tutorialDone = false
                tutorialState = .T5
                return
            } else if tutorialState == .T5 {
                guard nodeAtPoint.name == "timeBomb" else { return }
                tutorialDone = false
                tutorialState = .T6
                return
            } else if tutorialState == .T6 {
                tutorialDone = false
                tutorialState = .T7
                return
            } else if tutorialState == .T8 {
                if tutorial4T8Done == false {
                    tutorial4T8Done = true
                    resetDiscription()
                    xValue = gridNode.flashGrid(labelNode: valueOfX)
                    /* Calculate each enemy's variable expression */
                    for enemy in self.gridNode.enemyArray {
                        enemy.calculatePunchLength(value: xValue)
                    }
                    let wait = SKAction.wait(forDuration: 1.8)
                    let moveState = SKAction.run({
                        self.gameState = .PlayerTurn
                        self.playerTurnState = .TurnEnd
                    })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                }
            } else if tutorialState == .T9 {
                tutorialDone = false
                tutorialState = .T10
                return
            } else if tutorialState == .T10 {
                tutorialDone = false
                tutorialState = .T11
                return
            } else if tutorialState == .T11 {
                resetDiscription()
                touchScreenLabel.isHidden = true
                tutorialState = .T12
                gameState = .PlayerTurn
                playerTurnState = .ItemOn
                return
            }
        }
        
        guard gameState == .PlayerTurn else { return }
        
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
                self.gridNode.resetSquareArray(color: "purple")
                /* Set timeBomb using state */
                itemType = .timeBomb
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                //                print("Now item index is \(usingItemIndex)")
                           
            /* If player touch other place than item icons, back to MoveState */
            } else {
                guard setCatapultDoneFlag == false else { return }
                guard selectCatapultDoneFlag == false else { return }
                
                /* Show attack and item buttons */
                buttonAttack.isHidden = false
                buttonItem.isHidden = false
                
                playerTurnState = .MoveState
                /* Set item area cover */
                itemAreaCover.isHidden = false
                
                /* Reset hero */
                activeHero.resetHero()
                
                /* Reset item type */
                self.itemType = .None
                
                /* Remove active area */
                self.gridNode.resetSquareArray(color: "purple")
                self.gridNode.resetSquareArray(color: "red")
                
            }
        } else if playerTurnState == .ShowingCard {
            showinCardFlag = false
            playerTurnState = .TurnEnd
            if let card = childNode(withName: "itemCard") {
                card.removeFromParent()
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
                    /* Other items */
                    } else {
                        item.removeFromParent()
                        /* Store game property */
                        let ud = UserDefaults.standard
                        /* user flag */
                        GameScene.firstGetItemFlagArray[1] = true
                        ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                        if stageLevel >= 8 {
//                            itemSpot.append(item.spotPos)
                            autoSetItems()
                        }
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
                    /* Other items */
                    } else {
                        item.removeFromParent()
                        /* Store game property */
                        let ud = UserDefaults.standard
                        /* user flag */
                        GameScene.firstGetItemFlagArray[1] = true
                        ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                        if stageLevel >= 8 {
//                            itemSpot.append(item.spotPos)
                            autoSetItems()
                        }
                    }
                }
                
            /* Be hitten by enemy */
            } else {
                hitByEnemyFlag = true
                if contactA.categoryBitMask == 1 {
                    let hero = contactA.node as! HeroForTutorial2
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
                    let hero = contactB.node as! HeroForTutorial2
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
            //            print("cate 4 hit")
            
            if contactA.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeB = contactB.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeB.removeAllActions()
            }
            
            if contactB.categoryBitMask == 4 {
                /* Get enemy body or arm or fist */
                let nodeA = contactA.node as! SKSpriteNode
                
                /* Stop arm and fist */
                nodeA.removeAllActions()
            }
        }
    }
    
    
    /*===========*/
    /*== Hero ==*/
    /*===========*/
    
    /*== Set initial hero ==*/
    func setHero() {
        let hero = HeroForTutorial2()
        hero.moveLevel = moveLevelArray[0]
        hero.positionX = 4
        hero.positionY = 3
        heroArray.append(hero)
        hero.position = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*4), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
        addChild(hero)
        activeHero = hero
    }
    
    /*===========*/
    /*== Enemy ==*/
    /*===========*/
    
    /*== Add enemy in fixed interval ==*/
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
    
    /*== Pick several variable expression from source ==*/
    func pickVariableExpression(origin: [[Int]], modified: [[Int]], num: Int) {
        var source1 = origin
        var source2 = modified
        for _ in 0..<num {
            let rand = Int(arc4random_uniform(UInt32(source1.count)))
            variableExpressionSourceRandom.append(source1[rand])
            variableExpressionSourceRandom.append(source2[rand])
            source1.remove(at: rand)
            source2.remove(at: rand)
        }
    }
    
    func pickVariableExpression3(origin: [[Int]], modified1: [[Int]], modified2: [[Int]], num: Int) {
        var source1 = origin
        var source2 = modified1
        var source3 = modified2
        for _ in 0..<num {
            let rand = Int(arc4random_uniform(UInt32(source1.count)))
            variableExpressionSourceRandom.append(source1[rand])
            variableExpressionSourceRandom.append(source2[rand])
            variableExpressionSourceRandom.append(source3[rand])
            source1.remove(at: rand)
            source2.remove(at: rand)
            source3.remove(at: rand)
        }
    }
    
    /*== Set each value of adding enemy management ==*/
    func SetAddEnemyMng() {
        numOfAddEnemy = addEnemyManagement[stageLevel][0]
        addInterval = addEnemyManagement[stageLevel][1]
        numOfTimeAddEnemy = addEnemyManagement[stageLevel][2]
        addYRange = addEnemyManagement[stageLevel][3]
    }
    
    /*===========*/
    /*== Items ==*/
    /*===========*/
    
    /*== Item Management ==*/
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
    
    /* Check it is first time to get or not */
    func checkFirstItem(itemName: String) {
        /* Store game property */
        let ud = UserDefaults.standard
        showinCardFlag = true
        switch itemName {
        case "timeBomb":
            if GameScene.firstGetItemFlagArray[1] == false {
                showItemCard(item: "cardTimeBomb")
                GameScene.firstGetItemFlagArray[1] = true
                ud.set(GameScene.firstGetItemFlagArray[1], forKey: "firstGetItemFlagArray")
            }
            break;
        default:
            break;
        }
    }
    
    /* Show item card when get it firstly */
    func showItemCard(item: String) {
        let card = SKSpriteNode(imageNamed: item)
        card.size = CGSize(width: 550, height: 769)
        card.position = CGPoint(x: self.size.width/2, y: self.size.height/2+100)
        card.name = "itemCard"
        card.zPosition = 50
        addChild(card)
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
    
    /*== Catapult ==*/
    /* Display active area for catapult */
    func setSingleActiveAreaForCatapult() -> SKShapeNode {
        let square = SKShapeNode(rectOf: CGSize(width: gridNode.cellWidth, height: 88))
        square.strokeColor = UIColor.white
        square.fillColor = UIColor.purple
        square.alpha = 0.4
        square.lineWidth = 2.0
        square.zPosition = 100
        square.name = "activeArea"
        square.isHidden = true
        return square
    }
    
    func setActiveAreaForCatapult() {
        for i in 0...8 {
            let activeArea = setSingleActiveAreaForCatapult()
            activeArea.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth)/2+CGFloat(Double(i)*gridNode.cellWidth), y: 236)
            addChild(activeArea)
            activeAreaForCatapult.append(activeArea)
        }
    }
    
    func showActiveAreaForCatapult() {
        for activeArea in activeAreaForCatapult {
            activeArea.isHidden = false
        }
    }
    
    func resetActiveAreaForCatapult() {
        for activeArea in activeAreaForCatapult {
            activeArea.isHidden = true
        }
    }
    
    /* Set input board for setiing variable expression */
    func setInputBoard() {
        inputBoard = InputVariableExpression()
        addChild(inputBoard)
    }
    
    /* Throw catapult stone animation */
    func throwBomb(value: Int, setCatapult: Catapult) {
        /* Create bomb */
        let catapultBomb = SKSpriteNode(imageNamed: "catapultBomb")
        catapultBomb.size = CGSize(width: 10, height: 10)
        catapultBomb.position = setCatapult.position
        catapultBomb.zPosition = 10
        
        let waitAni = SKAction.wait(forDuration: 0.5)
        let addBomb = SKAction.run({ self.addChild(catapultBomb) })

        let throwBomb = SKAction.run({
            /* Throw beyond grid */
            if value > self.gridNode.rows {
                let duration = 4.5
                let throwStone = SKAction.moveBy(x: 0, y: CGFloat(Double(value)*self.gridNode.cellHeight)+self.bottomGap, duration: duration)
                let scale1 = SKAction.scale(by: 7.0, duration: duration/2)
                let scale2 = SKAction.scale(by: 0.5, duration: duration/2)
                let seq = SKAction.sequence([scale1, scale2])
                let group = SKAction.group([throwStone, seq])
                catapultBomb.run(group)
                
                /* Make sure to kill enemy after finishing throw animation */
                let wait = SKAction.wait(forDuration: duration+0.2)
                
                /* Remove catapult and stone */
                let removeCatapult = SKAction.run({
                    setCatapult.numOfTurn -= 1
                    catapultBomb.removeFromParent()
                    self.inputBoard.outputValue = 0
                })
                /* Move state */
                let moveState = SKAction.run({
                    self.playerTurnState = .MoveState
                    self.itemType = .None
                    self.inputBoard.isActive = false
                })
                let seq2 = SKAction.sequence([wait, removeCatapult, moveState])
                self.run(seq2)
                
                /* Miss throw */
            } else if value < 1 {
                let throwStone = SKAction.moveBy(x: 0, y: self.bottomGap+30.0, duration: 0.5)
                catapultBomb.run(throwStone)
                /* Make sure to kill enemy after finishing throw animation */
                let wait = SKAction.wait(forDuration: 0.5+0.2)
                
                /* Remove catapult and stone */
                let removeCatapult = SKAction.run({
                    setCatapult.numOfTurn -= 1
                    catapultBomb.removeFromParent()
                    self.inputBoard.outputValue = 0
                })
                /* Move state */
                let moveState = SKAction.run({
                    self.playerTurnState = .MoveState
                    self.itemType = .None
                    self.inputBoard.isActive = false
                })
                let seq2 = SKAction.sequence([wait, removeCatapult, moveState])
                self.run(seq2)
                
                /* within grid */
            } else {
                let duration = TimeInterval(value)*0.3
                let throwStone = SKAction.moveBy(x: 0, y: CGFloat(Double(value)*self.gridNode.cellHeight)+self.bottomGap, duration: duration)
                let scale1 = SKAction.scale(by: 7.0, duration: duration/2)
                let scale2 = SKAction.scale(by: 0.5, duration: duration/2)
                let seq = SKAction.sequence([scale1, scale2])
                let group = SKAction.group([throwStone, seq])
                catapultBomb.run(group)
                
                /* Make sure to kill enemy after finishing throw animation */
                let wait = SKAction.wait(forDuration: duration+0.2)
                /* Kill enemy */
                let killEnemy = SKAction.run({
                    for enemy in self.gridNode.enemyArray {
                        /* Hit enemy! */
                        if enemy.positionX == setCatapult.xPos && enemy.positionY == value-1 || enemy.positionX == setCatapult.xPos-1 && enemy.positionY == value-1 || enemy.positionX == setCatapult.xPos+1 && enemy.positionY == value-1 || enemy.positionX == setCatapult.xPos && enemy.positionY == value || enemy.positionX == setCatapult.xPos && enemy.positionY == value-2 {
                            /* Effect */
                            self.gridNode.enemyDestroyEffect(enemy: enemy)
                            
                            /* Enemy */
                            let waitEffectRemove = SKAction.wait(forDuration: 1.0)
                            let removeEnemy = SKAction.run({ enemy.removeFromParent() })
                            let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                            self.run(seqEnemy)
                            enemy.aliveFlag = false
                            /* Count defeated enemy */
                            self.totalNumOfEnemy -= 1
                        }
                    }
                })
                
                /* Effect */
                let runEffect = SKAction.run({
                    /* Load our particle effect */
                    let particles = SKEmitterNode(fileNamed: "CatapultFire")!
                    let particles2 = SKEmitterNode(fileNamed: "CatapultFire2")!
                    particles.position = CGPoint(x: catapultBomb.position.x, y: catapultBomb.position.y-20)
                    particles2.position = CGPoint(x: catapultBomb.position.x, y: catapultBomb.position.y-20)
                    /* Add particles to scene */
                    self.addChild(particles)
                    self.addChild(particles2)
                    let waitRemoveExplode = SKAction.wait(forDuration: 2.0)
                    let removeParticles = SKAction.removeFromParent()
                    let seqEffect = SKAction.sequence([waitRemoveExplode, removeParticles])
                    let seqEffect2 = SKAction.sequence([waitRemoveExplode, removeParticles])
                    particles.run(seqEffect)
                    particles2.run(seqEffect2)
                })
                
                let waitRemoveEffect = SKAction.wait(forDuration: 2.0)
                
                /* Remove bomb */
                let removeBombs = SKAction.run({
                    setCatapult.numOfTurn -= 1
                    catapultBomb.removeFromParent()
                    self.inputBoard.outputValue = 0
                })
                /* Move state */
                let moveState = SKAction.run({
                    self.playerTurnState = .MoveState
                    self.itemType = .None
                    self.inputBoard.isActive = false
                })
                let seq2 = SKAction.sequence([wait, killEnemy, runEffect, waitRemoveEffect, removeBombs, moveState])
                self.run(seq2)
            }
        })
        let seqBomb = SKAction.sequence([waitAni, addBomb, throwBomb])
        self.run(seqBomb)
    }
    
    /* Fire and remove catapult */
    func fireAndRemoveCatapult() {
        for catapult in setCatapultArray {
            let catapultValue = catapult.calculateCatapultValue()
            let catapultAni = SKAction(named: "catapult")
            catapult.run(catapultAni!)
            self.throwBomb(value: catapultValue, setCatapult: catapult)
            catapult.numOfTurn -= 1
            var waitDuration = 0.0
            /* Calculate duration to wait */
            if catapultValue > self.gridNode.rows {
                waitDuration = 7
            } else if catapultValue <= 0 {
                waitDuration = 2
            } else {
                waitDuration = Double(catapultValue)*0.3
            }
            let waitAni = SKAction.wait(forDuration: TimeInterval(waitDuration))
            let handleCatapult = SKAction.run({
                if catapult.numOfTurn <= 0 {
                    catapult.removeFromParent()
                    catapult.activeFlag = false
                }
                self.activateCatapultDone = true
            })
            let seq = SKAction.sequence([waitAni, handleCatapult])
            self.run(seq)
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
    
    /*== Magic Sword ==*/
    /* Set effect when using magic sword */
    func setMagicSowrdEffect() {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "MagicSwordEffect")!
        particles.position = activeHero.position
        particles.name = "magicSwordEffect"
        /* Add particles to scene */
        addChild(particles)
    }
    
    /* Set effect to enemy when using magic sword */
    func setMagicSowrdEffectToEnemy(enemy: Enemy) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "MagicSwordEffect")!
        particles.position = CGPoint(x: enemy.position.x+gridNode.position.x, y: enemy.position.y+gridNode.position.y)
        particles.name = "magicSwordEffectToEnemy"
        /* Add particles to scene */
        addChild(particles)
    }
    
    /* Remove effect when using magic sword */
    func removeMagicSowrdEffect() {
        if let effect = childNode(withName: "magicSwordEffect") {
            effect.removeFromParent()
        }
    }
    
    /* Remove effect of enemy when using magic sword */
    func removeMagicSowrdEffectToEnemy() {
        if let effect = childNode(withName: "magicSwordEffectToEnemy") {
            effect.removeFromParent()
        }
    }
    
    /*== Cane ==*/
    /* Set input board for setiing variable expression */
    func setInputBoardForCane() {
        inputBoardForCane = InputVariable()
        inputBoardForCane.isHidden = true
        addChild(inputBoardForCane)
    }
    
    
    /*================*/
    /*== Grid Flash ==*/
    /*================*/
    
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
    
    /*=====================*/
    /*== Game Management ==*/
    /*=====================*/
    
//    /*== Reset All Stuff ==*/
//    func resetStuff() {
//        
//    }
    
    /* Tutorial flow */
    func tutorialFlow() {
        switch Tutorial.tutorialPhase {
        case 3:
            switch tutorialState {
            case .T1:
                self.createTutorialLabel(text: "Enemies are approaching, again!!", posY: 880)
                self.createTutorialLabel(text: "Defeat all enemies!", posY: 820)
                showTouchScreen(waitTime: 2.0)
                break;
            default:
                break;
            }
            break;
        case 4:
            switch tutorialState {
            case .T1:
                self.createTutorialLabel(text: "Next, let's use item!", posY: 880)
                self.createTutorialLabel(text: "Get the time bomb", posY: 820)
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+CGFloat(gridNode.cellWidth)*7+20, y: self.gridNode.position.y+CGFloat(gridNode.cellHeight)*4+20), size: CGSize(width: 60, height: 52))
                break;
            case .T2:
                resetDiscription()
                showItemCard(item: "cardTimeBomb")
                showTouchScreen(waitTime: 3.0)
                break;
            case .T3:
                if let card = childNode(withName: "itemCard") {
                    card.removeFromParent()
                }
                self.createTutorialLabel(text: "Good!", posY: 880)
                self.createTutorialLabel(text: "You got a time bomb!", posY: 820)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T4:
                resetDiscription()
                if let card = childNode(withName: "itemCard") {
                    card.removeFromParent()
                }
                self.createTutorialLabel(text: "Touch item icon to use it!", posY: 820)
                setPointingIcon(position: CGPoint(x: self.buttonItem.position.x+55, y: self.buttonItem.position.y+65), size: CGSize(width: 60, height: 52))
                buttonAttack.isHidden = false
                buttonItem.isHidden = false
                break;
            case .T5:
                resetDiscription()
                self.createTutorialLabel(text: "Touch the time bomb icon!", posY: 820)
                setPointingIcon(position: CGPoint(x: self.itemArray[0].position.x+55, y: self.itemArray[0].position.y+65), size: CGSize(width: 60, height: 52))
                itemAreaCover.isHidden = true
                break;
            case .T6:
                resetDiscription()
                self.createTutorialLabel(text: "You can set a time bomb", posY: 880)
                self.createTutorialLabel(text: "by touching purple areas", posY: 820)
                showTouchScreen(waitTime: 2.0)
                gridNode.showtimeBombSettingArea()
                break;
            case .T7:
                resetDiscription()
                self.createTutorialLabel2(text: "Let's set a time bomb here!!",posX: self.size.width/2, posY: 900, color: UIColor.white, size: 35)
                setPointingIcon(position: CGPoint(x: self.gridNode.position.x+CGFloat(gridNode.cellWidth)*2+20, y: self.gridNode.position.y+CGFloat(gridNode.cellHeight)*7+20), size: CGSize(width: 60, height: 52))
                break;
            case .T8:
                resetDiscription()
                self.createTutorialLabel(text: "A time bomb will explode next turn!", posY: 880)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T9:
                resetDiscription()
                self.createTutorialLabel(text: "Awesome!", posY: 880)
                self.createTutorialLabel(text: "Destroyed the enemy with a time bomb!", posY: 820)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T10:
                resetDiscription()
                self.createTutorialLabel(text: "As game progresses", posY: 880)
                self.createTutorialLabel(text: "More items will show up!", posY: 820)
                showTouchScreen(waitTime: 2.0)
                break;
            case .T11:
                resetDiscription()
                self.createTutorialLabel(text: "Let's defeat left enemies!!", posY: 880)
                showTouchScreen(waitTime: 2.0)
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
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
    
    /* Show touch screen popUp */
    func showTouchScreen(waitTime: TimeInterval) {
        let wait = SKAction.wait(forDuration: waitTime)
        let show = SKAction.run({ self.touchScreenLabel.isHidden = false })
        let seq = SKAction.sequence([wait, show])
        self.run(seq)
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
    
    /* Reset stuff when moving next discription */
    func resetDiscription() {
        removeTutorial()
        self.removeAllActions()
        touchScreenLabel.isHidden = true
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
    
    /* Set item spot */
    func setItemSpot() {
        for i in 1...7 {
            for v in 0...6 {
                itemSpot.append([i, v])
            }
        }
    }
    
    /* Auto Set item */
    func autoSetItems() {
        /* Determine position to set */
        let randPos = Int(arc4random_uniform(UInt32(itemSpot.count)))
        let position = itemSpot[randPos]
        itemSpot.remove(at: randPos)
        
        /* Determine item to set */
        let rand = arc4random_uniform(100)
        if rand < 10 {
            let timeBomb = TimeBomb()
            timeBomb.spotPos = position
            self.gridNode.addObjectAtGrid(object: timeBomb, x: position[0], y: position[1])
        } else if rand < 20 {
            let battleShip = BattleShip()
            battleShip.spotPos = position
            self.gridNode.addObjectAtGrid(object: battleShip, x: position[0], y: position[1])
        } else if rand < 30 {
            let teleport = Teleport()
            teleport.spotPos = position
            self.gridNode.addObjectAtGrid(object: teleport, x: position[0], y: position[1])
        } else if rand < 40 {
            let catapult = Catapult()
            catapult.spotPos = position
            self.gridNode.addObjectAtGrid(object: catapult, x: position[0], y: position[1])
        } else if rand < 50 {
            let resetCatapult = ResetCatapult()
            resetCatapult.spotPos = position
            self.gridNode.addObjectAtGrid(object: resetCatapult, x: position[0], y: position[1])
        } else if rand < 60 {
            let magicSword = MagicSword()
            magicSword.spotPos = position
            self.gridNode.addObjectAtGrid(object: magicSword, x: position[0], y: position[1])
        } else if rand < 70 {
            let multiAttack = MultiAttack()
            multiAttack.spotPos = position
            self.gridNode.addObjectAtGrid(object: multiAttack, x: position[0], y: position[1])
        } else if rand < 80 {
            let wall = Wall()
            wall.spotPos = position
            self.gridNode.addObjectAtGrid(object: wall, x: position[0], y: position[1])
        } else if rand < 90 {
            let cane = Cane()
            cane.spotPos = position
            self.gridNode.addObjectAtGrid(object: cane, x: position[0], y: position[1])
        } else if rand < 100 {
            let heart = Heart()
            heart.spotPos = position
            self.gridNode.addObjectAtGrid(object: heart, x: position[0], y: position[1])
            
        }
    }
    
    /*== Set Life ==*/
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

    
    /*== Set initial objects ==*/
    func setInitialObj(level: Int) {
        /* Set life */
        life = maxLife
        
        switch level {
        case 0:
            /* Set enemy */
            initialEnemyPosArray = [[2, 9], [6, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set boots */
            let bootsArray = [[4,5]]
            for bootsPos in bootsArray {
                let boots = Boots()
                self.gridNode.addObjectAtGrid(object: boots, x: bootsPos[0], y: bootsPos[1])
            }
        case 1:
            /* Set enemy */
            initialEnemyPosArray = [[1, 9], [4, 9], [7, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set timeBomb */
            let timeBombsArray = [[2,3],[6,3]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
        default:
            break;
        }
    }
    
}
