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
                if GameScene.stageLevel == 5, let _ = self.parent as? ScenarioScene {
                    if VEEquivalentController.numOfCheck > 3 {
                        ScenarioController.controllActions()
                        isEnable = false
                        return
                    } else {
                        CharacterController.doctor.balloon.isHidden = true
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
        
        if let _ = self.parent as? ScenarioScene {
        } else {
            if VEEquivalentController.numOfCheck > 3 {
                EqRobController.execute(4, enemy: nil)
                isUserInteractionEnabled = false
            }
        }
    }
    
    func signalTapped(value: Int, node: SKSpriteNode) {
        guard let gameScene = self.parent as? GameScene else { return }
        VEEquivalentController.numOfCheck += 1
        isEnable = false
        gameScene.valueOfX.text = "x=\(value)"
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.eqGrid)
        let dispatchgroup = DispatchGroup()
        for enemy in enemies {
            dispatchgroup.enter()
            SignalController.send(target: enemy, num: value, from: node.position, zPos: 10) {
                enemy.calculatePunchLength(value: value)
                for i in 1...enemy.valueOfEnemy {
                    GridActiveAreaController.showActiveArea(at: [(enemy.eqPosX, enemy.eqPosY-i)], color: "red", grid: gameScene.eqGrid)
                }
                dispatchgroup.leave()
            }
        }
        dispatchgroup.notify(queue: .main, execute: {
            self.isEnable = true
        })
        
        if let eqRob = eqRob {
            GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.eqGrid)
            SignalController.sendToEqRob(target: eqRob, num: value, from: node.position) {
                let length = eqRob.calculateValue(value: value)
                for i in 1...length {
                    GridActiveAreaController.showActiveArea(at: [(eqRob.eqPosX, eqRob.eqPosY-i)], color: "blue", grid: gameScene.eqGrid)
                }
            }
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
}
