//
//  TouchAreaController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct MoveTouchController {
    public static var gameScene: GameScene!
    
    public static func buttonAttackTapped() {
        guard gameScene.heroMovingFlag == false else { return }
        //guard gameScene.hero.attackDoneFlag == false else { return }
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Reset active area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        /* Set item area cover */
        gameScene.itemAreaCover.isHidden = false
        
        GridActiveAreaController.showAttackArea(posX: gameScene.hero.positionX, posY: gameScene.hero.positionY, grid: gameScene.gridNode)
        gameScene.playerTurnState = .AttackState
    }
    
    public static func buttonItemTapped() {
        guard gameScene.heroMovingFlag == false else { return }
        
        /* Reset active area */
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        
        /* Remove item area cover */
        gameScene.itemAreaCover.isHidden = true
        
        /* Change state to UsingItem */
        gameScene.playerTurnState = .UsingItem
    }
    
}
