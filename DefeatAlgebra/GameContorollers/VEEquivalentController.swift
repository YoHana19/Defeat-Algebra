//
//  VEEquivalentController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

public enum SignalState: Int {
    case Signal1 = 0, Signal2, Signal3
}

public enum SimState {
    case First, Second
}

struct VEEquivalentController {
    public static var gameScene: GameScene!
    private static var checkingEnemies = [Enemy]()
    public static var numOfCheck = 0
    public static var puttingXValue = false
    public static var xValue = 0
    public static var outPutXValue = 0
    public static var outPutNumValue = 0
    public static var curActivePos = (0,0)
    private static var dummyEnemy: DummyEnemy?
    private static var dummyEqRob: DummyEqRob?
    public static var simOneVeDone = false
    public static var simTwoVeDone = false
    public static var simOneSessionDone = false
    public static var allDone = false
    public static var lineState: EqRobSimLinesState = .PutX
    private static var dummyEnemies = [DummyEnemy]()
    private static var dummyEqRobs = [DummyEqRob]()
    private static var enemy1Value = 0
    
    public static var signalState: SignalState = .Signal1 {
        didSet {
            signalVisibility()
            switch signalState {
            case .Signal1:
                simState = .First
                break;
            case .Signal2:
                simState = .First
                break;
            case .Signal3:
                simState = .First
                break;
            }
        }
    }
    
    public static var simState: SimState = .First
    
    public static func showEqGrid(enemies: [Enemy], eqRob: EqRob? = nil) {
        SoundController.playBGM(bgm: .SimBGM, isLoop: true)
        gameScene.hero.setPhysics(isActive: false)
        gameScene.eqGrid.isHidden = false
        let bg = EqBackground(gameScene: gameScene, enemies: enemies, eqRob: eqRob)
        bg.zPosition = 8
        gameScene.eqGrid.zPosition = 9
        SignalController.speed = 0.002
        lineupEnemies(enemies: enemies)
        VEEquivalentController.xValue = 1
        CharacterController.doctor.changeBalloonTexture(index: 1)
        if let eqRob = eqRob {
            lineupEqRob(eqRob: eqRob) {
                if EqRobTouchController.state == .AliveInstruction {
                    self.activateVeSim()
                } else if EqRobTouchController.state == .DeadInstruction {
                    let wait = SKAction.wait(forDuration: 2.0)
                    gameScene.run(wait, completion: {
                        self.activateVeSim()
                    })
                }
            }
        } else {
            if let _ = gameScene as? ScenarioScene, ScenarioController.currentActionIndex < 4 {
            } else {
                activateVeSim()
            }
        }
        curActivePos = (checkingEnemies[0].eqPosX, checkingEnemies[0].eqPosY)
        signalState = .Signal1
    }
    
    private static func signalVisibility() {
        getBG() { b in
            if let bg = b {
                switch signalState {
                case .Signal1:
                    bg.signal1.isHidden = false
                    bg.signal2.isHidden = true
                    bg.signal3.isHidden = true
                    break;
                case .Signal2:
                    bg.signal1.isHidden = true
                    bg.signal2.isHidden = false
                    bg.signal3.isHidden = true
                    break;
                case .Signal3:
                    bg.signal1.isHidden = true
                    bg.signal2.isHidden = true
                    bg.signal3.isHidden = false
                    break;
                }
            }
        }
    }
    
    public static func activateVeSim() {
        getBG() { b in
            if let bg = b {
                bg.curVeSim.activate()
                EqRobSimLines.doctorSays(in: lineState, value: nil)
            }
        }
    }
    
    public static func showArea() {
        getBG() { b in
            if let bg = b {
                bg.showArea(eqGrid: gameScene.eqGrid, originPos: curActivePos)
            }
        }
    }
    
    private static func resetSim() {
        getBG() { b in
            if let bg = b {
                bg.enemyVeSim.reset()
                if let _ = bg.eqRob {
                    bg.eqRobVeSim.reset()
                } else {
                    bg.enemyVeSim2.reset()
                }
            }
        }
    }
    
