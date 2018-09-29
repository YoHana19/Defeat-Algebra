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
    
    static func sendSignal(in times: Int? = nil) {
        if !done {
            done = true
            gameScene.gridNode.numOfTurnEndEnemy = 0
            
            /* Calculate each enemy's variable expression */
            let willAttackEnemies = gameScene.gridNode.enemyArray.filter{ $0.state == .Attack && $0.reachCastleFlag == false }
            if willAttackEnemies.count > 0 {
                gameScene.xValue =  times ?? Int(arc4random_uniform(UInt32(3)))+1
                gameScene.valueOfX.fontColor = UIColor.red
                for enemy in willAttackEnemies {
                    enemy.calculatePunchLength(value: gameScene.xValue)
                    SignalController.send(target: enemy, num: gameScene.xValue)
                }
                if let maxDistanceEnemy = willAttackEnemies.max(by: {$1.distance(to: gameScene.madScientistNode) > $0.distance(to: gameScene.madScientistNode)}) {
                    let wait = SKAction.wait(forDuration: SignalController.signalSentDuration(target: maxDistanceEnemy, xValue: gameScene.xValue)+0.2)
                    gameScene.run(wait, completion: {
                        gameScene.gameState = .AddItem
                        done = false
                    })
                }
            } else {
                gameScene.valueOfX.text = "0"
                gameScene.valueOfX.fontColor = UIColor.red
                gameScene.gameState = .AddItem
                done = false
            }
        }
    }
    
    static func invisibleSignal(in times: Int? = nil) {
        if !done {
            done = true
            gameScene.gridNode.numOfTurnEndEnemy = 0
            let willAttackEnemies = gameScene.gridNode.enemyArray.filter{ $0.state == .Attack && $0.reachCastleFlag == false }
            if willAttackEnemies.count > 0 {
                gameScene.xValue = times ?? Int(arc4random_uniform(UInt32(3)))+1
                for enemy in willAttackEnemies {
                    enemy.calculatePunchLength(value: gameScene.xValue)
                    enemy.forcusForAttack(color: UIColor.red)
                }
            }
            gameScene.valueOfX.text = "？"
            gameScene.valueOfX.fontColor = UIColor.red
            gameScene.gameState = .AddItem
            done = false
        }
    }
}
