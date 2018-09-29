//
//  StageClearTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/26.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct StageClearTurnController {
    public static var gameScene: GameScene!
    
    public static func clear() {
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        /* Play Sound */
        if MainMenu.soundOnFlag {
            if gameScene.stageClearSoundDone == false {
                gameScene.stageClearSoundDone = true
                gameScene.stageClear.play()
                gameScene.main.stop()
            }
        }
        gameScene.clearLabel.isHidden = false
        
        if GameScene.stageLevel < 7 {
            gameScene.buttonNextLevel.state = .msButtonNodeStateActive
        } else {
            if gameScene.dispClearLabelDone == false {
                gameScene.dispClearLabelDone = true
                gameScene.createTutorialLabel(text: "Congulatulations!!", posY: 1120, size: 50)
                gameScene.createTutorialLabel(text: "You beat all stages!", posY: 1040, size: 35)
                gameScene.createTutorialLabel(text: "But keep it mind!", posY: 700, size: 35)
                gameScene.createTutorialLabel(text: "Algebra is your friend in real world!", posY: 640, size: 35)
            }
        }
    }
}
