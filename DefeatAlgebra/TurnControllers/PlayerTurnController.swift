//
//  PlayerTurnController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/24.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct PlayerTurnController {
    public static var gameScene: GameScene!
    public static var done = false
    
    public static func displayPhase() {
        gameScene.buttonRetry.state = .msButtonNodeStateHidden
        gameScene.playerPhaseLabel.isHidden = false
        let wait = SKAction.wait(forDuration: gameScene.phaseLabelTime)
        let moveState = SKAction.run({ gameScene.playerTurnState = .ItemOn })
        let seq = SKAction.sequence([wait, moveState])
        gameScene.run(seq)
    }
    
    public static func itemOn() {
        gameScene.playerPhaseLabel.isHidden = true
        gameScene.playerTurnState = .MoveState
        
        if !gameScene.eqRobTurnCountingDone {
            gameScene.eqRobTurnCountingDone = true
            if gameScene.eqRob.turn > 0 {
                gameScene.eqRob.turn -= 1
            }
        }
    }
    
    public static func moveState() {
        if gameScene.hero.moveDoneFlag == false {
            /* Display move area */
            GridActiveAreaController.showMoveArea(posX: gameScene.hero.positionX, posY: gameScene.hero.positionY, moveLevel: gameScene.hero.moveLevel, grid: gameScene.gridNode)
        }
        
        /* Display action buttons */
        gameScene.buttonAttack.isHidden = false
        gameScene.buttonItem.isHidden = false
    }
    
    public static func usingItem() {
        switch gameScene.itemType {
        case .None:
            break;
        case .timeBomb:
            GridActiveAreaController.showtimeBombSettingArea(grid: gameScene.gridNode)
            break;
        default:
            break;
        }
    }
    
    public static func turnEnd() {
        /* Reset Flags */
        gameScene.enemyTurnDoneFlag = false
        gameScene.hero.moveDoneFlag = false
        gameScene.hero.attackDoneFlag = false
        gameScene.eqRobTurnCountingDone = false
        
        /* Remove action buttons */
        gameScene.buttonAttack.isHidden = true
        gameScene.buttonItem.isHidden = true
        
        /* Remove move area */
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.gridNode)
        GridActiveAreaController.resetSquareArray(color: "purple", grid: gameScene.gridNode)
        
        /* Remove dead enemy from enemyArray */
        gameScene.gridNode.enemyArray = gameScene.gridNode.enemyArray.filter({ $0.aliveFlag == true })
        
        if gameScene.gridNode.enemyArray.count > 0 {
            gameScene.gridNode.enemyArray[0].myTurnFlag = true
        }
        
        if gameScene.dupliExsist {
            gameScene.dupliExsist = false
            EnemyMoveController.rePosEnemies(enemiesArray: gameScene.gridNode.enemyArray, gridNode: gameScene.gridNode)
        }
        
        
        if gameScene.willFastForward {
            gameScene.willFastForward = false
            AddEnemyTurnController.fastForward() {
                gameScene.countTurnForAddEnemy -= 1
                gameScene.gameState = .AddEnemy
            }
        } else {
            /* Display enemy phase label */
            if gameScene.enemyPhaseLabelDoneFlag == false {
                gameScene.enemyPhaseLabelDoneFlag = true
                gameScene.enemyPhaseLabel.isHidden = false
                let wait = SKAction.wait(forDuration: gameScene.phaseLabelTime)
                let moveState = SKAction.run({ gameScene.gameState = .EnemyTurn })
                let seq = SKAction.sequence([wait, moveState])
                gameScene.run(seq)
            }
        }
    }
}
