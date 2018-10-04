//
//  EqRobController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct EqRobController {
    public static var gameScene: GameScene!
    public static var eqRobOriginPos: CGPoint!
    private static var lines = [SKShapeNode]()
    private static var isPerfect = false
    public static var selectedEnemies = [Enemy]()
    public static var sameVeEnemies = [Enemy]()
    private static var enemiesToDestroy = [Enemy]()
    private static var selectedEnemyIndex: Int = 0
    private static var attackingEnemyIndex: Int = 0
    private static var missedEnemies = [Enemy]()
    private static var instructedEnemy: Enemy?
    
    public static var doctorOffPos = CGPoint(x: -200, y: 170)
    public static var doctorOnPos: [CGPoint] = [
        CGPoint(x: 150, y: 170),
        CGPoint(x: 90, y: 100),
        CGPoint(x: 150, y: -370)
    ]
    public static var doctorScale: [CGFloat] = [
        0.85,
        0.6,
        0.75
    ]
    
    public static func execute(_ index: Int, enemy: Enemy?) {
        switch index {
        case 0:
            showInputPanelWithDoctor()
            break;
        case 1:
            showSelectionPanelWithDoctor()
            break;
        case 2:
            setSelectedEnemyOnPanel(enemy: enemy!)
            break;
        case 3:
            isPerfect = eqRobGoToAttack()
            break;
        case 4:
            instruction()
            break;
        case 5:
            tellCharging()
            break;
        case 6:
            if EqRobTouchController.state == .Dead {
                tellReborn()
            } else if EqRobTouchController.state == .Charging {
                tellChargeDone()
            }
            break;
        default:
            break;
        }
    }
    
    public static func back(_ index: Int) {
        switch index {
        case 0:
            guard EqRobTouchController.state == .Pending else { return }
            hideInputPanelWithDoctor()
            break;
        case 1:
            resetSelectedEnemyOnPanel()
            break;
        case 2:
            resetAll()
            break;
        case 3:
            allDone()
            break;
        case 4:
            goBack()
            break;
        default:
            break;
        }
    }
    
    private static func showInputPanelWithDoctor() {
        resetAll()
        showInputPanel()
        gameScene.eqRob.stopAction()
        gameScene.eqRob.go(to: gameScene.inputPanel.eqRobPoint, completion: {
            gameScene.eqRob.rotateForever()
        })
        CharacterController.doctor.setScale(doctorScale[0])
        CharacterController.doctor.balloon.isHidden = false
        doctorSays(in: .WillInput, value: nil)
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos[0])
    }
    
    private static func hideInputPanelWithDoctor() {
        gameScene.inputPanel.variableExpression = ""
        hideInputPanel()
        EqRobTouchController.state = .Ready
        gameScene.eqRob.stopAction()
        gameScene.eqRob.resetVEElementArray()
        gameScene.eqRob.go(toPos: eqRobOriginPos) {
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            gameScene.eqRob.run(rotate)
        }
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
    }
    
    private static func showSelectionPanelWithDoctor() {
        CannonController.changeZpos(zPos: 3)
        hideInputPanel()
        EqRobTouchController.state = .WillAttack
        showSelectionPanel()
        gameScene.eqRob.stopAction()
        gameScene.eqRob.go(toPos: eqRobOriginPos) {
            EqRobTouchController.state = .Attack
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            gameScene.eqRob.run(rotate)
        }
        CharacterController.doctor.setScale(doctorScale[1])
        doctorSays(in: .WillSelectEnemies, value: gameScene.inputPanel.confirmedVE)
        gameScene.selectionPanel.veLabel.text = gameScene.inputPanel.confirmedVE
        CharacterController.doctor.move(from: nil, to: doctorOnPos[1])
    }
    
    private static func setSelectedEnemyOnPanel(enemy: Enemy) {
        guard selectedEnemyIndex < 8 else {
            doctorSays(in: .WarnSelection, value: nil)
            return
        }
        doctorSays(in: .SelectingEnemies, value: nil)
        if selectedEnemyIndex < 1 {
            drawLine(start: gameScene.eqRob.absolutePos(), end: enemy.absolutePos())
        } else {
            drawLine(start: selectedEnemies[selectedEnemyIndex-1].absolutePos(), end: enemy.absolutePos())
        }
        selectedEnemies.append(enemy)
        gameScene.selectionPanel.setSelectedEnemy(target: enemy, index: selectedEnemyIndex)
        selectedEnemyIndex += 1
    }
    
    private static func resetSelectedEnemyOnPanel() {
        lines.forEach { $0.removeFromParent() }
        selectedEnemies.forEach { $0.isSelectedForEqRob = false }
        selectedEnemyIndex = 0
        doctorSays(in: .WillSelectEnemies, value: gameScene.inputPanel.confirmedVE)
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        gameScene.selectionPanel.resetAllEnemies()
    }
    
    private static func eqRobGoToAttack() -> Bool {
        doctorSays(in: .EqRobGo, value: nil)
        eqRobAttackFirst(selectedEnemies[0])
        gameScene.selectionPanel.againButton.isHidden = true
        sameVeEnemies = gameScene.gridNode.enemyArray.filter { $0.vECategory == gameScene.eqRob.veCategory }
        if sameVeEnemies.count == selectedEnemies.count {
            return true
        } else {
            return false
        }
    }
    
    private static func eqRobAttackFirst(_ target: Enemy) {
        lines[attackingEnemyIndex].removeFromParent()
        if gameScene.eqRob.veCategory == target.vECategory {
            if attackingEnemyIndex < selectedEnemies.count-1 {
                gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    destroyEnemiesAtOnce()
                    gameScene.eqRob.go(toPos: eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        gameScene.eqRob.run(rotate)
                    }
                }
            }
        } else {
            destroyEnemiesAtOnce()
            gameScene.eqRob.killed(target) {
                eqRobDead(enemy: target)
            }
        }
    }
    
    private static func eqRobAttackNext(_ target: Enemy) {
        lines[attackingEnemyIndex].removeFromParent()
        if gameScene.eqRob.veCategory == target.vECategory {
            if attackingEnemyIndex < selectedEnemies.count-1 {
                gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    enemiesToDestroy.append(target)
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    destroyEnemiesAtOnce()
                    gameScene.eqRob.go(toPos: eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        gameScene.eqRob.run(rotate)
                    }
                }
            }
        } else {
            destroyEnemiesAtOnce()
            gameScene.eqRob.killed(target) {
                eqRobDead(enemy: target)
            }
        }
    }
    
    private static func eqRobDead(enemy: Enemy) {
        lines.forEach { $0.removeFromParent() }
        doctorSays(in: .EqRobDestroyed, value: nil)
        instructedEnemy = enemy
        let wait = SKAction.wait(forDuration: 2.0)
        gameScene.run(wait, completion: {
            pointingKillerEnemy()
        })
    }
    
    private static func pointingKillerEnemy() {
        instructedEnemy?.pointing()
        doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForDestroyedInstruction2())
        EqRobTouchController.state = .DeadInstruction
    }
    
