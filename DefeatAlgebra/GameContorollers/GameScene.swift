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
    case AddEnemy, AddItem, PlayerTurn, EnemyTurn, SignalSending, StageClear, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case DisplayPhase, ItemOn, MoveState, AttackState, UsingItem, TurnEnd
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
    var inputPanelForCannon: InputPanelForCannon!
    var plane: Plane!
    
    /*== Game labels ==*/
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
    
    var isCharactersTurn = false
    var countTurn = 0
    var countTurnDone = false
    var tutorialState: TutorialState = .Action
    
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
    var initialAddEnemyFlag = true
    var compAddEnemyFlag = false
    var countTurnForAddEnemy: Int = -1
    var dupliExsist = false
    
    /*== Enemy Turn management ==*/
    var enemyTurnDoneFlag = false
    var enemyPhaseLabelDoneFlag = false
    var addEnemyManager = [[Int]]()
    
    /*===========*/
    /*== Items ==*/
    /*===========*/
    
    /*== Add item management ==*/
    var initialAddItemFlag = true
    var compAddItemFlag = false
    var countTurnForAddItem: Int = -1
    
    /*== Item Management ==*/
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    var itemSpot = [[2,1],[2,3],[2,5],[4,1],[4,5],[6,1],[6,3],[6,5]]
    
    /* Time bomb */
    var bombExplodeDoneFlag = false
    var timeBombDoneFlag = false
    /* cane */
    var inputBoardForCane: InputVariable!
    var caneOnFlag = false
    /* eqROb */
    var eqRobTurnCountingDone = false
    
    /*=================*/
    /*== Send Signal ==*/
    /*=================*/
    
    var valueOfX: SKLabelNode!
    var xValue: Int = 0 {
        didSet {
            valueOfX.text = String(xValue)
        }
    }
    var signalInvisible = false
    
    /*=================*/
    /*== Castle life ==*/
    /*=================*/
    
    var maxLife = 3
    var life: Int = 3
    
    var log0: Log!
    var log1: Log!
    var log2: Log!
    var log3: Log!
    var log4: Log!
    var log5: Log!
    var log6: Log!
    var log7: Log!
    var log8: Log!
    
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
        plane = Plane(gameScene: self)
        log0 = childNode(withName: "log0") as! Log
        log1 = childNode(withName: "log1") as! Log
        log2 = childNode(withName: "log2") as! Log
        log3 = childNode(withName: "log3") as! Log
        log4 = childNode(withName: "log4") as! Log
        log5 = childNode(withName: "log5") as! Log
        log6 = childNode(withName: "log6") as! Log
        log7 = childNode(withName: "log7") as! Log
        log8 = childNode(withName: "log8") as! Log
        
        EqRobController.gameScene = self
        EqRobController.eqRobOriginPos = self.eqRob.absolutePos()
        CannonController.gameScene = self
        SignalController.gameScene = self
        MoveTouchController.gameScene = self
        AttackTouchController.gameScene = self
        ItemTouchController.gameScene = self
        AllTouchController.gameScene = self
        AddEnemyTurnController.gameScene = self
        AddItemTurnController.gameScene = self
        PlayerTurnController.gameScene = self
        EnemyTurnController.gameScene = self
        SignalSendingTurnController.gameScene = self
        StageClearTurnController.gameScene = self
        GameOverTurnController.gameScene = self
        ItemDropController.gameScene = self
        ContactController.gameScene = self
        SpeakInGameController.gameScene = self
        
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
            
            ResetController.reset()
            
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
            
            ResetController.reset()
            
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
        //let handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        
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
        setInputBoardForCane()
        setSimplificationBoard()
        setInputPanel()
        setSelectionPanel()
        setInputPanelForCannon()
        
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
        
        /* Set item area */
        setItemAreaCover()
        
        EnemyProperty.getNumOfAllEnemy(stageLevel: GameScene.stageLevel) { num in
            self.totalNumOfEnemy = num
        }
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set life */
        setLife(numOflife: maxLife)
        
        if GameScene.stageLevel > 3 {
            eqRob.isHidden = false
        } else {
            eqRob.isHidden = true
        }
        
        if GameScene.stageLevel > 4 {
            CannonController.add(type: 0, pos: [2, 9])
            CannonController.add(type: 0, pos: [3, 9])
            CannonController.add(type: 0, pos: [4, 9])
            CannonController.add(type: 0, pos: [5, 9])
            CannonController.add(type: 0, pos: [6, 9])
            CannonController.add(type: 0, pos: [7, 9])
            signalInvisible = true
        }
        
        gridNode.isTutorial = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* For debug */
        //print("\(gameState), \(playerTurnState), \(itemType)")
        
        SpeakInGameController.controlAction()
        
        if isCharactersTurn {
            
        } else {
            switch gameState {
            case .AddEnemy:
                AddEnemyTurnController.add()
                break;
            case .AddItem:
                AddItemTurnController.add()
                break;
            case .PlayerTurn:
                /* Check if all enemies are defeated or not */
                if totalNumOfEnemy <= 0 {
                    gameState = .StageClear
                    return
                }
                
                switch playerTurnState {
                case .DisplayPhase:
                    PlayerTurnController.displayPhase()
                    break;
                case .ItemOn:
                    PlayerTurnController.itemOn()
                    break;
                case .MoveState:
                    PlayerTurnController.moveState()
                    /* Wait for player touch to move */
                    break;
                case .AttackState:
                    /* Wait for player touch to attack */
                    break;
                case .UsingItem:
                    PlayerTurnController.usingItem()
                    /* Wait for player touch to point position to use item at */
                    break;
                case .TurnEnd:
                    if !countTurnDone {
                        countTurnDone = true
                        countTurn += 1
                    }
                    PlayerTurnController.turnEnd()
                    break;
                }
                break;
            case .EnemyTurn:
                EnemyTurnController.onTurn()
                
                /* All enemies finish their actions */
                if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
                    EnemyTurnController.turnEnd()
                }
                break;
            case .SignalSending:
                /* Cane */
                if caneOnFlag {
                    gameState = .PlayerTurn
                    gridNode.numOfTurnEndEnemy = 0
                } else if signalInvisible {
                    SignalSendingTurnController.invisibleSignal()
                } else {
                    SignalSendingTurnController.sendSignal()
                }
                break;
            case .StageClear:
                StageClearTurnController.clear()
                break;
            case .GameOver:
                GameOverTurnController.gameOver()
                break;
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard pauseFlag == false else { return }
        guard boardActiveFlag == false else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if isCharactersTurn {
            switch tutorialState {
            case .Converstaion:
                SpeakInGameController.nextLine()
                break;
            case .Action:
                break;
            }
        } else {
            guard gameState == .PlayerTurn else { return }
            guard SpeakInGameController.userTouch(on: nodeAtPoint.name) else { return }
            
            if nodeAtPoint.name == "eqRob" {
                AllTouchController.eqRobTouched()
                
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
                    
                    /* wall */
                } else if nodeAtPoint.name == "wall" {
                    /* Remove activeArea */
                    GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                    GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                    /* Remove triangle except the one of selected catapult */
                    
                    /* Remove input board for cane */
                    inputBoardForCane.isHidden = true
                    
                    /* Set timeBomb using state */
                    itemType = .Wall
                    
                    /* Get index of game using */
                    usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                    
                    /* cane */
                } else if nodeAtPoint.name == "cane" {
                    /* Remove activeArea */
                    GridActiveAreaController.resetSquareArray(color: "red", grid: self.gridNode)
                    GridActiveAreaController.resetSquareArray(color: "purple", grid: self.gridNode)
                    
                    /* Set timeBomb using state */
                    itemType = .Cane
                    
                    /* Get index of game using */
                    usingItemIndex = Int((nodeAtPoint.position.x-56.5)/91)
                    
                    /* If player touch other place than item icons, back to MoveState */
                } else {
                    ItemTouchController.othersTouched()
                }
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
                    let item = contactB.node as! Item
                    if let i = gridNode.itemsOnField.index(of: item) {
                        gridNode.itemsOnField.remove(at: i)
                    }
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                        if !DAUserDefaultUtility.bootsGotFirst {
                            SpeakInGameController.doAction(type: .BootsGotFirstly)
                        }
                    /* Get heart */
                    } else if item.name == "heart" {
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                        if !DAUserDefaultUtility.heartGotFirst {
                            SpeakInGameController.doAction(type: .HeartGotFirstly)
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
                        checkItemGotFirstly(name: item.name!)
                    }
                }
                /* B is hero */
                if contactB.categoryBitMask == 1 {
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let get = SKAction.playSoundFileNamed("ItemGet.wav", waitForCompletion: true)
                        self.run(get)
                    }
                    let item = contactA.node as! Item
                    if let i = gridNode.itemsOnField.index(of: item) {
                        gridNode.itemsOnField.remove(at: i)
                    }
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                        if !DAUserDefaultUtility.bootsGotFirst {
                            SpeakInGameController.doAction(type: .BootsGotFirstly)
                        }
                    /* Get heart */
                    } else if item.name == "heart" {
                        item.removeFromParent()
                        maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                        if !DAUserDefaultUtility.heartGotFirst {
                            SpeakInGameController.doAction(type: .HeartGotFirstly)
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
                        checkItemGotFirstly(name: item.name!)
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
                    /* Enemy hits wall by moving */
                    if contactB.categoryBitMask == 2 {
                        /* Get enemy */
                        let enemy = contactB.node as! Enemy
                        ContactController.enemyMoveToWall(wall: wall, enemy: enemy)
                    /* Enemy hits wall by punching */
                    } else {
                        /* Get enemy arm or fist */
                        let nodeB = contactB.node as! SKSpriteNode
                        /* Stop arm and fist */
                        nodeB.removeAllActions()
                        if let enemy = nodeB.parent as? Enemy {
                            ContactController.enemyPunchToWall(wall: wall, enemy: enemy)
                        }
                    }
                }
            }
            
            if contactB.categoryBitMask == 32 {
                
                /* Wall stop enemy punch or move */
                if contactB.node?.name == "wall" {
                    /* Get wall */
                    let wall = contactB.node as! Wall
                    /* Enemy hits wall by moving */
                    if contactA.categoryBitMask == 2 {
                        /* Get enemy */
                        let enemy = contactA.node as! Enemy
                        ContactController.enemyMoveToWall(wall: wall, enemy: enemy)
                    /* Enemy hits wall by punching */
                    } else {
                        /* Get enemy arm or fist */
                        let nodeA = contactA.node as! SKSpriteNode
                        /* Stop arm and fist */
                        nodeA.removeAllActions()
                        if let enemy = nodeA.parent as? Enemy {
                            ContactController.enemyPunchToWall(wall: wall, enemy: enemy)
                        }
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
        item.zPosition = 1
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
    
    func checkItemGotFirstly(name: String) {
        switch name {
        case "timeBomb":
            if !DAUserDefaultUtility.timeBombGotFirst {
                SpeakInGameController.doAction(type: .TimeBombGotFirstly)
            }
            break;
        case "cane":
            if !DAUserDefaultUtility.caneGotFirst {
                SpeakInGameController.doAction(type: .CaneGotFirstly)
            }
            break;
        case "wall":
            if !DAUserDefaultUtility.wallGotFirst {
                SpeakInGameController.doAction(type: .WallGotFirstly)
            }
            break;
        default:
            break;
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
    
    /* Set selection panel */
    func setSelectionPanel() {
        selectionPanel = SelectionPanel()
        selectionPanel.isHidden = true
        addChild(selectionPanel)
    }
    
    /* Set input panel for cannon */
    func setInputPanelForCannon() {
        inputPanelForCannon = InputPanelForCannon()
        inputPanelForCannon.isHidden = true
        addChild(inputPanelForCannon)
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
    
    func pointingAtkBtn() {
        let pos = CGPoint(x: buttonAttack.position.x + 50, y: buttonAttack.position.y + 50)
        pointing(pos: pos)
    }
    
    func pointingItmBtn() {
        let pos = CGPoint(x: buttonItem.position.x + 50, y: buttonItem.position.y + 50)
        pointing(pos: pos)
    }
    
    func pointingLastGotItem() {
        let pos = CGPoint(x: itemArray.last!.position.x + 50, y: itemArray.last!.position.y + 50)
        pointing(pos: pos)
    }
    
    /* Set pointing icon */
    private func pointing(pos: CGPoint) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 50, height: 50)
        icon.position = pos
        icon.zPosition = 7
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func removePointing() {
        if let icon = childNode(withName: "pointing") {
            icon.removeFromParent()
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
    
}

