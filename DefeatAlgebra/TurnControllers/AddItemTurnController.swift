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
        
        /* Make sure to call till complete adding enemy */
        if gameScene.compAddItemFlag == false {
            /* Make sure to call addEnemy once */
            if !done {
                done = true
                let stageLevel = GameStageController.adjustGameSceneLevel()
                
                gameScene.countTurnForAddItem += 1
                if gameScene.countTurnForAddItem >= ItemDropController.manager[stageLevel].count {
                    gameScene.compAddItemFlag = true
                    done = false
                    return
                }
                
                let addingIndex = ItemDropController.manager[stageLevel][gameScene.countTurnForAddItem]
                
                /* Add enemies initially */
                if gameScene.initialAddItemFlag {
                    gameScene.initialAddItemFlag = false
                    let items = ItemDropController.initialItemPosArray[stageLevel]
                    guard items.count > 0 else {
                        gameScene.gameState = .PlayerTurn
                        done = false
                        return
                    }
                    gameScene.plane.fly(items: items) {
                        /* Move to next state */
                        gameScene.gameState = .PlayerTurn
                        done = false
                    }
                } else if addingIndex != 0 {
                    let items = ItemDropController.itemManager[stageLevel][String(addingIndex)]
                    ItemDropController.makeItemPosArray(items: items!) { itemPosArray in
                        itemPos = itemPosArray
                        gameScene.plane.fly(items: itemPosArray) {
                            /* Move to next state */
                            gameScene.gameState = .PlayerTurn
                            done = false
                        }
                    }
                } else {
                    /* Move to next state */
                    gameScene.gameState = .PlayerTurn
                    done = false
                }
            }
        } else {
            /* Move to next state */
            gameScene.gameState = .PlayerTurn
            done = false
        }
    }
}
