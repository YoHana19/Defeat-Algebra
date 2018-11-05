//
//  SelectionPanel.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class SelectionPanel: SKSpriteNode {
    
    var veLabel: SKLabelNode!
    var xLabel: SKLabelNode!
    var xValueLabel: SKLabelNode!
    var againButton: SKSpriteNode!
    let leftTop = CGPoint(x: 100, y: -180)
    let rightTop = CGPoint(x: 420, y: -180)
    let merginY: CGFloat = 9
    let moveSpan: TimeInterval = 1.0
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "selectionPanel")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 10
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        self.setScale(0.55)
        self.position = CGPoint(x: 390, y: 294)
        self.isHidden = true
        
        setLabel()
        setAgainButton()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "again" {
            EqRobController.back(1)
        }
    }
    
    func moveWithScaling(to: CGPoint, value: CGFloat, completion: @escaping () -> Void) {
        self.scale(value: value)
        self.move(toPos: to) {
            return completion()
        }
    }
    
    func scale(value: CGFloat) {
        let scale = SKAction.scale(to: value, duration: moveSpan)
        self.run(scale)
    }
    
    func move(toPos position: CGPoint, completion: @escaping () -> Void) {
        let move = SKAction.move(to: position, duration: moveSpan)
        self.run(move, completion: {
            return completion()
        })
    }
    
    func setLabel() {
        veLabel = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel.fontSize = 70
        veLabel.position = CGPoint(x: 335, y: -100)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        self.addChild(veLabel)
        
        xLabel = SKLabelNode(fontNamed: DAFont.fontName)
        xLabel.fontSize = 60
        xLabel.position = CGPoint(x: 35, y: -180)
        xLabel.horizontalAlignmentMode = .left
        xLabel.text = "x="
        xLabel.zPosition = 3
        xLabel.fontColor = UIColor.white
        xLabel.isHidden = true
        self.addChild(xLabel)
        
        xValueLabel = SKLabelNode(fontNamed: DAFont.fontName)
        xValueLabel.fontSize = 60
        xValueLabel.position = CGPoint(x: 120, y: -180)
        xValueLabel.horizontalAlignmentMode = .left
        xValueLabel.text = ""
        xValueLabel.zPosition = 3
        xValueLabel.fontColor = UIColor.red
        xValueLabel.isHidden = true
        self.addChild(xValueLabel)
    }
    
    func setAgainButton() {
        let texture = SKTexture(imageNamed: "againButton")
        againButton = SKSpriteNode(texture: texture, color: UIColor.clear, size: texture.size())
        againButton.name = "again"
        againButton.zPosition = 3
        againButton.position = CGPoint(x: -220, y: -420)
        self.addChild(againButton)
    }
    
    func setSelectedEnemy(target: Enemy, index: Int) {
     
    }
    
    func resetAllEnemies() {
        for child in self.children {
            if child.name == "selectedEnemy" {
                child.removeFromParent()
            }
        }
    }
    
    func putCrossOnEnemyOnPanel(index: Int) {
      
    }
    
    func setXVlaue(value: String) {
        xValueLabel.text = value
    }
    
    func resetInstruction() {
        xValueLabel.text = ""
        xLabel.isHidden = true
        xValueLabel.isHidden = true
       
        self.isHidden = true
        againButton.isHidden = false
    }
}
