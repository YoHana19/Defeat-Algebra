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
    private static var missedEnemies = [Enemy]()
    
    static func userTouch(on name: String?) -> Bool {
        switch GameScene.stageLevel {
        case MainMenu.eqRobStartTurn:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 15:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 16:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 17:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 18:
                    if name == "button1" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 19:
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
    
    public static func pointingMissedEnemies() {
        missedEnemies = sameVeEnemies.filter { !self.selectedEnemies.contains($0) }
        missedEnemies.forEach { $0.pointing() }
        CharacterController.doctor.balloon.isHidden = false
        EqRobController.doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction())
        CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctorOnPos.x, y: CharacterController.doctorOnPos.y-200))
        EqRobTouchController.state = .AliveInstruction
    }
    
    public static func makeInsturctionForMiss() {
        missedEnemies.forEach { $0.removePointing() }
        VEEquivalentController.showEqGrid(enemies: missedEnemies, eqRob: EqRobController.gameScene.eqRob)
        EqRobController.gameScene.selectionPanel.resetInstruction()
        EqRobController.gameScene.selectionPanel.resetAllEnemies()
    }
    
    public static func allDone() {
        selectedEnemyIndex = 0
        attackingEnemyIndex = 0
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        isPerfect = false
        EqRobController.gameScene.selectionPanel.resetInstruction()
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.changeBalloonTexture(index: 0)
    }
}
