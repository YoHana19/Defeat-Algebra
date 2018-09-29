//
//  EnemyTurn.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/22.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct EnemyTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    
    public static func onTurn() {
        /* Reset Flags */
        gameScene.playerTurnDoneFlag = false
        gameScene.enemyPhaseLabelDoneFlag = false
        gameScene.enemyPhaseLabel.isHidden = true
        
        if gameScene.enemyTurnDoneFlag == false {
            
            /* Reset enemy position */
            EnemyMoveController.resetEnemyPositon(grid: gameScene.gridNode)
            
            for enemy in gameScene.gridNode.enemyArray {
                /* Enemy reach to castle */
                if enemy.reachCastleFlag {
                    enemy.punchToCastle()
                    /* Enemy move */
                } else if enemy.punchIntervalForCount > 0 {
                    enemy.enemyMove()
                    /* Enemy punch */
                } else {
                    enemy.punchAndMove()
                }
            }
            
            /* If life is 0, GameOver */
            if gameScene.life < 1 {
                gameScene.gameState = .GameOver
            }
        }
    }
    
    
    public static func turnEnd() {
        if !done {
            done = true
            
            gameScene.enemyTurnDoneFlag = true
            /* Reset all stuffs */
            gameScene.gridNode.turnIndex = 0
            for enemy in gameScene.gridNode.enemyArray {
                enemy.turnDoneFlag = false
                enemy.myTurnFlag = false
            }
            
            /* remove wall */
            if gameScene.gridNode.wallSetArray.count > 0 {
                for (i, wall) in gameScene.gridNode.wallSetArray.enumerated() {
                    wall.removeFromParent()
                    if i == gameScene.gridNode.wallSetArray.count-1 {
                        /* Reset wall array */
                        gameScene.gridNode.wallSetArray.removeAll()
                    }
                }
            }
            
            /* Update enemy position */
            EnemyMoveController.updateEnemyPositon(grid: gameScene.gridNode)
            
            var logDefenceOn = false
            
            /* Check if enemy reach to castle */
            for enemy in gameScene.gridNode.enemyArray {
                if enemy.positionY == 0 {
                    if logDefence(enemy: enemy) {
                        enemy.setPhysics(isActive: false)
                        let wait = SKAction.wait(forDuration: 6.0)
                        enemy.run(wait, completion: {
                            enemy.setPhysics(isActive: true)
                        })
                        logDefenceOn = true
                    } else {
                        enemy.reachCastleFlag = true
                        enemy.punchIntervalForCount = 0
                    }
                }
            }
            
            if logDefenceOn && CannonController.willFireCannon.count > 0 {
                CannonController.fire() {}
                let wait = SKAction.wait(forDuration: 6.0)
                gameScene.run(wait, completion: {
                    gameScene.gameState = .AddEnemy
                    gameScene.playerTurnState = .DisplayPhase
                    done = false
                })
            } else if logDefenceOn {
                let wait = SKAction.wait(forDuration: 6.0)
                gameScene.run(wait, completion: {
                    gameScene.gameState = .AddEnemy
                    gameScene.playerTurnState = .DisplayPhase
                    done = false
                })
            } else if CannonController.willFireCannon.count > 0 {
                CannonController.fire() {
                    gameScene.gameState = .AddEnemy
                    gameScene.playerTurnState = .DisplayPhase
                    done = false
                }
            } else {
                gameScene.gameState = .AddEnemy
                gameScene.playerTurnState = .DisplayPhase
                done = false
            }
        }
    }
    
    private static func logDefence(enemy: Enemy) -> Bool {
        switch enemy.positionX {
        case 0:
            if let log = gameScene.childNode(withName: "log0") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 1:
            if let log = gameScene.childNode(withName: "log1") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 2:
            if let log = gameScene.childNode(withName: "log2") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 3:
            if let log = gameScene.childNode(withName: "log3") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 4:
            if let log = gameScene.childNode(withName: "log4") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 5:
            if let log = gameScene.childNode(withName: "log5") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 6:
            if let log = gameScene.childNode(withName: "log6") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 7:
            if let log = gameScene.childNode(withName: "log7") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true
            } else {
                return false
            }
        case 8:
            if let log = gameScene.childNode(withName: "log8") as? Log {
                doLogDefence(log: log, enemy: enemy)
                return true 
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    private static func doLogDefence(log: Log, enemy: Enemy) {
        log.hit() {}
        let wait = SKAction.wait(forDuration: 2.0)
        gameScene.run(wait, completion: {
            EnemyMoveController.blowedToback(enemy: enemy, grid: gameScene.gridNode)
            if !DAUserDefaultUtility.logDefenceFirst {
                SpeakInGameController.doAction(type: .LogDefenceFirstly)
            }
        })
    }
    
}
