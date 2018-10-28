//
//  SignalSendingController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/24.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct SignalSendingTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    
    static func sendSignal(in times: Int? = nil, completion: @escaping() -> Void) {
        if !done {
            done = true
            gameScene.gridNode.numOfTurnEndEnemy = 0
            
            /* Calculate each enemy's variable expression */
            let willAttackEnemies = gameScene.gridNode.enemyArray.filter{ $0.state == .Attack && $0.reachCastleFlag == false }
            if willAttackEnemies.count > 0 {
                let max = GameStageController.signalVale()
                gameScene.xValue =  times ?? Int(arc4random_uniform(UInt32(max)))+1
                gameScene.valueOfX.fontColor = UIColor.red
                let dispatchGroup = DispatchGroup()
                for enemy in willAttackEnemies {
                    dispatchGroup.enter()
                    enemy.calculatePunchLength(value: gameScene.xValue)
                    SignalController.send(target: enemy, num: gameScene.xValue) {
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    gameScene.gameState = .AddItem
                    done = false
                    return completion()
                })
            } else {
                gameScene.xValue = 0
                gameScene.valueOfX.fontColor = UIColor.red
                gameScene.gameState = .AddItem
                done = false
                return completion()
            }
        }
    }
}
