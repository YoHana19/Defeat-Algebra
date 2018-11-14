//
//  AddItemTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct AddItemTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    public static var itemPos = [(Int, Int, Int)]()
    
    public static func add() {
        gameScene.playerTurnState = .DisplayPhase
        gameScene.playerTurnDoneFlag = false
        gameScene.enemyPhaseLabelDoneFlag = false
        gameScene.enemyPhaseLabel.isHidden = true
        
        /* Move to next state */
        gameScene.gameState = .PlayerTurn
    }
}
