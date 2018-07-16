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
    var againButton: SKSpriteNode!
    let leftTop = CGPoint(x: 100, y: -180)
    let rightTop = CGPoint(x: 420, y: -180)
    let merginY: CGFloat = 90
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "selectionPanel")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 101
        
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
            EqRobController.resetSelectedEnemyOnPanel()
        }
    }
    
    func setLabel() {
        veLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        veLabel.fontSize = 70
        veLabel.position = CGPoint(x: 335, y: -100)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        self.addChild(veLabel)
    }
    
    func setAgainButton() {
        let texture = SKTexture(imageNamed: "buttonAgain")
        againButton = SKSpriteNode(texture: texture, color: UIColor.clear, size: texture.size())
        againButton.name = "again"
        againButton.zPosition = 3
        againButton.position = CGPoint(x: -220, y: -420)
        self.addChild(againButton)
    }
    
    func setSelectedEnemy(target: Enemy, index: Int) {
        let enemy = SelectedEnemy()
        enemy.name = "selectedEnemy"
        enemy.veLabel.text = target.variableExpressionString
        enemy.setStandingtexture(direction: target.direction)
        if index < 4 {
            enemy.position = CGPoint(x: leftTop.x, y: leftTop.y-merginY*CGFloat(index))
        } else {
            enemy.position = CGPoint(x: rightTop.x, y: rightTop.y-merginY*CGFloat(index-4))
        }
        self.addChild(enemy)
    }
    
    func resetAllEnemies() {
        for child in self.children {
            if child.name == "selectedEnemy" {
                child.removeFromParent()
            }
        }
    }
}
