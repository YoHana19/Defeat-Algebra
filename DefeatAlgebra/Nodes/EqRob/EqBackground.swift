//
//  EqBackground.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqBackground: SKSpriteNode {
    
    public var isEnable = false
    var enemies = [Enemy]()
    var eqRob: EqRob?
    let doneButton = SKSpriteNode(imageNamed: "tryDoneButton")
    var signal1 = SignalValueHolder(value: 1)
    var originPos1 = CGPoint(x: 0, y: 0)
    var signal2 = SignalValueHolder(value: 1)
    var originPos2 = CGPoint(x: 0, y: 0)
    var signal3 = SignalValueHolder(value: 1)
    var originPos3 = CGPoint(x: 0, y: 0)
    var movingSignal = SignalValueHolder(value: 1)
    var originPos = CGPoint(x: 0, y: 0)
    var isMoving = false
    var enemyVeSim = EqVESimulator(text: "")
    var enemyVeSim2 = EqVESimulator(text: "")
    var eqRobVeSim = EqVESimulator(text: "")
    var curVeSim = EqVESimulator(text: "")
    
    init(gameScene: GameScene, enemies: [Enemy], eqRob: EqRob?) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "Grid2")
        let bodySize = CGSize(width: 750, height: 1344)
        
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        self.enemies = enemies
        self.eqRob = eqRob
        
        isUserInteractionEnabled = true
        
        self.position = CGPoint(x: 0, y: 0)
        /* Set Z-Position, ensure ontop of screen */
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 0)
        gameScene.addChild(self)
        
        self.name = "eqBackground"
        
        setSimulator()
        curVeSim = enemyVeSim
        
        /* Set buttons */
        setSignals()
        setButton()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSimulator() {
        if enemies.count > 1 {
            enemyVeSim = EqVESimulator(text: enemies[0].variableExpressionString)
            enemyVeSim2 = EqVESimulator(text: enemies[1].variableExpressionString)
            addChild(enemyVeSim)
            addChild(enemyVeSim2)
            enemyVeSim.position = CGPoint(x: 80, y: 250)
            enemyVeSim2.position = CGPoint(x: 80, y: 180)
        } else {
            enemyVeSim = EqVESimulator(text: enemies[0].variableExpressionString)
            addChild(enemyVeSim)
            eqRobVeSim = EqVESimulator(text: eqRob!.variableExpressionString)
            addChild(eqRobVeSim)
            enemyVeSim.position = CGPoint(x: 80, y: 250)
            eqRobVeSim.position = CGPoint(x: 80, y: 180)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let gameScene = self.parent as? GameScene else { return }
        if gameScene.isCharactersTurn {
            switch gameScene.tutorialState {
            case .None:
                break;
            case .Converstaion:
                ScenarioController.nextLine()
                return
            case .Action:
                if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = self.parent as? ScenarioScene {
                    guard ScenarioTouchController.eqRobSimulatorTutorialTouch() else { return }
                }
                break;
            }
        }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if VEEquivalentController.simOneSessionDone {
            VEEquivalentController.nextSessoin()
            return
        } else if VEEquivalentController.simTwoVeDone {
            VEEquivalentController.compare()
            return
        } else if VEEquivalentController.simOneVeDone {
            VEEquivalentController.nextSim()
            return
        } else if VEEquivalentController.allDone {
            VEEquivalentController.doneSimulation()
            return
        }
        
        if nodeAtPoint.name == "signal1" || nodeAtPoint.name == "label1" {
            CharacterController.doctor.balloon.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let signal = node as? SignalValueHolder {
                VEEquivalentController.xValue = 1
                movingSignal = signal
                originPos = originPos1
                isMoving = true
            }
        }
        
        if nodeAtPoint.name == "signal2" || nodeAtPoint.name == "label2" {
            CharacterController.doctor.balloon.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let signal = node as? SignalValueHolder {
                VEEquivalentController.xValue = 2
                movingSignal = signal
                originPos = originPos2
                isMoving = true
            }
        }
        
        if nodeAtPoint.name == "signal3" || nodeAtPoint.name == "label3" {
            CharacterController.doctor.balloon.isHidden = true
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            if let signal = node as? SignalValueHolder {
                VEEquivalentController.xValue = 3
                movingSignal = signal
                originPos = originPos3
                isMoving = true
            }
        }

//        guard let gameScene = self.parent as? GameScene else { return }
//        if gameScene.isCharactersTurn {
//            switch gameScene.tutorialState {
//            case .None:
//                break;
//            case .Converstaion:
//                ScenarioController.nextLine()
//                return
//            case .Action:
//                if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = self.parent as? ScenarioScene {
//                    if ScenarioController.currentActionIndex < 11 {
//                        if VEEquivalentController.numOfCheck > 2 {
//                            ScenarioController.controllActions()
//                            isEnable = false
//                            return
//                        }
//                    }
//                }
//                break;
//            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        
        if isMoving {
            movingSignal.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isMoving {
            if VEEquivalentController.puttingXValue {
                movingSignal.position = originPos
                VEEquivalentController.activateVeSim()
                ScenarioFunction.eqRobSimulatorTutorialTrriger()
            } else {
                EqRobSimLines.doctorSays(in: VEEquivalentController.lineState, value: nil)
                let move = SKAction.move(to: originPos, duration: 0.5)
                movingSignal.run(move)
            }
            isMoving = false
            VEEquivalentController.puttingXValue = false
        }
    }
    
    func setSignals() {
        for i in 1...3 {
            let signal = SignalValueHolder(value: i)
            signal.setScale(1.5)
            signal.physicsBody = SKPhysicsBody(circleOfRadius: signal.frame.width/2)
            signal.physicsBody?.categoryBitMask = 1024
            signal.physicsBody?.collisionBitMask = 0
            signal.physicsBody?.contactTestBitMask = 128
            signal.name = "signal\(i)"
            signal.xValue.name = "label\(i)"
            signal.zPosition = 3
            signal.position = CGPoint(x: 650, y: 180)
            addChild(signal)
            if i == 1 {
                signal1 = signal
                originPos1 = signal.position
            } else if i == 2 {
                signal2 = signal
                originPos2 = signal.position
            } else {
                signal3 = signal
                originPos3 = signal.position
            }
        }
    }
    
    func setSignalIcon(value: Int) {
        let signal = SignalValueHolder(value: value)
        signal.zPosition = 3
        signal.position = CGPoint(x: 650-160*CGFloat(value-1), y: 1300)
        signal.name = "signalIcon"
        addChild(signal)
    }
    
    func moveSignalIcon() {
        for child in self.children {
            if child.name == "signalIcon" {
                if let signalIcon = child as? SignalValueHolder {
                    switch signalIcon.xValue.text! {
                    case "1":
                        break;
                    case "2":
                        let distance = CGFloat(VEEquivalentController.gameScene.eqGrid.cellWidth)
                        let move = SKAction.moveBy(x: -distance, y: 0, duration: 1.0)
                        signalIcon.run(move)
                        break;
                    case "3":
                        let distance = CGFloat(VEEquivalentController.gameScene.eqGrid.cellWidth)*2
                        let move = SKAction.moveBy(x: -distance, y: 0, duration: 1.0)
                        signalIcon.run(move)
                        break;
                    default:
                        break;
                    }
                }
            }
        }
    }
    
    func forInstruction() {
        if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = self.parent as? ScenarioScene {
            if ScenarioController.currentActionIndex < 11 {
                if VEEquivalentController.numOfCheck == 1 {
                    ScenarioController.nextLineWithoutMoving()
                }
            }
        }
    }
    
    func forInstruction2() {
        if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = self.parent as? ScenarioScene {
            if ScenarioController.currentActionIndex < 11 {
                doneButton.isHidden = true
            }
        }
    }
    
    func setExcessArea(length: Double, posX: Int, bottom: Bool) {
        guard let gameScene = self.parent as? GameScene else { return }
        let square = SKShapeNode(rectOf: CGSize(width: gameScene.gridNode.cellWidth, height: length))
        square.fillColor = UIColor.yellow
        square.alpha = 0.4
        square.zPosition = 100
        square.name = "excessArea"
        let xPos = gameScene.gridNode.position.x + CGFloat((Double(posX)+0.5) * gameScene.gridNode.cellWidth)
        var yPos: CGFloat = 0
        if bottom {
            yPos = gameScene.gridNode.position.y - CGFloat(length/2)
        } else {
            yPos = gameScene.gridNode.position.y + CGFloat(12 * gameScene.gridNode.cellHeight) + CGFloat(length/2)
        }
        square.position = CGPoint(x: xPos, y: yPos)
        addChild(square)
    }
    
    func removeExcessArea() {
        for child in self.children {
            if child.name == "excessArea" {
                child.removeFromParent()
            }
        }
    }
    
    func setButton() {
        doneButton.size = CGSize(width: 130, height: 70)
        doneButton.position = CGPoint(x: 670, y: 1288)
        doneButton.zPosition = 5
        doneButton.name = "doneButton"
        addChild(doneButton)
        doneButton.isHidden = true
    }
    
    func removePointing() {
        if let icon = self.childNode(withName: "pointing") {
            icon.removeFromParent()
        }
    }
    
    func pointingSignalToX() {
        let from = CGPoint(x: 700, y: 230)
        let xPos = enemyVeSim.veUnit[0].absolutePos()
        let to = CGPoint(x: xPos.x+100, y: xPos.y+50)
        movePointing(from: from, to: to)
    }
    
    func movePointing(from: CGPoint, to: CGPoint) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 80, height: 80)
        icon.position = from
        icon.zPosition = 100
        let move = SKAction.move(to: to, duration: 2.5)
        let resetPos = SKAction.run({ icon.position = from })
        let seq = SKAction.sequence([move, resetPos])
        let repeatAction = SKAction.repeatForever(seq)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func pointingNumToTouch() {
        let numPos = enemyVeSim.veUnit[1].absolutePos()
        let pos = CGPoint(x: numPos.x+140, y: numPos.y+80)
        pointing(pos: pos)
    }
    
    func removePointingSignalButton() {
        if let icon = signal1.childNode(withName: "pointing") {
            icon.removeFromParent()
        }
        if let icon = signal2.childNode(withName: "pointing") {
            icon.removeFromParent()
        }
        if let icon = signal3.childNode(withName: "pointing") {
            icon.removeFromParent()
        }
    }
    
    func pointing(pos: CGPoint) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 80, height: 80)
        icon.position = pos
        icon.zPosition = 100
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func showArea(eqGrid: EqGrid, originPos: (Int, Int)) {
        resetArea(eqGrid: eqGrid)
        if VEEquivalentController.outPutXValue > 0 {
            for i in 1...VEEquivalentController.outPutXValue {
                GridActiveAreaController.showActiveArea(at: [(originPos.0, originPos.1-i)], color: "red", grid: eqGrid, zPosition: 12)
            }
            if VEEquivalentController.outPutNumValue > 0 {
                for i in 1...VEEquivalentController.outPutNumValue {
                    GridActiveAreaController.showActiveArea(at: [(originPos.0, originPos.1-VEEquivalentController.outPutXValue-i)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            } else if VEEquivalentController.outPutNumValue < 0 {
                for i in 1...abs(VEEquivalentController.outPutNumValue) {
                    GridActiveAreaController.showActiveArea(at: [(originPos.0, originPos.1-VEEquivalentController.outPutXValue+i-1)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            }
        } else {
            if VEEquivalentController.outPutNumValue > 0 {
                for i in 1...VEEquivalentController.outPutNumValue {
                    GridActiveAreaController.showActiveArea(at: [(originPos.0, originPos.1-i)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            } else if VEEquivalentController.outPutNumValue < 0 {
//                for i in 1...abs(VEEquivalentController.outPutNumValue) {
//                    GridActiveAreaController.showActiveArea(at: [(enemies[0].eqPosX, enemies[0].eqPosY-VEEquivalentController.outPutXValue+i-1)], color: "yellow", grid: eqGrid, zPosition: 12)
//                }
            }
        }
    }
    
    func resetArea(eqGrid: EqGrid) {
        GridActiveAreaController.resetSquareArray(at: VEEquivalentController.curActivePos.0, color: "red", grid: eqGrid)
        GridActiveAreaController.resetSquareArray(at: VEEquivalentController.curActivePos.0, color: "yellow", grid: eqGrid)
    }
}