//    private static func makeInsturctionForKilled(enemy: Enemy) {
//        let enemyPos = enemy.absolutePos()
//        if enemy.positionY < 6 {
//            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y+gameScene.selectionPanel.texture!.size().height+90)
//            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
//            enemy.pointing()
//            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
//            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
//            CharacterController.doctor.changeBalloonTexture(index: 1)
//            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
//                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
//                EqRobTouchController.state = .DeadInstruction
//            }
//        } else {
//            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y-65)
//            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
//            enemy.pointing()
//            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
//            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
//            CharacterController.doctor.changeBalloonTexture(index: 1)
//            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
//                //print(EqRobLines.curIndex)
//                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
//                EqRobTouchController.state = .DeadInstruction
//            }
//        }
//    }

    private static func makeInsturctionForKilled() {
        instructedEnemy?.removePointing()
        //doctorSays(in: .DestroyedInstruction, value: EqRobLines.subLinesForDestroyedInstruction2())
        VEEquivalentController.showEqGrid(enemies: [instructedEnemy!], eqRob: gameScene.eqRob)
        gameScene.selectionPanel.resetInstruction()
        gameScene.selectionPanel.resetAllEnemies()
    }
    
    private static func setDemoCalculation() {
        gameScene.selectionPanel.setXVlaue(value: String(EqRobLines.selectedRand))
        gameScene.selectionPanel.instructedEnemy.showCalculation(value: EqRobLines.selectedRand)
        gameScene.selectionPanel.instructedEqRob.showCalculation(value: EqRobLines.selectedRand)
    }
    
    private static func attackDone() {
        if isPerfect {
            gameScene.selectionPanel.resetAllEnemies()
            doctorSays(in: .PerfectKill, value: nil)
        } else {
            doctorSays(in: .MissEnemies, value: nil)
        }
        let wait = SKAction.wait(forDuration: 3.0)
        gameScene.run(wait, completion: {
            if isPerfect {
                back(3)
            } else {
                pointingMissedEnemies()
            }
        })
    }
    
    private static func destroyEnemiesAtOnce(delay: TimeInterval = 1.0) {
        let wait = SKAction.wait(forDuration: delay)
        gameScene.run(wait, completion: {
            for enemy in enemiesToDestroy {
                EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene) {
                    if let i = enemiesToDestroy.index(of: enemy) {
                        enemiesToDestroy.remove(at: i)
                    }
                }
            }
        })
    }
    
    private static func pointingMissedEnemies() {
        missedEnemies = sameVeEnemies.filter { !self.selectedEnemies.contains($0) }
        missedEnemies.forEach { $0.pointing() }
        doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction2())
        EqRobTouchController.state = .AliveInstruction
    }
    
