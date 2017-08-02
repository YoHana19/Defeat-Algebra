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
 32: setItems - wall-26(2,8,16), bullet-2
 64: getItems(Boots,timeBomb,Heart,callHero,catapult,multiAttack, battleShip) - 1
 128:
 1024:
 */

import SpriteKit
import GameplayKit

enum GameSceneState {
    case AddEnemy, PlayerTurn, EnemyTurn, GridFlashing, StageClear, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case DisplayPhase, ItemOn, MoveState, AttackState, UsingItem, TurnEnd
}

enum ItemType {
    case None, timeBomb, Catapult, Wall, MagicSword, BattleShip, Teleport
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*== Game objects ==*/
    var activeHero = Hero()
    var gridNode: Grid!
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    
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
    var buttonToL1: MSButtonNode!
    
    /*== Game constants ==*/
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    /* Game Management */
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
    var heroArray = [Hero]()
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
    var initialAddEnemyFlag = true
    /* [0: number of adding enemy, 1: inteval of adding enemy, 2: number of times of adding enemy] */
    var addEnemyManagement = [
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [4, 4, 1, 1],
        [4, 2, 3, 1],
        [3, 3, 2, 1],
        [3, 1, 5, 2],
        [4, 2, 4, 3],
        [6, 3, 3, 3],
        [5, 2, 3, 3],
        [4, 1, 3, 3],
        [4, 1, 3, 3],
        [4, 1, 3, 3]
    ]
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
    /* Catapult */
    var setCatapult = Catapult()
    var inputBoard: InputVariableExpression!
    var vELabel: SKLabelNode!
    var activeAreaForCatapult = [SKShapeNode]()
    var catapultXPos: Int = 0
    var setCatapultDoneFlag = false
    var catapultFireReady = false
    var catapultDoneFlag = false
    /* Magic sword */
    var magicSwordAttackDone = false
    /* timeBomb */
    var timeBombDoneFlag = false
    /* Wall */
    var wallDoneFlag = false
    /* Battle ship */
    var battleShipDoneFlag = false
    var battleShipOnceFlag = false
    
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
    
