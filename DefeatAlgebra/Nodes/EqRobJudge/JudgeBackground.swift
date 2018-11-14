//
//  JudgeBackground.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class JudgeBackground: SKSpriteNode {
    
    var eqRobDiff = SKSpriteNode(imageNamed: "eqRob")
    var eqRobEq = SKSpriteNode(imageNamed: "eqRob")
    var isEquivalent = false
    var isEnableTouch = false
    
    init(gameScene: GameScene, enemy1: Enemy, enemy2: Enemy, isEquivalent: Bool) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "judgeBG")
        let bodySize = CGSize(width: 750, height: 1344)
        
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        let enemyPos1 = CGPoint(x: self.frame.width/4, y: 800)
        let enemyPos2 = CGPoint(x: self.frame.width/4*3, y: 800)
        setEnemy(enemy: enemy1, enemyPos: enemyPos1)
        setEnemy(enemy: enemy2, enemyPos: enemyPos2)
        
        self.isEquivalent = isEquivalent
        
        setBoard()
        
        isUserInteractionEnabled = true
        self.position = CGPoint(x: 0, y: 0)
        
        /* Set Z-Position, ensure ontop of screen */
        self.zPosition = 50
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 0)
        gameScene.addChild(self)
        
        self.name = "JudgeBackground"
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        guard ScenarioTouchController.eqRobSimulatorTutorialTouch(value: nodeAtPoint.name) else { return }
        
        guard isEnableTouch else { return }
        
        if nodeAtPoint.name == "different" {
            EqRobJudgeController.hideJudge(diffSelected: true, pos: CGPoint(x: 255, y: 540))
        } else if nodeAtPoint.name == "equivalent" {
            EqRobJudgeController.hideJudge(diffSelected: false, pos: CGPoint(x: 495, y: 540))
        }
    }
    
    private func setEnemy(enemy: Enemy, enemyPos: CGPoint) {
        enemy.zPosition = 51
        enemy.xValueLabel.isHidden = true
        enemy.direction = .front
        enemy.setMovingAnimation()
        enemy.variableExpressionLabel.fontColor = UIColor.white
        let move = SKAction.move(to: enemyPos, duration: 1.0)
        let scale = SKAction.scale(by: 2.0, duration: 1.0)
        let group = SKAction.group([move, scale])
        enemy.run(group, completion: {
            enemy.resolveShield() {}
        })
    }
    
    private func setEqRob(board: SKSpriteNode, eqRob: SKSpriteNode, pos: CGPoint) {
        eqRob.size = CGSize(width: 82, height: 77)
        eqRob.setScale(1.5)
        eqRob.zPosition = 1
        eqRob.zRotation = .pi * -1/2
        eqRob.position = pos
        board.addChild(eqRob)
    }
    
    private func setBoard() {
        let board = SKSpriteNode(imageNamed: "JudgeBoard")
        board.zPosition = 1
        board.position = CGPoint(x: self.frame.width/2, y: 600)
        addChild(board)
        let epLabel = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        let epLabe2 = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        epLabel.text = "この二つの文字式は"
        epLabe2.text = "同じ／違う文字式？"
        epLabel.fontSize = 40
        epLabe2.fontSize = 40
        epLabel.zPosition = 1
        epLabe2.zPosition = 1
        /* position */
        epLabel.position = CGPoint(x:0, y: 90)
        epLabe2.position = CGPoint(x:0, y: 40)
        /* Add to Scene */
        board.addChild(epLabel)
        board.addChild(epLabe2)
        setEqRob(board: board, eqRob: eqRobDiff, pos: CGPoint(x: -120, y: -60))
        setEqRob(board: board, eqRob: eqRobEq, pos: CGPoint(x: 120, y: -60))
        eqRobDiff.name = "different"
        eqRobEq.name = "equivalent"
        setButton(eqRob: eqRobDiff)
        setButton(eqRob: eqRobEq)
    }
    
    private func setButton(eqRob: SKSpriteNode) {
        let buttonSize = CGSize(width: 100, height: 52)
        if eqRob.name == "different" {
            let diffButton = SKSpriteNode(imageNamed: "DifferentBtn")
            diffButton.zPosition = 1
            diffButton.name = "different"
            diffButton.position = CGPoint(x: 0, y: 0)
            diffButton.size = buttonSize
            diffButton.zRotation = .pi * 1/2
            eqRob.addChild(diffButton)
        } else if eqRob.name == "equivalent" {
            let eqButton = SKSpriteNode(imageNamed: "equivalentBtn")
            eqButton.zPosition = 1
            eqButton.name = "equivalent"
            eqButton.position = CGPoint(x: 0, y: 0)
            eqButton.size = buttonSize
            eqButton.zRotation = .pi * 1/2
            eqRob.addChild(eqButton)
        }
    }
    
}
