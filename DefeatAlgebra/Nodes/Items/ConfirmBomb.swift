//
//  ConfirmBomb.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ConfirmBomb: SKSpriteNode {
    
    public var gridX = 0
    public var gridY = 0
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "ConfirmBombSet")
        let bodySize = CGSize(width: 700, height: 454)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 13
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 670)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        
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
        
        if let _ = gameScene as? ScenarioScene, GameScene.stageLevel == MainMenu.timeBombStartTurn, ScenarioController.currentActionIndex == 13 {
            guard nodeAtPoint.name == "yes" else { return }
            ScenarioController.controllActions()
        }
        
        if nodeAtPoint.name == "yes" {
            DataController.setDataForUsedBomb()
            setBomb()
            self.isHidden = true
            gameScene.timeBombConfirming = false
        } else if nodeAtPoint.name == "no" {
            self.isHidden = true
            gameScene.timeBombConfirming = false
        }
        
    }
    
    func setBomb() {
        guard let gameScene = self.parent as? GameScene else { return }
        let gridNode = gameScene.gridNode as Grid
        
        /* Set timeBomb at the location you touch */
        let timeBomb = TimeBomb(pos: (gridX, gridY))
        timeBomb.texture = SKTexture(imageNamed: "timeBombToSet")
        timeBomb.zPosition = 3
        /* Make sure not to collide to hero */
        timeBomb.physicsBody = nil
        gridNode.timeBombSetArray.append(timeBomb)
        gridNode.addObjectAtGrid(object: timeBomb, x: gridX, y: gridY)
        
        /* Remove item active areas */
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gridNode)
        /* Reset item type */
        gameScene.itemType = .None
        /* Set item area cover */
        gameScene.itemAreaCover.isHidden = false
        
        /* Back to MoveState */
        gameScene.playerTurnState = .MoveState
        
        /* Remove used itemIcon from item array and Scene */
        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
    }
    
    
    func setButtons() {
        /* Set button size */
        //        let buttonSize = CGSize(width: 120, height: 120)
        
        /* Yes */
        let buttonItemList = SKSpriteNode(imageNamed: "confirmYes")
        buttonItemList.position = CGPoint(x: 150, y: -70)
        buttonItemList.name = "yes"
        buttonItemList.zPosition = 3
        addChild(buttonItemList)
        
        /* No */
        let buttonTutorial = SKSpriteNode(imageNamed: "confirmNo")
        buttonTutorial.position = CGPoint(x: -150, y: -70)
        buttonTutorial.name = "no"
        buttonTutorial.zPosition = 3
        addChild(buttonTutorial)
        
    }
}
