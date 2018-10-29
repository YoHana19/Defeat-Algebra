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
    public static var done = false
    
    public static func clear() {
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        /* Play Sound */
        if MainMenu.soundOnFlag {
            if gameScene.stageClearSoundDone == false {
                gameScene.stageClearSoundDone = true
                SoundController.playBGM(bgm: .StageClear, isLoop: false)
            }
        }
        gameScene.clearLabel.isHidden = false
        
        if GameScene.stageLevel < MainMenu.lastTurn {
            gameScene.buttonNextLevel.state = .msButtonNodeStateActive
        } else {
            if gameScene.dispClearLabelDone == false {
                gameScene.dispClearLabelDone = true
                gameScene.createTutorialLabel(text: "おめでとう！", posY: 700, size: 45)
                gameScene.createTutorialLabel(text: "全ステージクリアだ！", posY: 600, size: 45)
            }
        }
        
        if !done {
            done = true
            DataController.setDataForEnemyKilled()
        }
    }
}
