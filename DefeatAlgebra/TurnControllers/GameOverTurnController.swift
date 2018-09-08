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
        gameScene.buttonRetry.state = .msButtonNodeStateActive
    }
}
