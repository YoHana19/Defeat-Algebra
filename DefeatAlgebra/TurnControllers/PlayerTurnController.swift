//
//  PlayerTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/24.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct PlayerTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    public static var isNewEqRobTurn = true
    public static var countTurn = 0
    
    public static func displayPhase() {
        if !done {
            done = true
            gameScene.buttonRetry.state = .msButtonNodeStateHidden
            gameScene.playerPhaseLabel.isHidden = false
            let wait = SKAction.wait(forDuration: gameScene.phaseLabelTime)
            gameScene.run(wait, completion: {
                gameScene.playerTurnState = .ItemOn
                done = false
            })
        }
    }
    
    public static func itemOn() {
        if !done {
            done = true
            gameScene.playerPhaseLabel.isHidden = true
            if GameScene.stageLevel >= MainMenu.eqRobStartTurn && GameScene.stageLevel < MainMenu.eqRobNewStartTurn {
                if countTurn == 0 {
                    if gameScene.gridNode.enemyArray.count > 1 {
                        gameScene.itemType = .None
                        gameScene.playerTurnState = .UsingItem
                        gameScene.gameState = .PlayerTurn
                        EqRobJudgeController.getTwoEnemyRandomly() {
                            EqRobJudgeController.eqRobGoToScan()
                        }
                    } else {
                        gameScene.playerTurnState = .MoveState
                    }
                    countTurn = 1
                } else {
                    gameScene.playerTurnState = .MoveState
                    countTurn -= 1
                }
            } else if GameScene.stageLevel >= MainMenu.eqRobNewStartTurn && GameScene.stageLevel < MainMenu.cannonStartTurn {
                if countTurn == 0 {
                    if isNewEqRobTurn {
                        checkMultiSameEnemy() { over3 in
                            if over3 > 0 {
                                gameScene.itemType = .EqRob
                                gameScene.playerTurnState = .UsingItem
                                gameScene.gameState = .PlayerTurn
                                EqRobController.scannedVECategory = over3
                                EqRobController.execute(0, enemy: nil)
                            } else {
                                gameScene.playerTurnState = .MoveState
                            }
                        }
                        isNewEqRobTurn = false
                    } else {
                        if gameScene.gridNode.enemyArray.count > 1 {
                            gameScene.itemType = .None
                            gameScene.playerTurnState = .UsingItem
                            gameScene.gameState = .PlayerTurn
                            EqRobJudgeController.getTwoEnemyRandomly() {
                                EqRobJudgeController.eqRobGoToScan()
                            }
                        } else {
                            gameScene.playerTurnState = .MoveState
                        }
                        isNewEqRobTurn = true
                    }
                    countTurn = Int(arc4random_uniform(2))+1
                } else {
                    gameScene.playerTurnState = .MoveState
                    countTurn -= 1
                }
            } else {
                gameScene.playerTurnState = .MoveState
            }
        }
    }
    
    private static func checkMultiSameEnemy(completion: @escaping (Int) -> Void) {
        
        var cates = [Int]()
        var uniCates = [Int]()
        let dispatchGroup = DispatchGroup()
        for enemy in gameScene.gridNode.enemyArray {
            dispatchGroup.enter()
            VECategory.getCategory(ve: enemy.variableExpressionString) { cate in
                if !uniCates.contains(cate) {
                    uniCates.append(cate)
                }
                cates.append(cate)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            var over3 = -1
            let dispatchGroup2 = DispatchGroup()
            for cate in uniCates {
                dispatchGroup2.enter()
                if cates.filter({ $0 == cate}).count > 2 {
                    over3 = cate
                    dispatchGroup2.leave()
                } else {
                    dispatchGroup2.leave()
                }
            }
            dispatchGroup2.notify(queue: .main, execute: {
                return completion(over3)
            })
        })
    }
    
    public static func moveState() {
        if gameScene.hero.moveDoneFlag == false {
            /* Display move area */
            GridActiveAreaController.showMoveArea(posX: gameScene.hero.positionX, posY: gameScene.hero.positionY, moveLevel: gameScene.hero.moveLevel, grid: gameScene.gridNode)
        }
        
        /* Display action buttons */
        gameScene.buttonAttack.isHidden = false
    }
    
    public static func usingItem() {
        switch gameScene.itemType {
        case .timeBomb:
            GridActiveAreaController.showtimeBombSettingArea(grid: gameScene.gridNode)
            break;
        default:
            break;
        }
    }
    
    public static func turnEnd() {
        /* Reset Flags */
        gameScene.enemyTurnDoneFlag = false
        gameScene.hero.moveDoneFlag = false
        gameScene.eqRobTurnCountingDone = false
        done = false
        
        /* Remove action buttons */
        gameScene.buttonAttack.isHidden = true
        
        /* Remove move area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        /* Remove dead enemy from enemyArray */
        gameScene.gridNode.enemyArray = gameScene.gridNode.enemyArray.filter({ $0.aliveFlag == true })
        
        if gameScene.gridNode.enemyArray.count > 0 {
            gameScene.gridNode.enemyArray[0].myTurnFlag = true
        }
        
        if gameScene.dupliExsist {
            gameScene.dupliExsist = false
            EnemyMoveController.rePosEnemies(enemiesArray: gameScene.gridNode.enemyArray, gridNode: gameScene.gridNode)
        }
        
        
        if gameScene.willFastForward {
            gameScene.willFastForward = false
            AddEnemyTurnController.fastForward() {
                gameScene.countTurnForAddEnemy -= 1
                gameScene.gameState = .AddEnemy
            }
        } else {
            /* Display enemy phase label */
            if gameScene.enemyPhaseLabelDoneFlag == false {
                gameScene.enemyPhaseLabelDoneFlag = true
                gameScene.enemyPhaseLabel.isHidden = false
                let wait = SKAction.wait(forDuration: gameScene.phaseLabelTime)
                let moveState = SKAction.run({ gameScene.gameState = .EnemyTurn })
                let seq = SKAction.sequence([wait, moveState])
                gameScene.run(seq)
            }
        }
    }
}
