//
//  VEEquivalentController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct VEEquivalentController {
    public static var gameScene: GameScene!
    private static var checkingEnemies = [Enemy]()
    public static var numOfCheck = 0
    
    public static func showEqGrid(enemies: [Enemy], eqRob: EqRob? = nil) {
        gameScene.eqGrid.isHidden = false
        let bg = EqBackground(gameScene: gameScene, enemies: enemies, eqRob: eqRob)
        bg.zPosition = 8
        gameScene.eqGrid.zPosition = 9
        SignalController.speed = 0.002
        lineupEnemies(enemies: enemies)
        gameScene.signalHolder.zPosition = 9
        gameScene.valueOfX.zPosition = 10
        gameScene.valueOfX.text = ""
        if let eqRob = eqRob {
            lineupEqRob(eqRob: eqRob)
        }
    }
    
    private static func lineupEnemies(enemies: [Enemy]) {
        checkingEnemies = enemies
        if enemies.count == 1 {
            for enemy in enemies {
                setEnemy(enemy: enemy, x: 6, y: 11)
            }
        } else if enemies.count == 2 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: 3*i+4, y: 11)
            }
        } else if enemies.count == 3 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: 2*i+3, y: 11)
            }
        } else if enemies.count == 4 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: 2*i+2, y: 11)
            }
        } else if enemies.count == 5 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: i+3, y: 11)
            }
        } else if enemies.count == 6 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: i+2, y: 11)
            }
        } else if enemies.count == 7 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: i+2, y: 11)
            }
        } else if enemies.count == 8 {
            for (i, enemy) in enemies.enumerated() {
                setEnemy(enemy: enemy, x: i+1, y: 11)
            }
        } else {
            for (i, enemy) in enemies.enumerated() {
                guard i < 9 else { return }
                setEnemy(enemy: enemy, x: i+1, y: 11)
            }
        }
    }
    
    private static func lineupEqRob(eqRob: EqRob) {
        var xPos = 0
        switch checkingEnemies.count {
        case 1:
            xPos = 2
        case 2:
            xPos = 1
        case 3:
            xPos = 1
        case 5:
            xPos = 1
        default:
            xPos = 0
        }
        eqRob.setScale(0.8)
        eqRob.eqPosX = xPos
        let pos = getPosOnScene(x: xPos, y: 11)
        if EqRobTouchController.state == .AliveInstruction {
            eqRob.go(toPos: pos) {
                let rotate = SKAction.rotate(toAngle: .pi * 1/2, duration: 1.0)
                eqRob.run(rotate, completion: {
                    eqRob.variableExpressionLabel.isHidden = false
                })
            }
        } else if EqRobTouchController.state == .DeadInstruction {
            eqRob.variableExpressionLabel.isHidden = false
            eqRob.zRotation = .pi * 1/2
            eqRob.position = pos
            eqRob.isHidden = false
        }
    }
    
    private static func setEnemy(enemy: Enemy, x: Int, y: Int) {
        let pos = getPosOnGrid(x: x, y: y)
        enemy.eqPosX = x
        enemy.eqPosY = y
        enemy.zPosition = 10
        enemy.xValueLabel.text = ""
        enemy.variableExpressionLabel.color = UIColor.white
        let move = SKAction.move(to: pos, duration: 1.0)
        enemy.run(move)
    }
    
    private static func getPosOnGrid(x: Int, y: Int) -> CGPoint {
        let xPos = (Double(x)+0.5)*gameScene.eqGrid.cellWidth
        let yPos = (Double(y)+0.5)*gameScene.eqGrid.cellHeight
        return CGPoint(x: xPos, y: yPos)
    }
    
    private static func getPosOnScene(x: Int, y: Int) -> CGPoint {
        let xPos = CGFloat((Double(x)+0.5)*gameScene.eqGrid.cellWidth) + gameScene.eqGrid.position.x
        let yPos = CGFloat((Double(y)+0.5)*gameScene.eqGrid.cellHeight) + gameScene.eqGrid.position.y
        return CGPoint(x: xPos, y: yPos)
    }
    
    public static func hideEqGrid() {
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.eqGrid)
        GridActiveAreaController.resetSquareArray(color: "blue", grid: gameScene.eqGrid)
        gameScene.eqGrid.isHidden = false
        gameScene.eqGrid.zPosition = -1
        SignalController.speed = 0.006
        CharacterController.doctor.changeBalloonTexture(index: 0)
        gameScene.signalHolder.zPosition = 0
        gameScene.valueOfX.zPosition = 1
        numOfCheck = 0
        gameScene.xValue = gameScene.xValue
        backEnemies()
        getBG(completion: { bg in
            bg?.removeFromParent()
        })
        gameScene.eqRob.setScale(1.0)
        gameScene.eqRob.variableExpressionLabel.isHidden = true
        if EqRobTouchController.state == .AliveInstruction {
            gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
                let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                gameScene.eqRob.run(rotate)
            }
        } else if EqRobTouchController.state == .DeadInstruction {
            gameScene.eqRob.zRotation = .pi * -1/2
            gameScene.eqRob.isHidden = true
            gameScene.eqRob.position = EqRobController.eqRobOriginPos
        }
        
    }
    
    public static func getBG(completion: @escaping (EqBackground?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var cand: EqBackground? = nil
        for child in gameScene.children {
            dispatchGroup.enter()
            if let bg = child as? EqBackground {
                cand = bg
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(cand)
        })
    }
    
    public static func backEnemies() {
        for enemy in checkingEnemies {
            enemy.xValueLabel.text = ""
            enemy.variableExpressionLabel.fontColor = UIColor.white
            if enemy.punchIntervalForCount == 0 {
                enemy.forcusForAttack(color: UIColor.red, value: gameScene.xValue)
            }
            let pos = getPosOnGrid(x: enemy.positionX, y: enemy.positionY)
            enemy.zPosition = 4
            let move = SKAction.move(to: pos, duration: 1.0)
            enemy.run(move)
        }
    }
}
