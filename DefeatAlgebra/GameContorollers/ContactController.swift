//
//  ContactController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/29.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct ContactController {
    public static var gameScene: GameScene!
    
    static func enemyMoveToWall(wall: Wall, enemy: Enemy) {
        
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let hitWall = SKAction.playSoundFileNamed("hitWall.wav", waitForCompletion: false)
            gameScene.run(hitWall)
        }
        
        /* Stop Enemy move */
        enemy.removeAllActions()
        enemy.wallHitFlag = true
            
        /* move back according to direction of enemy */
        switch enemy.direction {
        case .front:
            /* Reposition enemy */
            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*gameScene.gridNode.cellWidth), y: CGFloat((Double(wall.posY+1)+0.5)*gameScene.gridNode.cellHeight)), duration: 0.5)
                enemy.run(moveBack)
                
            /* Set enemy position */
            enemy.positionY = wall.posY+1
        case .left:
            /* Reposition enemy */
            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(wall.posX+1)+0.5)*gameScene.gridNode.cellWidth), y: CGFloat((Double(wall.posY)+0.5)*gameScene.gridNode.cellHeight)), duration: 0.5)
            enemy.run(moveBack)
            /* Set enemy position */
            enemy.positionX = wall.posX+1
            enemy.positionY = wall.posY
        case .right:
            /* Reposition enemy */
            let moveBack = SKAction.move(to: CGPoint(x: CGFloat((Double(wall.posX-1)+0.5)*gameScene.gridNode.cellWidth), y: CGFloat((Double(wall.posY)+0.5)*gameScene.gridNode.cellHeight)), duration: 0.5)
            enemy.run(moveBack)
            /* Set enemy position */
            enemy.positionX = wall.posX-1
            enemy.positionY = wall.posY
        default:
            break;
        }
            
        
        /* Reset count down punchInterval */
        enemy.punchIntervalForCount = enemy.punchInterval
        
            
        /* Move next enemy's turn */
        let moveTurnWait = SKAction.wait(forDuration: enemy.singleTurnDuration)
        let moveNextEnemy = SKAction.run({
            enemy.myTurnFlag = false
            if gameScene.gridNode.turnIndex < gameScene.gridNode.enemyArray.count-1 {
                gameScene.gridNode.turnIndex += 1
                gameScene.gridNode.enemyArray[gameScene.gridNode.turnIndex].myTurnFlag = true
            }
                
            /* Reset enemy animation */
            enemy.setMovingAnimation()
                
            /* To check all enemy turn done */
            gameScene.gridNode.numOfTurnEndEnemy += 1
            
            enemy.wallHitFlag = false
                
        })
            
        /* excute drawPunch */
        let seq = SKAction.sequence([moveTurnWait, moveNextEnemy])
        gameScene.run(seq)
        
    }
    
    static func enemyPunchToWall(wall: Wall, enemy: Enemy) {
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let hitWall = SKAction.playSoundFileNamed("hitWall.wav", waitForCompletion: false)
            gameScene.run(hitWall)
        }
        
        enemy.punchToWall(wall: wall)
    }
}
