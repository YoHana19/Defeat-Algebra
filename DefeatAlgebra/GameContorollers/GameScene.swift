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
    var eqGrid: EqGrid!
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var signalHolder: SKSpriteNode!
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
    var stageHolder: SKNode!
    var confirmBomb = ConfirmBomb()
    
    /*== Game labels ==*/
    var gameOverLabel: SKNode!
    var clearLabel: SKNode!
    var levelLabel: SKLabelNode!
    var numOfTotalEnemyLabel: SKLabelNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    
    /*== Game buttons ==*/
    var buttonRetry: MSButtonNode!
    var buttonRetryFromTop: MSButtonNode!
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
    public var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase {
        didSet {
            if (oldValue != .MoveState && playerTurnState == .MoveState) {
                PlayerTurnController.moveState()
            }
        }
    }
    var itemType: ItemType = .None
    /* Game level */
    static var stageLevel: Int = 0
    var selectedLevel: Int?
    var moveLevel: Int = 1
    var handedItemNameArray: [String] = []
    var totalNumOfEnemy: Int = 0 {
        didSet {
            numOfTotalEnemyLabel.text = String(totalNumOfEnemy)
        }
    }
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
    var lastGameState: GameSceneState = .EnemyTurn
    var heroKilled: Bool = false
    
    /*===========*/
    /*== Enemy ==*/
    /*===========*/
    
    /*== Add enemy management ==*/
    var initialAddEnemyFlag = true
    var compAddEnemyFlag = false
    var countTurnForAddEnemy: Int = -1
    var dupliExsist = false
    var willFastForward = false
    var enemyKillingHero: Enemy?
    
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
    var timeBombConfirming = false
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
            if GameScene.stageLevel < MainMenu.invisivleStartTurn {
                if xValue == 0 {
                    valueOfX.text = ""
                } else {
                    valueOfX.text = "x = \(xValue)"
                }
            }
        }
    }
    var signalInvisible = false
    
    /*=================*/
    /*== Castle life ==*/
    /*=================*/
    
    //var maxLife = 3
    var life: Int = 5
    
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
        eqGrid = childNode(withName: "eqGrid") as! EqGrid
        eqGrid.isHidden = true
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        signalHolder = childNode(withName: "signalHolder") as! SKSpriteNode
        madScientistNode = childNode(withName: "madScientistNode") as! SKSpriteNode
        eqRob = childNode(withName: "eqRob") as! EqRob
        SignalController.madPos = madScientistNode.absolutePos()
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        plane = Plane(gameScene: self)
        stageHolder = childNode(withName: "stageHolder")
        log0 = childNode(withName: "log0") as! Log
        log1 = childNode(withName: "log1") as! Log
        log2 = childNode(withName: "log2") as! Log
        log3 = childNode(withName: "log3") as! Log
        log4 = childNode(withName: "log4") as! Log
        log5 = childNode(withName: "log5") as! Log
        log6 = childNode(withName: "log6") as! Log
        log7 = childNode(withName: "log7") as! Log
        log8 = childNode(withName: "log8") as! Log
        addChild(confirmBomb)
        
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
        TutorialController.scene = self
        SpeakInGameController.gameScene = self
        VEEquivalentController.gameScene = self
        CannonTryController.gameScene = self
        GameStageController.gameScene = self
        ScenarioTouchController.gameScene = self
        
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
        levelLabel = stageHolder.childNode(withName: "levelLabel") as! SKLabelNode
        numOfTotalEnemyLabel = childNode(withName: "numOfTotalEnemyLabel") as! SKLabelNode
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonRetryFromTop = childNode(withName: "buttonRetryFromTop") as! MSButtonNode
        buttonNextLevel = childNode(withName: "buttonNextLevel") as! MSButtonNode
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonRetryFromTop.state = .msButtonNodeStateHidden
        buttonNextLevel.state = .msButtonNodeStateHidden
        
        ResetController.reset()
        
        /* Retry button */
        buttonRetry.selectedHandler = { [weak self] in
            guard let flag = self?.heroKilled else { return }
            self?.buttonRetry.isHidden = true
            self?.buttonRetry.state = .msButtonNodeStateHidden
            if flag {
                self?.unDo(inGame: true) {
                    self?.heroKilled = false
                    self?.gameState = .AddItem
                    GameOverTurnController.gameOverReset()
                    GameOverTurnController.done = false
                }
            } else {
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
        }
        
        /* Retry button */
        buttonRetryFromTop.selectedHandler = { [weak self] in
            
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
            GameStageController.stageManager(scene: self, next: 1)
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
        
        /* Stage Level */
        levelLabel.text = String(GameScene.stageLevel+1)
        
        GameStageController.initialize()
        
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
        
        EnemyProperty.getNumOfAllEnemy(stageLevel: GameStageController.adjustGameSceneLevel()) { num in
            self.totalNumOfEnemy = num
        }
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set life */
        life = 5
        setLife(numOflife: life)
        
        SignalSendingTurnController.done = false
        StageClearTurnController.done = false
        GameOverTurnController.done = false
        gridNode.isTutorial = false
        DataController.isGameScene = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* For debug */
        //print("\(gameState), \(playerTurnState), \(itemType)")
        
//        print(GameScene.stageLevel)
//        print(GameStageController.adjustGameSceneLevel())
        
        SpeakInGameController.controlAction()
        
        if isCharactersTurn {
            
        } else {
            switch gameState {
            case .AddEnemy:
                AddEnemyTurnController.add()
                break;
            case .SignalSending:
                SignalSendingTurnController.sendSignal() {}
                break;
            case .AddItem:
                countTurnDone = false
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
        guard timeBombConfirming == false else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if isCharactersTurn {
            switch tutorialState {
            case .None:
                break;
            case .Converstaion:
                SpeakInGameController.nextLine()
                break;
            case .Action:
                break;
            }
        } else {
            guard gameState == .PlayerTurn else { return }
            guard SpeakInGameController.userTouch(on: nodeAtPoint.name) else { return }
            
            if nodeAtPoint.name == "eqRob" || nodeAtPoint.name == "eqRobCS" || nodeAtPoint.name == "eqRobRS" {
                
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
                    
                    /* Get heart */
                    if item.name == "heart" {
                        item.removeFromParent()
                        //maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                    /* Other items */
                    } else {
                        item.removeFromParent()
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 7 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
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
                    let item = contactA.node as! Item
                    if let i = gridNode.itemsOnField.index(of: item) {
                        gridNode.itemsOnField.remove(at: i)
                    }

                    /* Get heart */
                    if item.name == "heart" {
                        item.removeFromParent()
                        //maxLife += 1
                        life += 1
                        setLife(numOflife: life)
                    /* Other items */
                    } else {
                        item.removeFromParent()
                        /* Make sure to have items up tp 8 */
                        if itemArray.count >= 7 {
                            self.resetDisplayItem(index: 0)
                            displayitem(name: item.name!)
                        } else {
                            displayitem(name: item.name!)
                        }
                    }
                }
                
            /* Hit enemy */
            } else {
                if contactA.categoryBitMask == 1 {
                    let hero = contactA.node as! Hero
                    if let enemyFist = contactB.node as? EnemyFist {
                        if !heroKilled {
                            enemyKillingHero = enemyFist.parent as? Enemy
                        }
                    }
                    hero.isHidden = true
                    heroKilled = true
                    self.lastGameState = self.gameState
                    self.gameState = .GameOver
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! Hero
                    if let enemyFist = contactA.node as? EnemyFist {
                        if !heroKilled {
                            enemyKillingHero = enemyFist.parent as? Enemy
                        }
                    }
                    hero.isHidden = true
                    heroKilled = true
                    self.lastGameState = self.gameState
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
        inputPanelForCannon.isActive = false
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
        for i in 0..<numOflife+1 {
            if let node = childNode(withName: "life") {
                node.removeFromParent()
            }
            if i == numOflife {
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
        let label = SKLabelNode(fontNamed: DAFont.fontName)
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
    
    func showPunchIntervalLabel(active: Bool) {
        for enemy in gridNode.enemyArray {
            enemy.punchIntervalLabel.isHidden = !active
        }
    }
    
    // Pointing icon
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
    
    func pointingAllGotItems() {
        for item in itemArray {
            let icon = SKSpriteNode(imageNamed: "pointing")
            icon.size = CGSize(width: 50, height: 50)
            icon.position = CGPoint(x: 50, y: 50)
            icon.zPosition = 12
            let shakePoint = SKAction(named: "shakePoint")
            let repeatAction = SKAction.repeatForever(shakePoint!)
            icon.run(repeatAction)
            item.addChild(icon)
        }
    }
    
    func pointingEqRob() {
        let pos = CGPoint(x: eqRob.position.x + 50, y: eqRob.position.y + 50)
        pointing(pos: pos)
    }
    
    func pointingHeart() {
        let pos = CGPoint(x: 150, y: 250)
        pointing(pos: pos)
    }
    
    func pointingYes() {
        let pos = CGPoint(x: 650, y: 700)
        pointing(pos: pos)
    }
    
    func pointingHero() {
        let pos = CGPoint(x: hero.position.x + 50, y: hero.position.y + 50)
        pointing(pos: pos)
    }
    
    func pointingGridAt(x: Int, y: Int) {
        let gridPos = CGPoint(x: gridNode.position.x+CGFloat(self.gridNode.cellWidth/2)+CGFloat(self.gridNode.cellWidth*Double(x)), y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*Double(y)))
        let pos = CGPoint(x: gridPos.x + 70, y: gridPos.y + 80)
        pointing(pos: pos)
    }
    
    func pointingEqSignal() {
        pointingEqSignal1()
        pointingEqSignal2()
        pointingEqSignal3()
    }
    
    func pointingEqSignal1() {
        let pos1 = CGPoint(x: 510, y: 220)
        pointing(pos: pos1)
    }
    
    func pointingEqSignal2() {
        let pos2 = CGPoint(x: 630, y: 220)
        pointing(pos: pos2)
    }
    
    func pointingEqSignal3() {
        let pos3 = CGPoint(x: 740, y: 220)
        pointing(pos: pos3)
    }
    
    func pointingChangeVeButton() {
        let pos3 = CGPoint(x: 570, y: 1310)
        pointing(pos: pos3)
    }
    
    func pointingInputButton(name: String) {
        if name == "1" {
            let pos = CGPoint(x: 300, y: 720)
            pointing(pos: pos)
        } else if name == "2" {
            let pos = CGPoint(x: 390, y: 720)
            pointing(pos: pos)
        } else if name == "3" {
            let pos = CGPoint(x: 480, y: 720)
            pointing(pos: pos)
        } else if name == "4" {
            let pos = CGPoint(x: 570, y: 720)
            pointing(pos: pos)
        } else if name == "x" {
            let pos = CGPoint(x: 390, y: 550)
            pointing(pos: pos)
        } else if name == "+" {
            let pos = CGPoint(x: 290, y: 550)
            pointing(pos: pos)
        } else if name == "OK" {
            let pos = CGPoint(x: 700, y: 600)
            pointing(pos: pos)
        }
    }
    
    func pointingInputButtonForCannon(name: String) {
        if name == "1" {
            let pos = CGPoint(x: 210, y: 720)
            pointing(pos: pos)
        } else if name == "4" {
            let pos = CGPoint(x: 490, y: 720)
            pointing(pos: pos)
        } else if name == "6" {
            let pos = CGPoint(x: 390, y: 635)
            pointing(pos: pos)
        } else if name == "x" {
            let pos = CGPoint(x: 490, y: 550)
            pointing(pos: pos)
        } else if name == "+" {
            let pos = CGPoint(x: 390, y: 550)
            pointing(pos: pos)
        } else if name == "OK" {
            let pos = CGPoint(x: 700, y: 600)
            pointing(pos: pos)
        } else if name == "Try" {
            let pos = CGPoint(x: 700, y: 720)
            pointing(pos: pos)
        }
    }
    
    /* Set pointing icon */
    func pointing(pos: CGPoint) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 50, height: 50)
        icon.position = pos
        icon.zPosition = 100
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func movingPointing() {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 50, height: 50)
        icon.anchorPoint = CGPoint(x: 0, y: 0)
        icon.position = hero.position
        icon.zPosition = 7
        ScenarioController.keyTouchPos = (2, 1)
        let moveHorizontal = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth*2), y: 0, duration: 1.0)
        let moveVertical = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight*2), duration: 1.0)
        let resetPos = SKAction.run({ icon.position = self.hero.position })
        let seq = SKAction.sequence([moveVertical, moveHorizontal, resetPos])
        let repeatAction = SKAction.repeatForever(seq)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func removePointing() {
        if let icon = childNode(withName: "pointing") {
            icon.removeFromParent()
        }
    }
    
    func unDo(inGame: Bool = false, completion: @escaping () -> Void) {
        guard hero.posRecord.count > 0 else { return }
        gridNode.numOfTurnEndEnemy = 0
        gridNode.turnIndex = 0
        adjustItemCount()
        let heroLastPos = hero.posRecord[hero.posRecord.count-1]
        resetHeroPos(x: heroLastPos.0, y: heroLastPos.1)
        if inGame {
            if lastGameState == .EnemyTurn {
                let dispatchGroup = DispatchGroup()
                let doneEnemies = gridNode.enemyArray.filter({ $0.turnDoneFlag })
                for enemy in doneEnemies {
                    dispatchGroup.enter()
                    let enemyLastPos = enemy.posRecord[enemy.posRecord.count-1]
                    resetEnemyPos(enemy: enemy, x: enemyLastPos.0, y: enemyLastPos.1, punchInterval: enemyLastPos.2)
                    dispatchGroup.leave()
                }
                dispatchGroup.notify(queue: .main, execute: {
                    if self.gridNode.enemyArray.count > doneEnemies.count {
                        self.gridNode.enemyArray[doneEnemies.count].myTurnFlag = false
                    }
                    EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                    return completion()
                })
            } else {
                return completion()
            }
        } else {
            if gameState == .EnemyTurn {
                let dispatchGroup = DispatchGroup()
                let doneEnemies = gridNode.enemyArray.filter({ $0.turnDoneFlag })
                for enemy in doneEnemies {
                    dispatchGroup.enter()
                    let enemyLastPos = enemy.posRecord[enemy.posRecord.count-1]
                    resetEnemyPos(enemy: enemy, x: enemyLastPos.0, y: enemyLastPos.1, punchInterval: enemyLastPos.2)
                    dispatchGroup.leave()
                }
                dispatchGroup.notify(queue: .main, execute: {
                    if self.gridNode.enemyArray.count > doneEnemies.count {
                        self.gridNode.enemyArray[doneEnemies.count].myTurnFlag = false
                    }
                    EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
                    return completion()
                })
            } else {
                return completion()
            }
        }
    }
    
    func adjustItemCount() {
        if let _ = self as? ScenarioScene {
            return
        } else {
            if !compAddItemFlag {
                let stageLevel = GameStageController.adjustGameSceneLevel()
                if ItemDropController.manager[stageLevel][countTurnForAddItem-1] == 0 {
                    countTurnForAddItem -= 1
                }
            }
        }
    }
    
    func unDoTimeBomb(num: Int, completion: @escaping () -> Void) {
        guard gridNode.enemyArray.count > 0 else { return }
        gridNode.numOfTurnEndEnemy = 0
        gridNode.turnIndex = 0
        for _ in 0..<num {
            displayitem(name: "timeBomb")
        }
        let dispatchGroup = DispatchGroup()
        for enemy in gridNode.enemyArray {
            dispatchGroup.enter()
            let enemyLastPos = enemy.posRecord[enemy.posRecord.count-1]
            resetEnemyPos(enemy: enemy, x: enemyLastPos.0, y: enemyLastPos.1, punchInterval: enemyLastPos.2)
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            EnemyMoveController.updateEnemyPositon(grid: self.gridNode)
            return completion()
        })
    }
    
    func resetHeroPos(x: Int, y: Int) {
        gridNode.removeAllActions()
        hero.positionX = x
        hero.positionY = y
        hero.isHidden = false
        let xPos = gridNode.position.x+CGFloat(gridNode.cellWidth*(Double(x)+0.5))
        let yPos = gridNode.position.y+CGFloat(gridNode.cellHeight*(Double(y)+0.5))
        hero.position = CGPoint(x: xPos, y: yPos)
        hero.moveDoneFlag = false
        hero.aliveFlag = true
    }
    
    func resetEnemyPos(enemy: Enemy, x: Int, y: Int, punchInterval: Int?) {
        enemy.positionX = x
        enemy.positionY = y
        let gridPosition = CGPoint(x: (Double(enemy.positionX)+0.5)*gridNode.cellWidth, y: (Double(enemy.positionY)+0.5)*gridNode.cellHeight)
        enemy.position = gridPosition
        enemy.punchIntervalForCount = punchInterval ?? enemy.punchIntervalForCount
        if enemy.punchIntervalForCount == 0 {
            enemy.forcusForAttack(color: UIColor.red, value: xValue)
            valueOfX.text = "x = \(xValue)"
        }
        enemy.turnDoneFlag = false
        enemy.myTurnFlag = false
        if enemy.positionY == 0 {
            enemy.reachCastleFlag = true
        } else {
            enemy.reachCastleFlag = false
        }
    }
}

