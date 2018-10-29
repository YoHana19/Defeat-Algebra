//
//  AttackTouchController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct AttackTouchController {
    public static var gameScene: GameScene!
    
    public static func buttonItemTapped() {
        guard gameScene.heroMovingFlag == false else { return }
        
        SoundController.sound(scene: gameScene, sound: .ActionButton)
        
        /* Reset active area */
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        
        /* Remove item area cover */
        gameScene.itemAreaCover.isHidden = true
        
        /* Change state to UsingItem */
        gameScene.playerTurnState = .UsingItem
    }
    
    public static func activeAreaTouched(touchedPoint: CGPoint) {
        guard gameScene.heroMovingFlag == false else { return }
        let gridNode = gameScene.gridNode as Grid
        
        /* Remove attack area square */
        GridActiveAreaController.resetSquareArray(color: "red", grid: gridNode)
        
        /* Caclulate grid array position */
        let gridX = Int(Double(touchedPoint.x) / gridNode.cellWidth)
        let gridY = Int(Double(touchedPoint.y) / gridNode.cellHeight)
        
        /* Set direction of hero */
        gameScene.hero.setHeroDirection(posX: gridX, posY: gridY)
        
        gameScene.hero.setSwordAnimation() {}
        
        /* Play Sound */
        SoundController.sound(scene: gameScene, sound: .SwordSound)
        /* If hitting enemy! */
        if gridNode.positionEnemyAtGrid[gridX][gridY] {
            let waitAni = SKAction.wait(forDuration: 0.5)
            let destroyEnemy = SKAction.run({
                /* Look for the enemy to destroy */
                for enemy in gridNode.enemyArray {
                    if enemy.positionX == gridX && enemy.positionY == gridY {
                        DataController.countForEnemyKilledByDA(enemy: enemy)
                        EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene) {}
                    }
                }
            })
            let seq = SKAction.sequence([waitAni, destroyEnemy])
            gridNode.run(seq)
        }
        
        let wait = SKAction.wait(forDuration: gameScene.turnEndWait+1.0) /* 1.0 is wait time for animation */
        let moveState = SKAction.run({
            /* Reset hero animation to back */
            gameScene.hero.resetHero()
            gameScene.playerTurnState = .MoveState
        })
        let seq = SKAction.sequence([wait, moveState])
        gridNode.run(seq)
    }
    
    public static func othersTouched() {
        
        let gridNode = gameScene.gridNode as Grid
        
        gameScene.playerTurnState = .MoveState
        /* Set item area cover */
        gameScene.itemAreaCover.isHidden = false
        
        /* Reset item type */
        gameScene.itemType = .None
        
        /* Remove variable expression display */
        gameScene.hero.removeMagicSwordVE()
        
        /* Remove active area */
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gridNode)
    }
}
