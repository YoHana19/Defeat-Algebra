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
                                syncPunchInterval()
                                /* Update enemy position */
                                EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                                /* Move to next state */
                                gameScene.gameState = .SignalSending
                                done = false
                            }
                            break;
                        case 1:
                            EnemyAddController.addInitialEnemyAtGrid1(enemyPosArray: property.2, grid: gameScene.gridNode) {
                                syncPunchInterval()
                                /* Update enemy position */
                                EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                                /* Move to next state */
                                gameScene.gameState = .SignalSending
                                done = false
                            }
                            break;
                        case 2:
                            var veCate = property.1
                            var isHard = false
                            if property.1 > 100 {
                                veCate = property.1 - 100
                                isHard = true
                            }
                            EnemyAddController.addInitialEnemyAtGrid2(veCate: veCate, isHard: isHard, enemyPosArray: property.2, grid: gameScene.gridNode) {
                                syncPunchInterval()
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
                            syncPunchInterval()
                            /* Update enemy position */
                            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
                            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                            
                            guard !gameScene.hero.isHidden else { return }
                            /* Move to next state */
                            gameScene.gameState = .SignalSending
                            done = false
                        }
                    } else {
                        var isHard = false
                        if addingIndex > 100 {
                            isHard = true
                        }
                        /* Add enemy for eqRob */
                        EnemyAddController.addEnemyAtGrid2(addIndex: addingIndex, grid: gameScene.gridNode, isHard: isHard) {
                            /* Reset start enemy position array */
                            gameScene.gridNode.startPosArray = [0,1,2,3,4,5,6,7,8]
                            syncPunchInterval()
                            /* Update enemy position */
                            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
                            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
                            
                            guard !gameScene.hero.isHidden else { return }
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
    
    private static func syncPunchInterval() {
        if GameScene.stageLevel == MainMenu.timeBombStartTurn || GameScene.stageLevel == MainMenu.cannonStartTurn+2 || GameScene.stageLevel == MainMenu.lastTurn {
            let rand = Int(arc4random_uniform(UInt32(3)))
            gameScene.gridNode.enemyArray.forEach({ $0.punchInterval = rand; $0.punchIntervalForCount = rand })
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
