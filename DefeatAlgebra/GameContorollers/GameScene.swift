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
import Fabric
import Crashlytics
import AVFoundation

enum GameSceneState {
    case AddEnemy, PlayerTurn, EnemyTurn, SignalSending, StageClear, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case DisplayPhase, ItemOn, MoveState, AttackState, UsingItem, TurnEnd, ShowingCard
}

enum ItemType {
    case None, timeBomb, Catapult, Wall, MagicSword, Teleport, ResetCatapult, Cane, EqRob
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*== Game objects ==*/
    var gridNode: Grid!
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    var pauseScreen: PauseScreen!
    var simplificationBoard: SimplificationBoard!
    var madScientistNode: SKSpriteNode!
    var eqRob: EqRob!
    var inputPanel: InputPanel!
    var selectionPanel: SelectionPanel!
    
    /*== Game labels ==*/
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    var clearLabel: SKNode!
    var levelLabel: SKLabelNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    
    /*== Game buttons ==*/
    var buttonRetry: MSButtonNode!
    var buttonNextLevel: MSButtonNode!
    var buttonPause: MSButtonNode!
    
    /*== Game constants ==*/
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    /* Game Management */
    var pauseFlag = false
    var boardActiveFlag = false
    /* Game Speed */
    let turnEndWait: TimeInterval = 1.0
    let phaseLabelTime: TimeInterval = 0.3
    /* State cotrol */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var itemType: ItemType = .None
    /* Game level */
    static var stageLevel: Int = 0
    var selectedLevel: Int?
    var moveLevel: Int = 1
    var handedItemNameArray: [String] = []
    var totalNumOfEnemy: Int = 0
    var dispClearLabelDone = false
    
    /*== Game Sounds ==*/
    var main = BGM(bgm: 0)
    var stageClear = BGM(bgm: 2)
    var gameOverSoundDone = false
    var stageClearSoundDone = false
    var hitCastleWallSoundDone = false
    
    /*===========*/
    /*== Hero ==*/
    /*===========*/
    
    /*== Hero Management ==*/
    var hero: Hero!
    var heroMovingFlag = false
    /* Hero turn */
    var playerTurnDoneFlag = false
    
    
    /*===========*/
    /*== Enemy ==*/
    /*===========*/
    
    /*== Add enemy management ==*/
    var initialEnemyPosArray = [[Int]]()
    var initialEnemyPosArrayForUnS = [[Int]]()
    var initialAddEnemyFlag = true
    
    var countTurnForAddEnemy: Int = -1
    var CompAddEnemyFlag = false
    var addEnemyDoneFlag = false
    var dupliExsist = false
    
    /*== Enemy Turn management ==*/
    var enemyTurnDoneFlag = false
    var enemyPhaseLabelDoneFlag = false
    var addEnemyManager = [[Int]]()
    
    /*===========*/
    /*== Items ==*/
    /*===========*/
    
    /*== Item Management ==*/
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    var itemSpot = [[2,1],[2,3],[2,5],[4,1],[4,5],[6,1],[6,3],[6,5]]
    var cardArray = [SKSpriteNode]()
    static var firstGetItemFlagArray: [Bool] = [true, true, false, false, false, false, false, false, false, false, false, false, false]
    /* Time bomb */
    var bombExplodeDoneFlag = false
    /* Catapult */
    var activeCatapult = Catapult()
    var setCatapultArray = [Catapult]()
    var inputBoard: InputVariableExpression!
    var activeAreaForCatapult = [SKShapeNode]()
    var setCatapultDoneFlag = false
    var catapultFireReady = false
    var catapultFirstFireFlag = false
    var catapultDoneFlag = false
    var activateCatapultDone = false
    var catapultOnceFlag = false
    var highestCatapultValue = 0
    /* Reset catapult */
    var usingResetCatapultFlag = false
    var selecttingCatapultFlag = false
    var selectCatapultDoneFlag = false
    var resettingCatapultFlag = false
    var selectedCatapult = Catapult()
    /* Magic sword */
    var magicSwordAttackDone = false
    var usingMagicSword = false
    /* timeBomb */
    var timeBombDoneFlag = false
    /* Wall */
    var wallDoneFlag = false
    /* Battle ship */
    var battleShipDoneFlag = false
    var battleShipOnceFlag = false
    /* cane */
    var inputBoardForCane: InputVariable!
    var caneOnFlag = false
    
    var eqRobTurnCountingDone = false
    
    /*================*/
    /*== Grid Flash ==*/
    /*================*/
    
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    var xValue: Int = 0 {
        didSet {
            valueOfX.text = String(xValue)
        }
    }
    var flashGridDoneFlag = false
    
    /*=================*/
    /*== Castle life ==*/
    /*=================*/
    
    var maxLife = 3
    var life: Int = 3
    
