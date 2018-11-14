//
//  GameOverTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/26.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct GameOverTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    
    public static func gameOver() {
        gameScene.gameOverLabel.isHidden = false
        /* Play Sound */
        if MainMenu.soundOnFlag {
            if gameScene.gameOverSoundDone == false {
                SoundController.stopBGM()
                gameScene.gameOverSoundDone = true
                SoundController.sound(scene: gameScene, sound: .GameOver)
            }
        }
        
        if !done {
            done = true
            let wait = SKAction.wait(forDuration: calculateWaitTime())
            gameScene.run(wait, completion: {
                gameScene.enemyKillingHero = nil
                if gameScene.heroKilled {
                    gameScene.buttonRetry.isHidden = false
                    gameScene.buttonRetry.state = .msButtonNodeStateActive
                }
                gameScene.buttonRetryFromTop.state = .msButtonNodeStateActive
            })
            
            DataController.setDataForEnemyKilled()
            DataController.setDataForGameOver(isHit: gameScene.heroKilled)
        }
    }
    
    public static func gameOverReset() {
        gameScene.gameOverLabel.isHidden = true
        gameScene.buttonRetryFromTop.state = .msButtonNodeStateHidden
        /* Play Sound */
        if MainMenu.soundOnFlag {
            gameScene.gameOverSoundDone = false
            if let _ = gameScene as? ScenarioScene {
                GameStageController.soundForScenario()
            } else {
                GameStageController.sound()
            }
            gameScene.removeAllActions()
        }
    }
    
    private static func calculateWaitTime() -> TimeInterval {
        if let enemy = gameScene.enemyKillingHero {
            let dif = enemy.positionY - gameScene.hero.positionY
            let leftVal = enemy.valueOfEnemy - dif
            let leftPunchLength = CGFloat(leftVal) * enemy.singlePunchLength
            let totalLength = leftPunchLength + enemy.punchLength
            return TimeInterval(totalLength * enemy.punchSpeed)
        } else {
            return 0.5
        }
    }
    
    public static func calculateWaitTime(enemy: Enemy) -> TimeInterval {
        let dif = enemy.positionY - gameScene.hero.positionY
        let leftVal = enemy.valueOfEnemy - dif
        let leftPunchLength = CGFloat(leftVal) * enemy.singlePunchLength
        let totalLength = leftPunchLength + enemy.punchLength
        return TimeInterval(totalLength * enemy.punchSpeed)
    }
}
