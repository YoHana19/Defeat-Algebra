//
//  ScenarioScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import SpriteKit
import GameplayKit
import Fabric
import Crashlytics
import AVFoundation

enum TutorialState {
    case Converstaion, Action, None
}

class ScenarioScene: GameScene {
    
    var skipButton: MSButtonNode!
    var itemAreaCoverIsActive: Bool = true {
        didSet {
            itemAreaCover.isHidden = !itemAreaCoverIsActive
            if GameScene.stageLevel == MainMenu.timeBombStartTurn {
                if oldValue && !itemAreaCoverIsActive {
                    pointingAllGotItems()
                }
            }
        }
    }
    
    override var playerTurnState: PlayerTurnState {
        didSet {
            if (oldValue != .MoveState && playerTurnState == .MoveState) {
                if GameScene.stageLevel == 0 {
                    self.hero.checkEnemyAround() { enemy in
                        if let enemy = enemy {
                            ScenarioController.keyTouchPos = (enemy.positionX, enemy.positionY)
                            TutorialController.currentIndex = 6
                        }
                    }
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        eqGrid = childNode(withName: "eqGrid") as! EqGrid
        eqGrid.isHidden = true
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        madScientistNode = childNode(withName: "madScientistNode") as! SKSpriteNode
        signalHolder = childNode(withName: "signalHolder") as! SKSpriteNode
        stageHolder = childNode(withName: "stageHolder")
        eqRob = childNode(withName: "eqRob") as! EqRob
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        skipButton = childNode(withName: "skipButton")  as! MSButtonNode
        skipButton.isHidden = true
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
        ScenarioController.scenarioScene = self
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
        
        skipButton.selectedHandler = { [weak self] in
            if MainMenu.soundOnFlag {
                self?.main.stop()
                self?.stageClear.stop()
            }
            TutorialController.state = .Pending
            if GameScene.stageLevel == MainMenu.changeMoveSpanStartTurn || GameScene.stageLevel == MainMenu.timeBombStartTurn || GameScene.stageLevel == MainMenu.moveExplainStartTurn || GameScene.stageLevel == MainMenu.showUnsimplifiedStartTurn || GameScene.stageLevel == MainMenu.eqRobStartTurn || GameScene.stageLevel == MainMenu.invisibleStartTurn || GameScene.stageLevel == MainMenu.lastTurn {
                ScenarioController.loadGameScene()
            } else {
                CharacterController.retreatMainHero()
                CharacterController.retreatMadDoctor()
                CharacterController.retreatDoctor()
                GameStageController.stageManager(scene: self, next: 1)
            }
        }
        
        /* Next Level button */
        buttonNextLevel.selectedHandler = { [weak self] in
            if MainMenu.soundOnFlag {
                self?.main.stop()
                self?.stageClear.stop()
            }
            switch GameScene.stageLevel {
            case 0:
                DAUserDefaultUtility.doneFirstly(name: "initialScenario")
                break;
            case MainMenu.uncoverSignalStartTurn:
                DAUserDefaultUtility.doneFirstly(name: "uncoverSignal")
                break;
            case MainMenu.cannonStartTurn:
                DAUserDefaultUtility.doneFirstly(name: "cannonExplain")
                break;
            default:
                break;
            }
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
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set life */
        life = 5
        setLife(numOflife: life)
        
        GameStageController.initializeForScenario()
        
        self.isCharactersTurn = true
        gridNode.isTutorial = true
        ScenarioController.currentLineIndex = 0
        ScenarioController.currentActionIndex = 0
        TutorialController.initialize()
        
        DataController.isGameScene = false
        ScenarioController.controllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //print("\(hero.positionX), \(hero.positionY)")
//        print("currentActionIndex: \(ScenarioController.currentActionIndex)")
//        print("currentLineIndex: \(ScenarioController.currentLineIndex)")
        
        if isCharactersTurn {
            switch tutorialState {
            case .Converstaion:
                break;
            case .Action:
                break;
            case .None:
                break;
            }
        } else {
//            print("\(gameState), \(playerTurnState), \(itemType)")
//            print(TutorialController.currentIndex)
//            print(TutorialController.state)
            switch gameState {
            case .AddEnemy:
                //AddEnemyTurnController.add()
                ScenarioController.controllActions()
                gameState = .SignalSending
                break;
            case .SignalSending:
                SignalSendingTurnController.sendSignal() {}
                ScenarioController.controllActions()
                break;
            case .AddItem:
                //AddItemTurnController.add()
                ScenarioController.controllActions()
                TutorialController.active()
                gameState = .PlayerTurn
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
                    TutorialController.enable()
                    TutorialController.execute()
                    if GameScene.stageLevel == MainMenu.timeBombStartTurn {
                        if countTurn == 0 {
                            if itemArray.count < 1 {
                                itemAreaCoverIsActive = true
                                playerTurnState = .TurnEnd
                                GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                                return
                            }
                        } else {
                            isCharactersTurn = true
                            gridNode.isTutorial = true
                            tutorialState = .None
                            if gridNode.enemyArray.count > 0 {
                                ScenarioController.controllActions()
                            }
                            GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                            return
                        }
                        playerTurnState = .UsingItem
                        GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                        itemAreaCoverIsActive = false
                        return
                    } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
                        GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                        return
                    }
                    //PlayerTurnController.moveState()
                    /* Wait for player touch to move */
                    break;
                case .AttackState:
                    TutorialController.execute()
                    /* Wait for player touch to attack */
                    break;
                case .UsingItem:
                    TutorialController.execute()
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
                    if GameScene.stageLevel == MainMenu.timeBombStartTurn {
                        isCharactersTurn = true
                        tutorialState = .None
                        EnemyTurnController.timeBombOn() {
                            self.gameState = .PlayerTurn
                            self.playerTurnState = .ItemOn
                            self.isCharactersTurn = false
                            self.tutorialState = .Action
                        }
                        return
                    } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
                        self.isCharactersTurn = true
                        self.gridNode.isTutorial = true
                        self.tutorialState = .Action
                        CannonController.fire() {
                            if self.gridNode.enemyArray.count > 0 {
                                ScenarioController.controllActions()
                            } else {
                                self.gameState = .StageClear
                                self.isCharactersTurn = false
                            }
                        }
                        return
                    }
                    EnemyTurnController.turnEnd()
                    countTurnDone = false
                }
                ScenarioController.controllActions()
                break;
            case .StageClear:
                if GameScene.stageLevel == 0 {
                    DAUserDefaultUtility.doneFirstly(name: "initialScenarioFirst")
                    StageClearTurnController.clear()
                } else if GameScene.stageLevel == 1 {
                    TutorialController.currentIndex = 11
                    TutorialController.enable()
                    TutorialController.execute()
                    StageClearTurnController.clear()
                } else if GameScene.stageLevel == MainMenu.timeBombStartTurn {
                    ScenarioController.currentActionIndex = 21
                    ScenarioController.controllActions()
                } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
                    TutorialController.currentIndex = 4
                    TutorialController.enable()
                    TutorialController.execute()
                    DAUserDefaultUtility.doneFirstly(name: "cannonExplainFirst")
                    StageClearTurnController.clear()
                } else {
                    ScenarioController.controllActions()
                }
                break;
            case .GameOver:
                ScenarioController.controllActions()
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
            case .None:
                break;
            case .Converstaion:
                ScenarioController.nextLine()
                break;
            case .Action:
                ScenarioTouchController.controllerForScenarioScene(name: nodeAtPoint.name)
                break;
            }
        } else {
            guard gameState == .PlayerTurn else { return }
            guard TutorialController.userTouch(on: nodeAtPoint.name) else { return }
            
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
                    if GameScene.stageLevel == 2 { return }
                    ItemTouchController.buttonAttackTapped()
                    /* Use timeBomb */
                } else if nodeAtPoint.name == "timeBomb" {
                    ItemTouchController.timeBombTapped(touchedNode: nodeAtPoint)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
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
                        if itemArray.count >= 8 {
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
                    if GameScene.stageLevel == 0 {
                        hero.isHidden = true
                        if ScenarioController.currentActionIndex < 15 {
                            ScenarioController.currentActionIndex = 15
                            ScenarioController.controllActions()
                        }
                    } else if GameScene.stageLevel == 1 {
                        hero.isHidden = true
                        if ScenarioController.currentActionIndex < 13 {
                            ScenarioController.currentActionIndex = 13
                            ScenarioController.controllActions()
                        }
                    } else {
                        hero.removeFromParent()
                        self.gameState = .GameOver
                    }
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! Hero
                    if GameScene.stageLevel == 0 {
                        hero.isHidden = true
                        if ScenarioController.currentActionIndex < 15 {
                            ScenarioController.currentActionIndex = 15
                            ScenarioController.controllActions()
                        }
                    } else if GameScene.stageLevel == 1 {
                        hero.isHidden = true
                        if ScenarioController.currentActionIndex < 13 {
                            ScenarioController.currentActionIndex = 13
                            ScenarioController.controllActions()
                        }
                    } else {
                        hero.removeFromParent()
                        self.gameState = .GameOver
                    }
                }
            }
        }
        
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            if life > 1 {
                if GameScene.stageLevel == 0 {
                    TutorialController.currentIndex = 15
                    TutorialController.enable()
                    TutorialController.execute()
                } else if GameScene.stageLevel == 1 {
                    TutorialController.currentIndex = 8
                    TutorialController.enable()
                    TutorialController.execute()
                }
            }
            
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
    }
    
    func madEnter() {
        let move = SKAction.moveBy(x: 0, y: -110, duration: 1.0)
        madScientistNode.run(move)
    }
    
    func heroEnter(x: Int, y: Int, completion: @escaping () -> Void) {
        hero = Hero()
        hero.moveLevel = moveLevel
        hero.positionX = x
        hero.positionY = y
        hero.position = CGPoint(x: gridNode.position.x+CGFloat(gridNode.cellWidth/2)+CGFloat(gridNode.cellWidth*Double(x)), y: 0)
        addChild(hero)
        let move = SKAction.moveBy(x: 0, y: CGFloat(gridNode.position.y+CGFloat(gridNode.cellHeight/2)+CGFloat(gridNode.cellHeight*Double(y))), duration: 3.0)        
        hero.run(move, completion: {
            self.hero.setSwordAnimation() {}
            return completion()
        })
    }
    
    func enemyEnter(_ enemies: [(Int, Int, String, Int)], completion: @escaping () -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        for enemyInfo in enemies {
            dispatchGroup.enter()
            let posX = enemyInfo.0
            let posY = enemyInfo.1
            
            let enemy = Enemy(ve: enemyInfo.2)
            /* Store variable expression as origin */
            enemy.originVariableExpression = enemy.variableExpressionString
            
            enemy.punchInterval = enemyInfo.3
            enemy.punchIntervalForCount = enemy.punchInterval
            
            /* Set direction of enemy */
            enemy.direction = .front
            enemy.setMovingAnimation()
            
            /* Set position on screen */
            
            /* Keep track enemy position */
            enemy.positionX = posX
            enemy.positionY = posY
            
            if GameScene.stageLevel < 1 {
                enemy.moveSpeed = 0.2
                enemy.punchSpeed = 0.0025
                enemy.singleTurnDuration = 1.0
                enemy.xValueLabel.isHidden = true
            }
            
            /* Calculate gap between top of grid and gameScene */
            let gridPosition = CGPoint(x: (Double(posX)+0.5)*gridNode.cellWidth, y: Double(self.topGap+gridNode.size.height))
            enemy.position = gridPosition
            
            /* Set enemy's move distance when showing up */
            let startMoveDistance = Double(self.topGap)+gridNode.cellHeight*(Double(11-posY)+0.5)
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(startMoveDistance/Double(gridNode.cellHeight)*gridNode.addingMoveSpeed)
            
            /* Add enemy to grid node */
            gridNode.addChild(enemy)
            
            /* Add enemy to enemyArray */
            gridNode.enemyArray.append(enemy)
            
            /* Move enemy for startMoveDistance */
            let move = SKAction.moveTo(y: CGFloat((Double(enemy.positionY)+0.5)*gridNode.cellHeight), duration: startDulation)
            enemy.run(move, completion: {
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion()
        })
    }
    
    func showX() {
        for enemy in gridNode.enemyArray {
            enemy.variableExpressionLabel.isHidden = false
        }
    }
    
    func removeShowLengths() {
        for child in gridNode.children {
            if child.name == "veLength" || child.name == "showLength" {
                child.removeFromParent()
            }
        }
    }
    
    func getCannon(pos: [Int], completion: @escaping (Cannon) -> Void) {
        var cand = Cannon(type: 0)
        let dispatchGroup = DispatchGroup()
        for child in gridNode.children {
            dispatchGroup.enter()
            if let cannon = child as? Cannon  {
                if cannon.spotPos == pos {
                    cand = cannon
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(cand)
        })
    }
    
    func getSignal(completion: @escaping (SignalValueHolder) -> Void) {
        var cand = SignalValueHolder(value: 1)
        let dispatchGroup = DispatchGroup()
        for child in self.children {
            dispatchGroup.enter()
            if let signal = child as? SignalValueHolder  {
                cand = signal
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(cand)
        })
    }
    
    func pointingSignal() {
        getSignal() { signal in
            let pos = CGPoint(x: signal.position.x + 50, y: signal.position.y + 50)
            self.pointing(pos: pos)
        }
    }
    
    func resetEnemies() {
        guard gridNode.enemyArray.count > 0 else { return }
        self.enemyTurnDoneFlag = true
        self.gridNode.turnIndex = 0
        self.gridNode.numOfTurnEndEnemy = 0
        if GameScene.stageLevel == 0 {
            if gridNode.enemyArray.count == 1 {
                let enemy = gridNode.enemyArray[0]
                resetEnemy(enemy: enemy)
                enemy.positionX = 4
                enemy.positionY = 10
                let gridPosition = CGPoint(x: (Double(enemy.positionX)+0.5)*gridNode.cellWidth, y: (Double(enemy.positionY)+0.5)*gridNode.cellHeight)
                enemy.position = gridPosition
                enemy.myTurnFlag = true
            }
        } else if GameScene.stageLevel == 1 {
            if gridNode.enemyArray.count == 1 {
                let enemy = gridNode.enemyArray[0]
                resetEnemy(enemy: enemy)
                enemy.positionX = 4
                enemy.positionY = 10
                let gridPosition = CGPoint(x: (Double(enemy.positionX)+0.5)*gridNode.cellWidth, y: (Double(enemy.positionY)+0.5)*gridNode.cellHeight)
                enemy.position = gridPosition
                enemy.myTurnFlag = true
            } else {
                let enemy0 = gridNode.enemyArray[0]
                let enemy1 = gridNode.enemyArray[1]
                resetEnemy(enemy: enemy0)
                resetEnemy(enemy: enemy1)
                resetEnemyPos(enemy: enemy0, x: 2, y: 10, punchInterval: nil)
                resetEnemyPos(enemy: enemy1, x: 6, y: 10, punchInterval: nil)
                enemy0.myTurnFlag = true
            }
        }
    }
    
    func resetEnemy(enemy: Enemy) {
        enemy.turnDoneFlag = false
        enemy.myTurnFlag = false
        enemy.reachCastleFlag = false
        enemy.punchIntervalForCount = enemy.punchInterval
        enemy.posRecord.removeAll()
    }
}

