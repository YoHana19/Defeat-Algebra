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
    case Converstaion, Action
}

class ScenarioScene: GameScene {
    
    var signalHolder: SKSpriteNode!
    var xEqLabel: SKLabelNode!
    var skipButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        madScientistNode = childNode(withName: "madScientistNode") as! SKSpriteNode
        signalHolder = childNode(withName: "signalHolder") as! SKSpriteNode
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
        xEqLabel = childNode(withName: "xEqLabel") as! SKLabelNode
        
        /* Connect game buttons */
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonNextLevel = childNode(withName: "buttonNextLevel") as! MSButtonNode
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        buttonRetry.state = .msButtonNodeStateHidden
        buttonNextLevel.state = .msButtonNodeStateHidden
        
        skipButton.selectedHandler = { [weak self] in
            CharacterController.retreatMainHero()
            CharacterController.retreatMadDoctor()
            CharacterController.retreatDoctor()
            
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
        setLife(numOflife: life)
        
        // mad pos
        if GameScene.stageLevel > 1 {
            madScientistNode.position = CGPoint(x: 374.999, y: 1282.404)
            SignalController.madPos = madScientistNode.absolutePos()
        }
        
        // eqRob
        if GameScene.stageLevel > 3 {
            eqRob.isHidden = false
            if GameScene.stageLevel == 4 {
                eqRob.position = CGPoint(x: eqRob.position.x-200, y: eqRob.position.y)
                selectionPanel.againButton.isHidden = true
            }
        } else {
            eqRob.isHidden = true
        }
        
        // cannon
        setCanoon()
        
        // nunOfEnemy
        if GameScene.stageLevel == 0 {
            self.totalNumOfEnemy = 2
        } else if GameScene.stageLevel == 4 {
            self.totalNumOfEnemy = 4
        } else {
            self.totalNumOfEnemy = 1
        }
        
        // x label
        if GameScene.stageLevel == 0 {
            signalHolder.isHidden = true
            xEqLabel.isHidden = true
            valueOfX.isHidden = true
        }
        
        // skipButton
        if GameScene.stageLevel == 0 {
            skipButton.isHidden = !DAUserDefaultUtility.initialScenarioFirst
        } else if GameScene.stageLevel == 2 {
            skipButton.isHidden = !DAUserDefaultUtility.moveExplainFirst
        } else if GameScene.stageLevel == 4 {
            skipButton.isHidden = !DAUserDefaultUtility.eqRobExplainFirst
        } else if GameScene.stageLevel == 6 {
            skipButton.isHidden = !DAUserDefaultUtility.cannonExplainFirst
        } else if GameScene.stageLevel == 7 {
            skipButton.isHidden = !DAUserDefaultUtility.invisibleSignalFirst
        }
        
        self.isCharactersTurn = true
        gridNode.isTutorial = true
        ScenarioController.currentLineIndex = 0
        ScenarioController.currentActionIndex = 0
        TutorialController.initialize()
        
        ScenarioController.controllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isCharactersTurn {
            switch tutorialState {
            case .Converstaion:
                break;
            case .Action:
                break;
            }
        } else {
            print("\(gameState), \(playerTurnState), \(itemType)")
            switch gameState {
            case .AddEnemy:
                //AddEnemyTurnController.add()
                ScenarioController.controllActions()
                gameState = .SignalSending
                break;
            case .AddItem:
                //AddItemTurnController.add()
                ScenarioController.controllActions()
                gameState = .PlayerTurn
                TutorialController.active()
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
                    PlayerTurnController.moveState()
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
                    EnemyTurnController.turnEnd()
                    countTurnDone = false
                }
                ScenarioController.controllActions()
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
                ScenarioController.controllActions()
                break;
            case .StageClear:
                ScenarioController.controllActions()
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
                ScenarioController.nextLine()
                break;
            case .Action:
                if GameScene.stageLevel == 4 {
                    if ScenarioController.currentActionIndex == 3 {
                        if nodeAtPoint.name == "eqRob" {
                            ScenarioController.controllActions()
                        }
                    } else if ScenarioController.currentActionIndex == 4 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 13 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 15 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 20 {
                        if nodeAtPoint.name == "eqRob" {
                            ScenarioController.controllActions()
                        }
                    } else if ScenarioController.currentActionIndex == 23 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 25 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 26 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex == 27 {
                        ScenarioController.controllActions()
                    }
                } else if GameScene.stageLevel == 6 {
                    if ScenarioController.currentActionIndex == 4 {
                        ScenarioController.controllActions()
                    }
                } else if GameScene.stageLevel == 7 {
                    if ScenarioController.currentActionIndex >= 4 && ScenarioController.currentActionIndex <= 16 {
                        ScenarioController.controllActions()
                    } else if ScenarioController.currentActionIndex >= 26 && ScenarioController.currentActionIndex <= 31 {
                        ScenarioController.controllActions()
                    }
                }
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
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                    
                    /* Get heart */
                    } else if item.name == "heart" {
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
                    /* Get boots */
                    if item.name == "boots" {
                        item.removeFromParent()
                        if hero.moveLevel < 4 {
                            self.hero.moveLevel += 1
                        }
                    /* Get heart */
                    } else if item.name == "heart" {
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
        signalHolder.isHidden = false
        xEqLabel.isHidden = false
        valueOfX.isHidden = false
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
}