//    private static func makeInsturctionForMiss(enemy: Enemy) {
//        let enemyPos = enemy.absolutePos()
//        gameScene.gridNode.enemyArray.forEach { $0.removePointing() }
//        instructedEnemy?.pointing()
//        if enemy.positionY < 6 {
//            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y+gameScene.selectionPanel.texture!.size().height+90)
//            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
//            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
//            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
//            CharacterController.doctor.changeBalloonTexture(index: 1)
//            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
//                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
//                EqRobTouchController.state = .AliveInstruction
//            }
//        } else {
//            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y-65)
//            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
//            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
//            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
//            CharacterController.doctor.changeBalloonTexture(index: 1)
//            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
//                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
//                EqRobTouchController.state = .AliveInstruction
//            }
//        }
//    }

    private static func makeInsturctionForMiss() {
        //EqRobTouchController.state = .Dead // just for disabel touching
        missedEnemies.forEach { $0.removePointing() }
        VEEquivalentController.showEqGrid(enemies: missedEnemies, eqRob: gameScene.eqRob)
        gameScene.selectionPanel.resetInstruction()
        gameScene.selectionPanel.resetAllEnemies()
    }
    
    private static func instruction() {
        switch EqRobTouchController.state {
        case .DeadInstruction:
            switch EqRobLines.curIndex {
            case 0:
                VEEquivalentController.hideEqGrid()
                back(3)
                break;
            case 1:
                makeInsturctionForKilled()
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.subLinesForDestroyedInstruction2())
                break;
            case 2:
                guard VEEquivalentController.numOfCheck > 3 else { return }
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.subLinesForDestroyedInstruction2())
                break;
            case 3:
                guard VEEquivalentController.numOfCheck > 3 else { return }
                VEEquivalentController.getBG() { bg in
                    guard let backGround = bg else { return }
                    guard backGround.isEnable, !backGround.isUserInteractionEnabled else { return }
                    doctorSays(in: .DestroyedInstruction, value: EqRobLines.subLinesForDestroyedInstruction2())
                }
                break;
            default:
                break;
            }
            break;
        case .AliveInstruction:
            switch EqRobLines.curIndex {
            case 0:
                VEEquivalentController.hideEqGrid()
                back(3)
                break;
            case 1:
                makeInsturctionForMiss()
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction2())
                break;
            case 2:
                guard VEEquivalentController.numOfCheck > 3 else { return }
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction2())
                break;
            case 3:
                guard VEEquivalentController.numOfCheck > 3 else { return }
                VEEquivalentController.getBG() { bg in
                    guard let backGround = bg else { return }
                    guard backGround.isEnable, !backGround.isUserInteractionEnabled else { return }
                    doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction2())
                }
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }
    
    private static func resetAll() {
        selectedEnemyIndex = 0
        attackingEnemyIndex = 0
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        EqRobTouchController.state = .Ready
        isPerfect = false
        gameScene.selectionPanel.againButton.isHidden = false
    }
    
    private static func allDone() {
        CannonController.changeZpos(zPos: 5)
        selectedEnemyIndex = 0
        attackingEnemyIndex = 0
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        if EqRobTouchController.state == .DeadInstruction {
            EqRobTouchController.state = .Dead
            gameScene.eqRob.turn = gameScene.eqRob.deadTurnIndex
            gameScene.eqRob.wasDead = true
        } else  {
            EqRobTouchController.state = .Charging
            gameScene.eqRob.turn = gameScene.eqRob.chargingTurnIndex
            gameScene.eqRob.wasDead = false
        }
        gameScene.eqRob.resetVEElementArray()
        isPerfect = false
        instructedEnemy?.removePointing()
        gameScene.selectionPanel.resetInstruction()
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
        //gameScene.eqRob.position = eqRobOriginPos
        gameScene.itemType = .None
        CharacterController.doctor.changeBalloonTexture(index: 0)
        ItemTouchController.othersTouched()
    }
    
    private static func tellCharging() {
        comeAndTell()
        doctorSays(in: .Charging, value: nil)
    }
    
    private static func tellChargeDone() {
        comeAndTell()
        doctorSays(in: .ChargeDone, value: nil)
        let wait = SKAction.wait(forDuration: 3.0)
        gameScene.run(wait, completion: {
            EqRobTouchController.state = .Ready
            goBack()
        })
    }
    
    private static func tellReborn() {
        comeAndTell()
        doctorSays(in: .Reborn, value: nil)
        gameScene.eqRob.isHidden = false
        let wait = SKAction.wait(forDuration: 3.0)
        gameScene.run(wait, completion: {
            EqRobTouchController.state = .Ready
            goBack()
        })
    }
    
    private static func comeAndTell() {
        CharacterController.doctor.setScale(doctorScale[0])
        CharacterController.doctor.balloon.isHidden = false
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos[0])
    }
    
    private static func goBack() {
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
    }
    
    private static func showInputPanel() {
       gameScene.inputPanel.isHidden = false
    }
    
    private static func hideInputPanel() {
        gameScene.inputPanel.isHidden = true
    }
    
    public static func showSelectionPanel() {
        gameScene.selectionPanel.isHidden = false
        gameScene.selectionPanel.setScale(0.55)
        gameScene.selectionPanel.position = CGPoint(x: 390, y: 294)
    }
    
    private static func hideSelectionPanel() {
        gameScene.selectionPanel.isHidden = true
    }
    
    public static func doctorSays(in state: EqRobLinesState, value: String?) {
        EqRobLines.getLines(state: state, value: value).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line, pos: 0)
        }
    }
    
    private static func drawLine(start: CGPoint, end: CGPoint) {
        let line = Line(startPoint: start, endPoint: end)
        lines.append(line)
        gameScene.addChild(line)
    }
    
}

