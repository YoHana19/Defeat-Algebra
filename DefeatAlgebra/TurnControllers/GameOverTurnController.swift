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
        if gameScene.heroKilled {
            gameScene.buttonRetry.state = .msButtonNodeStateActive
        }
        gameScene.buttonRetryFromTop.state = .msButtonNodeStateActive
        
        if !done {
            done = true
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
}
