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
    public static var eqRobOriginPos = CGPoint(x: -60, y: 246.5)
    public static var eqRobCenterPos = CGPoint(x: 375, y: 246.5)
    public static var scannedVECategory = 0
    private static var lines = [SKShapeNode]()
    public static var isPerfect = false
    public static var selectedEnemies = [Enemy]()
    public static var sameVeEnemies = [Enemy]()
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
            showEqRobWithDoctor()
            break;
        case 1:
            guard let enemy = enemy else { return }
            select(enemy: enemy)
            break;
        case 2:
            guard EqRobController.selectedEnemies.count > 0 else { return }
            isPerfect = eqRobGoToAttack()
            ScenarioFunction.eqRobSimulatorTutorialTrriger()
            break;
        case 3:
            instructionDone()
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
        case 7:
            instructionDone()
            break;
        case 8:
            tellReparing()
            break;
        default:
            break;
        }
    }
    
    public static func back(_ index: Int) {
        switch index {
        case 0:
            guard EqRobTouchController.state == .Pending else { return }
            
            break;
        case 1:
            resetSelectedEnemy()
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
    
    private static func showEqRobWithDoctor() {
        gameScene.gridNode.enemyArray.forEach({ $0.isSelectedForEqRob = false })
        gameScene.eqRob.go(toPos: eqRobCenterPos, completion: {
            gameScene.eqRob.look(at: gameScene.madScientistNode) {
                scan()
            }
        })
        gameScene.resizeLongVeNeighbor()
        CharacterController.doctor.setScale(doctorScale[0])
        CharacterController.doctor.changeBalloonTexture(index: 1)
        CharacterController.doctor.balloon.isHidden = false
        doctorSays(in: .Scan, value: nil)
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos[0])
    }
    
    public static func scan() {
        gridFlash() {
            var cands = [String]()
            if GameScene.stageLevel < MainMenu.secondDayStartTurn {
                cands = VECategory.originVEsForEqRob(veCate: scannedVECategory)
            } else {
                cands = VECategory.unSVEsForEqRob(veCate: scannedVECategory)
            }
            let rand = Int(arc4random_uniform(UInt32(cands.count)))
            gameScene.eqRob.variableExpressionString = cands[rand]
            gameScene.eqRob.veCategory = scannedVECategory
            gameScene.eqRob.showVELabel()
            doctorSays(in: .ScanDone, value: cands[rand])
            let wait = SKAction.wait(forDuration: 2.0)
            gameScene.run(wait, completion: {
                startSelect(ve: cands[rand])
                gameScene.againButton.isHidden = false
            })
        }
    }
    
    private static func gridFlash(completion: @escaping () -> Void) {
        let flashSpeed = 1.0
        /* Set flash animation */
        let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(flashSpeed/4))
        let wait = SKAction.wait(forDuration: TimeInterval(flashSpeed/4))
        let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(flashSpeed/4))
        let flash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
        SoundController.sound(scene: gameScene, sound: .Flash)
        gameScene.gridNode.run(flash, completion: {
            return completion()
        })
    }
    
    private static func startSelect(ve: String) {
        EqRobTouchController.state = .WillAttack
        doctorSays(in: .WillSelectEnemies, value: ve)
        ScenarioFunction.eqRobSimulatorTutorialTrriger()
    }
    
    private static func select(enemy: Enemy) {
        if selectedEnemyIndex < 1 {
            drawLine(start: gameScene.eqRob.absolutePos(), end: enemy.absolutePos())
        } else {
            drawLine(start: selectedEnemies[selectedEnemyIndex-1].absolutePos(), end: enemy.absolutePos())
        }
        selectedEnemies.append(enemy)
        selectedEnemyIndex += 1
        if let _ = gameScene as? ScenarioScene, ScenarioController.currentActionIndex < 19 {
        } else {
            doctorSays(in: .SelectingEnemies, value: nil)
        }
    }
    
    private static func resetSelection() {
        lines.forEach { $0.removeFromParent() }
        selectedEnemies.forEach { $0.isSelectedForEqRob = false }
        selectedEnemyIndex = 0
        doctorSays(in: .WillSelectEnemies, value: gameScene.inputPanel.confirmedVE)
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
    }
    
    private static func eqRobGoToAttack() -> Bool {
        doctorSays(in: .EqRobGo, value: nil)
        eqRobAttackFirst(selectedEnemies[0])
        gameScene.againButton.isHidden = true
        gameScene.gridNode.enemyArray.forEach({ $0.variableExpressionLabel.fontSize = $0.veLabelSize })
        let difEnemies = selectedEnemies.filter { $0.vECategory != gameScene.eqRob.veCategory }
        sameVeEnemies = gameScene.gridNode.enemyArray.filter { $0.vECategory == gameScene.eqRob.veCategory }
        if difEnemies.count > 0 {
            return false
        } else {
            if sameVeEnemies.count == selectedEnemies.count {
                return true
            } else {
                return false
            }
        }
    }
    
    private static func eqRobAttackFirst(_ target: Enemy) {
        lines[attackingEnemyIndex].removeFromParent()
        if gameScene.eqRob.veCategory == target.vECategory {
            if attackingEnemyIndex < selectedEnemies.count-1 {
                gameScene.eqRob.kill(target) {
                    SoundController.sound(scene: gameScene, sound: .EqAttack)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    SoundController.sound(scene: gameScene, sound: .EqAttack)
                    attackDone()
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
                    SoundController.sound(scene: gameScene, sound: .EqAttack)
                    attackingEnemyIndex += 1
                    eqRobAttackNext(selectedEnemies[attackingEnemyIndex])
                }
            } else {
                gameScene.eqRob.kill(target) {
                    SoundController.sound(scene: gameScene, sound: .EqAttack)
                    attackDone()
                }
            }
        } else {
            gameScene.eqRob.killed(target) {
                eqRobDead(enemy: target)
            }
        }
    }
    
    // perfect, miss -> attackDone()
    
    // fail -> eqRobDead
    
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
        instructedEnemy?.isSelectedForEqRob = false
        doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForDestroyedInstruction())
        EqRobTouchController.state = .DeadInstruction
        gameScene.eqRob.state = .Dead
        let wait = SKAction.wait(forDuration: 1.5)
        gameScene.run(wait, completion: {
            instruction()
        })
    }

    private static func makeInsturctionForKilled() {
        instructedEnemy?.removePointing()
        VEEquivalentController.showEqGrid(enemies: [instructedEnemy!], eqRob: gameScene.eqRob)
        gameScene.selectionPanel.resetInstruction()
        gameScene.selectionPanel.resetAllEnemies()
    }
    
    
    private static func attackDone() {
        if isPerfect {
            destroyEnemiesAtOnce()
            gameScene.eqRob.variableExpressionString = ""
            gameScene.eqRob.go(toPos: eqRobOriginPos) {}
            doctorSays(in: .PerfectKill, value: nil)
            let wait = SKAction.wait(forDuration: 3.0)
            gameScene.run(wait, completion: {
                allDone()
                ScenarioFunction.eqRobSimulatorTutorialTrriger(key: "perfect")
            })
        } else {
            doctorSays(in: .MissEnemies, value: nil)
            gameScene.eqRob.go(toPos: eqRobCenterPos) {
                pointingMissedEnemy()
                gameScene.eqRob.look(at: gameScene.madScientistNode) {}
            }
        }
    }
    
    private static func destroyEnemiesAtOnce(delay: TimeInterval = 1.0) {
        DataController.countForEnemyKilledByEqRob(num: sameVeEnemies.count)
        let wait = SKAction.wait(forDuration: delay)
        gameScene.run(wait, completion: {
            for enemy in sameVeEnemies {
                EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene, isEqRob: true) {}
            }
        })
    }
    
    private static func pointingMissedEnemy() {
        missedEnemies = sameVeEnemies.filter { !self.selectedEnemies.contains($0) }
        missedEnemies.sort(by: {$0.variableExpressionString.count > $1.variableExpressionString.count})
        instructedEnemy = missedEnemies[0]
        instructedEnemy?.pointing()
        doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction())
        EqRobTouchController.state = .AliveInstruction
        gameScene.eqRob.state = .Charging
        let wait = SKAction.wait(forDuration: 2.5)
        gameScene.run(wait, completion: {
            instructedEnemy?.removePointing()
            instruction()
        })
    }
    
    private static func makeInsturctionForMiss() {
        VEEquivalentController.showEqGrid(enemies: [instructedEnemy!], eqRob: gameScene.eqRob)
    }
    
    private static func instruction() {
        switch EqRobTouchController.state {
        case .DeadInstruction:
            switch EqRobLines.curIndex {
            case 0:
                break;
            case 1:
                makeInsturctionForKilled()
                doctorSays(in: .DestroyedInstruction, value: EqRobLines.subLinesForDestroyedInstruction())
                break;
            default:
                break;
            }
            break;
        case .AliveInstruction:
            switch EqRobLines.curIndex {
            case 0:
                break;
            case 1:
                makeInsturctionForMiss()
                doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction())
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }
    
    private static func instructionDone() {
        switch gameScene.eqRob.state {
        case .Dead:
            switch EqRobLines.curIndex {
            case 0:
                VEEquivalentController.hideEqGrid()
                CharacterController.doctor.setScale(1.0)
                CharacterController.showDoctor()
                doctorSays(in: .DestroyedInstructionDone, value: EqRobLines.subLinesForDestroyedInstructionDone())
                EqRobTouchController.state = .InstructionDone
                break;
            case 1:
                doctorSays(in: .DestroyedInstructionDone, value: EqRobLines.subLinesForDestroyedInstructionDone())
                break;
            case 2:
                EqRobLines.curIndex = 0
                back(3)
                break;
            default:
                break;
            }
        case .Charging:
            switch EqRobLines.curIndex {
            case 0:
                VEEquivalentController.hideEqGrid()
                CharacterController.doctor.setScale(1.0)
                CharacterController.showDoctor()
                doctorSays(in: .MissEnemiesInstructionDone, value: EqRobLines.subLinesForMissEnemiesInstructionDone())
                EqRobTouchController.state = .InstructionDone
                break;
            case 1:
                doctorSays(in: .MissEnemiesInstructionDone, value: EqRobLines.subLinesForMissEnemiesInstructionDone())
                break;
            case 2:
                doctorSays(in: .MissEnemiesInstructionDone, value: EqRobLines.subLinesForMissEnemiesInstructionDone())
                break;
            case 3:
                EqRobLines.curIndex = 0
                back(3)
                break;
            default:
                break;
            }
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
    }
    
    private static func resetSelectedEnemy() {
        lines.forEach { $0.removeFromParent() }
        selectedEnemies.forEach { $0.isSelectedForEqRob = false }
        selectedEnemyIndex = 0
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
    }
    
    private static func allDone() {
        selectedEnemyIndex = 0
        attackingEnemyIndex = 0
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        if gameScene.eqRob.state == .Dead {
            DataController.setDataForEqRob(isPerfect: false, isMiss: false)
        } else  {
            DataController.setDataForEqRob(isPerfect: isPerfect, isMiss: true)
        }
        gameScene.eqRob.state = .Pending
        gameScene.eqRob.resetVEElementArray()
        isPerfect = false
        instructedEnemy?.removePointing()
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.changeBalloonTexture(index: 0)
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
        gameScene.itemType = .None
        ItemTouchController.othersTouched()
    }
    
    private static func tellCharging() {
        comeAndTell()
        doctorSays(in: .Charging, value: nil)
    }
    
    private static func tellReparing() {
        comeAndTell()
        doctorSays(in: .Dead, value: nil)
    }
    
    private static func tellChargeDone() {
        comeAndTell()
        doctorSays(in: .ChargeDone, value: nil)
        let wait = SKAction.wait(forDuration: 2.0)
        gameScene.run(wait, completion: {
            EqRobTouchController.state = .Ready
            goBack()
        })
    }
    
    private static func tellReborn() {
        comeAndTell()
        doctorSays(in: .Reborn, value: nil)
        gameScene.eqRob.isHidden = false
        let wait = SKAction.wait(forDuration: 2.0)
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
        CharacterController.doctor.balloon.isHidden = false
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
    case Ready, Pending, WillAttack, Attack, Attacking, DeadInstruction, AliveInstruction, InstructionDone, Dead, Charging
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
        case .Dead:
            EqRobController.execute(8, enemy: nil)
            break;
        default:
            break;
        }
    }
}