enum EqRobState {
    case Ready, Pending, WillAttack, Attack, Attacking, DeadInstruction, AliveInstruction, Dead, Charging
}

struct EqRobTouchController {
    
    public static var state: EqRobState = .Ready
    
    public static func onEvent() {
        switch state {
        case .Ready:
            EqRobController.execute(0, enemy: nil)
            state = .Pending
            break;
        case .Attack:
            guard EqRobController.selectedEnemies.count > 0 else { return }
            EqRobController.execute(3, enemy: nil)
            state = .Attacking
            break;
        case .Charging:
            EqRobController.execute(5, enemy: nil)
            break;
        default:
            break;
        }
    }
}

enum EqRobLinesState {
    case WillInput, WillSelectEnemies, SelectingEnemies, WarnSelection, EqRobGo, EqRobDestroyed, DestroyedInstruction, MissEnemies, MissEnemiesInstruction, PerfectKill, Charging, ChargeDone, Reborn
}

struct EqRobLines {
    static func getLines(state: EqRobLinesState, value: String?) -> String {
        switch state {
        case .WillInput:
            return "エクロボに暗号を入力するのじゃ！"
        case .WillSelectEnemies:
            return value! + "と同じ暗号を持つ敵を選ぶのじゃ！"
        case .SelectingEnemies:
            return subLineRandom(lines: subLinesForSelecting)
        case .WarnSelection:
            return "すまぬ!\n8体までしか選択できんのじゃ"
        case .EqRobGo:
            return "エクロボ 発進じゃ！"
        case .EqRobDestroyed:
            return "むむぅ...\nどうやら選択ミスしてしまったようじゃの"
        case .DestroyedInstruction:
            return value!
        case .MissEnemies:
            return "よくやったぞ！\nじゃが、まだ倒せた敵はいたようじゃのぅ"
        case .MissEnemiesInstruction:
            return value!
        case .PerfectKill:
            return "パーフェクトじゃ！！\nさすがじゃのう"
        case .Charging:
            return "エクロボは、まだチャージ中じゃ"
        case .ChargeDone:
            return "チャージ完了じゃ！！"
        case .Reborn:
            return "修理完了じゃ\nもう壊さないように頼むぞ！"
        default:
            return ""
        }
    }
    