    public static func nextSessoin() {
        guard simOneSessionDone else { return }
        guard simState == .Second else { return }
        simOneSessionDone = false
        let nextState = SignalState(rawValue: signalState.rawValue+1)
        if let ns = nextState {
            signalState = ns
            resetSim()
            changeCurActiveSim()
            lineState = .Start
            xValue = ns.rawValue+1
            EqRobSimLines.doctorSays(in: lineState, value: nil)
            let wait = SKAction.wait(forDuration: 2.0)
            gameScene.run(wait, completion: {
                activateVeSim()
            })
        } else {
            // all Done
            conclude()
        }
    }
    
    public static func doneSimulation() {
        guard allDone else { return }
        guard gameScene.eqGrid.showConclusionLabel() else { return }
        allDone = false
        if let _ = gameScene as? ScenarioScene {
            ScenarioController.controllActions()
        } else {
            if exsitEqRob() {
                EqRobController.execute(3, enemy: nil)
            } else {
                EqRobJudgeController.checkDone()
            }
        }
    }
    
    public static func conclude() {
        GridActiveAreaController.resetSquareArray(color: "yellow", grid: gameScene.eqGrid)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.eqGrid)
        getBG() { b in
            if let bg = b {
                bg.enemyVeSim.removeFromParent()
                bg.enemyVeSim2.removeFromParent()
                bg.eqRobVeSim.removeFromParent()
                bg.moveSignalIcon()
                bg.signal3.isHidden = true
            }
        }
        gameScene.eqRob.isHidden = true
        checkingEnemies.forEach({ $0.isHidden = true })
        dummyEnemies.forEach({ $0.lastMove {} })
        dummyEqRobs.forEach({ $0.lastMove {} })
        let waitForSound = SKAction.wait(forDuration: 1.0)
        gameScene.run(waitForSound, completion: {
            SoundController.sound(scene: gameScene, sound: .ShowVe)
        })
        lineState = .Conclution
        CharacterController.doctor.changeBalloonTexture(index: 0)
        ScenarioFunction.eqRobSimulatorTutorialTrriger(key: "last")
        EqRobSimLines.doctorSays(in: lineState, value: nil)
        let wait = SKAction.wait(forDuration: 2.0)
        gameScene.run(wait, completion: {
            allDone = true
        })
    }
    
    public static func compare() {
        guard simTwoVeDone else { return }
        guard simState == .Second else { return }
        simTwoVeDone = false
        getBG() { b in
            if let bg = b {
                if let _ = bg.eqRob {
                    if let deq = dummyEqRob {
                        GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "red", grid: gameScene.eqGrid)
                        GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "yellow", grid: gameScene.eqGrid)
                        deq.move() {
                            lineState = .Compare
                            if let de = dummyEnemy {
                                let enemyValue = de.outPutXValue+de.outPutNumValue
                                let eqRobValue = deq.outPutXValue+deq.outPutNumValue
                                if enemyValue == eqRobValue {
                                    EqRobSimLines.doctorSays(in: lineState, value: "同じ")
                                } else {
                                    EqRobSimLines.doctorSays(in: lineState, value: "違う")
                                }
                            }
                            simOneSessionDone = true
                            bg.setSignalIcon(value: xValue)
                        }
                    }
                } else {
                    if let de = dummyEnemy {
                        GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "red", grid: gameScene.eqGrid)
                        GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "yellow", grid: gameScene.eqGrid)
                        de.move() {
                            simOneSessionDone = true
                            bg.setSignalIcon(value: xValue)
                            ScenarioFunction.eqRobSimulatorTutorialTrriger(key: "compare1")
                            lineState = .Compare
                            
                            if enemy1Value == de.outPutXValue+de.outPutNumValue {
                                EqRobSimLines.doctorSays(in: lineState, value: "同じ")
                            } else {
                                EqRobSimLines.doctorSays(in: lineState, value: "違う")
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static func nextSim() {
        guard simOneVeDone else { return }
        guard simState == .First else { return }
        simOneVeDone = false
        simState = .Second
        if let de = dummyEnemy {
            GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "red", grid: gameScene.eqGrid)
            GridActiveAreaController.resetSquareArray(at: curActivePos.0, color: "yellow", grid: gameScene.eqGrid)
            enemy1Value = de.outPutXValue+de.outPutNumValue
            de.move() {}
        }
        changeCurActiveSim()
        if exsitEqRob() {
            lineState = .NextEqRob
        } else {
            lineState = .NextEnemy
        }
        EqRobSimLines.doctorSays(in: lineState, value: nil)
        let wait = SKAction.wait(forDuration: 2.0)
        gameScene.run(wait, completion: {
            activateVeSim()
        })
    }
    
    public static func doneSim() {
        setDummy()
        if simState == .First {
            simOneVeDone = true
            lineState = .EnemyResult
            EqRobSimLines.doctorSays(in: lineState, value: nil)
        } else {
            simTwoVeDone = true
            if exsitEqRob() {
                lineState = .EqRobResult
            } else {
                lineState = .AnotherEnemyResult
            }
            EqRobSimLines.doctorSays(in: lineState, value: nil)
        }
    }
    
    public static func changeCurActiveSim() {
        getBG() { b in
            if let bg = b {
                switch simState {
                case .First:
                    self.curActivePos = (checkingEnemies[0].eqPosX, checkingEnemies[0].eqPosY)
                    bg.curVeSim = bg.enemyVeSim
                    break;
                case .Second:
                    if let eqRob = bg.eqRob {
                        self.curActivePos = (eqRob.eqPosX, eqRob.eqPosY)
                        bg.curVeSim = bg.eqRobVeSim
                    } else {
                        self.curActivePos = (checkingEnemies[1].eqPosX, checkingEnemies[1].eqPosY)
                        bg.curVeSim = bg.enemyVeSim2
                    }
                    break;
                }
                outPutXValue = 0
                outPutNumValue = 0
            }
        }
    }
    
    private static func setDummy() {
        getBG() { b in
            if let bg = b {
                var toXPos = 0
                var lastXPos = 0
                if simState == .First {
                    switch signalState {
                    case .Signal1:
                        toXPos = 8
                        lastXPos = 8
                        break;
                    case .Signal2:
                        toXPos = 6
                        lastXPos = 5
                        break;
                    case .Signal3:
                        toXPos = 4
                        lastXPos = 2
                        break;
                    }
                    dummyEnemy = DummyEnemy(position: checkingEnemies[0].absolutePos(), xValue: outPutXValue, numValue: outPutNumValue, ve: checkingEnemies[0].variableExpressionString, bg: bg, grid: gameScene.eqGrid, fromXPosOnGrid: curActivePos.0, toXPosOnGrid: toXPos, lastPos: lastXPos)
                    dummyEnemies.append(dummyEnemy!)
                } else {
                    switch signalState {
                    case .Signal1:
                        toXPos = 7
                        lastXPos = 7
                        break;
                    case .Signal2:
                        toXPos = 5
                        lastXPos = 4
                        break;
                    case .Signal3:
                        toXPos = 3
                        lastXPos = 1
                        break;
                    }
                    if let eqRob = bg.eqRob {
                        dummyEqRob = DummyEqRob(position: eqRob.absolutePos(), xValue: outPutXValue, numValue: outPutNumValue, ve: eqRob.variableExpressionString, bg: bg, grid: gameScene.eqGrid, fromXPosOnGrid: curActivePos.0, toXPosOnGrid: toXPos, lastPos: lastXPos)
                        dummyEqRobs.append(dummyEqRob!)
                    } else {
                        dummyEnemy = DummyEnemy(position: checkingEnemies[1].absolutePos(), xValue: outPutXValue, numValue: outPutNumValue, ve: checkingEnemies[1].variableExpressionString, bg: bg, grid: gameScene.eqGrid, fromXPosOnGrid: curActivePos.0, toXPosOnGrid: toXPos, lastPos: lastXPos)
                        dummyEnemies.append(dummyEnemy!)
                    }
                }
            }
        }
    }
    
    private static func lineupEnemies(enemies: [Enemy]) {
        checkingEnemies = enemies
        if enemies.count == 1 {
            for enemy in enemies {
                setEnemy(enemy: enemy, x: 2, y: 11)
            }
        } else if enemies.count == 2 {
            setEnemy(enemy: enemies[0], x: 2, y: 11)
            setEnemy(enemy: enemies[1], x: 0, y: 11)
        }
    }
    
    private static func lineupEqRob(eqRob: EqRob, completion: @escaping () -> Void) {
        let xPos = 0
        eqRob.setScale(0.8)
        eqRob.eqPosX = xPos
        let pos = getPosOnScene(x: xPos, y: 11)
        if EqRobTouchController.state == .AliveInstruction {
            eqRob.go(toPos: pos) {
                let rotate = SKAction.rotate(toAngle: .pi * 1/2, duration: 1.0)
                eqRob.run(rotate, completion: {
                    eqRob.variableExpressionLabel.isHidden = false
                    eqRob.variableExpressionLabel.zRotation = .pi * -1/2
                    return completion()
                })
            }
        } else if EqRobTouchController.state == .DeadInstruction {
            eqRob.variableExpressionLabel.isHidden = false
            eqRob.zRotation = .pi * 1/2
            eqRob.variableExpressionLabel.zRotation = .pi * -1/2
            eqRob.position = pos
            eqRob.isHidden = false
            return completion()
        }
    }
    
    private static func setEnemy(enemy: Enemy, x: Int, y: Int) {
        let pos = getPosOnGrid(x: x, y: y)
        enemy.eqPosX = x
        enemy.eqPosY = y
        enemy.zPosition = 10
        enemy.xValueLabel.text = ""
        enemy.variableExpressionLabel.color = UIColor.white
        enemy.adjustLabelSize()
        let move = SKAction.move(to: pos, duration: 1.0)
        enemy.run(move, completion: {
            enemy.resolveShield() {}
        })
    }
    
    public static func getPosOnGrid(x: Int, y: Int) -> CGPoint {
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
        if let _ = gameScene as? ScenarioScene {
            GameStageController.soundForScenario()
        } else {
            GameStageController.sound()
        }
        
        outPutXValue = 0
        outPutNumValue = 0
        GridActiveAreaController.resetSquareArray(color: "yellow", grid: gameScene.eqGrid)
        GridActiveAreaController.resetSquareArray(color: "red", grid: gameScene.eqGrid)
        gameScene.eqGrid.hideConclusionLabel()
        gameScene.eqGrid.isHidden = false
        gameScene.eqGrid.zPosition = -1
        gameScene.eqGrid.demoCalcLabel.isHidden = true
        SignalController.speed = 0.006
        CharacterController.doctor.changeBalloonTexture(index: 0)
        numOfCheck = 0
        gameScene.xValue = gameScene.xValue
        backEnemies()
        getBG(completion: { bg in
            bg?.removeFromParent()
        })
        gameScene.eqRob.setScale(1.0)
        gameScene.eqRob.isHidden = false
        gameScene.eqRob.variableExpressionLabel.isHidden = true
        if EqRobTouchController.state == .AliveInstruction {
            gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {}
        } else if EqRobTouchController.state == .DeadInstruction {
            gameScene.eqRob.zRotation = .pi * -1/2
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
    
    public static func exsitEqRob() -> Bool {
        if let bg = gameScene.childNode(withName: "eqBackground") as? EqBackground {
            if let _ = bg.eqRob {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private static func enableEqBgTouch() {
        getBG() { bg in
            guard let bg = bg else { return }
            bg.isEnable = true
        }
    }
    
    public static func backEnemies() {
        let dispatchGroup = DispatchGroup()
        for enemy in checkingEnemies {
            dispatchGroup.enter()
            enemy.isHidden = false
            enemy.isSelectedForEqRob = false
            enemy.xValueLabel.text = ""
            enemy.demoCalcLabel.isHidden = true
            enemy.variableExpressionLabel.fontColor = UIColor.white
            if enemy.punchIntervalForCount == 0 && enemy.positionY != 0 {
                enemy.forcusForAttack(color: UIColor.red, value: gameScene.xValue)
            }
            let pos = getPosOnGrid(x: enemy.positionX, y: enemy.positionY)
            enemy.zPosition = 4
            enemy.calculatePunchLength(value: gameScene.xValue)
            let move = SKAction.move(to: pos, duration: 1.0)
            enemy.run(move, completion: {
                dispatchGroup.leave()
            })
            if enemy.state == .Defence {
                enemy.defend()
            } else if enemy.stateRecord.count < 1 {
                enemy.defend()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            gameScene.hero.setPhysics(isActive: true)
        })
    }
    
    public static func showEcessArea(yValue: Int, posX: Int) {
        getBG() { bg in
            guard let bg = bg else { return }
            bg.setExcessArea(yValue: yValue, posX: posX)
        }
    }
    
    public static func resetEcessArea(posX: Int) {
        getBG() { bg in
            guard let bg = bg else { return }
            bg.removeExcessArea(posX: posX)
        }
    }
    
}

enum EqRobSimLinesState {
    case Start, PutX, TouchNum, EnemyResult, NextEqRob, NextEnemy, EqRobResult, AnotherEnemyResult, Compare, Conclution
}

struct EqRobSimLines {
    
    public static func doctorSays(in state: EqRobSimLinesState, value: String?) {
        CharacterController.doctor.balloon.isHidden = false
        EqRobSimLines.getLines(state: state, value: value).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line, pos: 0)
        }
    }
    
    static func getLines(state: EqRobSimLinesState, value: String?) -> String {
        switch state {
        case .Start:
            switch VEEquivalentController.xValue {
            case 1:
                return "まずは、x＝１で試してみよう"
            case 2:
                return "次は、x＝２で試してみよう"
            case 3:
                return "最後に、x＝３で試してみよう"
            default:
                return ""
            }
        case .PutX:
            return "\(VEEquivalentController.xValue)をxの中に入れるんじゃ"
        case .TouchNum:
            return "数字をタッチするのじゃ"
        case .EnemyResult:
            return "x=\(VEEquivalentController.xValue)の時、この敵の文字式を計算すると\(VEEquivalentController.outPutXValue+VEEquivalentController.outPutNumValue)になるようじゃな"
        case .NextEqRob:
            return "次はエクロボの文字式を試してみよう"
        case .NextEnemy:
            return "もう片方のロボットの文字式を試してみよう"
        case .EqRobResult:
            return "x=\(VEEquivalentController.xValue)の時、エクロボの文字式を計算すると\(VEEquivalentController.outPutXValue+VEEquivalentController.outPutNumValue)になるようじゃな"
        case .AnotherEnemyResult:
            return "x=\(VEEquivalentController.xValue)の時、こっちの敵の文字式は計算すると\(VEEquivalentController.outPutXValue+VEEquivalentController.outPutNumValue)になるようじゃな"
        case .Compare:
            return "x＝\(VEEquivalentController.xValue)のとき、二つの文字式は\(value!)計算結果になるようじゃな"
        case .Conclution:
            if EqRobTouchController.state == .AliveInstruction {
                return "xに入る数が違っても計算結果が同じということは、同じ文字式ということだ！"
            } else if EqRobTouchController.state == .DeadInstruction {
                return "xに入る数が違うと計算結果が違うということは、違う文字式ということだ！"
            } else {
                if let _ = VEEquivalentController.gameScene as? ScenarioScene {
                    CharacterController.doctor.setScale(1.0)
                    return "このようにxに入る数が違っても、同じ計算結果になる文字式は"
                } else {
                    if EqRobJudgeController.isEquivalent {
                        return "xに入る数が違っても計算結果が同じということは、同じ文字式ということだ！"
                    } else {
                        return "xに入る数が違うと計算結果が違うということは、違う文字式ということだ！"
                    }
                }
            }
        }
    }
}