    var lifeLabel: SKLabelNode!
    var maxLife = 3
    var life: Int = 3 {
        willSet {
            lifeLabel.text = String(life)
        }
        didSet {
            lifeLabel.text = String(life)
        }
    }
    
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
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
        buttonToL1 = childNode(withName: "buttonToL1") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonNextLevel.state = .msButtonNodeStateHidden
        buttonToL1.state = .msButtonNodeStateHidden
        
        
        /* Retry button */
        buttonRetry.selectedHandler = {
            
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
        
        /* Next Level button */
        buttonNextLevel.selectedHandler = {
            /* To next stage level */
            self.stageLevel += 1
            
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(self.stageLevel, forKey: "stageLevel")
            /* Hero */
            self.moveLevelArray = []
            for (i, hero) in self.heroArray.enumerated() {
                self.moveLevelArray.append(hero.moveLevel)
                if i == self.heroArray.count-1 {
                    ud.set(self.moveLevelArray, forKey: "moveLevelArray")
                }
            }
            /* Items */
            var itemNameArray = [String]()
            for (i, item) in self.itemArray.enumerated() {
                itemNameArray.append(item.name!)
                if i == self.itemArray.count-1 {
                    ud.set(itemNameArray, forKey: "itemNameArray")
                }
            }
            /* Life */
            ud.set(self.maxLife, forKey: "life")
            
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
        
        /* Back to Level 1 button */
        buttonToL1.selectedHandler = {
            /* To next stage level */
            self.stageLevel = 0
            
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(self.stageLevel, forKey: "stageLevel")
            /* Hero */
            self.moveLevelArray = [1]
            ud.set(self.moveLevelArray, forKey: "moveLevelArray")
            /* item */
            let itemNameArray = [String]()
            ud.set(itemNameArray, forKey: "itemNameArray")
            /* life */
            ud.set(3, forKey: "life")
            
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
        
        /* Pick game property from user data and set them */
        let ud = UserDefaults.standard
        /* stageLevel */
        stageLevel = ud.integer(forKey: "stageLevel")
        levelLabel.text = String(stageLevel+1)
        /* Hero */
        moveLevelArray = ud.array(forKey: "moveLevelArray") as? [Int] ?? [1]
        /* Set hero */
        setHero()
        /* Items */
        let handedItemNameArray = ud.array(forKey: "itemNameArray") as? [String] ?? []
        print(handedItemNameArray)
        for itemName in handedItemNameArray {
            displayitem(name: itemName)
        }
        /* Life */
        maxLife = ud.integer(forKey: "life")
        /* For first time to install */
        if maxLife == 0 {
            maxLife = 3
        }
        
        /* Set input board */
        setInputBoard()
        
        
        /* For testing: initialize userDefaults */
        /* Store game property */
        //        let ud = UserDefaults.standard
        //        /* Stage level */
        //        ud.set(0, forKey: "stageLevel")
        //        /* Hero */
        //        ud.set([1], forKey: "moveLevelArray")
        //        /* item */
        //        ud.set([], forKey: "itemNameArray")
        //        /* life */
        //        ud.set(5, forKey: "life")
        
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Score label */
        lifeLabel = childNode(withName: "lifeLabel") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set initial objects */
        setInitialObj(level: self.stageLevel)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set each value of adding enemy management */
        SetAddEnemyMng()
        
        /* Set variable expression source form level 9 */
        setVariableExpressionFrom8()
        
        /* Set active area for catapult */
        setActiveAreaForCatapult()
        
        /* For magic sword */
        setMagicSwordVE()
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        
        /* Check available fonts */
        //        for family in UIFont.familyNames {
        //            print("Font family name: \(family)")
        //            for fontName in UIFont.fontNames(forFamilyName: family) {
        //                print("    > Font name: \(fontName)")
        //            }
        //        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            //                        print("AddEnemy")
            /* Make sure to call till complete adding enemy */
            if CompAddEnemyFlag == false {
                /* Make sure to call addEnemy once */
                if addEnemyDoneFlag == false {
                    addEnemyDoneFlag = true
                    
                    /* Initial add or add on the way */
                    if initialAddEnemyFlag {
                        initialAddEnemyFlag = false
                        
                        /* Add enemy */
                        let addEnemy = SKAction.run({
                            if self.stageLevel < 8 {
                                self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSource[self.stageLevel])
                            } else {
                                self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSourceRandom)
                            }
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            self.gridNode.updateEnemyPositon()
                            
                            /* Move to next state */
                            self.gameState = .GridFlashing
                            
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                        
                        /* The time to add enemy */
                    } else if countTurnForAddEnemy == addInterval {
                        /* Add enemy */
                        let addEnemy = SKAction.run({
                            if self.stageLevel < 8 {
                                self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSource[self.stageLevel] , yRange: self.addYRange)
                            } else {
                                self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSourceRandom, yRange: self.addYRange)
                            }
                            
                        })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                        let moveState = SKAction.run({
                            /* Reset start enemy position array */
                            self.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                            
                            /* Update enemy position */
                            self.gridNode.resetEnemyPositon()
                            self.gridNode.updateEnemyPositon()
                            //                            print(self.gridNode.positionEnemyAtGrid)
                            
                            /* Count up to complete adding enemy */
                            self.countTurnForCompAddEnemy += 1
                            
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                            
                            /* Move to next state */
                            self.gameState = .GridFlashing
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                        /* Reset countTurnForAddEnemy */
                        countTurnForAddEnemy = 0
                        
                    } else {
                        /* Count up to adding enemy time */
                        countTurnForAddEnemy += 1
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
                    for (i, timeBombPos) in self.gridNode.timeBombSetPosArray.enumerated() {
                        /* Look for the enemy to destroy  if any */
                        for enemy in self.gridNode.enemyArray {
                            /* Hit enemy! */
                            if enemy.positionX == timeBombPos[0] && enemy.positionY == timeBombPos[1] {
                                enemy.aliveFlag = false
                                enemy.removeFromParent()
                                /* Count defeated enemy */
                                totalNumOfEnemy -= 1
                            }
                        }
                        if i == self.gridNode.timeBombSetArray.count-1 {
                            /* Reset timeBomb array */
                            self.gridNode.timeBombSetPosArray.removeAll()
                            for (i, timeBomb) in self.gridNode.timeBombSetArray.enumerated() {
                                timeBomb.removeFromParent()
                                if i == self.gridNode.timeBombSetArray.count-1 {
                                    /* Reset itemSet arrays */
                                    self.gridNode.timeBombSetArray.removeAll()
                                    timeBombDoneFlag = true
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
                            }
                        })
                        let wait = SKAction.wait(forDuration: 4.0)
                        let remove = SKAction.run({
                            for (i, battleShip) in self.gridNode.battleShipSetArray.enumerated() {
                                battleShip.removeFromParent()
                                if i == self.gridNode.battleShipSetArray.count-1 {
                                    /* Reset wall array */
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
                
                if timeBombDoneFlag && wallDoneFlag && battleShipDoneFlag {
                    playerTurnState = .MoveState
                    timeBombDoneFlag = false
                    wallDoneFlag = false
                    battleShipDoneFlag = false
                    battleShipOnceFlag = false
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
                            setCatapult.run(catapultAni!)
                            /* Create stone */
                            let catapultStone = SKSpriteNode(imageNamed: "stone")
                            catapultStone.size = CGSize(width: 45, height: 45)
                            catapultStone.position = setCatapult.position
                            catapultStone.zPosition = 10
                            addChild(catapultStone)
                            /* Throw stone */
                            throwStone(obj: catapultStone, value: inputBoard.outputValue)
                            
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
            gridNode.resetSquareArray(color: "blue")
            clearLabel.isHidden = false
            buttonNextLevel.state = .msButtonNodeStateActive
            break;
            
        case .GameOver:
            gameOverLabel.isHidden = false
            buttonRetry.state = .msButtonNodeStateActive
            buttonToL1.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print("scene touchBegan")
        
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
                }
                
                /* Use timeBomb */
            } else if nodeAtPoint.name == "timeBomb" {
                /* Remove activeArea for catapult */
                self.gridNode.resetSquareArray(color: "red")
                resetActiveAreaForCatapult()
                
                /* Set timeBomb using state */
                itemType = .timeBomb
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                //                print("Now item index is \(usingItemIndex)")
                /* Use callHero */
            } else if nodeAtPoint.name == "callHero" {
                /* Remove active area if any */
                self.gridNode.resetSquareArray(color: "purple")
                self.gridNode.resetSquareArray(color: "red")
                resetActiveAreaForCatapult()
                
                /* Set none using state */
                itemType = .None
                
                /* Call another hero */
                addHero()
                
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
                self.gridNode.resetSquareArray(color: "purple")
                resetActiveAreaForCatapult()
                
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
                                enemy.aliveFlag = false
                                enemy.removeFromParent()
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
                resetActiveAreaForCatapult()
                
                /* Set timeBomb using state */
                itemType = .Wall
                
                /* Get index of game using */
                usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                
                /* magic sword */
            } else if nodeAtPoint.name == "magicSword" {
                /* Remove activeArea */
                self.gridNode.resetSquareArray(color: "red")
                resetActiveAreaForCatapult()
                
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
                
                /* Set timeBomb using state */
                itemType = .Teleport
                
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
                    
                    /* Stor x position */
                    catapultXPos = gridX
                    
                    /* Set Catapult base */
                    let catapultBase = SKSpriteNode(imageNamed: "catapultBase")
                    catapultBase.name = "catapultBase"
                    catapultBase.zPosition = 100
                    catapultBase.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth)/2+CGFloat(Double(gridX)*gridNode.cellWidth), y: 236)
                    addChild(catapultBase)
                    
                    /* Set catpult */
                    setCatapult = Catapult()
                    setCatapult.texture = SKTexture(imageNamed: "catapultToSet")
                    setCatapult.name = "catapultToSet"
                    setCatapult.zPosition = 101
                    setCatapult.size = CGSize(width: 62, height: 76)
                    setCatapult.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth)/2+CGFloat(Double(gridX)*gridNode.cellWidth), y: 256)
                    addChild(setCatapult)
                    
                    /* Set Input board */
                    self.inputBoard.isActive = !self.inputBoard.isActive
                    
                    /* Remove used itemIcon from item array and Scene */
                    resetDisplayItem(index: usingItemIndex)
                    
                }
                /* Toggle input board visibility */
            } else if nodeAtPoint.name == "catapultToSet" {
                guard catapultFireReady == false else { return }
                self.inputBoard.isActive = !self.inputBoard.isActive
                
                /* If player touch other place than item icons, back to MoveState */
            } else {
                guard setCatapultDoneFlag == false else { return }
                
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
                resetActiveAreaForCatapult()
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
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
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
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 8 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                    }
                }
                
                /* Be hitten by enemy */
            } else {
                if contactA.categoryBitMask == 1 {
                    let hero = contactA.node as! Hero
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
            //            print("cate 4 hit")
            
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
        
        /* Items set hit enemy */
        if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32 {
            
            if contactA.categoryBitMask == 32 {
                
                /* Wall stop enemy punch or move */
                if contactA.node?.name == "wall" {
                    /* Get wall */
                    let wall = contactA.node as! Wall
                    
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
                    print("bullet hit")
                    let enemy = contactB.node as! Enemy
                    enemy.aliveFlag = false
                    enemy.removeFromParent()
                    /* Count defeated enemy */
                    totalNumOfEnemy -= 1
                }
                
            }
            
            if contactB.categoryBitMask == 32 {
                
                /* Wall stop enemy punch or move */
                if contactB.node?.name == "wall" {
                    /* Get wall */
                    let wall = contactB.node as! Wall
                    
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
                    print("bullet hit")
                    let enemy = contactA.node as! Enemy
                    enemy.aliveFlag = false
                    enemy.removeFromParent()
                    /* Count defeated enemy */
                    totalNumOfEnemy -= 1
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
            let hero = Hero()
            hero.moveLevel = moveLevelArray[0]
            hero.positionX = 4
            hero.positionY = 3
            heroArray.append(hero)
            hero.position = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*4), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
            addChild(hero)
        } else if moveLevelArray.count == 2 {
            let heroPosArray = [[3,3],[5,3]]
            
            for (i, moveLevel) in moveLevelArray.enumerated() {
                let hero = Hero()
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
        if stageLevel == 8 {
            pickVariableExpression(origin: variableExpressionSource[8], modified: variableExpressionSource[10], num: 6)
            /* 1+2-x, 2x+2-1, x+x+1 */
        } else if stageLevel == 9 {
            pickVariableExpression(origin: variableExpressionSource[9], modified: variableExpressionSource[11], num: 3)
            pickVariableExpression(origin: variableExpressionSource[8], modified: variableExpressionSource[12], num: 3)
            /* x+x+1, x+x+1+1, 2x+x-2, 2x+x-2+1, 2-2x+x, 1+2-3x+x */
        } else if stageLevel == 10 {
            pickVariableExpression3(origin: variableExpressionSource[8], modified1: variableExpressionSource[12], modified2: variableExpressionSource[14], num: 3)
            pickVariableExpression3(origin: variableExpressionSource[9], modified1: variableExpressionSource[13], modified2: variableExpressionSource[15], num: 3)
        } else if stageLevel == 11 {
            variableExpressionSourceRandom = [[0, 2, 2, 9], [0, 2, 4, 17], [4, 4, 2, 18], [10, 2, 2, 9], [10, 2, 4, 17], [11, 2, 2, 9], [11, 2, 4, 17], [12, 4, -2, 18]]
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
    func throwStone(obj: SKSpriteNode, value: Int) {
        /* Throw beyond grid */
        if value > self.gridNode.rows {
            let duration = 4.5
            let throwStone = SKAction.moveBy(x: 0, y: CGFloat(Double(value)*self.gridNode.cellHeight)+self.bottomGap, duration: duration)
            let scale1 = SKAction.scale(by: 2.0, duration: duration/2)
            let scale2 = SKAction.scale(by: 0.5, duration: duration/2)
            let seq = SKAction.sequence([scale1, scale2])
            let group = SKAction.group([throwStone, seq])
            obj.run(group)
            
            /* Make sure to kill enemy after finishing throw animation */
            let wait = SKAction.wait(forDuration: duration+0.2)
            
            /* Remove catapult and stone */
            let removeCatapult = SKAction.run({
                self.setCatapult.isHidden = true
                obj.removeFromParent()
                if let catapultBase = self.childNode(withName: "catapultBase") {
                    catapultBase.removeFromParent()
                }
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
            obj.run(throwStone)
            /* Make sure to kill enemy after finishing throw animation */
            let wait = SKAction.wait(forDuration: 0.5+0.2)
            
            /* Remove catapult and stone */
            let removeCatapult = SKAction.run({
                self.setCatapult.isHidden = true
                if let catapultBase = self.childNode(withName: "catapultBase") {
                    catapultBase.removeFromParent()
                }
                obj.removeFromParent()
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
            
            /* no problem */
        } else {
            let duration = TimeInterval(value)*0.3
            let throwStone = SKAction.moveBy(x: 0, y: CGFloat(Double(value)*self.gridNode.cellHeight)+self.bottomGap, duration: duration)
            let scale1 = SKAction.scale(by: 2.0, duration: duration/2)
            let scale2 = SKAction.scale(by: 0.5, duration: duration/2)
            let seq = SKAction.sequence([scale1, scale2])
            let group = SKAction.group([throwStone, seq])
            obj.run(group)
            
            /* Make sure to kill enemy after finishing throw animation */
            let wait = SKAction.wait(forDuration: duration+0.2)
            /* Kill enemy */
            let killEnemy = SKAction.run({
                for enemy in self.gridNode.enemyArray {
                    /* Hit enemy! */
                    if enemy.positionX == self.catapultXPos && enemy.positionY == self.inputBoard.outputValue-1 || enemy.positionX == self.catapultXPos-1 && enemy.positionY == self.inputBoard.outputValue-1 || enemy.positionX == self.catapultXPos+1 && enemy.positionY == self.inputBoard.outputValue-1 || enemy.positionX == self.catapultXPos && enemy.positionY == self.inputBoard.outputValue || enemy.positionX == self.catapultXPos && enemy.positionY == self.inputBoard.outputValue-2 {
                        enemy.aliveFlag = false
                        enemy.removeFromParent()
                        /* Count defeated enemy */
                        self.totalNumOfEnemy -= 1
                    }
                }
            })
            
            /* Remove catapult and stone */
            let removeCatapult = SKAction.run({
                self.setCatapult.isHidden = true
                if let catapultBase = self.childNode(withName: "catapultBase") {
                    catapultBase.removeFromParent()
                }
                obj.removeFromParent()
                self.inputBoard.outputValue = 0
            })
            /* Move state */
            let moveState = SKAction.run({
                self.playerTurnState = .MoveState
                self.itemType = .None
                self.inputBoard.isActive = false
            })
            let seq2 = SKAction.sequence([wait, killEnemy, removeCatapult, moveState])
            self.run(seq2)
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
    
    /*== Call Hero ==*/
    func addHero() {
        
        /* Create hero */
        let hero = Hero()
        
        /* Set moving animation */
        hero.direction = .back
        hero.setMovingAnimation()
        
        /* Hero come from castle to grid(4,0) */
        let startPosition = CGPoint(x: gridNode.position.x+gridNode.size.width/2, y: castleNode.position.y)
        print(startPosition)
        hero.position = startPosition
        
        /* Move hero */
        let move = SKAction.moveBy(x: 0, y: CGFloat(gridNode.cellHeight)/2+bottomGap+castleNode.size.height/2, duration: 1.0)
        hero.run(move)
        print("hero position is \(hero.position)")
        
        /* Set hero position at grid */
        hero.positionX = 4
        hero.positionY = 0
        
        /* Add screen and heroArray */
        addChild(hero)
        heroArray.append(hero)
    }
    
    /*== Magic Sword ==*/
    /* Display variable expression you attack when using magic sword */
    func setMagicSwordVE() {
        /* label of variable expresion */
        vELabel = SKLabelNode(fontNamed: "GillSans-Bold")
        vELabel.text = "0"
        vELabel.fontSize = 96
        vELabel.position = CGPoint(x: self.size.width/2, y: 170)
        vELabel.zPosition = 20
        vELabel.isHidden = true
        addChild(vELabel)
    }
    func dispMagicSwordVE(vE: String) {
        vELabel.text = vE
        vELabel.isHidden = false
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
    
    /*== Set initial objects ==*/
    func setInitialObj(level: Int) {
        /* Set life */
        life = maxLife
        
        switch level {
            /* Level 1 */
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
            
            /* Level 2 */
        case 1:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [4, 10], [7, 10], [2, 8], [6, 8]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set boots */
            let bootsArray = [[4,5]]
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
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
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
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
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
            initialEnemyPosArray = [[1, 11], [3, 11], [5, 11], [7, 11], [1, 9], [3, 9], [5, 9], [7, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
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
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
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
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set multiAttack */
            let multiAttackArray = [[1,3],[7,3]]
            for multiAttackPos in multiAttackArray {
                let multiAttack = MultiAttack()
                self.gridNode.addObjectAtGrid(object: multiAttack, x: multiAttackPos[0], y: multiAttackPos[1])
            }
            
            /* Set wall */
            let wallsArray = [[2,1],[7,1]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set battle ship */
            let battleShipsArray = [[4,6]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[4,0],[2,5],[6,5]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set heart */
            let heartArray = [[3,2],[5,4]]
            for heartPos in heartArray {
                let heart = Heart()
                self.gridNode.addObjectAtGrid(object: heart, x: heartPos[0], y: heartPos[1])
            }
            /* Level 8 */
        case 7:
            /* Set enemy */
            initialEnemyPosArray = [[1, 11], [2, 9], [4, 7], [6, 9], [8, 11]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set wall */
            let wallsArray = [[1,3]]
            for wallPos in wallsArray {
                let wall = Wall()
                self.gridNode.addObjectAtGrid(object: wall, x: wallPos[0], y: wallPos[1])
            }
            
            /* Set battle ship */
            let battleShipsArray = [[7,3]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[6,1],[2,5]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[2,1],[6,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            /* Level 9 */
        case 8:
            /* Set enemy */
            initialEnemyPosArray = [[0, 9], [1, 11], [2, 9], [3, 11], [4, 9], [5, 11], [6, 9], [7, 11], [8, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set battle ship */
            let battleShipsArray = [[4,0]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[6,2],[6,4]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[2,2],[2,4],[4,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Level 10 */
        case 9:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [2, 8], [4, 10], [5, 8], [6, 10]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set battle ship */
            let battleShipsArray = [[4,0]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[6,2],[6,4]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[2,2],[2,4],[4,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Set teleport */
            let teleportArray = [[4,1]]
            for teleportPos in teleportArray {
                let teleport = Teleport()
                self.gridNode.addObjectAtGrid(object: teleport, x: teleportPos[0], y: teleportPos[1])
            }
            /* Level 11 */
        case 10:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [2, 8], [4, 10], [5, 8], [6, 10]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set battle ship */
            let battleShipsArray = [[4,0]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[6,2],[6,4]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[2,2],[2,4],[4,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Set teleport */
            let teleportArray = [[4,1]]
            for teleportPos in teleportArray {
                let teleport = Teleport()
                self.gridNode.addObjectAtGrid(object: teleport, x: teleportPos[0], y: teleportPos[1])
            }
            /* Level 12 */
        case 11:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [2, 8], [4, 10], [5, 8], [6, 10]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set battle ship */
            let battleShipsArray = [[4,0]]
            for battleShipPos in battleShipsArray {
                let battleShip = BattleShip()
                self.gridNode.addObjectAtGrid(object: battleShip, x: battleShipPos[0], y: battleShipPos[1])
            }
            
            /* Set catapult */
            let catapultArray = [[6,2],[6,4]]
            for catapultPos in catapultArray {
                let catapult = Catapult()
                self.gridNode.addObjectAtGrid(object: catapult, x: catapultPos[0], y: catapultPos[1])
            }
            
            /* Set magicSword */
            let magicSwordArray = [[2,2],[2,4],[4,5]]
            for magicSwordPos in magicSwordArray {
                let magicSword = MagicSword()
                self.gridNode.addObjectAtGrid(object: magicSword, x: magicSwordPos[0], y: magicSwordPos[1])
            }
            
            /* Set teleport */
            let teleportArray = [[4,1]]
            for teleportPos in teleportArray {
                let teleport = Teleport()
                self.gridNode.addObjectAtGrid(object: teleport, x: teleportPos[0], y: teleportPos[1])
            }
            
        default:
            break;
        }
    }
    
    
}
