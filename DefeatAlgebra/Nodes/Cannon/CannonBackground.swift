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
    
    var isEnable = true
    var enemy = Enemy(variableExpressionSource: ["x"], forEdu: false)
    var cannon = Cannon(type: 0)
    let changeVeButton = SKSpriteNode(imageNamed: "changeVeButton")
    let tryDoneButton = SKSpriteNode(imageNamed: "tryDoneButton")
    
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
        
        if nodeAtPoint.name == "changeVeButton" {
            guard isEnable else { return }
            CannonController.showInputPanelInTrying()
        }
        
        if nodeAtPoint.name == "tryDoneButton" {
            guard isEnable else { return }
            CannonTryController.hideEqGrid()
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
            self.enemy.calculatePunchLength(value: value)
        }
        
        dispatchGroup.enter()
        SignalController.sendToCannon(target: cannon, num: value, from: node.position) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            self.enemy.punchAndMoveForCannon {
                self.cannon.throwBombForTry(enemy: self.enemy, value: value, completion: { result in
                    CannonController.doctorSays(in: .Trying, value: String(result))
                    let wait = SKAction.wait(forDuration: 2.5)
                    self.parent!.run(wait, completion: {
                        let rand = arc4random_uniform(UInt32(3))
                        CannonController.doctorSays(in: .Trying, value: String(rand+3))
                        CannonTryController.resetEnemy()
                        self.isEnable = true
                    })
                    
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
        }
    }
}
