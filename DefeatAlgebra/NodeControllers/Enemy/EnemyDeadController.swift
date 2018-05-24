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
    static func hitEnemy(enemy: Enemy, gameScene: GameScene) {
        if enemy.enemyLife > 0 {
            enemy.enemyLife -= 1
            enemy.resetColorizeEnemy()
        } else {
            /* Effect */
            gameScene.gridNode.enemyDestroyEffect(enemy: enemy)
            
            /* Enemy */
            let waitEffectRemove = SKAction.wait(forDuration: 1.0)
            let removeEnemy = SKAction.run({ enemy.removeFromParent() })
            let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
            gameScene.run(seqEnemy)
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
        }
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
