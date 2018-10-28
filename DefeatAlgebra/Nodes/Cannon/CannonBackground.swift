//
//  CannonBackground.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CannonBackground: SKSpriteNode {
    
    public var isEnable = true
    var enemy = Enemy(variableExpressionSource: ["x"], forEdu: false)
    var cannon = Cannon(type: 0)
    let changeVeButton = SKSpriteNode(imageNamed: "changeVeButton")
    let tryDoneButton = SKSpriteNode(imageNamed: "tryDoneButton")
    var recordBoard = CannonRecordBoard(isLeft: true, enemyVe: "", cannonVe: "")
    var isSignal1Tapped = false
    var isSignal2Tapped = false
    var isSignal3Tapped = false
    var signal1 = SignalValueHolder(value: 1)
    var signal2 = SignalValueHolder(value: 1)
    var signal3 = SignalValueHolder(value: 1)
    
    init(gameScene: GameScene, enemy: Enemy, cannon: Cannon) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "Grid2")
        let bodySize = CGSize(width: 750, height: 1344)
        
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        self.enemy = enemy
        self.cannon = cannon
        
        isUserInteractionEnabled = true
        
        self.position = CGPoint(x: 0, y: 0)
        /* Set Z-Position, ensure ontop of screen */
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 0)
        gameScene.addChild(self)
        
        self.name = "cannonBackground"
        
        /* Set buttons */
        setSignals()
        
        setButton()
        
        if enemy.positionX > 3 {
            setRecordBoard(isLeft: true, enemyVe: enemy.variableExpressionString, cannonVe: cannon.variableExpressionLabel.text!)
        } else {
            setRecordBoard(isLeft: false, enemyVe: enemy.variableExpressionString, cannonVe: cannon.variableExpressionLabel.text!)
        }
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let gameScene = self.parent as? GameScene else { return }

        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if gameScene.isCharactersTurn {
            switch gameScene.tutorialState {
            case .None:
                break;
            case .Converstaion:
                ScenarioController.nextLine()
                return
            case .Action:
                if let _ = gameScene as? ScenarioScene {
                    if GameScene.stageLevel == MainMenu.invisibleStartTurn {
                        guard CannonTutorialController.userTouch(on: nodeAtPoint.name) else { return }
                    }
                }
                break;
            }
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "signal1" || nodeAtPoint.name == "label1" {
            guard isEnable else { return }
            signal1.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let _ = gameScene as? ScenarioScene {
                signalTappedForScenario(value: 1, node: node as! SKSpriteNode)
            } else {
                signalTapped(value: 1, node: node as! SKSpriteNode)
            }
        /* Touch button 2 */
        } else if nodeAtPoint.name == "signal2" || nodeAtPoint.name == "label2" {
            guard isEnable else { return }
            signal2.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let _ = gameScene as? ScenarioScene {
                signalTappedForScenario(value: 2, node: node as! SKSpriteNode)
            } else {
                signalTapped(value: 2, node: node as! SKSpriteNode)
            }
        /* Touch button 3 */
        } else if nodeAtPoint.name == "signal3" || nodeAtPoint.name == "label3" {
            guard isEnable else { return }
            signal3.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let _ = gameScene as? ScenarioScene {
                signalTappedForScenario(value: 3, node: node as! SKSpriteNode)
            } else {
                signalTapped(value: 3, node: node as! SKSpriteNode)
            }
        } else if nodeAtPoint.name == "changeVeButton" {
            guard isEnable else { return }
            isSignal1Tapped = false
            isSignal2Tapped = false
            isSignal3Tapped = false
            if let _ = gameScene as? ScenarioScene {
                CannonController.showInputPanelInTrying()
                ScenarioController.controllActions()
            } else {
                CannonController.showInputPanelInTrying()
            }
            CannonTryController.numOfChangeVE += 1
        } else if nodeAtPoint.name == "tryDoneButton" {
            guard isEnable else { return }
            if let _ = gameScene as? ScenarioScene {
                if GameScene.stageLevel == MainMenu.invisibleStartTurn {
                    if ScenarioController.currentActionIndex > 21 && ScenarioController.currentActionIndex < 36 {
                        CannonTutorialController.hideEqGrid()
                    } else {
                        CannonTryController.hideEqGrid()
                        TutorialController.visibleTutorialLabel(true)
                    }
                }
            } else {
                CannonTryController.hideEqGrid()
            }
        } else {
            guard let gameScene = self.parent as? GameScene else { return }
            if gameScene.inputPanelForCannon.isActive == true {
                CannonController.hideInputPanelInTrying()
            }
        }
    }
    
    func signalTapped(value: Int, node: SKSpriteNode) {
        guard let gameScene = self.parent as? GameScene else { return }
        CharacterController.doctor.balloon.isHidden = true
        VEEquivalentController.numOfCheck += 1
        isEnable = false
        gameScene.valueOfX.text = "x=\(value)"
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
            dispatchGroup.leave()
            self.enemy.calculatePunchLengthForCannon(value: value)
        }
        
        dispatchGroup.enter()
        SignalController.sendToCannon(target: cannon, num: value, from: node.position) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            self.enemy.punchAndMoveForCannon {
                self.cannon.throwBombForTry(enemy: self.enemy, value: value, completion: { result in
                    CannonController.doctorSays(in: .Trying, value: String(result))
                    let cannonValue = self.cannon.calculateValue(value: value)
                    let distance = (self.cannon.spotPos[1]-cannonValue) - (self.enemy.positionY-self.enemy.valueOfEnemy)
                    self.record(value: value, distance: distance, enemyValue: self.enemy.valueOfEnemy, cannonValue: cannonValue)
                    let wait = SKAction.wait(forDuration: 2.0)
                    self.parent!.run(wait, completion: {
                        if !CannonTryController.hintOn && !CannonTryController.isCorrect {
                            let rand = arc4random_uniform(UInt32(3))
                            CannonController.doctorSays(in: .Trying, value: String(rand+3))
                        }
                        self.rePosChangeVeButton(originPos: false)
                        CannonTryController.resetEnemy()
                        self.isEnable = true
                    })
                })
            }
        })
    }
    
    func signalTappedForScenario(value: Int, node: SKSpriteNode) {
        guard let gameScene = self.parent as? GameScene else { return }
        CharacterController.doctor.balloon.isHidden = true
        VEEquivalentController.numOfCheck += 1
        CannonTutorialController.isTouchEnable = false
        isEnable = false
        gameScene.valueOfX.text = "x=\(value)"
        gameScene.removePointing()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
            dispatchGroup.leave()
            self.enemy.calculatePunchLengthForCannon(value: value)
        }
        
        dispatchGroup.enter()
        SignalController.sendToCannon(target: cannon, num: value, from: node.position) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            self.enemy.punchAndMoveForCannon {
                self.cannon.throwBombForTry(enemy: self.enemy, value: value, completion: { result in
                    if GameScene.stageLevel == MainMenu.invisibleStartTurn && ScenarioController.currentActionIndex < 32 {
                        let cannonValue = self.cannon.calculateValue(value: value)
                        let distance = (self.cannon.spotPos[1]-cannonValue) - (self.enemy.positionY-self.enemy.valueOfEnemy)
                        self.record(value: value, distance: distance, enemyValue: self.enemy.valueOfEnemy, cannonValue: cannonValue)
                        ScenarioController.controllActions()
                        self.rePosChangeVeButton(originPos: false)
                        CannonTutorialController.isTouchEnable = true
                        self.isEnable = true
                    } else {
                        CannonController.doctorSays(in: .Trying, value: String(result))
                        let cannonValue = self.cannon.calculateValue(value: value)
                        let distance = (self.cannon.spotPos[1]-cannonValue) - (self.enemy.positionY-self.enemy.valueOfEnemy)
                        self.record(value: value, distance: distance, enemyValue: self.enemy.valueOfEnemy, cannonValue: cannonValue)
                        let wait = SKAction.wait(forDuration: 2.0)
                        self.parent!.run(wait, completion: {
                            if !CannonTryController.hintOn && !CannonTryController.isCorrect {
                                let rand = arc4random_uniform(UInt32(3))
                                CannonController.doctorSays(in: .Trying, value: String(rand+3))
                            }
                            self.rePosChangeVeButton(originPos: false)
                            CannonTryController.resetEnemy()
                            CannonTutorialController.isTouchEnable = true
                            self.isEnable = true
                        })
                    }
                })
            }
        })
    }
    
    func setButton() {
        changeVeButton.size = CGSize(width: 280, height: 70)
        changeVeButton.position = CGPoint(x: 430, y: 1288)
        changeVeButton.zPosition = 5
        changeVeButton.name = "changeVeButton"
        addChild(changeVeButton)
        
        tryDoneButton.size = CGSize(width: 130, height: 70)
        tryDoneButton.position = CGPoint(x: 670, y: 1288)
        tryDoneButton.zPosition = 5
        tryDoneButton.name = "tryDoneButton"
        addChild(tryDoneButton)
    }
    
    func setSignals() {
        for i in 1...3 {
            let signal = SignalValueHolder(value: i)
            signal.setScale(1.5)
            signal.name = "signal\(i)"
            signal.xValue.name = "label\(i)"
            signal.zPosition = 3
            signal.position = CGPoint(x: 120*i+320, y: 150)
            addChild(signal)
            if i == 1 {
                signal1 = signal
            } else if i == 2 {
                signal2 = signal
            } else {
                signal3 = signal
            }
        }
    }
    
    func rePosChangeVeButton(originPos: Bool) {
        if originPos {
            changeVeButton.position = CGPoint(x: 430, y: 1288)
        } else {
            if signal1.isHidden && signal2.isHidden && signal3.isHidden {
                changeVeButton.position = CGPoint(x: 560, y: 150)
            }
        }
    }
    
    func showAllSignalButton() {
        signal1.isHidden = false
        signal2.isHidden = false
        signal3.isHidden = false
    }
    
    func setRecordBoard(isLeft: Bool, enemyVe: String, cannonVe: String) {
        recordBoard = CannonRecordBoard(isLeft: isLeft, enemyVe: enemyVe, cannonVe: cannonVe)
        addChild(recordBoard)
    }
    
    func record(value: Int, distance: Int, enemyValue: Int, cannonValue: Int) {
        switch value {
        case 1:
            guard !isSignal1Tapped else { return }
            isSignal1Tapped = true
            recordBoard.createRecord(xValue: value, distanse: distance, enemyValue: enemyValue, cannonValue: cannonValue)
            break;
        case 2:
            guard !isSignal2Tapped else { return }
            isSignal2Tapped = true
            recordBoard.createRecord(xValue: value, distanse: distance, enemyValue: enemyValue, cannonValue: cannonValue)
            break;
        case 3:
            guard !isSignal3Tapped else { return }
            isSignal3Tapped = true
            recordBoard.createRecord(xValue: value, distanse: distance, enemyValue: enemyValue, cannonValue: cannonValue)
            break;
        default:
            break;
        }
    }
}