enum EqRobLinesState {
    case Scan, ScanDone, WillSelectEnemies, SelectingEnemies, WarnSelection, EqRobGo, EqRobDestroyed, DestroyedInstruction, DestroyedInstructionDone, MissEnemies, MissEnemiesInstruction, MissEnemiesInstructionDone, PerfectKill, Charging, Dead, ChargeDone, Reborn
}

struct EqRobLines {
    static func getLines(state: EqRobLinesState, value: String?) -> String {
        switch state {
        case .Scan:
            return "エクロボが敵の文字式をスキャンするぞ！"
        case .ScanDone:
            return "\(value!)と\n同じ文字式を持つ敵が多いようじゃ！"
        case .WillSelectEnemies:
            return value! + "と同じ文字式を持つ敵を全て選ぶのじゃ！"
        case .SelectingEnemies:
            return subLineOrder(lines: subLinesForSelecting)
        case .WarnSelection:
            return "すまぬ!\n8体までしか選択できんのじゃ"
        case .EqRobGo:
            return "エクロボ 発進じゃ！"
        case .EqRobDestroyed:
            return "むむぅ・・・\n間違った敵を選んでしまったようじゃの"
        case .DestroyedInstruction:
            print("curIndex: \(curIndex)")
            return value!
        case .DestroyedInstructionDone:
            return value!
        case .MissEnemies:
            return "むむぅ・・・\nどうやら同じ文字式の敵がまだいたようじゃ"
        case .MissEnemiesInstruction:
            return value!
        case .MissEnemiesInstructionDone:
            return value!
        case .PerfectKill:
            return "パーフェクトじゃ！！\nさすがじゃのう"
        case .Charging:
            return "エクロボは、まだチャージ中じゃ"
        case .Dead:
            return "エクロボは、まだ修理中じゃ"
        case .ChargeDone:
            return "チャージ完了じゃ！！"
        case .Reborn:
            return "修理完了じゃ\nもう壊さないように頼むぞ！"
        }
    }
    
