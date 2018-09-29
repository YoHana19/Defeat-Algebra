//
//  EqRobTutorialController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/25.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqRobTutorialController {
    
    private static var lines = [SKShapeNode]()
    public static var isPerfect = false
    public static var selectedEnemies = [Enemy]()
    public static var sameVeEnemies = [Enemy]()
    private static var enemiesToDestroy = [Enemy]()
    private static var selectedEnemyIndex: Int = 0
    private static var attackingEnemyIndex: Int = 0
    public static var instructedEnemy: Enemy?
    
    static func userTouch(on name: String?) -> Bool {
        switch GameScene.stageLevel {
        case 4:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 4:
                    ScenarioController.controllActions()
                    return false
                case 5:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 6:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 7:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 8:
                    if name == "button1" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 9:
                    if name == "buttonOK" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                default:
                    return true
                }
            } else {
                return true
            }
        default:
            return true
        }
    }
    
    static func showInputPanel() {
        EqRobController.gameScene.inputPanel.isHidden = false
        EqRobController.gameScene.eqRob.go(to: EqRobController.gameScene.inputPanel.eqRobPoint, completion: {
            EqRobController.gameScene.eqRob.rotateForever()
        })
        CharacterController.doctor.setScale(EqRobController.doctorScale[0])
        CharacterController.doctor.balloon.isHidden = false
        CharacterController.doctor.move(from: nil, to: EqRobController.doctorOnPos[0])
    }
    
    static func showSelectionPanel() {
        EqRobController.gameScene.inputPanel.isHidden = true
        EqRobTouchController.state = .WillAttack
        EqRobController.showSelectionPanel()
        EqRobController.gameScene.eqRob.stopAction()
        EqRobController.gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
            EqRobTouchController.state = .Attack
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            EqRobController.gameScene.eqRob.run(rotate)
        }
        EqRobController.gameScene.selectionPanel.veLabel.text = "2x+1"
    }
    
    static func setSelectedEnemyOnPanel(enemy: Enemy) {
        if selectedEnemyIndex < 1 {
            drawLine(start: EqRobController.gameScene.eqRob.absolutePos(), end: enemy.absolutePos())
        } else {
            drawLine(start: selectedEnemies[selectedEnemyIndex-1].absolutePos(), end: enemy.absolutePos())
        }
        selectedEnemies.append(enemy)
        EqRobController.gameScene.selectionPanel.setSelectedEnemy(target: enemy, index: selectedEnemyIndex)
        selectedEnemyIndex += 1
    }
    
    private static func drawLine(start: CGPoint, end: CGPoint) {
        let line = Line(startPoint: start, endPoint: end)
        lines.append(line)
        EqRobController.gameScene.addChild(line)
    }
    
    static func eqRobGoToAttack() -> Bool {
        eqRobAttackFirst(selectedEnemies[0])
        sameVeEnemies = EqRobController.gameScene.gridNode.enemyArray.filter { $0.vECategory == EqRobController.gameScene.eqRob.veCategory }
        if sameVeEnemies.count == selectedEnemies.count {
            return true
        } else {
            return false
        }
    }
    
    private static func eqRobAttackFirst(_ target: Enemy) {
        lines[attackingEnemyIndex].removeFromParent()
        if EqRobController.gameScene.eqRob.veCategory == target.vECategory {
            if attackingEnemyIndex < selectedEnemies.count-1 {
                EqRobController.gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    EqRobController.gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                EqRobController.gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    EqRobController.gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    destroyEnemiesAtOnce()
                    EqRobController.gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        EqRobController.gameScene.eqRob.run(rotate)
                    }
                }
            }
        }
    }
    
    private static func eqRobAttackNext(_ target: Enemy) {
        lines[attackingEnemyIndex].removeFromParent()
        if EqRobController.gameScene.eqRob.veCategory == target.vECategory {
            if attackingEnemyIndex < selectedEnemies.count-1 {
                EqRobController.gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    EqRobController.gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                EqRobController.gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    EqRobController.gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    destroyEnemiesAtOnce()
                    EqRobController.gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        EqRobController.gameScene.eqRob.run(rotate)
                    }
                }
            }
        }
    }
    
    private static func attackDone() {
        if isPerfect {
            EqRobController.gameScene.selectionPanel.resetAllEnemies()
            EqRobController.gameScene.selectionPanel.isHidden = true
        }
        let wait = SKAction.wait(forDuration: 3.0)
        EqRobController.gameScene.run(wait, completion: {
            ScenarioController.controllActions()
        })
    }
    
    private static func destroyEnemiesAtOnce(delay: TimeInterval = 1.0) {
        let wait = SKAction.wait(forDuration: delay)
        EqRobController.gameScene.run(wait, completion: {
            for enemy in enemiesToDestroy {
                EnemyDeadController.hitEnemy(enemy: enemy, gameScene: EqRobController.gameScene) {
                    if let i = enemiesToDestroy.index(of: enemy) {
                        enemiesToDestroy.remove(at: i)
                    }
                }
            }
        })
    }
    
    static func pointingMissedEnemies() {
        var missedEnemies = sameVeEnemies.filter { !self.selectedEnemies.contains($0) }
        missedEnemies.forEach { $0.pointing() }
        if missedEnemies.count < 2 {
            instructedEnemy = missedEnemies[0]
        } else {
            instructedEnemy = missedEnemies[0]
        }
    }
    
    static func makeInsturctionForMiss() {
        let enemyPos = instructedEnemy!.absolutePos()
        EqRobController.gameScene.gridNode.enemyArray.forEach { $0.removePointing() }
        instructedEnemy?.pointing()
        let panelPos = CGPoint(x: EqRobController.gameScene.size.width/2-EqRobController.gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y-65)
        let doctorPos = CGPoint(x: EqRobController.doctorOnPos[2].x, y: panelPos.y+EqRobController.doctorOnPos[2].y)
        EqRobController.gameScene.selectionPanel.setInstruction(enemyVe: instructedEnemy!.variableExpressionString)
        EqRobController.gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
        CharacterController.doctor.changeBalloonTexture(index: 1)
        CharacterController.doctor.moveWithScaling(to: doctorPos, value: EqRobController.doctorScale[2], duration: 2.0) {
            ScenarioController.controllActions()
        }
    }
    
    static func setDemoCalculation(value: Int) {
        EqRobController.gameScene.selectionPanel.setXVlaue(value: String(value))
        EqRobController.gameScene.selectionPanel.instructedEnemy.showCalculation(value: value)
        EqRobController.gameScene.selectionPanel.instructedEqRob.showCalculation(value: value)
    }
}
