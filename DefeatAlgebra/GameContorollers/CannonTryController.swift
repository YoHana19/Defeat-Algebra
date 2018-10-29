//
//  CannonTryController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct CannonTryController {
    public static var gameScene: GameScene!
    private static var checkingEnemy = Enemy(variableExpressionSource: ["x"], forEdu: false)
    public static var numOfCheck = 0
    public static var numOfChangeVE = 0
    public static var hintOn: Bool = false {
        didSet {
            if !oldValue && hintOn {
                if let _ = gameScene as? ScenarioScene {
                    if GameScene.stageLevel == 7 && ScenarioController.currentActionIndex > 17 {
                        CannonController.execute(5, cannon: nil)
                    } else {
                        hintOn = false
                    }
                } else {
                    CannonController.execute(5, cannon: nil)
                }
            }
        }
    }
    
    public static var isCorrect: Bool = false {
        didSet {
            if !oldValue && isCorrect {
                if let _ = gameScene as? ScenarioScene {
                    if GameScene.stageLevel == 7 && ScenarioController.currentActionIndex > 17 {
                        CannonController.execute(6, cannon: nil)
                    }
                } else {
                    CannonController.execute(6, cannon: nil)
                }
            }
        }
    }
    
    public static func showEqGrid(enemy: Enemy, cannon: Cannon) {
        SoundController.playBGM(bgm: .SimBGM, isLoop: true)
        gameScene.hero.setPhysics(isActive: false)
        gameScene.eqGrid.isHidden = false
        gameScene.eqGrid.zPosition = 9
        gameScene.inputPanelForCannon.zPosition = 12
        gameScene.eqRob.zPosition = 7
        let bg = CannonBackground(gameScene: gameScene, enemy: enemy, cannon: cannon)
        bg.zPosition = 8
        SignalController.speed = 0.002
        lineup(cannon: cannon, enemy: enemy)
        gameScene.signalHolder.zPosition = 9
        gameScene.valueOfX.zPosition = 10
        gameScene.valueOfX.text = ""
    }
    
    private static func lineup(cannon: Cannon, enemy: Enemy) {
        checkingEnemy = enemy
        setEnemy(enemy: enemy)
        cannon.zPosition = 11
    }
    
    private static func setEnemy(enemy: Enemy) {
        let pos = getPosOnGrid(x: enemy.positionX, y: enemy.positionY)
        enemy.cannonPosY = enemy.positionY
        enemy.zPosition = 10
        enemy.xValueLabel.text = ""
        enemy.variableExpressionLabel.color = UIColor.white
        let move = SKAction.move(to: pos, duration: 0.5)
        enemy.run(move)
    }
    
    public static func resetEnemy() {
        checkingEnemy.isHidden = false
        let pos = getPosOnGrid(x: checkingEnemy.positionX, y: checkingEnemy.positionY)
        checkingEnemy.cannonPosY = checkingEnemy.positionY
        checkingEnemy.xValueLabel.text = ""
        checkingEnemy.variableExpressionLabel.color = UIColor.white
        checkingEnemy.position = pos
    }
    
    private static func getPosOnGrid(x: Int, y: Int) -> CGPoint {
        let xPos = (Double(x)+0.5)*gameScene.eqGrid.cellWidth
        let yPos = (Double(y)+0.5)*gameScene.eqGrid.cellHeight
        return CGPoint(x: xPos, y: yPos)
    }
    
    public static func hideEqGrid() {
        if let _ = gameScene as? ScenarioScene {
            GameStageController.soundForScenario()
        } else {
            GameStageController.sound()
        }
        gameScene.hero.setPhysics(isActive: true)
        CannonController.selectedCannon.zPosition = 6
        gameScene.eqGrid.isHidden = true
        gameScene.eqGrid.zPosition = -1
        gameScene.eqRob.zPosition = 11
        gameScene.inputPanelForCannon.zPosition = 10
        SignalController.speed = 0.006
        CharacterController.doctor.changeBalloonTexture(index: 0)
        gameScene.signalHolder.zPosition = 0
        gameScene.valueOfX.zPosition = 1
        numOfCheck = 0
        numOfChangeVE = 0
        gameScene.valueOfX.text = ""
        backEnemy()
        getBG(completion: { bg in
            bg?.removeFromParent()
        })
        gameScene.isCharactersTurn = false
        gameScene.gridNode.isTutorial = false
        CannonController.execute(1, cannon: nil)
    }
    
    public static func getBG(completion: @escaping (CannonBackground?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var cand: CannonBackground? = nil
        for child in gameScene.children {
            dispatchGroup.enter()
            if let bg = child as? CannonBackground {
                cand = bg
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(cand)
        })
    }
    
    public static func backEnemy() {
        checkingEnemy.xValueLabel.text = ""
        checkingEnemy.calculatePunchLength(value: gameScene.xValue)
        checkingEnemy.variableExpressionLabel.fontColor = UIColor.white
        checkingEnemy.punchIntervalForCount = 0
        checkingEnemy.forcusForAttack(color: UIColor.red, value: gameScene.xValue)
        checkingEnemy.zPosition = 4
    }
    
}
