//
//  AllTouchController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/22.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct AllTouchController {
    public static var gameScene: GameScene!
    
    public static func eqRobTouched() {
        guard gameScene.playerTurnState == .MoveState || gameScene.playerTurnState == .AttackState || gameScene.playerTurnState == .UsingItem else { return }
        guard gameScene.itemType != .Cannon else { return }
        
        /* Hide attack and item buttons */
        gameScene.buttonAttack.isHidden = true
        gameScene.buttonItem.isHidden = true
        /* Reset hero */
        gameScene.hero.resetHero()
        /* Remove active area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        gameScene.itemAreaCover.isHidden = false
        gameScene.playerTurnState = .UsingItem
        gameScene.itemType = .EqRob
        
        EqRobTouchController.onEvent()
    }
    
    public static func cannonTouched(node: Cannon) {
        guard gameScene.playerTurnState == .MoveState || gameScene.playerTurnState == .AttackState || gameScene.playerTurnState == .UsingItem else { return }
        guard gameScene.itemType != .EqRob else { return }
        let cands = gameScene.gridNode.enemyArray.filter({ $0.state == .Attack && $0.positionX == node.spotPos[0] })
        guard cands.count > 0 else {
            CannonController.execute(4, cannon: nil)
            return
        }
        
        
        /* Hide attack and item buttons */
        gameScene.buttonAttack.isHidden = true
        gameScene.buttonItem.isHidden = true
        /* Reset hero */
        gameScene.hero.resetHero()
        /* Remove active area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        gameScene.itemAreaCover.isHidden = false
        gameScene.playerTurnState = .UsingItem
        gameScene.itemType = .Cannon
        
        CannonTouchController.onEvent(cannon: node, enemy: nil)
    }
}
