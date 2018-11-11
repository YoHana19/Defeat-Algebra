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
        madScientistNode = childNode(withName: "madScientistNode") as! SKSpriteNode
        signalHolder = childNode(withName: "signalHolder") as! SKSpriteNode
        stageHolder = childNode(withName: "stageHolder")
        againButton = childNode(withName: "againButton") as! SKSpriteNode
        againButton.isHidden = true
        buttonAttack = childNode(withName: "buttonAttack")
        skipButton = childNode(withName: "skipButton")  as! MSButtonNode
        skipButton.isHidden = true
        buttonAttack.isHidden = true
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
        ScenarioController.scenarioScene = self
        TutorialController.scene = self
        SpeakInGameController.gameScene = self
        VEEquivalentController.gameScene = self
        CannonTryController.gameScene = self
        GameStageController.gameScene = self
        ScenarioTouchController.gameScene = self
        EqRobJudgeController.gameScene = self
//        EnemyMoveController.gameScene = self
        
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
            SoundController.stopBGM()
            
            TutorialController.state = .Pending
            if GameScene.stageLevel == MainMenu.changeMoveSpanStartTurn || GameScene.stageLevel == MainMenu.timeBombStartTurn || GameScene.stageLevel == MainMenu.showUnsimplifiedStartTurn || GameScene.stageLevel == MainMenu.eqRobStartTurn || GameScene.stageLevel == MainMenu.lastTurn {
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
            SoundController.stopBGM()
            
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
            case MainMenu.invisibleStartTurn:
                DAUserDefaultUtility.doneFirstly(name: "invisibleSignal")
                break;
            default:
                break;
            }
            GameStageController.stageManager(scene: self, next: 1)
        }
        
        /* Pause button */
        buttonPause.selectedHandler = { [weak self] in
            guard let pauseFlag = self?.pauseFlag, let pauseScreen = self?.pauseScreen else { return }
            self?.pauseFlag = !pauseFlag
            self?.pauseScreen.isHidden = !pauseScreen.isHidden
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
        setInputPanel()
        setSelectionPanel()
        setInputPanelForCannon()
        
        /* Set Pause screen */
        pauseScreen = PauseScreen()
        addChild(pauseScreen)
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+40) // 40 is top ha;f of castleNode physics
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if GameScene.stageLevel < MainMenu.invisibleStartTurn {
            /* Set castleWall physics property */
            castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
            castleNode.physicsBody?.categoryBitMask = 4
            castleNode.physicsBody?.collisionBitMask = 0
            castleNode.physicsBody?.contactTestBitMask = 24
        }
        
        /* Set life */
        life = 5
        setLife(numOflife: life)
        
        GameStageController.initializeForScenario()
        
        setEqRob()
        
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
                //TutorialController.active()
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
                    TutorialController.active()
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
                        GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                        return
                    } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
                        GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                        return
                    } else if GameScene.stageLevel == MainMenu.invisibleStartTurn {
                        if countTurn == 0 {
                            if CannonController.willFireCannon.count == gridNode.enemyArray.count {
                                guard CannonTouchController.state != .Trying else { return }
                                TutorialController.removeTutorialLabel()
                                playerTurnState = .TurnEnd
                                GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                                ScenarioController.currentActionIndex += 1
                                return
                            }
                        }
                        GridActiveAreaController.resetSquareArray(color: "blue", grid: gridNode)
                        return
                    }
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
                    
                    if GameScene.stageLevel == MainMenu.uncoverSignalStartTurn {
                        isCharactersTurn = true
                        gridNode.isTutorial = true
                        tutorialState = .None
                        if ScenarioFunction.judgeCanAttack() {
                            ScenarioController.currentActionIndex = 4
                        } else {
                            ScenarioController.currentActionIndex = 5
                        }
                        ScenarioController.controllActions()
                        return
                    } else if GameScene.stageLevel == MainMenu.timeBombStartTurn {
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
                    StageClearTurnController.clear()
                } else if GameScene.stageLevel == 1 {
                    StageClearTurnController.clear()
                } else if GameScene.stageLevel == MainMenu.timeBombStartTurn {
                    ScenarioController.currentActionIndex = 15
                    ScenarioController.controllActions()
                } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
                    TutorialController.currentIndex = 4
                    TutorialController.enable()
                    TutorialController.execute()
                    StageClearTurnController.clear()
                } else if GameScene.stageLevel == MainMenu.invisibleStartTurn {
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
                } else if nodeAtPoint.name == "timeBomb" {
                    MoveTouchController.buttonItemTapped()
                    ItemTouchController.timeBombTapped(touchedNode: nodeAtPoint)
                }
                
                /* Select attack position */
            } else if playerTurnState == .AttackState {
                /* Touch item button */
                if nodeAtPoint.name == "timeBomb" {
                    AttackTouchController.buttonItemTapped()
                    ItemTouchController.timeBombTapped(touchedNode: nodeAtPoint)
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
                } else if nodeAtPoint.name == "againButton" {
                    guard itemType == .EqRob else { return }
                    EqRobController.back(1)
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
                    SoundController.sound(scene: self, sound: .ItemGet)
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
                    SoundController.sound(scene: self, sound: .ItemGet)
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
                    if GameScene.stageLevel == 1 {
                        hero.isHidden = true
                        self.gameState = .GameOver
                    } else {
                        hero.removeFromParent()
                        self.gameState = .GameOver
                    }
                } else if contactB.categoryBitMask == 1 {
                    let hero = contactB.node as! Hero
                    if GameScene.stageLevel == 1 {
                        hero.isHidden = true
                        self.gameState = .GameOver
                    } else {
                        hero.removeFromParent()
                        self.gameState = .GameOver
                    }
                }
            }
        }
        
        if (contactA.categoryBitMask == 1024 && contactB.categoryBitMask == 128) || (contactA.categoryBitMask == 128 && contactB.categoryBitMask == 1024) {
            VEEquivalentController.puttingXValue = true
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
                if enemy.punchIntervalForCount == 0 {
                    enemy.defend()
                } else {
                    enemy.state = .Defence
                }
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
        
        if GameScene.stageLevel == 1 {
            if gridNode.enemyArray.count == 1 {
                let enemy = gridNode.enemyArray[0]
                resetEnemy(enemy: enemy)
                enemy.positionX = 4
                enemy.positionY = 9
                let gridPosition = CGPoint(x: (Double(enemy.positionX)+0.5)*gridNode.cellWidth, y: (Double(enemy.positionY)+0.5)*gridNode.cellHeight)
                enemy.position = gridPosition
                enemy.myTurnFlag = true
            }
        }
    }
    
    func resetEnemy(enemy: Enemy) {
        enemy.turnDoneFlag = false
        enemy.myTurnFlag = false
        enemy.punchIntervalForCount = enemy.punchInterval
        enemy.defend()
        enemy.posRecord.removeAll()
    }
}

