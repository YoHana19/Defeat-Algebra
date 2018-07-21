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
    private static var selectedEnemyIndex: Int = 0
    private static var attackingEnemyIndex: Int = 0
    private static var instructedEnemy: Enemy?
    private static var doctorOffPos = CGPoint(x: -200, y: 170)
    private static var doctorOnPos: [CGPoint] = [
        CGPoint(x: 150, y: 170),
        CGPoint(x: 90, y: 100),
        CGPoint(x: 150, y: -370)
    ]
    private static var doctorScale: [CGFloat] = [
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
        hideInputPanel()
        EqRobTouchController.state = .Ready
        gameScene.eqRob.stopAction()
        gameScene.eqRob.go(toPos: eqRobOriginPos) {
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            gameScene.eqRob.run(rotate)
        }
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
    }
    
    private static func showSelectionPanelWithDoctor() {
        hideInputPanel()
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
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    gameScene.eqRob.go(toPos: eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        gameScene.eqRob.run(rotate)
                    }
                }
            }
        } else {
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
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    gameScene.selectionPanel.putCrossOnEnemyOnPanel(index: attackingEnemyIndex)
                    attackDone()
                    gameScene.eqRob.go(toPos: eqRobOriginPos) {
                        let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                        gameScene.eqRob.run(rotate)
                    }
                }
            }
        } else {
            gameScene.eqRob.killed(target) {
                eqRobDead(enemy: target)
            }
        }
    }
    
    private static func eqRobDead(enemy: Enemy) {
        lines.forEach { $0.removeFromParent() }
        doctorSays(in: .EqRobDestroyed, value: nil)
        EqRobTouchController.state = .DeadInstruction
        makeInsturctionForKilled(enemy: enemy)
        instructedEnemy = enemy
    }
    
    private static func makeInsturctionForKilled(enemy: Enemy) {
        let enemyPos = enemy.absolutePos()
        if enemy.positionY < 6 {
            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y+gameScene.selectionPanel.texture!.size().height+90)
            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
            enemy.pointing()
            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
            CharacterController.doctor.changeBalloonTexture(index: 1)
            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
            }
        } else {
            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y-65)
            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
            enemy.pointing()
            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
            CharacterController.doctor.changeBalloonTexture(index: 1)
            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
                print(EqRobLines.curIndex)
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
            }
        }
    }
    
    private static func setDemoCalculation() {
        gameScene.selectionPanel.setXVlaue(value: String(EqRobLines.selectedRand))
        gameScene.selectionPanel.instructedEnemy.showCalculation(value: EqRobLines.selectedRand)
        gameScene.selectionPanel.instructedEqRob.showCalculation(value: EqRobLines.selectedRand)
    }
    
    private static func attackDone() {
        if isPerfect {
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
    
    private static func pointingMissedEnemies() {
        var missedEnemies = sameVeEnemies.filter { !self.selectedEnemies.contains($0) }
        missedEnemies.forEach { $0.pointing() }
        if missedEnemies.count < 2 {
            instructedEnemy = missedEnemies[0]
            doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: "この敵"))
        } else {
            missedEnemies.sort { $0.variableExpressionString.count > $1.variableExpressionString.count }
            instructedEnemy = missedEnemies[0]
            doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: "これらの敵"))
        }
        EqRobTouchController.state = .AliveInstruction
    }
    
    private static func makeInsturctionForMiss(enemy: Enemy) {
        let enemyPos = enemy.absolutePos()
        gameScene.gridNode.enemyArray.forEach { $0.removePointing() }
        instructedEnemy?.pointing()
        if enemy.positionY < 6 {
            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y+gameScene.selectionPanel.texture!.size().height+90)
            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
            CharacterController.doctor.changeBalloonTexture(index: 1)
            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
            }
        } else {
            let panelPos = CGPoint(x: gameScene.size.width/2-gameScene.selectionPanel.texture!.size().width/2, y: enemyPos.y-65)
            let doctorPos = CGPoint(x: doctorOnPos[2].x, y: panelPos.y+doctorOnPos[2].y)
            gameScene.selectionPanel.setInstruction(enemyVe: enemy.variableExpressionString)
            gameScene.selectionPanel.moveWithScaling(to: panelPos, value: 1) {}
            CharacterController.doctor.changeBalloonTexture(index: 1)
            CharacterController.doctor.moveWithScaling(to: doctorPos, value: doctorScale[2], duration: 2.0) {
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: enemy, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
            }
        }
    }
    
    private static func instruction() {
        switch EqRobTouchController.state {
        case .DeadInstruction:
            if EqRobLines.curIndex == 0 {
                back(3)
            } else if EqRobLines.curIndex == 1 || EqRobLines.curIndex == 2 {
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
                setDemoCalculation()
            } else {
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.setSubLineForDestroyedInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
            }
            break;
        case .AliveInstruction:
            if EqRobLines.curIndex == 0 {
                back(3)
            } else if EqRobLines.curIndex == 1 {
                makeInsturctionForMiss(enemy: instructedEnemy!)
            } else if EqRobLines.curIndex == 2 || EqRobLines.curIndex == 3 {
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
                setDemoCalculation()
            } else {
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.setSubLineForMissEnemiesInstruction(enemy: instructedEnemy!, eqRob: gameScene.eqRob, eqRobVe: gameScene.selectionPanel.veLabel.text!))
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
        isPerfect = false
        instructedEnemy?.removePointing()
        gameScene.selectionPanel.resetInstruction()
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
        gameScene.eqRob.position = eqRobOriginPos
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
    
    private static func showSelectionPanel() {
        gameScene.selectionPanel.isHidden = false
    }
    
    private static func hideSelectionPanel() {
        gameScene.selectionPanel.isHidden = true
    }
    
    private static func doctorSays(in state: EqRobLinesState, value: String?) {
        EqRobLines.getLines(state: state, value: value).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line)
        }
    }
    
    private static func drawLine(start: CGPoint, end: CGPoint) {
        let line = Line(startPoint: start, endPoint: end)
        lines.append(line)
        gameScene.addChild(line)
    }
    
}

enum EqRobState {
    case Ready, Pending, Attack, Attacking, DeadInstruction, AliveInstruction, Dead, Charging
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
            return "エクロボに文字式を入力するのじゃ！"
        case .WillSelectEnemies:
            return value! + "と同じ文字式を持つ敵を選ぶのじゃ！"
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
        "xの数に関係なく、計算したら同じになる文字式を選ぶのじゃ",
        "見た目に騙されるでないぞ。計算して同じならば、同じ文字式なのじゃ"
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
            return value + "が本当に違う文字式なのか確かめるぞ"
        case 1:
            curIndex += 1
            return "例えば" + value
        case 2:
            curIndex += 1
            return "他にも" + value
        case 3:
            curIndex += 1
            return "このように、同じxの値で、計算結果が違う文字式は、異なる文字式なのじゃ"
        case 4:
            curIndex = 0
            return "次から、間違えないように気をつけるんじゃぞ"
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
            return value + "が本当に同じ文字式なのか確かめるぞ"
        case 2:
            curIndex += 1
            return "例えば" + value
        case 3:
            curIndex += 1
            return "他にも" + value
        case 4:
            curIndex += 1
            return "このように、同じxの値で、計算結果が同じ文字式は、同等の文字式なのじゃ"
        case 5:
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
        let valueOfEqRob = VECategory.calculateValue(veCategory: eqRob.veCategory, value: selectedRand)
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
