//
//  ScenarioFunction.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/03.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ScenarioFunction {
    
    private static var arms = [EnemyArm]()
    private static var fists = [EnemyFist]()
    
    public static func startPlayerTurn(phase: PlayerTurnState) {
        ScenarioController.scenarioScene.gameState = .PlayerTurn
        ScenarioController.scenarioScene.playerTurnState = phase
        ScenarioController.scenarioScene.isCharactersTurn = false
        ScenarioController.scenarioScene.gridNode.isTutorial = false
    }
    
    public static func heroMove(gridX: Int, gridY: Int, completion: @escaping () -> Void) {
        GridActiveAreaController.resetSquareArray(color: "blue", grid: ScenarioController.scenarioScene.gridNode)
        /* Move hero to touch location */
        ScenarioController.scenarioScene.hero.heroMoveToDest(posX: gridX, posY: gridY) {
            /* Keep track hero position */
            ScenarioController.scenarioScene.hero.positionX = gridX
            ScenarioController.scenarioScene.hero.positionY = gridY
            return completion()
        }
    }
    
    public static func showNHideEnemyPhase(completion: @escaping () -> Void) {
        ScenarioController.scenarioScene.enemyPhaseLabel.isHidden = false
        let wait = SKAction.wait(forDuration: 0.5)
        ScenarioController.scenarioScene.run(wait, completion: {
            ScenarioController.scenarioScene.enemyPhaseLabel.isHidden = true
            return completion()
        })
    }
    
    public static func showNHideHeroPhase(completion: @escaping () -> Void) {
        ScenarioController.scenarioScene.playerPhaseLabel.isHidden = false
        let wait = SKAction.wait(forDuration: 0.5)
        ScenarioController.scenarioScene.run(wait, completion: {
            ScenarioController.scenarioScene.playerPhaseLabel.isHidden = true
            return completion()
        })
    }
    
    public static func enemyPunchNMove(enemy: Enemy, num: Int?, completion: @escaping () -> Void) {
        let value = num ?? ScenarioController.scenarioScene.xValue
        enemy.calculatePunchLength(value: value)
        enemy.resolveShield {
            /* Do punch */
            enemy.punch() { armAndFist in
                enemy.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    enemy.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: enemy.valueOfEnemy) {
                        enemy.removeArmNFist()
                        enemy.positionY -= enemy.valueOfEnemy
                        enemy.variableExpressionLabel.fontColor = UIColor.white
                        enemy.state = .Stay
                        enemy.xValueLabel.text = ""
                        return completion()
                    }
                }
            }
        }
    }
    
    public static func enemyPunch(enemy: Enemy, num: Int?, completion: @escaping () -> Void) {
        let value = num ?? ScenarioController.scenarioScene.xValue
        enemy.calculatePunchLength(value: value)
        enemy.resolveShield {
            /* Do punch */
            enemy.punch() { armAndFist in
                enemy.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    arms = newArms
                    fists = armAndFist.fist
                    return completion()
                }
            }
        }
    }
    
    public static func enemyDrawPunch(enemy: Enemy, completion: @escaping () -> Void) {
        enemy.drawPunchNMove(arms: arms, fists: fists, num: enemy.valueOfEnemy) {
            enemy.removeArmNFist()
            enemy.positionY -= enemy.valueOfEnemy
            enemy.variableExpressionLabel.fontColor = UIColor.white
            enemy.state = .Stay
            enemy.xValueLabel.text = ""
            return completion()
        }
    }
    
    public static func enemyMoveNDefend(enemy: Enemy, direction: Direction, completion: @escaping () -> Void) {
        enemy.direction = direction
        EnemyMoveController.moveAni(enemy: enemy, gridNode: ScenarioController.scenarioScene.gridNode) {
            enemy.state = .Defence
            enemy.punchIntervalForCount -= 1
            return completion()
        }
    }
    
    public static func judgeCanAttack() -> Bool {
        guard let hero = ScenarioController.scenarioScene.hero else { return false }
        let enemy = ScenarioController.scenarioScene.gridNode.enemyArray[0]
        var canAttack = false
        if hero.positionX-1 == enemy.positionX && hero.positionY == enemy.positionY {
            canAttack = true
        }
        if hero.positionX+1 == enemy.positionX && hero.positionY == enemy.positionY {
            canAttack = true
        }
        if hero.positionX == enemy.positionX && hero.positionY-1 == enemy.positionY {
            canAttack = true
        }
        if hero.positionX == enemy.positionX && hero.positionY+1 == enemy.positionY {
            canAttack = true
        }
        return canAttack
    }
    
    
    
    public static func eqRobSimulatorTutorialTrriger(key: String = "") {
        guard GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = VEEquivalentController.gameScene as? ScenarioScene else { return }
        if ScenarioController.currentActionIndex == 5 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 6 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 8 {
            guard key == "compare1" else { return }
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 10 {
            guard key == "last" else { return }
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 16 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 21 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 22 {
            guard key == "perfect" else { return }
            ScenarioController.currentActionIndex += 2
            ScenarioController.controllActions()
        }
    }
    
    public static func eqRobNewSimulatorTutorialTrriger(key: String = "") -> Bool {
        guard GameScene.stageLevel == MainMenu.eqRobNewStartTurn, let _ = VEEquivalentController.gameScene as? ScenarioScene else { return true }
        if ScenarioController.currentActionIndex == 3 {
            ScenarioController.controllActions()
            return false
        } else if ScenarioController.currentActionIndex == 6 {
            guard key == "eqRob" else { return true }
            ScenarioController.controllActions()
            return true
        } else if ScenarioController.currentActionIndex == 7 {
            guard key == "perfect" else { return false }
            ScenarioController.currentActionIndex += 2
            ScenarioController.controllActions()
            return false
        } else {
            return true
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
