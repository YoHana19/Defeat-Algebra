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
        guard gameScene.hero.attackDoneFlag == false else { return }
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Reset active area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        /* Set item area cover */
        gameScene.itemAreaCover.isHidden = false
        
        GridActiveAreaController.showAttackArea(posX: gameScene.hero.positionX, posY: gameScene.hero.positionY, grid: gameScene.gridNode)
        gameScene.playerTurnState = .AttackState
        
        /* Remove triangle except the one of selected catapult */
        for catapult in gameScene.setCatapultArray {
            if let node = catapult.childNode(withName: "pointingCatapult") {
                node.removeFromParent()
            }
        }

        /* Remove input board for cane */
        gameScene.inputBoardForCane.isHidden = true
    }
    
    public static func timeBombTapped(touchedNode: SKNode) {
        /* Remove activeArea for catapult */
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        gameScene.resetActiveAreaForCatapult()
        /* Remove triangle except the one of selected catapult */
        for catapult in gameScene.setCatapultArray {
            if let node = catapult.childNode(withName: "pointingCatapult") {
                node.removeFromParent()
            }
        }
        /* Remove input board for cane */
        gameScene.inputBoardForCane.isHidden = true
        
        /* Set timeBomb using state */
        gameScene.itemType = .timeBomb
        
        /* Get index of game using */
        gameScene.usingItemIndex = Int((touchedNode.position.x-56.5)/91)
    }
    
    public static func AAForTimeBombTapped(gridX: Int, gridY: Int) {
        let gridNode = gameScene.gridNode as Grid
        
        /* Store position of set timeBomb */
        gridNode.timeBombSetPosArray.append([gridX, gridY])
        
        /* Set timeBomb at the location you touch */
        let timeBomb = TimeBomb()
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
    
    public static func enemyTapped(enemy: Enemy) {
        if gameScene.itemType == .EqRob && EqRobTouchController.state == .Attack {
            guard !enemy.isSelectedForEqRob else { return }
            enemy.isSelectedForEqRob = true
            EqRobController.execute(2, enemy: enemy)
        }
    }
    
    public static func othersTouched() {
        guard gameScene.setCatapultDoneFlag == false else { return }
        guard gameScene.selectCatapultDoneFlag == false else { return }
        
        if gameScene.itemType == .EqRob {
            if EqRobTouchController.state == .Pending {
                EqRobController.back(0)
            } else if EqRobTouchController.state == .DeadInstruction || EqRobTouchController.state == .AliveInstruction {
                EqRobController.execute(4, enemy: nil)
                return
            } else if EqRobTouchController.state == .Charging {
                EqRobController.back(4)
            } else {
                return
            }
        }
        
        /* Show attack and item buttons */
        gameScene.buttonAttack.isHidden = false
        gameScene.buttonItem.isHidden = false
        
        gameScene.playerTurnState = .MoveState
        
        /* Set item area cover */
        gameScene.itemAreaCover.isHidden = false
        
        /* Reset hero */
        gameScene.hero.resetHero()
        /* Remove effect */
        gameScene.removeMagicSowrdEffect()
        
        /* Reset color of enemy for magic sword */
        if gameScene.usingMagicSword {
            gameScene.usingMagicSword = false
            for enemy in gameScene.gridNode.enemyArray {
                if enemy.enemyLife > 0 {
                    enemy.colorizeEnemy(color: UIColor.green)
                } else {
                    enemy.resetColorizeEnemy()
                }
            }
        }
        
        /* Remove variable expression display for magic sword */
        gameScene.hero.removeMagicSwordVE()
        gameScene.magicSwordAttackDone = false
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Remove active area */
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        gameScene.resetActiveAreaForCatapult()
        
        /* Remove triangle except the one of selected catapult */
        for catapult in gameScene.setCatapultArray {
            if let node = catapult.childNode(withName: "pointingCatapult") {
                node.removeFromParent()
            }
        }
        
        /* Remove input board for cane */
        gameScene.inputBoardForCane.isHidden = true
        
    }
}
