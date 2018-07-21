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
        let texture = SKTexture(imageNamed: "inputBoardForCane")
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
            inputDone(value: 1)
            gameScene.xValue = 1
            for enemy in gameScene.gridNode.enemyArray {
                enemy.calculatePunchLength(value: gameScene.xValue)
            }
            if MainMenu.soundOnFlag {
                /* Play Sound */
                let blessing = SKAction.playSoundFileNamed("cane.mp3", waitForCompletion: true)
                self.run(blessing)
                let wait = SKAction.wait(forDuration: 3.0)
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 1, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                let seq = SKAction.sequence([wait, flash])
                self.run(seq)
            } else {
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 1, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                self.run(flash)
            }
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
            inputDone(value: 2)
            gameScene.xValue = 2
            for enemy in gameScene.gridNode.enemyArray {
                enemy.calculatePunchLength(value: gameScene.xValue)
            }
            if MainMenu.soundOnFlag {
                /* Play Sound */
                let blessing = SKAction.playSoundFileNamed("cane.mp3", waitForCompletion: true)
                self.run(blessing)
                let wait = SKAction.wait(forDuration: 3.0)
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 2, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                let seq = SKAction.sequence([wait, flash])
                self.run(seq)
            } else {
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 2, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                self.run(flash)
            }
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
            inputDone(value: 3)
            gameScene.xValue = 3
            for enemy in gameScene.gridNode.enemyArray {
                enemy.calculatePunchLength(value: gameScene.xValue)
            }
            if MainMenu.soundOnFlag {
                /* Play Sound */
                let blessing = SKAction.playSoundFileNamed("cane.mp3", waitForCompletion: true)
                self.run(blessing)
                let wait = SKAction.wait(forDuration: 3.0)
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 3, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                let seq = SKAction.sequence([wait, flash])
                self.run(seq)
            } else {
                let flash = SKAction.run({
                    GridFlashController.flashGridForCane(labelNode: gameScene.valueOfX, numOfFlash: 3, grid: gameScene.gridNode)
                    gameScene.caneOnFlag = true
                })
                self.run(flash)
            }
        }
        
    }
    
    func inputDone(value: Int) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        /* Remove used itemIcon from item array and Scene */
        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
        self.isHidden = true
        gameScene.itemType = .None
        let waitForFlash = SKAction.wait(forDuration: TimeInterval(value)*1.0+3.0)
        let moveState = SKAction.run({
            gameScene.playerTurnState = .MoveState
        })
        let seq = SKAction.sequence([waitForFlash, moveState])
        self.run(seq)
    }
    
    func setButtons() {
        /* Set button size */
        let buttonSize = CGSize(width: 120, height: 120)
        
        /* button 1 */
        let button1 = SKSpriteNode(imageNamed: "input1")
        button1.size = buttonSize
        button1.position = CGPoint(x: -140, y: -50)
        button1.name = "button1"
        button1.zPosition = 3
        addChild(button1)
        
        /* button 2 */
        let button2 = SKSpriteNode(imageNamed: "input2")
        button2.size = buttonSize
        button2.position = CGPoint(x: 0, y: -50)
        button2.name = "button2"
        button2.zPosition = 3
        addChild(button2)
        
        /* button 3 */
        let button3 = SKSpriteNode(imageNamed: "input3")
        button3.size = buttonSize
        button3.position = CGPoint(x: 140, y: -50)
        button3.name = "button3"
        button3.zPosition = 3
        addChild(button3)
    }
}