    override func didMove(to view: SKView) {
        
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        madScientistNode = childNode(withName: "madScientistNode") as! SKSpriteNode
        eqRob = childNode(withName: "eqRob") as! EqRob
        SignalController.madPos = madScientistNode.absolutePos()
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
        EqRobController.gameScene = self
        EqRobController.eqRobOriginPos = self.eqRob.absolutePos()
        SignalController.gameScene = self
        MoveTouchController.gameScene = self
        AttackTouchController.gameScene = self
        ItemTouchController.gameScene = self
        
        /* Sound */
        if MainMenu.soundOnFlag {
            main.play()
            main.numberOfLoops = -1
        }
        
        /* Labels */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        clearLabel = childNode(withName: "clearLabel")
        clearLabel.isHidden = true
        levelLabel = childNode(withName: "levelLabel") as! SKLabelNode
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonNextLevel = childNode(withName: "buttonNextLevel") as! MSButtonNode
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonNextLevel.state = .msButtonNodeStateHidden
        
        
        /* Retry button */
        buttonRetry.selectedHandler = { [weak self] in
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* Next Level button */
        buttonNextLevel.selectedHandler = { [weak self] in
            
            /* Analytics */
            Answers.logLevelEnd("Easy Level \(GameScene.stageLevel+1)",
                score: nil,
                success: true
            )
            
            /* To next stage level */
            GameScene.stageLevel += 1
            
            /* Store game property */
            DAUserDefaultUtility.SetData(gameScene: self)
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
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
        
        /*====================================================*/
        /*== Pick game property from user data and set them ==*/
        /*====================================================*/
        
        DAUserDefaultUtility.DrawData(gameScene: self)
        
        /* Debug */
        //GameScene.stageLevel = 7
        //moveLevel = 4
        //let handedItemNameArray = ["catapult", "magicSword", "cane", "timeBomb"]
        let handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        
        /* Stage Level */
        levelLabel.text = String(GameScene.stageLevel+1)
        /* Set hero */
        setHero()
        /* Items */
        for itemName in handedItemNameArray {
            displayitem(name: itemName)
        }
        
        /* Set characters */
        CharacterController.setCharacter(scene: self)
        
        /* Set input boards */
        setInputBoard()
        setInputBoardForCane()
        setSimplificationBoard()
        setInputPanel()
        setSelectionPanel()
        
        /* Set Pause screen */
        pauseScreen = PauseScreen()
        addChild(pauseScreen)
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set initial objects */
        setInitialObj(level: GameScene.stageLevel)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set each value of adding enemy management */
        addEnemyManager = EnemyProperty.addEnemyManager[GameScene.stageLevel]
        initialEnemyPosArray = EnemyProperty.initialEnemyPosArray[GameScene.stageLevel]
        initialEnemyPosArrayForUnS = EnemyProperty.initialEnemyPosArrayForUnS[GameScene.stageLevel]
        EnemyProperty.getNumOfAllEnemy(stageLevel: GameScene.stageLevel) { num in
            self.totalNumOfEnemy = num
            //print(self.totalNumOfEnemy)
        }
        
        /* Set active area for catapult */
        setActiveAreaForCatapult()
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set life */
        setLife(numOflife: maxLife)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* For debug */
        //print("\(gameState), \(playerTurnState), \(itemType)")
        
        if cardArray.count > 0 {
            gameState = .PlayerTurn
            playerTurnState = .ShowingCard
        }
        
        switch gameState {
        case .AddEnemy:
            /* Make sure to call till complete adding enemy */
            if CompAddEnemyFlag == false {
                /* Make sure to call addEnemy once */
                if addEnemyDoneFlag == false {
                    addEnemyDoneFlag = true
                    countTurnForAddEnemy += 1
                    if countTurnForAddEnemy >= addEnemyManager.count {
                        CompAddEnemyFlag = true
                        break;
                    }
                    
                    /* Add enemies initially */
                    if initialAddEnemyFlag {
                        initialAddEnemyFlag = false
                        
                        let addEnemy = SKAction.run({
                            EnemyAddController.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, enemyPosArrayForUnS: self.initialEnemyPosArrayForUnS, sVariableExpressionSource: EnemyProperty.simplifiedVariableExpressionSource[GameScene.stageLevel], uVariableExpressionSource: EnemyProperty.unSimplifiedVariableExpressionSource[GameScene.stageLevel], grid: self.gridNode)
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                            
                            /* Move to next state */
                            self.gameState = .SignalSending
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                        
                        
                        /* Add enemies in the middle of game */
                    } else if addEnemyManager[countTurnForAddEnemy][0] == 1 {
                        /* Add enemy for Education */
                        if addEnemyManager[countTurnForAddEnemy][1] == 1 {
                            let addEnemy = SKAction.run({
                                EnemyAddController.addEnemyForEdu(sVariableExpressionSource: EnemyProperty.simplifiedVariableExpressionSource[GameScene.stageLevel], uVariableExpressionSource: EnemyProperty.unSimplifiedVariableExpressionSource[GameScene.stageLevel], numOfOrigin: self.addEnemyManager[self.countTurnForAddEnemy][2], grid: self.gridNode)
                            })
                            let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                            let moveState = SKAction.run({
                                
                                /* Update enemy position */
                                EnemyMoveController.resetEnemyPositon(grid: self.gridNode)
                                EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                                
                                /* Count up to adding normal enemy time */
                                /* Move to next state */
                                self.gameState = .SignalSending
                                
                            })
                            let seq = SKAction.sequence([addEnemy, wait, moveState])
                            self.run(seq)
                            
                            /* Add enemy normaly */
                        } else if addEnemyManager[countTurnForAddEnemy][1] == 0 {
                            let addEnemy = SKAction.run({
                                EnemyAddController.addEnemyAtGrid(self.addEnemyManager[self.countTurnForAddEnemy][2], variableExpressionSource: EnemyProperty.simplifiedVariableExpressionSource[GameScene.stageLevel]+EnemyProperty.unSimplifiedVariableExpressionSource[GameScene.stageLevel] , yRange: self.addEnemyManager[self.countTurnForAddEnemy][3], grid: self.gridNode)
                            })
                            let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                            let moveState = SKAction.run({
                                /* Reset start enemy position array */
                                self.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                                
                                /* Update enemy position */
                                EnemyMoveController.resetEnemyPositon(grid: self.gridNode)
                                EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                                
                                /* Move to next state */
                                self.gameState = .SignalSending
                            })
                            let seq = SKAction.sequence([addEnemy, wait, moveState])
                            self.run(seq)
                            
                        }
                    } else {
                        /* Move to next state */
                        self.gameState = .SignalSending
                    }
                }
            } else {
                /* Move to next state */
                self.gameState = .SignalSending
            }
            break;
        case .PlayerTurn:
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
                /* For used cane */
                caneOnFlag = false
                break;
            case .ItemOn:
                playerPhaseLabel.isHidden = true
                
                /* timeBomb */
                if self.gridNode.timeBombSetArray.count > 0 {
                    if bombExplodeDoneFlag == false {
                        bombExplodeDoneFlag = true
                        /* Play Sound */
                        if MainMenu.soundOnFlag {
                            let explode = SKAction.playSoundFileNamed("timeBombExplosion.mp3", waitForCompletion: true)
                            self.run(explode)
                        }
                        for (i, timeBombPos) in self.gridNode.timeBombSetPosArray.enumerated() {
                            /* Look for the enemy to destroy  if any */
                            for enemy in self.gridNode.enemyArray {
                                /* Hit enemy! */
                                if enemy.positionX == timeBombPos[0] && enemy.positionY == timeBombPos[1] {
                                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: self) {}
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
                
                /* wall */
                if self.gridNode.wallSetArray.count > 0 {
                    for (i, wall) in self.gridNode.wallSetArray.enumerated() {
                        wall.removeFromParent()
                        if i == self.gridNode.wallSetArray.count-1 {
                            /* Reset wall array */
                            self.gridNode.wallSetArray.removeAll()
                            wallDoneFlag = true
                        }
                    }
                } else {
                    wallDoneFlag = true
                }
                
                /* battle ship */
                /* Make sure to call once */
                if battleShipOnceFlag == false {
                    battleShipOnceFlag = true
                    if self.gridNode.battleShipSetArray.count > 0 {
                        let shoot = SKAction.run({
                            for battleShip in self.gridNode.battleShipSetArray {
                                battleShip.shootBullet()
                                /* Play Sound */
                                if MainMenu.soundOnFlag {
                                    let shoot = SKAction.playSoundFileNamed("battleShipShoot.wav", waitForCompletion: true)
                                    self.run(shoot)
                                }
                                
                            }
                        })
                        let wait = SKAction.wait(forDuration: 4.0)
                        let remove = SKAction.run({
                            for (i, battleShip) in self.gridNode.battleShipSetArray.enumerated() {
                                battleShip.removeFromParent()
                                if i == self.gridNode.battleShipSetArray.count-1 {
                                    /* Reset batlle ship array */
                                    self.gridNode.battleShipSetArray.removeAll()
                                }
                            }
                        })
                        let moveState = SKAction.run({ self.battleShipDoneFlag = true })
                        let seq = SKAction.sequence([shoot, wait, remove, moveState])
                        self.run(seq)
                    } else {
                        battleShipDoneFlag = true
                    }
                }
                
                /* catapult */
                if self.setCatapultArray.count > 0 {
                    /* Make sure to call once */
                    if catapultOnceFlag == false {
                        catapultOnceFlag = true
                        detectHighestCatapultValue()
                        fireAndRemoveCatapult()
                    }
                } else {
                    activateCatapultDone = true
                }
                
                
                if timeBombDoneFlag && wallDoneFlag && battleShipDoneFlag && activateCatapultDone {
                    playerTurnState = .MoveState
                    timeBombDoneFlag = false
                    wallDoneFlag = false
                    battleShipDoneFlag = false
                    battleShipOnceFlag = false
                    bombExplodeDoneFlag = false
                    catapultOnceFlag = false
                    activateCatapultDone = false
                    highestCatapultValue = 0
                    
                    if !eqRobTurnCountingDone {
                        eqRobTurnCountingDone = true
                        if eqRob.turn > 0 {
                            eqRob.turn -= 1
                        }
                    }
                }
            case .MoveState:
                if hero.moveDoneFlag == false {
                    /* Display move area */
                    GridActiveAreaController.showMoveArea(posX: hero.positionX, posY: hero.positionY, moveLevel: hero.moveLevel, grid: self.gridNode)
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
                    GridActiveAreaController.showtimeBombSettingArea(grid: self.gridNode)
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
                            /* On First fire flag */
                            catapultFirstFireFlag = true
                        }
                        break;
                    }
                    break;
                case .Wall:
                    GridActiveAreaController.showWallSettingArea(grid: self.gridNode)
                    break;
                case .MagicSword:
                    if magicSwordAttackDone == false {
                        GridActiveAreaController.showAttackArea(posX: hero.positionX, posY: hero.positionY, grid: self.gridNode)
                    }
                    break;
                case .Teleport:
                    GridActiveAreaController.showTeleportSettingArea(grid: self.gridNode)
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
                case .EqRob:
                    break;
                }
            
                /* Wait for player touch to point position to use item at */
                break;
            case .TurnEnd:                
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                hero.moveDoneFlag = false
                hero.attackDoneFlag = false
                eqRobTurnCountingDone = false
                
                /* Remove action buttons */
                buttonAttack.isHidden = true
                buttonItem.isHidden = true
                
                /* Remove move area */
                GridActiveAreaController.resetSquareArray(color: "blue", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                
                /* Remove dead enemy from enemyArray */
                self.gridNode.enemyArray = self.gridNode.enemyArray.filter({ $0.aliveFlag == true })
                
                if gridNode.enemyArray.count > 0 {
                    gridNode.enemyArray[0].myTurnFlag = true
                }
                
                if dupliExsist {
                    dupliExsist = false
                    EnemyMoveController.rePosEnemies(enemiesArray: gridNode.enemyArray, gridNode: gridNode)
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
            
            /* Reset Flags */
            addEnemyDoneFlag = false
            playerTurnDoneFlag = false
            flashGridDoneFlag = false
            enemyPhaseLabelDoneFlag = false
            enemyPhaseLabel.isHidden = true
            
            if enemyTurnDoneFlag == false {
                
                /* Reset enemy position */
                EnemyMoveController.resetEnemyPositon(grid: self.gridNode)
                
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
                
                enemyTurnDoneFlag = true
                /* Reset all stuffs */
                gridNode.turnIndex = 0
                for enemy in gridNode.enemyArray {
                    enemy.turnDoneFlag = false
                    enemy.myTurnFlag = false
                }
                
                /* Update enemy position */
                EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                EnemyMoveController.moveDuplicatedEnemies(enemiesArray: gridNode.enemyArray) { exsist in
                    self.dupliExsist = exsist
                }
                
                /* Check if enemy reach to castle */
                for enemy in self.gridNode.enemyArray {
                    if enemy.positionY == 0 {
                        enemy.reachCastleFlag = true
                        enemy.punchIntervalForCount = 0
                    }
                }
                
                gameState = .AddEnemy
                playerTurnState = .DisplayPhase
                
            }
            break;
        case .SignalSending:
            /* Make sure to call once */
            if caneOnFlag {
                gameState = .PlayerTurn
                gridNode.numOfTurnEndEnemy = 0
                return
            } else if flashGridDoneFlag == false {
                flashGridDoneFlag = true
                gridNode.numOfTurnEndEnemy = 0
                
                
                /* Calculate each enemy's variable expression */
                let willAttackEnemies = gridNode.enemyArray.filter{ $0.state == .Attack && $0.reachCastleFlag == false }
                if willAttackEnemies.count > 0 {
                    xValue =  Int(arc4random_uniform(UInt32(3)))+1
                    for enemy in willAttackEnemies {
                        enemy.calculatePunchLength(value: xValue)
                        SignalController.send(target: enemy, num: xValue)
                    }
                    if let maxDistanceEnemy = willAttackEnemies.max(by: {$1.distance(to: madScientistNode) > $0.distance(to: madScientistNode)}) {
                        let wait = SKAction.wait(forDuration: SignalController.signalSentDuration(target: maxDistanceEnemy, xValue: self.xValue)+0.2)
                        self.run(wait, completion: {
                            self.gameState = .PlayerTurn
                        })
                    }
                } else {
                    valueOfX.text = ""
                    self.gameState = .PlayerTurn
                }
                
            }
            break;
        case .StageClear:
            GridActiveAreaController.resetSquareArray(color: "blue", grid: self.gridNode)
            /* Play Sound */
            if MainMenu.soundOnFlag {
                if stageClearSoundDone == false {
                    stageClearSoundDone = true
                    stageClear.play()
                    main.stop()
                }
            }
            clearLabel.isHidden = false
            if GameScene.stageLevel < 11 {
                buttonNextLevel.state = .msButtonNodeStateActive
            } else {
                if dispClearLabelDone == false {
                    dispClearLabelDone = true
                    createTutorialLabel(text: "Congulatulations!!", posY: 1120, size: 50)
                    createTutorialLabel(text: "You beat all stages!", posY: 1040, size: 35)
                    createTutorialLabel(text: "But keep it mind!", posY: 700, size: 35)
                    createTutorialLabel(text: "Algebra is your friend in real world!", posY: 640, size: 35)
                }
            }
            break;
            
        case .GameOver:
            gameOverLabel.isHidden = false
            /* Play Sound */
            if MainMenu.soundOnFlag {
                if gameOverSoundDone == false {
                    gameOverSoundDone = true
                    main.stop()
                    let sound = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: true)
                    self.run(sound)
                }
            }
            buttonRetry.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard pauseFlag == false else { return }
        guard boardActiveFlag == false else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        guard gameState == .PlayerTurn else { return }
        
        if nodeAtPoint.name == "eqRob" {
            guard playerTurnState == .MoveState || playerTurnState == .AttackState || playerTurnState == .UsingItem else { return }
            
            /* Hide attack and item buttons */
            buttonAttack.isHidden = true
            buttonItem.isHidden = true
            /* Reset hero */
            hero.resetHero()
            /* Remove active area */
            GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
            GridActiveAreaController.resetSquareArray(color: "purple", grid: gridNode)
            GridActiveAreaController.resetSquareArray(color: "red", grid: gridNode)
            itemAreaCover.isHidden = false
            playerTurnState = .UsingItem
            itemType = .EqRob
            
            EqRobTouchController.onEvent()
            
        } else if playerTurnState == .MoveState {
            /* Touch attack button */
            if nodeAtPoint.name == "buttonAttack" {
                MoveTouchController.buttonAttackTapped()
                
            /* Touch item button */
            } else if nodeAtPoint.name == "buttonItem" {
                MoveTouchController.buttonItemTapped()
            }
            
        /* Select attack position */
        } else if playerTurnState == .AttackState {
            /* Touch item button */
            if nodeAtPoint.name == "buttonItem" {
                AttackTouchController.buttonItemTapped()
            /* If touch anywhere but activeArea, back to MoveState  */
            } else if nodeAtPoint.name != "activeArea" {
                AttackTouchController.othersTouched()
            }
            
        /* Use item from itemArea */
        } else if playerTurnState == .UsingItem {
            /* Touch attack button */
            if nodeAtPoint.name == "buttonAttack" {
                ItemTouchController.buttonAttackTapped()
                
            /* Use timeBomb */
            } else if nodeAtPoint.name == "timeBomb" {
                ItemTouchController.timeBombTapped(touchedNode: nodeAtPoint)
                
            /*
            /* Use catapult */
            } else if nodeAtPoint.name == "catapult" {
                /* Remove active area if any */
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Remove attack and item buttons */
                buttonAttack.isHidden = true
                buttonItem.isHidden = true
                
                /* Set catapult using state */
                itemType = .Catapult
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* Use multiAttack */
            } else if nodeAtPoint.name == "multiAttack" {
                /* Remove active area if any */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Do attack animation */
                hero.setMultiSwordAttackAnimation()
                
                let hitSpotArray = checkWithinGrid()
                
                /* If hitting enemy! */
                if self.gridNode.positionEnemyAtGrid[hitSpotArray.0][hero.positionY] || self.gridNode.positionEnemyAtGrid[hitSpotArray.1][hero.positionY] || self.gridNode.positionEnemyAtGrid[hero.positionX][hitSpotArray.2] || self.gridNode.positionEnemyAtGrid[hero.positionX][hitSpotArray.3] {
                    let waitAni = SKAction.wait(forDuration: 4.0)
                    let removeEnemy = SKAction.run({
                        /* Look for the enemy to destroy */
                        for enemy in self.gridNode.enemyArray {
                            if enemy.positionX == self.hero.positionX && enemy.positionY == hitSpotArray.2 || enemy.positionX == self.hero.positionX && enemy.positionY == hitSpotArray.3 || enemy.positionX == hitSpotArray.0 && enemy.positionY == self.hero.positionY || enemy.positionX == hitSpotArray.1 && enemy.positionY == self.hero.positionY {
                                EnemyDeadController.hitEnemy(enemy: enemy, gameScene: self) {}
                            }
                        }
                    })
                    let seq = SKAction.sequence([waitAni, removeEnemy])
                    self.run(seq)
                }
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* Remove used itemIcon from item array and Scene */
                resetDisplayItem(index: usingItemIndex)
                
                /* Cover item area */
                self.itemAreaCover.isHidden = false
                
                /* Change state to MoveState */
                let wait = SKAction.wait(forDuration: 4.0)
                let moveState = SKAction.run({
                    /* Reset hero animation */
                    self.hero.resetHero()
                    self.playerTurnState = .MoveState
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                
            /* wall */
            } else if nodeAtPoint.name == "wall" {
                /* Remove activeArea */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Set timeBomb using state */
                itemType = .Wall
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* magic sword */
            } else if nodeAtPoint.name == "magicSword" {
                /* Remove activeArea */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Set timeBomb using state */
                itemType = .MagicSword
                usingMagicSword = true
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* teleport */
            } else if nodeAtPoint.name == "teleport" {
                /* Remove activeArea */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Set timeBomb using state */
                itemType = .Teleport
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* resetCatapult */
            } else if nodeAtPoint.name == "resetCatapult" {
                /* Remove activeArea */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Set resetCatapult using state */
                itemType = .ResetCatapult
                usingResetCatapultFlag = true
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* cane */
            } else if nodeAtPoint.name == "cane" {
                /* Remove activeArea */
                GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                
                /* Set timeBomb using state */
                itemType = .Cane
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
            /* Touch active area  */
            } else if nodeAtPoint.name == "activeArea" {
                /* Using catapult */
                if itemType == .Catapult {
                    
                    /* On set catapult done flag */
                    setCatapultDoneFlag = true
                    
                    /* Remove active area */
                    resetActiveAreaForCatapult()
                    
                    /* Cover item area */
                    itemAreaCover.isHidden = false
                    
                    /* Remove attack and item buttons */
                    buttonAttack.isHidden = true
                    buttonItem.isHidden = true
                    
                    /* Calculate touch x position of grid */
                    let gridX = Int(Double(location.x-gridNode.position.x)/gridNode.cellWidth)
                    
                    /* Set catpult */
                    let catapult = Catapult()
                    catapult.texture = SKTexture(imageNamed: "catapultToSet")
                    catapult.name = "catapultToSet"
                    catapult.xPos = gridX
                    catapult.zPosition = 101
                    catapult.size = CGSize(width: 62, height: 76)
                    catapult.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth)/2+CGFloat(Double(gridX)*gridNode.cellWidth), y: 256)
                    addChild(catapult)
                    setCatapultArray.append(catapult)
                    
                    /* Set Catapult base */
                    catapult.setCatapultBase()
                    
                    /* To put animation later */
                    activeCatapult = catapult
                    
                    /* Set Input board */
                    self.inputBoard.isActive = !self.inputBoard.isActive
                    
                    /* Remove used itemIcon from item array and Scene */
                    resetDisplayItem(index: usingItemIndex)
                    
                /* Using resetCatapult */
                } else if itemType == .ResetCatapult {
                    selectCatapultDoneFlag = false
                    /* Remove active area */
                    resetActiveAreaForCatapult()
                    
                    /* Calculate touch x position of grid */
                    let gridX = Int(Double(location.x-gridNode.position.x)/gridNode.cellWidth)
                    
                    /* Update x position of catapult */
                    selectedCatapult.xPos = gridX
                    
                    /* Reposition catapult */
                    selectedCatapult.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth)/2+CGFloat(Double(gridX)*gridNode.cellWidth), y: 256)
                    
                    /* Remove triangle */
                    if let node = selectedCatapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                    
                    itemType = .None
                    playerTurnState = .MoveState
                    
                }
 
            /* Reset position of catapult or Toggle input board visibility */
            } else if nodeAtPoint.name == "catapultToSet" {
                /* using resetCatapult */
                if selecttingCatapultFlag {
                    selecttingCatapultFlag = false
                    selectCatapultDoneFlag = true
                    
                    /* Cover item area */
                    itemAreaCover.isHidden = false
                    
                    /* Remove attack and item buttons */
                    buttonAttack.isHidden = true
                    buttonItem.isHidden = true
                    
                    /* Remove used itemIcon from item array and Scene */
                    resetDisplayItem(index: usingItemIndex)
                    
                    /* Remove triangle except the one of selected catapult */
                    for catapult in setCatapultArray {
                        if let node = catapult.childNode(withName: "pointingCatapult") {
                            node.removeFromParent()
                        }
                    }
                    selectedCatapult = nodeAtPoint as! Catapult
                    selectedCatapult.makeTriangle()
                    /* using catapult */
                } else if catapultFireReady == false {
                    guard itemType == .Catapult else { return }
                    self.inputBoard.isActive = !self.inputBoard.isActive
                }
            */

            /* If player touch other place than item icons, back to MoveState */
            } else {
                ItemTouchController.othersTouched()
            }
        } else if playerTurnState == .ShowingCard {
            cardArray[0].removeFromParent()
            cardArray.removeFirst()
            gameState = .EnemyTurn
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
                
                /* A is hero */
                if contactA.categoryBitMask == 1 {
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let get = SKAction.playSoundFileNamed("ItemGet.wav", waitForCompletion: true)
                        self.run(get)
                    }
                    let item = contactB.node as! SKSpriteNode
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                        if GameScene.stageLevel >= 10 {
                            let boots = item as! Boots
                            autoSetItems()
                            itemSpot.append(boots.spotPos)
                        }
                        /* Get heart */
                    } else if item.name == "heart" {
                        checkFirstItem(itemName: item.name!)
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                        if GameScene.stageLevel >= 10 {
                            let heart = item as! Heart
                            autoSetItems()
                            itemSpot.append(heart.spotPos)
                        }
                        /* Other items */
                    } else {
                        item.removeFromParent()
                        checkFirstItem(itemName: item.name!)
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                        if GameScene.stageLevel >= 10 {
                            if item.name == "timeBomb" {
                                let temp = item as! TimeBomb
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "multiAttack" {
                                let temp = item as! MultiAttack
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "wall" {
                                let temp = item as! Wall
                                itemSpot.append(temp.spotPos)
                                autoSetItems()
                            } else if item.name == "battleShip" {
                                let temp = item as! BattleShip
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "magicSword" {
                                let temp = item as! MagicSword
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "catapult" {
                                let temp = item as! Catapult
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "resetCatapult" {
                                let temp = item as! ResetCatapult
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "cane" {
                                let temp = item as! Cane
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "spear" {
                                let temp = item as! Spear
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "teleport" {
                                let temp = item as! Teleport
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "callHero" {
                                let temp = item as! CallHero
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            }
                        }
                    }
                }
                /* B is hero */
                if contactB.categoryBitMask == 1 {
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let get = SKAction.playSoundFileNamed("ItemGet.wav", waitForCompletion: true)
                        self.run(get)
                    }
                    let item = contactA.node as! SKSpriteNode
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                        if GameScene.stageLevel >= 10 {
                            let boots = item as! Boots
                            autoSetItems()
                            itemSpot.append(boots.spotPos)
                        }
                        /* Get heart */
                    } else if item.name == "heart" {
                        checkFirstItem(itemName: item.name!)
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                        if GameScene.stageLevel >= 10 {
                            //                            itemSpot.append(item.spotPos)
                            autoSetItems()
                        }
                        if GameScene.stageLevel >= 10 {
                            let heart = item as! Heart
                            autoSetItems()
                            itemSpot.append(heart.spotPos)
                        }
                        /* Other items */
                    } else {
                        item.removeFromParent()
                        checkFirstItem(itemName: item.name!)
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                        if GameScene.stageLevel >= 10 {
                            if item.name == "timeBomb" {
                                let temp = item as! TimeBomb
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "multiAttack" {
                                let temp = item as! MultiAttack
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "wall" {
                                let temp = item as! Wall
                                itemSpot.append(temp.spotPos)
                                autoSetItems()
                            } else if item.name == "battleShip" {
                                let temp = item as! BattleShip
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "magicSword" {
                                let temp = item as! MagicSword
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "catapult" {
                                let temp = item as! Catapult
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "resetCatapult" {
                                let temp = item as! ResetCatapult
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "cane" {
                                let temp = item as! Cane
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "spear" {
                                let temp = item as! Spear
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "teleport" {
                                let temp = item as! Teleport
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            } else if item.name == "callHero" {
                                let temp = item as! CallHero
                                autoSetItems()
                                itemSpot.append(temp.spotPos)
                            }
                        }
                    }
                }
                
                /* Hit enemy */
            } else {
                if contactA.categoryBitMask == 1 {
                    let hero = contactA.node as! Hero
                    hero.removeFromParent()
                    self.gameState = .GameOver
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! Hero
                    hero.removeFromParent()
                    self.gameState = .GameOver
                }
            }
        }
        
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            /* Make sure to call once at each enemy */
            if hitCastleWallSoundDone == false {
                hitCastleWallSoundDone = true
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("castleWallHit.mp3", waitForCompletion: true)
                    self.run(sound)
                }
            }
            
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
        
        /* Items set hit enemy */
        if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32 {
            
            if contactA.categoryBitMask == 32 {
                
                /* Wall stop enemy punch or move */
                if contactA.node?.name == "wall" {
                    /* Get wall */
                    let wall = contactA.node as! Wall
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let hitWall = SKAction.playSoundFileNamed("hitWall.wav", waitForCompletion: false)
                        self.run(hitWall)
                    }
                    
                    /* Enemy hits wall */
                    if contactB.categoryBitMask == 2 {
                        /* Get enemy */
                        let enemy = contactB.node as! Enemy
                        /* Stop Enemy move */
                        enemy.removeAllActions()
                        enemy.wallHitFlag = true
                        
                        /* move back according to direction of enemy */
                        switch enemy.direction {
                        case .front:
                            /* Reposition enemy */
                            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*self.gridNode.cellWidth), y: CGFloat((Double(wall.posY+1)+0.5)*self.gridNode.cellHeight)), duration: 0.5)
                            enemy.run(moveBack)
                            
                            /* Set enemy position */
                            enemy.positionY = wall.posY+1
                        case .left:
                            /* Reposition enemy */
                            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(wall.posX+1)+0.5)*self.gridNode.cellWidth), y: CGFloat((Double(wall.posY)+0.5)*self.gridNode.cellHeight)), duration: 0.5)
                            enemy.run(moveBack)
                            /* Set enemy position */
                            enemy.positionX = wall.posX+1
                            enemy.positionY = wall.posY
                        case .right:
                            /* Reposition enemy */
                            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(wall.posX-1)+0.5)*self.gridNode.cellWidth), y: CGFloat((Double(wall.posY)+0.5)*self.gridNode.cellHeight)), duration: 0.5)
                            enemy.run(moveBack)
                            /* Set enemy position */
                            enemy.positionX = wall.posX-1
                            enemy.positionY = wall.posY
                        default:
                            break;
                        }
                        
                        /* Get rid of all arms and fists */
                        let punchDone = SKAction.run({
                            enemy.removeArmNFist()
                        })
                        
                        /* Set variable expression */
                        let setVariableExpression = SKAction.run({
                            /* Reset count down punchInterval */
                            enemy.punchIntervalForCount = enemy.punchInterval
                        })
                        
                        /* Move next enemy's turn */
                        let moveTurnWait = SKAction.wait(forDuration: enemy.singleTurnDuration)
                        let moveNextEnemy = SKAction.run({
                            enemy.myTurnFlag = false
                            if self.gridNode.turnIndex < self.gridNode.enemyArray.count-1 {
                                self.gridNode.turnIndex += 1
                                self.gridNode.enemyArray[self.gridNode.turnIndex].myTurnFlag = true
                            }
                            
                            /* Reset enemy animation */
                            enemy.setMovingAnimation()
                            
                            /* To check all enemy turn done */
                            self.gridNode.numOfTurnEndEnemy += 1
                            
                        })
                        
                        /* excute drawPunch */
                        let seq = SKAction.sequence([punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
                        self.run(seq)
                        
                        /* Fist and arm hits wall */
                    } else {
                        /* Get enemy arm or fist */
                        let nodeB = contactB.node as! SKSpriteNode
                        
                        /* Stop arm and fist */
                        nodeB.removeAllActions()
                    }
                    /* bullet hit enemy */
                } else if contactA.node?.name == "bullet" {
                    let enemy = contactB.node as! Enemy
                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: self) {}
                }
                
            }
            
            if contactB.categoryBitMask == 32 {
                
                /* Wall stop enemy punch or move */
                if contactB.node?.name == "wall" {
                    /* Get wall */
                    let wall = contactB.node as! Wall
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let hitWall = SKAction.playSoundFileNamed("hitWall.wav", waitForCompletion: true)
                        self.run(hitWall)
                    }
                    
                    
                    /* Enemy hits wall */
                    if contactA.categoryBitMask == 2 {
                        /* Get enemy */
                        let enemy = contactA.node as! Enemy
                        /* Stop Enemy move */
                        enemy.removeAllActions()
                        enemy.wallHitFlag = true
                        
                        /* Reposition enemy */
                        let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*self.gridNode.cellWidth), y: CGFloat((Double(wall.posY+1)+0.5)*self.gridNode.cellHeight)), duration: 0.5)
                        enemy.run(moveBack)
                        
                        /* Get rid of all arms and fists */
                        let punchDone = SKAction.run({
                            enemy.removeArmNFist()
                        })
                        
                        /* Set variable expression */
                        let setVariableExpression = SKAction.run({
                            /* Reset count down punchInterval */
                            enemy.punchIntervalForCount = enemy.punchInterval
                        })
                        
                        /* Move next enemy's turn */
                        let moveTurnWait = SKAction.wait(forDuration: enemy.singleTurnDuration)
                        let moveNextEnemy = SKAction.run({
                            enemy.myTurnFlag = false
                            if self.gridNode.turnIndex < self.gridNode.enemyArray.count-1 {
                                self.gridNode.turnIndex += 1
                                self.gridNode.enemyArray[self.gridNode.turnIndex].myTurnFlag = true
                            }
                            
                            /* Reset enemy animation */
                            enemy.setMovingAnimation()
                            
                            /* To check all enemy turn done */
                            self.gridNode.numOfTurnEndEnemy += 1
                            
                            
                            /* Set enemy position to edge */
                            enemy.positionY = wall.posY+1
                        })
                        
                        /* excute drawPunch */
                        let seq = SKAction.sequence([punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
                        self.run(seq)
                        
                        /* Fist and arm hits wall */
                    } else {
                        /* Get enemy arm or fist */
                        let nodeA = contactA.node as! SKSpriteNode
                        
                        /* Stop arm and fist */
                        nodeA.removeAllActions()
                    }
                    /* Bullet hit enemy */
                } else if contactB.node?.name == "bullet" {
                    let enemy = contactA.node as! Enemy
                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: self) {}
                }
            }
        }
    }
    
    
    /*===========*/
    /*== Hero ==*/
    /*===========*/
    
    /*== Set initial hero ==*/
    func setHero() {
        hero = Hero()
        hero.moveLevel = moveLevel
        hero.positionX = 4
        hero.positionY = 3
        hero.position = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*4), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
        addChild(hero)
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
        itemAreaCover.zPosition = 3
        addChild(itemAreaCover)
    }
    
    /* Check it is first time to get or not */
    func checkFirstItem(itemName: String) {
        /* Store game property */
        let ud = UserDefaults.standard
        switch itemName {
        case "heart":
            if GameScene.firstGetItemFlagArray[2] == false {
                showItemCard(item: "cardHeart")
                GameScene.firstGetItemFlagArray[2] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "wall":
            if GameScene.firstGetItemFlagArray[3] == false {
                showItemCard(item: "cardWall")
                GameScene.firstGetItemFlagArray[3] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "multiAttack":
            if GameScene.firstGetItemFlagArray[4] == false {
                showItemCard(item: "cardMultiAttack")
                GameScene.firstGetItemFlagArray[4] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "battleShip":
            if GameScene.firstGetItemFlagArray[5] == false {
                showItemCard(item: "cardBattleShip")
                GameScene.firstGetItemFlagArray[5] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "catapult":
            if GameScene.firstGetItemFlagArray[6] == false {
                showItemCard(item: "cardCatapult")
                GameScene.firstGetItemFlagArray[6] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "resetCatapult":
            if GameScene.firstGetItemFlagArray[7] == false {
                showItemCard(item: "cardResetCatapult")
                GameScene.firstGetItemFlagArray[7] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "cane":
            if GameScene.firstGetItemFlagArray[8] == false {
                showItemCard(item: "cardCane")
                GameScene.firstGetItemFlagArray[8] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "magicSword":
            if GameScene.firstGetItemFlagArray[9] == false {
                showItemCard(item: "cardMagicSword")
                GameScene.firstGetItemFlagArray[9] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "teleport":
            if GameScene.firstGetItemFlagArray[10] == false {
                showItemCard(item: "cardTeleport")
                GameScene.firstGetItemFlagArray[10] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "spear":
            if GameScene.firstGetItemFlagArray[11] == false {
                showItemCard(item: "cardSpear")
                GameScene.firstGetItemFlagArray[11] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "callHero":
            if GameScene.firstGetItemFlagArray[12] == false {
                showItemCard(item: "cardCallHero")
                GameScene.firstGetItemFlagArray[12] = true
                ud.set(GameScene.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        default:
            break;
        }
    }
    
    /* Show item card when get it firstly */
    func showItemCard(item: String) {
        let card = SKSpriteNode(imageNamed: item)
        card.size = CGSize(width: 500, height: 693)
        card.position = CGPoint(x: self.size.width/2, y: self.size.height/2+100)
        cardArray.append(card)
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
    
    /* Set simplification board */
    func setSimplificationBoard() {
        simplificationBoard = SimplificationBoard()
        addChild(simplificationBoard)
    }
    
    /* Set input panel */
    func setInputPanel() {
        inputPanel = InputPanel()
        inputPanel.isHidden = true
        addChild(inputPanel)
    }
    
    /* Set input panel */
    func setSelectionPanel() {
        selectionPanel = SelectionPanel()
        selectionPanel.isHidden = true
        addChild(selectionPanel)
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
                    if self.catapultFirstFireFlag {
                        self.playerTurnState = .MoveState
                        self.catapultFirstFireFlag = false
                    }
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
                    if self.catapultFirstFireFlag {
                        self.playerTurnState = .MoveState
                        self.catapultFirstFireFlag = false
                    }
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
                            EnemyDeadController.hitEnemy(enemy: enemy, gameScene: self) {}
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
                    particles.zPosition = 3
                    particles2.zPosition = 3
                    /* Add particles to scene */
                    self.addChild(particles)
                    self.addChild(particles2)
                    let waitRemoveExplode = SKAction.wait(forDuration: 2.0)
                    let removeParticles = SKAction.removeFromParent()
                    let seqEffect = SKAction.sequence([waitRemoveExplode, removeParticles])
                    let seqEffect2 = SKAction.sequence([waitRemoveExplode, removeParticles])
                    particles.run(seqEffect)
                    particles2.run(seqEffect2)
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let explode = SKAction.playSoundFileNamed("catapultBomb.mp3", waitForCompletion: true)
                        self.run(explode)
                    }
                    
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
                    if self.catapultFirstFireFlag {
                        self.playerTurnState = .MoveState
                        self.catapultFirstFireFlag = false
                    }
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
            /* Calculate duration to wait */
            if catapultValue > self.gridNode.rows {
                let waitDuration = 5.0
                let waitAni = SKAction.wait(forDuration: TimeInterval(waitDuration))
                let handleCatapult = SKAction.run({
                    if catapult.numOfTurn <= 0 {
                        catapult.removeFromParent()
                        catapult.activeFlag = false
                    }
                    if self.highestCatapultValue == catapultValue {
                        self.activateCatapultDone = true
                    }
                })
                let seq = SKAction.sequence([waitAni, handleCatapult])
                self.run(seq)
            } else if catapultValue <= 0 {
                let waitDuration = 1.0
                let waitAni = SKAction.wait(forDuration: TimeInterval(waitDuration))
                let handleCatapult = SKAction.run({
                    if catapult.numOfTurn <= 0 {
                        catapult.removeFromParent()
                        catapult.activeFlag = false
                    }
                    if self.highestCatapultValue == catapultValue {
                        self.activateCatapultDone = true
                    }
                })
                let seq = SKAction.sequence([waitAni, handleCatapult])
                self.run(seq)
            } else {
                let waitDuration = Double(catapultValue)*0.3+2.7
                let waitAni = SKAction.wait(forDuration: TimeInterval(waitDuration))
                let handleCatapult = SKAction.run({
                    if catapult.numOfTurn <= 0 {
                        catapult.removeFromParent()
                        catapult.activeFlag = false
                        
                    }
                    if self.highestCatapultValue == catapultValue {
                        self.activateCatapultDone = true
                    }
                })
                let seq = SKAction.sequence([waitAni, handleCatapult])
                self.run(seq)
            }
        }
    }
    
    func detectHighestCatapultValue() {
        for catapult in setCatapultArray {
            let catapultValue = catapult.calculateCatapultValue()
            if highestCatapultValue < catapultValue {
                highestCatapultValue = catapultValue
            }
        }
    }
    
    /* Check within grid for catapult */
    func checkWithinGrid() -> (Int, Int, Int, Int) {
        /* Calculate hit spots */
        /* Make sure hit spots within grid */
        if hero.positionX == 0 {
            let hitSpotXLeft = 0
            let hitSpotXRight = hero.positionX+1
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else if hero.positionX == 8 {
            let hitSpotXLeft = hero.positionX-1
            let hitSpotXRight = 8
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else {
            let hitSpotXLeft = hero.positionX-1
            let hitSpotXRight = hero.positionX+1
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        }
    }
    
    /*== Magic Sword ==*/
    /* Set effect when using magic sword */
    func setMagicSowrdEffect() {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "MagicSwordEffect")!
        particles.position = hero.position
        particles.name = "magicSwordEffect"
        /* Add particles to scene */
        addChild(particles)
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let magicSword = SKAction.playSoundFileNamed("magicSword.wav", waitForCompletion: true)
            let keepPlaying = SKAction.repeatForever(magicSword)
            particles.run(keepPlaying)
        }
    }
    
    /* Set effect to enemy when using magic sword */
    func setMagicSowrdEffectToEnemy(enemy: Enemy) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "MagicSwordEffect")!
        particles.position = CGPoint(x: enemy.position.x+gridNode.position.x, y: enemy.position.y+gridNode.position.y)
        particles.name = "magicSwordEffectToEnemy"
        /* Add particles to scene */
        addChild(particles)
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let magicSword = SKAction.playSoundFileNamed("magicSword.wav", waitForCompletion: true)
            let keepPlaying = SKAction.repeatForever(magicSword)
            particles.run(keepPlaying)
        }
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
    
    /*=====================*/
    /*== Game Management ==*/
    /*=====================*/
    
    //    /*== Reset All Stuff ==*/
    //    func resetStuff() {
    //
    //    }
    
    /* Create label for tutorial */
    func createTutorialLabel(text: String, posY: CGFloat, size: CGFloat) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        /* Set text */
        label.text = text
        /* Set font size */
        label.fontSize = size
        /* Set zPosition */
        label.zPosition = 200
        /* Set position */
        label.position = CGPoint(x: self.size.width/2, y: posY)
        /* Add to Scene */
        self.addChild(label)
    }
    
    /* Auto Set item */
    func autoSetItems() {
        /* Determine position to set */
        let randPos = Int(arc4random_uniform(UInt32(itemSpot.count)))
        let position = itemSpot[randPos]
        itemSpot.remove(at: randPos)
        
        /* Determine item to set */
        let rand = arc4random_uniform(100)
        if rand < 3 {
            let boots = Boots()
            boots.spotPos = position
            self.gridNode.addObjectAtGrid(object: boots, x: position[0], y: position[1])
        } else if rand < 10 {
            let timeBomb = TimeBomb()
            timeBomb.spotPos = position
            self.gridNode.addObjectAtGrid(object: timeBomb, x: position[0], y: position[1])
        } else if rand < 15 {
            let heart = Heart()
            heart.spotPos = position
            self.gridNode.addObjectAtGrid(object: heart, x: position[0], y: position[1])
        } else if rand < 22 {
            let multiAttack = MultiAttack()
            multiAttack.spotPos = position
            self.gridNode.addObjectAtGrid(object: multiAttack, x: position[0], y: position[1])
        } else if rand < 32 {
            let wall = Wall()
            wall.spotPos = position
            self.gridNode.addObjectAtGrid(object: wall, x: position[0], y: position[1])
        } else if rand < 37 {
            let battleShip = BattleShip()
            battleShip.spotPos = position
            self.gridNode.addObjectAtGrid(object: battleShip, x: position[0], y: position[1])
        } else if rand < 55 {
            let magicSword = MagicSword()
            magicSword.spotPos = position
            self.gridNode.addObjectAtGrid(object: magicSword, x: position[0], y: position[1])
        } else if rand < 73 {
            let catapult = Catapult()
            catapult.spotPos = position
            self.gridNode.addObjectAtGrid(object: catapult, x: position[0], y: position[1])
        } else if rand < 78 {
            let resetCatapult = ResetCatapult()
            resetCatapult.spotPos = position
            self.gridNode.addObjectAtGrid(object: resetCatapult, x: position[0], y: position[1])
        } else if rand < 88 {
            let cane = Cane()
            cane.spotPos = position
            self.gridNode.addObjectAtGrid(object: cane, x: position[0], y: position[1])
        } else if rand < 93 {
            let teleport = Teleport()
            teleport.spotPos = position
            self.gridNode.addObjectAtGrid(object: teleport, x: position[0], y: position[1])
        } else if rand < 100 {
            let spear = Spear()
            spear.spotPos = position
            self.gridNode.addObjectAtGrid(object: spear, x: position[0], y: position[1])
        }
    }
    
    func autoSetInitialItems(posArray: [[Int]]) {
        
        for position in posArray {
            itemSpot = itemSpot.filter({ $0 != position })
            /* Determine item to set */
            let rand = arc4random_uniform(100)
            if rand < 3 {
                let boots = Boots()
                boots.spotPos = position
                self.gridNode.addObjectAtGrid(object: boots, x: position[0], y: position[1])
            } else if rand < 10 {
                let timeBomb = TimeBomb()
                timeBomb.spotPos = position
                self.gridNode.addObjectAtGrid(object: timeBomb, x: position[0], y: position[1])
            } else if rand < 15 {
                let heart = Heart()
                heart.spotPos = position
                self.gridNode.addObjectAtGrid(object: heart, x: position[0], y: position[1])
            } else if rand < 22 {
                let multiAttack = MultiAttack()
                multiAttack.spotPos = position
                self.gridNode.addObjectAtGrid(object: multiAttack, x: position[0], y: position[1])
            } else if rand < 32 {
                let wall = Wall()
                wall.spotPos = position
                self.gridNode.addObjectAtGrid(object: wall, x: position[0], y: position[1])
            } else if rand < 37 {
                let battleShip = BattleShip()
                battleShip.spotPos = position
                self.gridNode.addObjectAtGrid(object: battleShip, x: position[0], y: position[1])
            } else if rand < 55 {
                let magicSword = MagicSword()
                magicSword.spotPos = position
                self.gridNode.addObjectAtGrid(object: magicSword, x: position[0], y: position[1])
            } else if rand < 73 {
                let catapult = Catapult()
                catapult.spotPos = position
                self.gridNode.addObjectAtGrid(object: catapult, x: position[0], y: position[1])
            } else if rand < 78 {
                let resetCatapult = ResetCatapult()
                resetCatapult.spotPos = position
                self.gridNode.addObjectAtGrid(object: resetCatapult, x: position[0], y: position[1])
            } else if rand < 88 {
                let cane = Cane()
                cane.spotPos = position
                self.gridNode.addObjectAtGrid(object: cane, x: position[0], y: position[1])
            } else if rand < 93 {
                let teleport = Teleport()
                teleport.spotPos = position
                self.gridNode.addObjectAtGrid(object: teleport, x: position[0], y: position[1])
            } else if rand < 100 {
                let spear = Spear()
                spear.spotPos = position
                self.gridNode.addObjectAtGrid(object: spear, x: position[0], y: position[1])
            }
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
                    life.zPosition = 6
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
            /* Level 1 */
        case 0:
            /* Set boots */
            let bootsArray = [[3,3]]
            for bootsPos in bootsArray {
                let boots = Boots()
                self.gridNode.addObjectAtGrid(object: boots, x: bootsPos[0], y: bootsPos[1])
            }
            
            /* Set timeBomb */
            let timeBombsArray = [[5,3]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            /* Level 2 */
        case 1:
            /* Set boots */
            let bootsArray = [[4,6]]
            for bootsPos in bootsArray {
                let boots = Boots()
                self.gridNode.addObjectAtGrid(object: boots, x: bootsPos[0], y: bootsPos[1])
            }
            
            /* Set timeBomb */
            let timeBombsArray = [[1,3],[7,3]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            /* Set heart */
            let heartArray = [[4,1]]
            for heartPos in heartArray {
                let heart = Heart()
                self.gridNode.addObjectAtGrid(object: heart, x: heartPos[0], y: heartPos[1])
            }
            
            /* Level 3 */
        case 2:
            /* Set boots */
            let bootsArray = [[1,6],[7,6]]
            for bootsPos in bootsArray {
                let boots = Boots()
                self.gridNode.addObjectAtGrid(object: boots, x: bootsPos[0], y: bootsPos[1])
            }
            
            /* Set timeBomb */
            let timeBombsArray = [[1,3],[7,3],[2,0],[6,0]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            /* Set heart */
            let heart = Heart()
            self.gridNode.addObjectAtGrid(object: heart, x: 4, y: 6)
            
            
            /* Level 4 */
        case 3:
            
            /* Set timeBomb */
            let timeBombsArray = [[2,0],[6,0],[7,3]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            /* Set heart */
            let heart = Heart()
            self.gridNode.addObjectAtGrid(object: heart, x: 4, y: 6)
            
            /* Set wall */
            let wallsArray = [[4,0],[1,3]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set multiAttack */
            let multiAttackArray = [[3,5],[5,5]]
            for multiAttackPos in multiAttackArray {
                let multiAttack = MultiAttack()
                self.gridNode.addObjectAtGrid(object: multiAttack, x: multiAttackPos[0], y: multiAttackPos[1])
            }
            
            /* Level 5 */
        case 4:
            
            /* Set timeBomb */
            let timeBombsArray = [[4,0],[4,6],[1,3],[7,3]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            /* Set multiAttack */
            let multiAttackArray = [[3,2],[5,4],[2,5],[6,1]]
            for multiAttackPos in multiAttackArray {
                let multiAttack = MultiAttack()
                self.gridNode.addObjectAtGrid(object: multiAttack, x: multiAttackPos[0], y: multiAttackPos[1])
            }
            
            /* Set wall */
            let wallsArray = [[3,4],[5,2],[2,1],[6,5]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Level 6 */
        case 5:
            /* Set timeBomb */
            let timeBombsArray = [[4,6],[4,0]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            /* Set multiAttack */
            let multiAttackArray = [[3,5],[5,1]]
            for multiAttackPos in multiAttackArray {
                let multiAttack = MultiAttack()
                self.gridNode.addObjectAtGrid(object: multiAttack, x: multiAttackPos[0], y: multiAttackPos[1])
            }
            
            /* Set wall */
            let wallsArray = [[2,4],[6,2]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set battle ship */
            let battleShipsArray = [[1,3],[7,3]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Level 7 */
        case 6:
            /* Set multiAttack */
            let multiAttackArray = [[1,3],[7,3]]
            for multiAttackPos in multiAttackArray {
                let multiAttack = MultiAttack()
                self.gridNode.addObjectAtGrid(object: multiAttack, x: multiAttackPos[0], y: multiAttackPos[1])
            }
            
            /* Set wall */
            let wallsArray = [[2,1],[6,1]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set battle ship */
            let battleShipsArray = [[4,0]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[2,5],[6,5]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set heart */
            let heartArray = [[4,6]]
            for heartPos in heartArray {
                let heart = Heart()
                self.gridNode.addObjectAtGrid(object: heart, x: heartPos[0], y: heartPos[1])
            }
            /* Level 8 */
        case 7:
            /* Set cane */
            let caneArray = [[4,4], [4,2]]
            for canePos in caneArray {
                let cane = Cane()
                self.gridNode.addObjectAtGrid(object: cane, x: canePos[0], y: canePos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[2,1],[2,5]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set resetCatapult */
            let resetCatapultArray = [[4,0],[7,3]]
            for resetCatapultPos in resetCatapultArray {
                let resetCatapult = ResetCatapult()
                self.gridNode.addObjectAtGrid(object: resetCatapult, x: resetCatapultPos[0], y: resetCatapultPos[1])
            }
            
            
            /* Set magicSword */
            let magicSwordArray = [[6,1],[6,5],[1,3]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            /* Level 9 */
        case 8:
            /* Set catapult */
            let catapultArray = [[3,1]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set resetCatapult */
            let resetCatapultArray = [[2,2]]
            for resetCatapultPos in resetCatapultArray {
                let resetCatapult = ResetCatapult()
                self.gridNode.addObjectAtGrid(object: resetCatapult, x: resetCatapultPos[0], y: resetCatapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[5,5],[6,4]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Set teleport */
            let teleportArray = [[2,4]]
            for teleportPos in teleportArray {
                let teleport = Teleport()
                self.gridNode.addObjectAtGrid(object: teleport, x: teleportPos[0], y: teleportPos[1])
            }
            
            /* Set cane */
            let caneArray = [[3,5]]
            for canePos in caneArray {
                let cane = Cane()
                self.gridNode.addObjectAtGrid(object: cane, x: canePos[0], y: canePos[1])
            }
            
            /* Set wall */
            let wallsArray = [[5,1]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set timeBomb */
            let timeBombsArray = [[6,2]]
            for timeBombPos in timeBombsArray {
                let timeBomb = TimeBomb()
                self.gridNode.addObjectAtGrid(object: timeBomb, x: timeBombPos[0], y: timeBombPos[1])
            }
            
            
            /* Level 10 */
        case 9:
            /* Set cane */
            let caneArray = [[1,5],[4,0]]
            for canePos in caneArray {
                let cane = Cane()
                self.gridNode.addObjectAtGrid(object: cane, x: canePos[0], y: canePos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[3,4],[5,2]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[1,1],[4,6],[7,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Set teleport */
            let teleportArray = [[0,3]]
            for teleportPos in teleportArray {
                let teleport = Teleport()
                self.gridNode.addObjectAtGrid(object: teleport, x: teleportPos[0], y: teleportPos[1])
            }
            
            /* Set spear */
            let spearArray = [[7,1]]
            for spearPos in spearArray {
                let spear = Spear()
                self.gridNode.addObjectAtGrid(object: spear, x: spearPos[0], y: spearPos[1])
            }
            
            /* Set spear */
            let callHeroArray = [[8,3]]
            for callHeroPos in callHeroArray {
                let callHero = CallHero()
                self.gridNode.addObjectAtGrid(object: callHero, x: callHeroPos[0], y: callHeroPos[1])
            }
            
            /* Level 11 */
        case 10:
            /* Set initial items */
            autoSetInitialItems(posArray: [[2, 1], [2, 5], [6, 1], [6, 5]])
            
            /* Level 12 */
        case 11:
            /* Set initial items */
            autoSetInitialItems(posArray: [[2, 1], [2, 5], [6, 1], [6, 5]])
            
        default:
            break;
        }
    }
    
}

