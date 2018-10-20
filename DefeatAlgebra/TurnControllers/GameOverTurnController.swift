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
                gameScene.gameOverSoundDone = true
                gameScene.main.stop()
                let sound = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: true)
                gameScene.run(sound)
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
            gameScene.gameOverSoundDone = true
            gameScene.main.play()
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
}
