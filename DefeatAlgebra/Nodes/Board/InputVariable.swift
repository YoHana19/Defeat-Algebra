//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class InputVariable: SKSpriteNode {
    
    /* Set buttons */
    var button1: SKSpriteNode!
    var button2: SKSpriteNode!
    var button3: SKSpriteNode!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "inputVariableBoard")
        let bodySize = CGSize(width: 500, height: 327)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 10
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 700)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch button 1 */
        if nodeAtPoint.name == "button1" {
            buttonTapped(value: 1)
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
            buttonTapped(value: 2)
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
            buttonTapped(value: 3)
        }
        
    }
    
    func buttonTapped(value: Int) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
        self.isHidden = true
        gameScene.itemType = .None
        
        /* Calculate each enemy's variable expression */
        let willAttackEnemies = gameScene.gridNode.enemyArray.filter{ $0.state == .Attack && $0.reachCastleFlag == false }
        if willAttackEnemies.count > 0 {
            gameScene.xValue =  value
            gameScene.valueOfX.fontColor = UIColor.yellow
            for enemy in willAttackEnemies {
                enemy.calculatePunchLength(value: gameScene.xValue)
                SignalController.sendFromHero(target: enemy, heroPos: gameScene.hero.absolutePos(), num: gameScene.xValue)
            }
            if let maxDistanceEnemy = willAttackEnemies.max(by: {$1.distance(to: gameScene.hero) > $0.distance(to: gameScene.hero)}) {
                let wait = SKAction.wait(forDuration: SignalController.signalSentDurationFromHero(target: maxDistanceEnemy, heroPos: gameScene.hero.absolutePos(), xValue: gameScene.xValue)+0.2)
                gameScene.run(wait, completion: {
                    gameScene.playerTurnState = .MoveState
                })
            }
        } else {
            gameScene.valueOfX.text = ""
            gameScene.playerTurnState = .MoveState
        }
    }
    
    func setButtons() {
        /* Set button size */
        let buttonSize = CGSize(width: 100, height: 100)
        
        /* button 1 */
        let button1 = SKSpriteNode(imageNamed: "input1")
        button1.size = buttonSize
        button1.position = CGPoint(x: -160, y: -40)
        button1.name = "button1"
        button1.zPosition = 3
        addChild(button1)
        
        /* button 2 */
        let button2 = SKSpriteNode(imageNamed: "input2")
        button2.size = buttonSize
        button2.position = CGPoint(x: -50, y: -40)
        button2.name = "button2"
        button2.zPosition = 3
        addChild(button2)
        
        /* button 3 */
        let button3 = SKSpriteNode(imageNamed: "input3")
        button3.size = buttonSize
        button3.position = CGPoint(x: 60, y: -40)
        button3.name = "button3"
        button3.zPosition = 3
        addChild(button3)
    }
}
