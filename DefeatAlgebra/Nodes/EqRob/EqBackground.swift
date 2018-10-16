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
    
    var isEnable = true
    var enemies = [Enemy]()
    var eqRob: EqRob?
    let doneButton = SKSpriteNode(imageNamed: "tryDoneButton")
    
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
        
        /* Set buttons */
        setSignals()
        setButton()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
                    if ScenarioController.currentActionIndex < 11 {
                        if VEEquivalentController.numOfCheck > 2 {
                            ScenarioController.controllActions()
                            isEnable = false
                            return
                        }
                    }
                }
                break;
            }
        }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch button 1 */
        if nodeAtPoint.name == "signal1" || nodeAtPoint.name == "label1" {
            guard isEnable else { return }
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            signalTapped(value: 1, node: node as! SKSpriteNode)
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "signal2" || nodeAtPoint.name == "label2" {
            guard isEnable else { return }
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            signalTapped(value: 2, node: node as! SKSpriteNode)
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "signal3" || nodeAtPoint.name == "label3" {
            guard isEnable else { return }
            let node = nodeAtPoint as? SKSpriteNode ?? nodeAtPoint.parent
            signalTapped(value: 3, node: node as! SKSpriteNode)
        }
        
        if nodeAtPoint.name == "doneButton" {
            guard isEnable else { return }
            if let _ = self.parent as? ScenarioScene {
                ScenarioController.controllActions()
            } else {
                EqRobController.execute(7, enemy: nil)
            }
        }
    }
    
    func signalTapped(value: Int, node: SKSpriteNode) {
        guard let gameScene = self.parent as? GameScene else { return }
        CharacterController.doctor.balloon.isHidden = true
        VEEquivalentController.numOfCheck += 1
        if VEEquivalentController.numOfCheck > 2 {
            doneButton.isHidden = false
        }
        forInstruction2()
        isEnable = false
        gameScene.valueOfX.text = "x=\(value)"
        GridActiveAreaController.resetSquareArray(color: "green", grid: gameScene.eqGrid)
        
        if let eqRob = eqRob {
            gameScene.eqGrid.demoCalcLabel.isHidden = true
            if enemies.count > 1 {
                for (i, enemy) in enemies.enumerated() {
                    enemy.demoCalcLabel.isHidden = true
                    let odd = i % 2
                    SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
                        enemy.calculatePunchLength(value: value)
                        let labelPos = CGPoint(x: 0, y: -CGFloat(enemy.valueOfEnemy+1)*CGFloat(gameScene.gridNode.cellHeight)+40*CGFloat(odd-1))
                        enemy.showCalculation(pos: labelPos, value: value)
                        for idx in 1...enemy.valueOfEnemy {
                            GridActiveAreaController.showActiveArea(at: [(enemy.eqPosX, enemy.eqPosY-idx)], color: "green", grid: gameScene.eqGrid, zPosition: 12)
                        }
                    }
                }
            } else {
                for enemy in enemies {
                    enemy.demoCalcLabel.isHidden = true
                    SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
                        enemy.calculatePunchLength(value: value)
                        let labelPos = CGPoint(x: 0, y: -CGFloat(enemy.valueOfEnemy+1)*CGFloat(gameScene.gridNode.cellHeight))
                        enemy.showCalculation(pos: labelPos, value: value)
                        for i in 1...enemy.valueOfEnemy {
                            GridActiveAreaController.showActiveArea(at: [(enemy.eqPosX, enemy.eqPosY-i)], color: "green", grid: gameScene.eqGrid, zPosition: 12)
                        }
                    }
                }
            }
            
            removeExcessArea()
            GridActiveAreaController.resetSquareArray(color: "yellow", grid: gameScene.eqGrid)
            SignalController.sendToEqRob(target: eqRob, num: value, from: node.position) {
                let length = eqRob.calculateValue(value: value)
                if length < 0 {
                    let labelPos = VEEquivalentController.getPosOnGrid(x: eqRob.eqPosX, y: 10)
                    let excessLength = Double(-1 * length) * gameScene.gridNode.cellHeight
                    self.setExcessArea(length: excessLength, posX: eqRob.eqPosX, bottom: false)
                    gameScene.eqGrid.showEqRobDemoCalcLabel(pos: labelPos, value: value, eqRob: eqRob)
                } else if length < 12 {
                    let labelPos = VEEquivalentController.getPosOnGrid(x: eqRob.eqPosX, y: eqRob.eqPosY-length-1)
                    gameScene.eqGrid.showEqRobDemoCalcLabel(pos: labelPos, value: value, eqRob: eqRob)
                    for i in 1...length {
                        GridActiveAreaController.showActiveArea(at: [(eqRob.eqPosX, eqRob.eqPosY-i)], color: "yellow", grid: gameScene.eqGrid, zPosition: 12)
                    }
                } else {
                    let labelPos = VEEquivalentController.getPosOnGrid(x: eqRob.eqPosX, y: 0)
                    let excessLength = Double(length - 11) * gameScene.gridNode.cellHeight
                    self.setExcessArea(length: excessLength, posX: eqRob.eqPosX, bottom: true)
                    gameScene.eqGrid.showEqRobDemoCalcLabel(pos: labelPos, value: value, eqRob: eqRob)
                    for i in 1...11 {
                        GridActiveAreaController.showActiveArea(at: [(eqRob.eqPosX, eqRob.eqPosY-i)], color: "yellow", grid: gameScene.eqGrid, zPosition: 12)
                    }
                }
                self.isEnable = true
            }
        } else {
            let dispatchgroup = DispatchGroup()
            for enemy in enemies {
                dispatchgroup.enter()
                SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
                    enemy.calculatePunchLength(value: value)
                    for i in 1...enemy.valueOfEnemy {
                        GridActiveAreaController.showActiveArea(at: [(enemy.eqPosX, enemy.eqPosY-i)], color: "green", grid: gameScene.eqGrid, zPosition: 12)
                    }
                    dispatchgroup.leave()
                }
            }
            dispatchgroup.notify(queue: .main, execute: {
                self.forInstruction()
                self.isEnable = true
            })
        }
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
}
