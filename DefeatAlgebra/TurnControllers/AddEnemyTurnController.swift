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
            let stageLevel = GameStageController.adjustGameSceneLevel()
            DataController.setDataForEnemyKilled()
            
            /* Make sure to call till complete adding enemy */
            if gameScene.compAddEnemyFlag == false {
                gameScene.willFastForward = false
                gameScene.countTurnForAddEnemy += 1
                if gameScene.countTurnForAddEnemy >= EnemyProperty.addEnemyManager[stageLevel].count {
                    gameScene.compAddEnemyFlag = true
                    done = false
                    return
                }
                
                let addingIndex = EnemyProperty.addEnemyManager[stageLevel][gameScene.countTurnForAddEnemy]
                
                /* Add enemies initially */
                if gameScene.initialAddEnemyFlag {
                    gameScene.initialAddEnemyFlag = false
                    let property = EnemyProperty.initialEnemyPosArray[stageLevel]
                    
                    switch property.0 {
                        case 0:
                            EnemyAddController.addInitialEnemyAtGrid0(veCate: property.1, enemyPosArray: property.2, grid: gameScene.gridNode) {
                                /* Update enemy position */
                                EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                                /* Move to next state */
                                gameScene.gameState = .SignalSending
                                done = false
                            }
                            break;
                        case 1:
                            EnemyAddController.addInitialEnemyAtGrid1(enemyPosArray: property.2, grid: gameScene.gridNode) {
                                /* Update enemy position */
                                EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                                /* Move to next state */
                                gameScene.gameState = .SignalSending
                                done = false
                            }
                            break;
                        case 2:
                            var veCate = 0
                            var originIncluded = 0
                            if property.1 < 100 {
                                veCate = property.1
                                originIncluded = 0
                            } else if property.1 < 1000 {
                                veCate = property.1 - 100
                                originIncluded = 1
                            } else {
                                veCate = property.1 - 1000
                                originIncluded = 2
                            }
                            EnemyAddController.addInitialEnemyAtGrid2(veCate: veCate, originInclude: originIncluded, enemyPosArray: property.2, grid: gameScene.gridNode) {
                                /* Update enemy position */
                                EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                                /* Move to next state */
                                gameScene.gameState = .SignalSending
                                done = false
                            }
                            break;
                        default:
                            break;
                    }
                /* Add enemy in the middle */
                } else if addingIndex != 0 {
                    if addingIndex < 10 {
                        /* Add enemy normaly */
                        EnemyAddController.addEnemyAtGrid1(addIndex: addingIndex, grid: gameScene.gridNode) {
                            /* Reset start enemy position array */
                            gameScene.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                            
                            /* Update enemy position */
                            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
                            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                            
                            
                            /* Move to next state */
                            gameScene.gameState = .SignalSending
                            done = false
                        }
                    } else {
                        /* Add enemy normaly */
                        EnemyAddController.addEnemyAtGrid2(addIndex: addingIndex, grid: gameScene.gridNode) {
                            /* Reset start enemy position array */
                            gameScene.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                            
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
        let stageLevel = GameStageController.adjustGameSceneLevel()
        guard gameScene.countTurnForAddEnemy < EnemyProperty.addEnemyManager[stageLevel].count else { return completion() }
        while EnemyProperty.addEnemyManager[stageLevel][gameScene.countTurnForAddEnemy] == 0 {
            gameScene.countTurnForAddEnemy += 1
        }
        return completion()
        
    }
}
