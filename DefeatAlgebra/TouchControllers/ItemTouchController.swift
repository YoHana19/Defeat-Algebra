//
//  ItemTouchController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct ItemTouchController {
    public static var gameScene: GameScene!

    public static func buttonAttackTapped() {
        guard gameScene.heroMovingFlag == false else { return }
        
        SoundController.sound(scene: gameScene, sound: .ActionButton)
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Reset active area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        GridActiveAreaController.showAttackArea(posX: gameScene.hero.positionX, posY: gameScene.hero.positionY, grid: gameScene.gridNode)
        gameScene.playerTurnState = .AttackState

    }
    
    public static func timeBombTapped(touchedNode: SKNode) {
        SoundController.sound(scene: gameScene, sound: .UtilButton)
        /* Remove activeArea for catapult */
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        /* Set timeBomb using state */
        gameScene.itemType = .timeBomb
        
        /* Get index of game using */
        gameScene.usingItemIndex = Int((touchedNode.position.x-56.5)/91)
    }
    
    public static func AAForTimeBombTapped(gridX: Int, gridY: Int) {
        guard !gameScene.timeBombConfirming else { return }
        SoundController.sound(scene: gameScene, sound: .TimeBombAA)
        gameScene.timeBombConfirming = true
        gameScene.confirmBomb.gridX = gridX
        gameScene.confirmBomb.gridY = gridY
        gameScene.confirmBomb.isHidden = false
    }
    
    public static func enemyTapped(enemy: Enemy) {
        if gameScene.itemType == .EqRob && EqRobTouchController.state == .Attack {
            guard !enemy.isSelectedForEqRob else { return }
            SoundController.sound(scene: gameScene, sound: .ActionButton)
            enemy.isSelectedForEqRob = true
            EqRobController.execute(2, enemy: enemy)
        }
    }
    
    public static func othersTouched() {
        if gameScene.itemType == .EqRob {
            if EqRobTouchController.state == .Pending {
                EqRobController.back(0)
            } else if EqRobTouchController.state == .InstructionDone {
                EqRobController.execute(7, enemy: nil)
                return
            } else if EqRobTouchController.state == .Charging || EqRobTouchController.state == .Dead {
                EqRobController.back(4)
            } else {
                return
            }
        } else if gameScene.itemType == .Cannon {
            if CannonTouchController.state == .Pending {
                CannonController.back(0)
            }
        }
        
        /* Show attack and item buttons */
        gameScene.buttonAttack.isHidden = false
        
        gameScene.playerTurnState = .MoveState
        
        /* Reset hero */
        gameScene.hero.resetHero()
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Remove active area */
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        
    }
}
