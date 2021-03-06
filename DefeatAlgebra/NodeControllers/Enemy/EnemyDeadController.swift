//
//  EnemyDeadController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyDeadController {
    static func hitEnemy(enemy: Enemy, gameScene: GameScene, completion: @escaping () -> Void) {
        enemy.aliveFlag = false
        /* Count defeated enemy */
        gameScene.totalNumOfEnemy -= 1
        
        /* If you killed origin enemy */
        if enemy.forEduOriginFlag {
            EnemyDeadController.originEnemyDead(origin: enemy, gridNode: gameScene.gridNode)
            /* If you killed branch enemy */
        } else if enemy.forEduBranchFlag {
            EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: gameScene.gridNode)
        }
        
        /* Effect */
        enemyDestroyEffect(grid: gameScene.gridNode, enemy: enemy) {
            /* Enemy */
            let removeEnemy = SKAction.run({ enemy.removeFromParent() })
            gameScene.run(removeEnemy)
            return completion()
        }
        
        if let i = gameScene.gridNode.enemyArray.index(of: enemy) {
            gameScene.gridNode.enemyArray.remove(at: i)
        }
    }
    
    /*== Set effect when enemy destroyed ==*/
    private static func enemyDestroyEffect(grid: Grid, enemy: Enemy, completion: @escaping () -> Void) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "DestroyEnemy")!
        particles.position = CGPoint(x: enemy.position.x, y: enemy.position.y-20)
        /* Add particles to scene */
        grid.addChild(particles)
        let waitEffectRemove = SKAction.wait(forDuration: 1.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitEffectRemove, removeParticles])
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let dead = SKAction.playSoundFileNamed("enemyKilled.mp3", waitForCompletion: true)
            grid.run(dead)
        }
        particles.run(seqEffect, completion: {
            return completion()
        })
    }
    
    static func originEnemyDead(origin: Enemy, gridNode: Grid) {
        if let branch = gridNode.enemySUPairDict[origin] {
            branch.forEduBranchFlag = false
            gridNode.enemySUPairDict[origin] = nil
        } else {
            print("something wrong in EnemyDeadController.originEnemyDead")
        }
    }
    
    static func branchEnemyDead(branch: Enemy, gridNode: Grid) {
        let temp = gridNode.enemySUPairDict.flatMap({ $0.1 == branch ? $0.0 : nil })
        if let origin = temp.first {
            origin.forEduOriginFlag = false
            gridNode.enemySUPairDict[origin] = nil
        } else {
            print("something wrong in EnemyDeadController.branchEnemyDead")
        }
    }
}