    static var selectedLine = ""
    static let subLinesForSelecting: [String] = [
        "エクロボをタッチすれば、選択した敵たちに向かって発進するぞ",
        "やり直したい時は、下のやり直しボタンを押すのじゃ",
        "xの数に関係なく、同じになる暗号を選ぶのじゃ",
        "見た目に騙されるでないぞ。xの値が違っても同じ大きさになるものは、同じ暗号なのじゃ"
    ]
    
    static var curIndex = 0
    static func setSubLineForDestroyedInstruction(enemy: Enemy, eqRob: EqRob, eqRobVe: String) -> String {
        if curIndex == 1 || curIndex == 2 {
            let value = demo(enemy: enemy, eqRob: eqRob, eqRobVe: eqRobVe)
            return subLinesForDestroyedInstruction(value: value)
        } else {
            let value = "\(eqRobVe)と\(enemy.variableExpressionString)"
            return subLinesForDestroyedInstruction(value: value)
        }
    }
    
    static func subLinesForDestroyedInstruction(value: String) -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return value + "が違う暗号なのか確かめるぞ"
        case 1:
            curIndex += 1
            return "例えば" + value
        case 2:
            curIndex += 1
            return "他にも" + value
        case 3:
            curIndex += 1
            return "このようにxの値が色々変わった時、異なる値になる暗号は違うものじゃ"
        case 4:
            curIndex = 0
            return "次から、間違えないように気をつけるんじゃぞ"
        default:
            return ""
        }
    }
    
    static func subLinesForDestroyedInstruction2() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "この敵を間違えてしまったようじゃな"
        case 1:
            curIndex += 1
            return "違う文字式なのか確かめるぞ"
        case 2:
            curIndex += 1
            return "xの数によって文字式の計算結果が違うことがわかったかな"
        case 3:
            curIndex = 0
            return "次は、間違えないように気をつけるんじゃぞ"
        default:
            return ""
        }
    }
    
    static func setSubLineForMissEnemiesInstruction(enemy: Enemy, eqRob: EqRob, eqRobVe: String) -> String {
        if curIndex == 0 {
            let value = eqRobVe
            return subLinesForMissEnemiesInstruction(value: value)
        } else if curIndex == 1 {
            let value = "\(eqRobVe)と\(enemy.variableExpressionString)"
            return subLinesForMissEnemiesInstruction(value: value)
        } else if curIndex == 2 || curIndex == 3 {
            let value = demo(enemy: enemy, eqRob: eqRob, eqRobVe: eqRobVe)
            return subLinesForMissEnemiesInstruction(value: value)
        } else {
            return subLinesForMissEnemiesInstruction(value: "")
        }
    }
    
    static func subLinesForMissEnemiesInstruction(value: String) -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return value + "が見逃してしまった敵じゃ"
        case 1:
            curIndex += 1
            return value + "が同じ暗号なのか確かめるぞ"
        case 2:
            curIndex += 1
            return "例えば" + value
        case 3:
            curIndex += 1
            return "他にも" + value
        case 4:
            curIndex += 1
            return "このようにxの値が色々変わっても、同じ値になる暗号は同じものじゃ"
        case 5:
            curIndex = 0
            return "次は、パーフェクトを目指すのじゃ！"
        default:
            return ""
        }
    }
    
    static func subLinesForMissEnemiesInstruction2() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "この敵を見逃してしまったようじゃな"
        case 1:
            curIndex += 1
            return "同じ文字式なのか確かめるぞ"
        case 2:
            curIndex += 1
            return "xがどんな数でも文字式の計算結果が同じになることがわかったかな"
        case 3:
            curIndex = 0
            return "次は、パーフェクトを目指すのじゃ！"
        default:
            return ""
        }
    }
    
    static var selectedRand = 0
    static let randArray = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    static func demo(enemy: Enemy, eqRob: EqRob, eqRobVe: String) -> String {
        let cand = randArray.filter { $0 != selectedRand }
        let rand = arc4random_uniform(UInt32(cand.count))
        selectedRand = cand[Int(rand)]
        let valueOfEnemy = VECategory.calculateValue(veCategory: enemy.vECategory, value: selectedRand)
        let valueOfEqRob = eqRob.calculateValue(value: selectedRand)
        print("\(selectedRand), \(valueOfEqRob), \(valueOfEnemy)")
        if valueOfEnemy == valueOfEqRob {
            return "x=\(selectedRand)のとき、\(eqRobVe)は\(valueOfEqRob)、\(enemy.variableExpressionString)は\(valueOfEnemy)で同じ値になるじゃろ"
        } else {
            return "x=\(selectedRand)のとき、\(eqRobVe)は\(valueOfEqRob)、\(enemy.variableExpressionString)は\(valueOfEnemy)で違う値になるじゃろ"
        }
    }
    
    static func subLineOrder(lines: [String]) -> String {
        if let index = lines.index(of: selectedLine) {
            if index < lines.count-1 {
                selectedLine = lines[index+1]
                return selectedLine
            } else {
                selectedLine = ""
                return selectedLine
            }
        } else {
            selectedLine = lines[0]
            return selectedLine
        }
    }
    
    static func subLineRandom(lines: [String]) -> String {
        let otherLines = lines.filter { $0 != selectedLine }
        let index = arc4random_uniform(UInt32(otherLines.count))
        selectedLine = otherLines[Int(index)]
        return selectedLine
    }
}