    static var selectedLine = ""
    static let subLinesForSelecting: [String] = [
        "同じ文字式の敵を全て選べないと攻撃が失敗してしまうぞ",
        "取りこぼしが一体でもあると攻撃が失敗してしまうぞ",
        "違う文字式を選んでしまうと攻撃が失敗してしまうぞ",
        "xにどんな数が入っても計算結果が同じになる文字式を選ぶのじゃ",
        "エクロボをタッチすれば、選択した敵たちに向かって発進するぞ"
    ]
    
    static var curIndex = 0
    
    static func subLinesForDestroyedInstruction() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "この敵を間違えてしまったようじゃな"
        case 1:
            curIndex = 0
            return "xに数を入れてみて、違う文字式なのか確かめるぞ"
        default:
            return ""
        }
    }
    
    static func subLinesForDestroyedInstructionDone() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "xの数によって文字式の計算結果が違うことがわかったかな"
        case 1:
            curIndex += 1
            return "次は、エクロボがスキャンした文字式と同じ文字式だけを選ぶのじゃ！"
        default:
            return ""
        }
    }
    
    static func subLinesForMissEnemiesInstruction() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "例えばこの敵を見逃してしまったようじゃな"
        case 1:
            curIndex = 0
            return "xに数を入れてみて、同じ文字式なのか確かめるぞ"
        default:
            return ""
        }
    }
    
    static func subLinesForMissEnemiesInstructionDone() -> String {
        switch curIndex {
        case 0:
            curIndex += 1
            return "xがどんな数でも文字式の計算結果が同じになることがわかったかな"
        case 1:
            curIndex += 1
            return "次は、エクロボの文字式と同じ文字式の敵を全て選んで"
        case 2:
            curIndex += 1
            return "パーフェクトを目指すのじゃ！"
        default:
            return ""
        }
    }
    
    static func subLineOrder(lines: [String]) -> String {
        if let index = lines.index(of: selectedLine) {
            if index < lines.count-1 {
                selectedLine = lines[index+1]
                return selectedLine
            } else {
                selectedLine = lines[0]
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
