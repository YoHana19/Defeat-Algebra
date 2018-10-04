//
//  AddEnemyTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/24.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct AddEnemyTurnController {
    public static var gameScene: GameScene!
    public static var done: Bool = false {
        willSet {
            if !newValue && done {
                EnemyMoveController.moveDuplicatedEnemies(enemiesArray: gameScene.gridNode.enemyArray) { exsist in
                    gameScene.dupliExsist = exsist
                }
            }
        }
    }
    
    public static func add() {
        /* Make sure to call addEnemy once */
        if !done {
            done = true
            /* Make sure to call till complete adding enemy */
            if gameScene.compAddEnemyFlag == false {
                gameScene.countTurnForAddEnemy += 1
                if gameScene.countTurnForAddEnemy >= EnemyProperty.addEnemyManager[GameScene.stageLevel].count {
                    gameScene.compAddEnemyFlag = true
                    done = false
                    return
                }
                
                let addingIndex = EnemyProperty.addEnemyManager[GameScene.stageLevel][gameScene.countTurnForAddEnemy]
                
                /* Add enemies initially */
                if gameScene.initialAddEnemyFlag {
                    gameScene.initialAddEnemyFlag = false
                    EnemyAddController.addInitialEnemyAtGrid(enemyPosArray: EnemyProperty.initialEnemyPosArray[GameScene.stageLevel], grid: gameScene.gridNode) {
                        /* Update enemy position */
                        EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                        if GameScene.stageLevel == 1 {
                            gameScene.showPunchIntervalLabel(active: false)
                        }
                        /* Move to next state */
                        gameScene.gameState = .SignalSending
                        done = false
                    }
                    
                /* Add enemy in the middle */
                } else if addingIndex != 0 {
                    /* Add enemy normaly */
                    if addingIndex < 100 {
                        EnemyAddController.addEnemyAtGrid(addIndex: addingIndex, grid: gameScene.gridNode) {
                            /* Reset start enemy position array */
                            gameScene.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                                
                            /* Update enemy position */
                            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
                            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                            
                            
                            /* Move to next state */
                            gameScene.gameState = .SignalSending
                            done = false
                        }
                    /* Add enemy for edu */
                    } else {
                        EnemyAddController.addEnemyForEdu(addIndex: addingIndex, grid: gameScene.gridNode) {
                            
                            /* Update enemy position */
                            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
                            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                            
                            /* Move to next state */
                            gameScene.gameState = .SignalSending
                            done = false
                        }
                    }
                } else {
                    /* Move to next state */
                    gameScene.gameState = .SignalSending
                    done = false
                }
            } else {
                /* Move to next state */
                gameScene.gameState = .SignalSending
                done = false
            }
        }
    }
    
    public static func fastForward(completion: @escaping () -> Void) {
        guard gameScene.countTurnForAddEnemy < EnemyProperty.addEnemyManager[GameScene.stageLevel].count else { return completion() }
        while EnemyProperty.addEnemyManager[GameScene.stageLevel][gameScene.countTurnForAddEnemy] == 0 {
            gameScene.countTurnForAddEnemy += 1
        }
        return completion()
        
    }
}
