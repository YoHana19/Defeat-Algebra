//
//  GameSceneEasy.swift
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

class GameSceneEasy: SKScene, SKPhysicsContactDelegate {
    
    /*== Game objects ==*/
    var activeHero = HeroEasy()
    var gridNode: GridEasy!
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    var pauseScreen: PauseScreenEasy!
    var simplificationBoard: SimplificationBoardEasy!
    
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
    /* Game Speed */
    let turnEndWait: TimeInterval = 1.0
    let phaseLabelTime: TimeInterval = 0.3
    /* State cotrol */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var itemType: ItemType = .None
    /* Game level */
    static var stageLevel: Int = 0
    var moveLevelArray: [Int] = [1]
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
    var heroArray = [HeroEasy]()
    var heroMovingFlag = false
    /* Hero turn */
    var numOfTurnDoneHero = 0
    var playerTurnDoneFlag = false
    
    
    /*===========*/
    /*== Enemy ==*/
    /*===========*/
    
    /*== Resource of variable expression ==*/
    /* 1st element decides which is coefficiet or constant term, last elment indicates equivarence of variable expression */
    /* 1st element 0:x+1, 1:1+x, 2:1×x, 3:x×1, 4:2x-1, 5:3-x, 6:X+1+2;2x-3+1, 7:2+1-x, 8:x+x+1;2x-x;x+x-1, 9:x+x+2+1 */
    /* 8th: 01origin, 9th: 45origin, 10th: 01to6, 11th: 45to67, 12th: 01to8, 13th: 45to8, 14th: 01to9, 15th: 45to9 */
    let variableExpressionSource = [
        [[0, 1, 0, 0]],
        [[0, 1, 0, 0]],
        [[0 ,1, 0, 0], [0, 1, 1, 1], [0, 1, 2, 2]],
        [[0, 1, 0, 0], [0, 1, 1, 1], [0, 1, 2, 2], [0, 1, 3, 3], [1, 1, 1, 1], [1, 1, 2, 2], [1, 1, 3, 3]],
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5], [2, 1, 0, 0], [2, 2, 0, 4], [2, 3, 0, 5], [3, 1, 0, 0], [3, 2, 0, 4], [3, 3, 0, 5]],
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5], [0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10], [1, 1, 1, 1], [1, 2, 1, 7], [1, 3, 1, 8], [1, 1, 2, 2], [1, 2, 2, 9], [1, 3, 2, 10]],
        [[0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10], [4, 2, 1, 11], [4, 3, 1, 12], [4, 3, 2, 13], [5, 1, 4, 14], [5, 2, 7, 15], [5, 2, 8, 16]],
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 1, 1, 1], [0, 2, 1, 7], [0, 2, 2, 9], [0, 3, 1, 8], [2, 1, 0, 0], [2, 2, 0, 4], [3, 1, 0, 0], [3, 2, 0, 4], [1, 1, 1, 1], [1, 2, 1, 7], [1, 2, 2, 9], [1, 3, 1, 8]],
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5], [0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10]],
        [[4, 2, 1, 11], [4, 3, 1, 12], [4, 3, 2, 13], [5, 1, 4, 14], [5, 2, 7, 15], [5, 2, 8, 16]],
        [[6, 1, 0, 0], [6, 2, 0, 4], [6, 3, 0, 5], [6, 1, 1, 1], [6, 2, 1, 7], [6, 3, 1, 8], [6, 1, 2, 2], [6, 2, 2, 9], [6, 3, 2, 10]],
        [[6, 2, -1, 11], [6, 3, -1, 12], [6, 3, -2, 13], [7, 1, 4, 14], [7, 2, 7, 15], [7, 2, 8, 16]],
        [[8, 1, 0, 0], [8, 2, 0, 4], [8, 3, 0, 5], [8, 1, 1, 1], [8, 2, 1, 7], [8, 3, 1, 8], [8, 1, 2, 2], [8, 2, 2, 9], [8, 3, 2, 10]],
        [[8, 2, -1, 11], [8, 3, -1, 12], [8, 3, -2, 13], [8, -1, 4, 14], [8, -2, 7, 15], [8, -2, 8, 16]],
        [[9, 1, 0, 0], [9, 2, 0, 4], [9, 3, 0, 5], [9, 1, 1, 1], [9, 2, 1, 7], [9, 3, 1, 8], [9, 1, 2, 2], [9, 2, 2, 9], [9, 3, 2, 10]],
        [[9, 2, -1, 11], [9, 3, -1, 12], [9, 3, -2, 13], [9, -1, 4, 14], [9, -2, 7, 15], [9, -2, 8, 16]]
    ]
    var variableExpressionSourceRandom = [[Int]]()
    
    /*== Add enemy management ==*/
    var initialEnemyPosArray = [[Int]]()
    var initialEnemyPosArrayForUnS = [[Int]]()
    var initialAddEnemyFlag = true
    /* [0: number of adding enemy, 1: inteval of adding enemy, 2: number of times of adding enemy, 3: range of start yPos] */
    var addEnemyManagement = [
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [4, 4, 1, 1],
        [4, 2, 3, 1],
        [4, 6, 2, 1],
        [3, 1, 5, 2],
        [4, 2, 4, 3],
        [6, 3, 3, 3],
        [5, 2, 3, 3],
        [4, 1, 3, 3],
        [5, 1, 5, 3],
        [5, 1, 5, 3]
    ]
    var numOfAddEnemy: Int = 0
    var countTurnForAddEnemy: Int = -1
    var countTurnForAddEnemyForEdu: Int = 0
    var numOfPassedTurnForEdu: Int = 0
    var addInterval: Int = 0
    var addIntervalForEdu: Int = 1
    var addYRange: Int = 0
    var countTurnForCompAddEnemy: Int = 0
    var numOfTimeAddEnemy: Int = 0
    //    var numOfTimeAddEnemyForEdu: Int = 0
    var CompAddEnemyFlag = false
    var addEnemyDoneFlag = false
    
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
    /* timeBomb */
    var timeBombDoneFlag = false
    /* Wall */
    var wallDoneFlag = false
    /* Battle ship */
    var battleShipDoneFlag = false
    var battleShipOnceFlag = false
    /* cane */
    var inputBoardForCane: InputVariableEasy!
    var caneOnFlag = false
    /* spear */
    var spearTurnCount = 0
    var checkSpearDone = false
    /* call hero */
    var callHeroCount = 0
    var callHeroCountDone = false
    var callingHero = false
    
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
        gridNode = childNode(withName: "gridNode") as! GridEasy
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
            
            /* Analytics */
            Answers.logLevelEnd("Easy Level \(GameSceneEasy.stageLevel+1)",
                score: nil,
                success: false,
                customAttributes: ["Custom String": "Retry"]
            )
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameSceneEasy(fileNamed:"GameSceneEasy") as GameSceneEasy! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameSceneEasy */
            skView?.presentScene(scene)
        }
        
        /* Next Level button */
        buttonNextLevel.selectedHandler = { [weak self] in
            
            /* Analytics */
            Answers.logLevelEnd("Easy Level \(GameSceneEasy.stageLevel+1)",
                score: nil,
                success: true
            )
            
            /* To next stage level */
            GameSceneEasy.stageLevel += 1
            
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(GameSceneEasy.stageLevel, forKey: "stageLevelEasy")
            /* Hero */
            self?.moveLevelArray = []
            for (i, hero) in (self?.heroArray.enumerated())! {
                self?.moveLevelArray.append(hero.moveLevel)
                if i == (self?.heroArray.count)!-1 {
                    ud.set(self?.moveLevelArray, forKey: "moveLevelArrayEasy")
                }
            }
            /* Items */
            var itemNameArray = [String]()
            for (i, item) in (self?.itemArray.enumerated())! {
                itemNameArray.append(item.name!)
                if i == (self?.itemArray.count)!-1 {
                    ud.set(itemNameArray, forKey: "itemNameArrayEasy")
                }
            }
            /* Life */
            ud.set(self?.maxLife, forKey: "lifeEasy")
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameSceneEasy(fileNamed:"GameSceneEasy") as GameSceneEasy! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameSceneEasy */
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
        
        let ud = UserDefaults.standard
        /* stageLevel */
        GameSceneEasy.stageLevel = ud.integer(forKey: "stageLevelEasy")
        GameSceneEasy.stageLevel = 4
        levelLabel.text = String(GameSceneEasy.stageLevel+1)
        /* Hero */
        moveLevelArray = ud.array(forKey: "moveLevelArrayEasy") as? [Int] ?? [1]
        //moveLevelArray = [4]
        /* Set hero */
        setHero()
        /* Items */
        let handedItemNameArray = ud.array(forKey: "itemNameArrayEasy") as? [String] ?? []
        //        let handedItemNameArray = ["catapult", "magicSword", "cane", "timeBomb"]
        for itemName in handedItemNameArray {
            displayitem(name: itemName)
        }
        /* Life */
        maxLife = ud.integer(forKey: "lifeEasy")
        /* For first time to install */
        if maxLife == 0 {
            maxLife = 3
        }
        /* Item flag */
        GameSceneEasy.firstGetItemFlagArray = ud.array(forKey: "firstGetItemFlagArray") as? [Bool] ?? [true, true, false, false, false, false, false, false, false, false, false, false, false]
        
        /* For Analytics */
        Answers.logLevelStart("Easy Level \(GameSceneEasy.stageLevel+1)")
        
        /* Set input boards */
        setInputBoard()
        setInputBoardForCane()
        setSimplificationBoard()
        
        /* Set Pause screen */
        pauseScreen = PauseScreenEasy()
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
        setInitialObj(level: GameSceneEasy.stageLevel)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set each value of adding enemy management */
        SetAddEnemyMng()
        addEnemyManager = EnemyProperty.addEnemyManager[GameSceneEasy.stageLevel]
        
        /* Set variable expression source form level 9 */
        setVariableExpressionFrom8()
        
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
                            self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, enemyPosArrayForUnS: self.initialEnemyPosArrayForUnS, sVariableExpressionSource: EnemyProperty.simplifiedVariableExpressionSource[GameSceneEasy.stageLevel], uVariableExpressionSource: EnemyProperty.unSimplifiedVariableExpressionSource[GameSceneEasy.stageLevel])
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            self.gridNode.updateEnemyPositon()
                            
                            /* Move to next state */
                            self.gameState = .GridFlashing
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                    
                    
                    /* Add enemies in the middle of game */
                    } else if addEnemyManager[countTurnForAddEnemy][0] == 1 {
                        /* Add enemy for Education */
                        if addEnemyManager[countTurnForAddEnemy][1] == 1 {
                            let addEnemy = SKAction.run({
                                self.gridNode.addEnemyForEdu(sVariableExpressionSource: EnemyProperty.simplifiedVariableExpressionSource[GameSceneEasy.stageLevel], uVariableExpressionSource: EnemyProperty.unSimplifiedVariableExpressionSource[GameSceneEasy.stageLevel], index: self.numOfPassedTurnForEdu)
                            })
                            let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                            let moveState = SKAction.run({
                                
                                /* Update enemy position */
                                self.gridNode.resetEnemyPositon()
                                self.gridNode.updateEnemyPositon()
                                
                                /* Count up to adding normal enemy time */
                                /* Move to next state */
                                self.gameState = .GridFlashing
                                
                            })
                            let seq = SKAction.sequence([addEnemy, wait, moveState])
                            self.run(seq)
                            
                        /* Add enemy normaly */
                        } else if addEnemyManager[countTurnForAddEnemy][0] == 0 {
                            let addEnemy = SKAction.run({
                                self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSource[GameSceneEasy.stageLevel] , yRange: self.addYRange)
                            })
                            let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                            let moveState = SKAction.run({
                                /* Reset start enemy position array */
                                self.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                                
                                /* Update enemy position */
                                self.gridNode.resetEnemyPositon()
                                self.gridNode.updateEnemyPositon()
                                
                                /* Move to next state */
                                self.gameState = .GridFlashing
                            })
                            let seq = SKAction.sequence([addEnemy, wait, moveState])
                            self.run(seq)
                            
                        }
                    } else {
                        /* Move to next state */
                        self.gameState = .GridFlashing
                    }
                }
            } else {
                /* Move to next state */
                self.gameState = .GridFlashing
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
                /* Check game over */
                if heroArray.count < 1 {
                    gameState = .GameOver
                } else {
                    /* Activate initial hero */
                    activeHero = heroArray[0]
                }
                
                playerPhaseLabel.isHidden = true
                
                /* spear */
                /* Make sure to call once */
                if checkSpearDone == false {
                    checkSpearDone = true
                    if spearTurnCount < 1 {
                        activeHero.attackType = 0
                    } else {
                        spearTurnCount -= 1
                    }
                }
                
                /* callHero */
                if callingHero {
                    /* Make sure to call once */
                    if callHeroCountDone == false {
                        callHeroCountDone = true
                        if callHeroCount < 1 {
                            
                            if heroArray.count > 1 {
                                let calledHero = heroArray.last!
                                calledHero.direction = .front
                                calledHero.setMovingAnimation()
                                calledHero.physicsBody = nil
                                let getOut = SKAction.moveTo(y: -30, duration: 3.0)
                                let wait = SKAction.wait(forDuration: 3.0)
                                let removeHero = SKAction.run({
                                    calledHero.removeFromParent()
                                    self.heroArray.removeLast()
                                })
                                let seq = SKAction.sequence([getOut, wait, removeHero])
                                calledHero.run(seq)
                            }
                            callingHero = false
                        } else {
                            callHeroCount -= 1
                        }
                    }
                }
                
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
                                    
                                    /* If you killed origin enemy */
                                    if enemy.forEduOriginFlag {
                                        EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self.gridNode)
                                        /* If you killed branch enemy */
                                    } else if enemy.forEduBranchFlag {
                                        EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self.gridNode)
                                    }
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
                            /* On First fire flag */
                            catapultFirstFireFlag = true
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
                
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                for hero in heroArray {
                    hero.attackDoneFlag = false
                    hero.moveDoneFlag = false
                }
                numOfTurnDoneHero = 0
                checkSpearDone = false
                callHeroCountDone = false
                
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
            /* Make sure to call once */
            if caneOnFlag {
                gameState = .PlayerTurn
                gridNode.numOfTurnEndEnemy = 0
                return
            } else if flashGridDoneFlag == false {
                flashGridDoneFlag = true
                
                gridNode.numOfTurnEndEnemy = 0
                
                /* Make grid flash */
                xValue = self.gridNode.flashGrid(labelNode: valueOfX)
                
                /* Calculate each enemy's variable expression */
                for enemy in self.gridNode.enemyArray {
                    enemy.calculatePunchLength(value: xValue)
                }
                
                if xValue == 3 {
                    let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)+0.7))
                    let moveState = SKAction.run({ self.gameState = .PlayerTurn })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                } else {
                    let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
                    let moveState = SKAction.run({ self.gameState = .PlayerTurn })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                }
            }
            break;
        case .StageClear:
            gridNode.resetSquareArray(color: "blue")
            /* Play Sound */
            if MainMenu.soundOnFlag {
                if stageClearSoundDone == false {
                    stageClearSoundDone = true
                    stageClear.play()
                    main.stop()
                }
            }
            clearLabel.isHidden = false
            if GameSceneEasy.stageLevel < 11 {
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
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
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
                    
                    /* Remove triangle except the one of selected catapult */
                    for catapult in setCatapultArray {
                        if let node = catapult.childNode(withName: "pointingCatapult") {
                            node.removeFromParent()
                        }
                    }
                    
                    /* Remove input board for cane */
                    inputBoardForCane.isHidden = true
                }
                
                /* Use timeBomb */
            } else if nodeAtPoint.name == "timeBomb" {
                /* Remove activeArea for catapult */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                itemType = .timeBomb
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* Use callHero */
            } else if nodeAtPoint.name == "callHero" {
                /* Remove active area if any */
                self.gridNode.resetSquareArray(color: "purple")
                self.gridNode.resetSquareArray(color: "red")
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
                
                /* Set none using state */
                itemType = .None
                
                /* Call another hero */
                addHero()
                
                /* On flag */
                callingHero = true
                callHeroCount = 3
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* Remove used itemIcon from item array and Scene */
                resetDisplayItem(index: usingItemIndex)
                
                /* Cover item area */
                self.itemAreaCover.isHidden = false
                
                /* Change state to MoveState */
                let wait = SKAction.wait(forDuration: 1.5)
                let moveState = SKAction.run({ self.playerTurnState = .MoveState })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                
                /* Use catapult */
            } else if nodeAtPoint.name == "catapult" {
                /* Remove active area if any */
                self.gridNode.resetSquareArray(color: "purple")
                self.gridNode.resetSquareArray(color: "red")
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
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                activeHero.setMultiSwordAttackAnimation()
                
                let hitSpotArray = checkWithinGrid()
                
                /* If hitting enemy! */
                if self.gridNode.positionEnemyAtGrid[hitSpotArray.0][activeHero.positionY] || self.gridNode.positionEnemyAtGrid[hitSpotArray.1][activeHero.positionY] || self.gridNode.positionEnemyAtGrid[activeHero.positionX][hitSpotArray.2] || self.gridNode.positionEnemyAtGrid[activeHero.positionX][hitSpotArray.3] {
                    let waitAni = SKAction.wait(forDuration: 4.0)
                    let removeEnemy = SKAction.run({
                        /* Look for the enemy to destroy */
                        for enemy in self.gridNode.enemyArray {
                            if enemy.positionX == self.activeHero.positionX && enemy.positionY == hitSpotArray.2 || enemy.positionX == self.activeHero.positionX && enemy.positionY == hitSpotArray.3 || enemy.positionX == hitSpotArray.0 && enemy.positionY == self.activeHero.positionY || enemy.positionX == hitSpotArray.1 && enemy.positionY == self.activeHero.positionY {
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
                    self.activeHero.resetHero()
                    self.playerTurnState = .MoveState
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                
                /* wall */
            } else if nodeAtPoint.name == "wall" {
                /* Remove activeArea */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* battle ship */
            } else if nodeAtPoint.name == "battleShip" {
                /* Remove activeArea */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                itemType = .BattleShip
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* teleport */
            } else if nodeAtPoint.name == "teleport" {
                /* Remove activeArea */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
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
                
                /* spear */
            } else if nodeAtPoint.name == "spear" {
                /* Remove activeArea */
                self.gridNode.resetSquareArray(color: "red")
                self.gridNode.resetSquareArray(color: "purple")
                resetActiveAreaForCatapult()
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                
                if self.activeHero.attackType < 1 {
                    self.activeHero.attackType += 1
                    self.spearTurnCount = 3
                }
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* Remove used itemIcon from item array and Scene */
                resetDisplayItem(index: usingItemIndex)
                
                /* Cover item area */
                self.itemAreaCover.isHidden = false
                
                /* Change state to MoveState */
                let wait = SKAction.wait(forDuration: 0.1)
                let moveState = SKAction.run({
                    /* Reset hero animation */
                    self.activeHero.resetHero()
                    self.playerTurnState = .MoveState
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                
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
                /* Remove effect */
                removeMagicSowrdEffect()
                
                /* Reset color of enemy for magic sword */
                for enemy in self.gridNode.enemyArray {
                    enemy.resetColorizeEnemy()
                }
                
                /* Remove variable expression display for magic sword */
                activeHero.removeMagicSwordVE()
                
                /* Reset item type */
                self.itemType = .None
                
                /* Remove active area */
                self.gridNode.resetSquareArray(color: "purple")
                self.gridNode.resetSquareArray(color: "red")
                resetActiveAreaForCatapult()
                
                /* Remove triangle except the one of selected catapult */
                for catapult in setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                
                /* Remove input board for cane */
                inputBoardForCane.isHidden = true
            }
        } else if playerTurnState == .ShowingCard {
            cardArray[0].removeFromParent()
            cardArray.removeFirst()
            heroArray = heroArray.filter({ $0.aliveFlag == true })
            if heroArray.count > 0{
                playerTurnState = .TurnEnd
            } else {
                gameState = .GameOver
            }
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
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
                        if GameSceneEasy.stageLevel >= 10 {
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
                        if GameSceneEasy.stageLevel >= 10 {
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
                        if GameSceneEasy.stageLevel >= 10 {
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
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
                        if GameSceneEasy.stageLevel >= 10 {
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
                        if GameSceneEasy.stageLevel >= 10 {
                            //                            itemSpot.append(item.spotPos)
                            autoSetItems()
                        }
                        if GameSceneEasy.stageLevel >= 10 {
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
                        if GameSceneEasy.stageLevel >= 10 {
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
                    let hero = contactA.node as! HeroEasy
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
                            hero.aliveFlag = false
                            self.gameState = .GameOver
                        } else {
                            /* On dead flag */
                            hero.aliveFlag = false
                            playerTurnState = .TurnEnd
                        }
                    }
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! HeroEasy
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
                            hero.aliveFlag = false
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
                        let enemy = contactB.node as! EnemyEasy
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
                            enemy.removeAllChildren()
                        })
                        
                        /* Set variable expression */
                        let setVariableExpression = SKAction.run({
                            /* Reset count down punchInterval */
                            enemy.punchIntervalForCount = enemy.punchInterval
                            //                            enemy.makeTriangle()
                            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
                        })
                        
                        /* Move next enemy's turn */
                        let moveTurnWait = SKAction.wait(forDuration: enemy.singleTurnDuration)
                        let moveNextEnemy = SKAction.run({
                            enemy.myTurnFlag = false
                            if self.gridNode.turnIndex < self.gridNode.enemyArray.count-1 {
                                self.gridNode.turnIndex += 1
                                self.gridNode.enemyArray[self.gridNode.turnIndex].myTurnFlag = true
                            }
                            
                            /* Set enemy turn interval */
                            enemy.setPunchIntervalLabel()
                            
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
                    
                    let enemy = contactB.node as! EnemyEasy
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
                    
                    /* If you killed origin enemy */
                    if enemy.forEduOriginFlag {
                        EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self.gridNode)
                        /* If you killed branch enemy */
                    } else if enemy.forEduBranchFlag {
                        EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self.gridNode)
                    }
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
                        let enemy = contactA.node as! EnemyEasy
                        /* Stop Enemy move */
                        enemy.removeAllActions()
                        enemy.wallHitFlag = true
                        
                        /* Reposition enemy */
                        let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*self.gridNode.cellWidth), y: CGFloat((Double(wall.posY+1)+0.5)*self.gridNode.cellHeight)), duration: 0.5)
                        enemy.run(moveBack)
                        
                        /* Get rid of all arms and fists */
                        let punchDone = SKAction.run({
                            enemy.removeAllChildren()
                        })
                        
                        /* Set variable expression */
                        let setVariableExpression = SKAction.run({
                            /* Reset count down punchInterval */
                            enemy.punchIntervalForCount = enemy.punchInterval
                            //                            enemy.makeTriangle()
                            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
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
                            
                            /* Set enemy turn interval */
                            enemy.setPunchIntervalLabel()
                            
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
                    
                    let enemy = contactA.node as! EnemyEasy
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
                    
                    /* If you killed origin enemy */
                    if enemy.forEduOriginFlag {
                        EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self.gridNode)
                        /* If you killed branch enemy */
                    } else if enemy.forEduBranchFlag {
                        EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self.gridNode)
                    }
                }
            }
        }
    }
    
    
    /*===========*/
    /*== Hero ==*/
    /*===========*/
    
    /*== Set initial hero ==*/
    func setHero() {
        if moveLevelArray.count == 1 {
            let hero = HeroEasy()
            hero.moveLevel = moveLevelArray[0]
            hero.positionX = 4
            hero.positionY = 3
            heroArray.append(hero)
            hero.position = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*4), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
            addChild(hero)
        } else if moveLevelArray.count == 2 {
            let heroPosArray = [[3,3],[5,3]]
            
            for (i, moveLevel) in moveLevelArray.enumerated() {
                let hero = HeroEasy()
                hero.moveLevel = moveLevel
                hero.positionX = heroPosArray[i][0]
                hero.positionY = heroPosArray[i][1]
                heroArray.append(hero)
                hero.position = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*Double(heroPosArray[i][0])), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*Double(heroPosArray[i][1])))
                addChild(hero)
            }
        }
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
    
    /* Set variable expression source form level 9 */
    func setVariableExpressionFrom8() {
        /* x+1+1 */
        if GameSceneEasy.stageLevel == 8 {
            pickVariableExpression(origin: variableExpressionSource[8], modified: variableExpressionSource[10], num: 6)
            /* 1+2-x, 2x+2-1, x+x+1 */
        } else if GameSceneEasy.stageLevel == 9 {
            pickVariableExpression(origin: variableExpressionSource[9], modified: variableExpressionSource[11], num: 3)
            pickVariableExpression(origin: variableExpressionSource[8], modified: variableExpressionSource[12], num: 3)
            /* x+x+1, x+x+1+1, 2x+x-2, 2x+x-2+1, 2-2x+x, 1+2-3x+x */
        } else if GameSceneEasy.stageLevel == 10 {
            pickVariableExpression3(origin: variableExpressionSource[8], modified1: variableExpressionSource[12], modified2: variableExpressionSource[14], num: 3)
            pickVariableExpression3(origin: variableExpressionSource[9], modified1: variableExpressionSource[13], modified2: variableExpressionSource[15], num: 3)
        } else if GameSceneEasy.stageLevel == 11 {
            variableExpressionSourceRandom = [[0, 2, 2, 9], [0, 2, 4, 17], [4, 4, 2, 18], [10, 2, 2, 9], [10, 2, 4, 17], [11, 2, 2, 9], [11, 2, 4, 17], [12, 4, -2, 18]]
        }
    }
    
    /*== Set each value of adding enemy management ==*/
    func SetAddEnemyMng() {
        numOfAddEnemy = addEnemyManagement[GameSceneEasy.stageLevel][0]
        addInterval = addEnemyManagement[GameSceneEasy.stageLevel][1]
        numOfTimeAddEnemy = addEnemyManagement[GameSceneEasy.stageLevel][2]
        addYRange = addEnemyManagement[GameSceneEasy.stageLevel][3]
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
        switch itemName {
        case "heart":
            if GameSceneEasy.firstGetItemFlagArray[2] == false {
                showItemCard(item: "cardHeart")
                GameSceneEasy.firstGetItemFlagArray[2] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "wall":
            if GameSceneEasy.firstGetItemFlagArray[3] == false {
                showItemCard(item: "cardWall")
                GameSceneEasy.firstGetItemFlagArray[3] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "multiAttack":
            if GameSceneEasy.firstGetItemFlagArray[4] == false {
                showItemCard(item: "cardMultiAttack")
                GameSceneEasy.firstGetItemFlagArray[4] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "battleShip":
            if GameSceneEasy.firstGetItemFlagArray[5] == false {
                showItemCard(item: "cardBattleShip")
                GameSceneEasy.firstGetItemFlagArray[5] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "catapult":
            if GameSceneEasy.firstGetItemFlagArray[6] == false {
                showItemCard(item: "cardCatapult")
                GameSceneEasy.firstGetItemFlagArray[6] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "resetCatapult":
            if GameSceneEasy.firstGetItemFlagArray[7] == false {
                showItemCard(item: "cardResetCatapult")
                GameSceneEasy.firstGetItemFlagArray[7] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "cane":
            if GameSceneEasy.firstGetItemFlagArray[8] == false {
                showItemCard(item: "cardCane")
                GameSceneEasy.firstGetItemFlagArray[8] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "magicSword":
            if GameSceneEasy.firstGetItemFlagArray[9] == false {
                showItemCard(item: "cardMagicSword")
                GameSceneEasy.firstGetItemFlagArray[9] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "teleport":
            if GameSceneEasy.firstGetItemFlagArray[10] == false {
                showItemCard(item: "cardTeleport")
                GameSceneEasy.firstGetItemFlagArray[10] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "spear":
            if GameSceneEasy.firstGetItemFlagArray[11] == false {
                showItemCard(item: "cardSpear")
                GameSceneEasy.firstGetItemFlagArray[11] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
            }
            break;
        case "callHero":
            if GameSceneEasy.firstGetItemFlagArray[12] == false {
                showItemCard(item: "cardCallHero")
                GameSceneEasy.firstGetItemFlagArray[12] = true
                ud.set(GameSceneEasy.firstGetItemFlagArray, forKey: "firstGetItemFlagArray")
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
        simplificationBoard = SimplificationBoardEasy()
        addChild(simplificationBoard)
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
                            
                            /* If you killed origin enemy */
                            if enemy.forEduOriginFlag {
                                EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self.gridNode)
                                /* If you killed branch enemy */
                            } else if enemy.forEduBranchFlag {
                                EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self.gridNode)
                            }
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
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let magicSword = SKAction.playSoundFileNamed("magicSword.wav", waitForCompletion: true)
            let keepPlaying = SKAction.repeatForever(magicSword)
            particles.run(keepPlaying)
        }
    }
    
    /* Set effect to enemy when using magic sword */
    func setMagicSowrdEffectToEnemy(enemy: EnemyEasy) {
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
        inputBoardForCane = InputVariableEasy()
        inputBoardForCane.isHidden = true
        addChild(inputBoardForCane)
    }
    
    /*== Call Hero ==*/
    func addHero() {
        
        /* Create hero */
        let hero = HeroEasy()
        
        /* Set moving animation */
        hero.direction = .back
        hero.setMovingAnimation()
        
        /* Hero come from castle to grid(4,0) */
        let startPosition = CGPoint(x: gridNode.position.x+gridNode.size.width/2, y: castleNode.position.y)
        
        hero.position = startPosition
        
        /* Move hero */
        let move = SKAction.moveBy(x: 0, y: CGFloat(gridNode.cellHeight)/2+bottomGap+castleNode.size.height/2, duration: 1.0)
        hero.run(move)
        
        /* Set hero position at grid */
        hero.positionX = 4
        hero.positionY = 0
        
        hero.moveLevel = 2
        
        /* Add screen and heroArray */
        addChild(hero)
        heroArray.append(hero)
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
            /* Level 1 */
        case 0:
            /* Set enemy */
            initialEnemyPosArray = [[1, 9], [4, 9], [7, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 3
            
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
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [4, 10], [7, 10], [2, 8], [6, 8]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 5
            
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
            /* Set enemy */
            initialEnemyPosArray = [[1, 11], [3, 11], [5, 11], [7, 11], [2, 9], [4, 9], [6, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            initialEnemyPosArray = [[0, 10], [2, 10], [4, 10], [6, 10], [8, 10], [3, 8], [5, 8]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            //            initialEnemyPosArray = [[1, 11], [5, 11], [1, 9], [5, 9]]
            //            initialEnemyPosArrayForUnS = [[3, 11], [7, 11], [3, 9], [7, 9]]
            
            initialEnemyPosArray = [[1, 11]]
            initialEnemyPosArrayForUnS = [[3, 11]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 15
            
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
            /* Set enemy */
            initialEnemyPosArray = [[2, 10], [6, 10], [2, 8], [6, 8], [4, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            initialEnemyPosArray = [[1, 11], [2, 10], [3, 9], [7, 11], [6, 10], [5, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            initialEnemyPosArray = [[0, 9], [1, 11], [2, 9], [3, 11], [4, 9], [5, 11], [6, 9], [7, 11], [8, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            initialEnemyPosArray = [[1, 11], [2, 9], [1, 7], [4, 9], [6, 9], [7, 11], [7, 7]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
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
            /* Set enemy */
            initialEnemyPosArray = [[0, 11], [0, 7], [2, 10], [2, 8], [6, 10], [6, 8], [8, 7], [8, 11]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
            
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
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
            /* Set initial items */
            autoSetInitialItems(posArray: [[2, 1], [2, 5], [6, 1], [6, 5]])
            
            /* Level 12 */
        case 11:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = 20
            
            /* Set initial items */
            autoSetInitialItems(posArray: [[2, 1], [2, 5], [6, 1], [6, 5]])
            
        default:
            break;
        }
    }
    
}

