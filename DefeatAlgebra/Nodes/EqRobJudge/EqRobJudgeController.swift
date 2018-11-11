//
//  EqRobJudgeController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqRobJudgeController {
    
    public static var gameScene: GameScene!
    private static var enemy1 = Enemy(ve: "")
    private static var enemy2 = Enemy(ve: "")
    public static var isEquivalent: Bool = false
    private static var isCorrect: Bool = false
    
    public static func getTwoEnemyRandomly(completion: @escaping () -> Void) {
        let enemise = gameScene.gridNode.enemyArray
        DAUtility.getRandomNumbers(total: enemise.count, times: 2) { nums in
            enemy1 = enemise[nums[0]]
            enemy2 = enemise[nums[1]]
            VECategory.getCategory(ve: enemy1.variableExpressionString) { cate1 in
                VECategory.getCategory(ve: enemy2.variableExpressionString) { cate2 in
                    if cate1 == cate2 {
                        isEquivalent = true
                    } else {
                        isEquivalent = false
                    }
                    return completion()
                }
            }
        }
    }
    
    public static func eqRobGoToScan() {
        CharacterController.doctor.setScale(EqRobController.doctorScale[0])
        CharacterController.doctor.changeBalloonTexture(index: 1)
        CharacterController.doctor.balloon.isHidden = false
        doctorSays(in: .Start)
        CharacterController.doctor.move(from: nil, to: EqRobController.doctorOnPos[0])
        
        gameScene.eqRob.go(to: enemy1) {
            gameScene.eqRob.go(to: enemy2) {
                gameScene.eqRob.go(toPos: EqRobController.eqRobCenterPos) {
                    doctorSays(in: .ScanDone)
                    enemy1.pointing()
                    enemy2.pointing()
                    gameScene.eqRob.look(at: gameScene.madScientistNode) {
                        let wait = SKAction.wait(forDuration: 3.0)
                        gameScene.run(wait, completion: {
                            enemy1.removePointing()
                            enemy2.removePointing()
                            showJudge()
                        })
                    }
                }
            }
        }
    }
    
    public static func showJudge() {
        CharacterController.doctor.zPosition = 55
        doctorSays(in: .Choice)
        let _ = JudgeBackground(gameScene: gameScene, enemy1: enemy1, enemy2: enemy2, isEquivalent: isEquivalent)
    }
    
    public static func hideJudge(diffSelected: Bool, pos: CGPoint) {
        for child in gameScene.children {
            if let bg = child as? JudgeBackground {
                bg.removeFromParent()
            }
        }
        CharacterController.doctor.zPosition = 20
        doctorSays(in: .EqRobAttack)
        resetEnemy(enemy: enemy1)
        resetEnemy(enemy: enemy2)
        backEqRob(diffSelected: diffSelected, pos: pos)
    }
    
    private static func backEqRob(diffSelected: Bool, pos: CGPoint) {
        if (diffSelected && !isEquivalent) || (!diffSelected && isEquivalent) {
            isCorrect = true
        } else {
            isCorrect = false
        }
        gameScene.eqRob.position = pos
        if diffSelected {
            gameScene.eqRob.diffSign.isHidden = false
        } else {
            gameScene.eqRob.eqSign.isHidden = false
        }
        gameScene.eqRob.go(toPos: EqRobController.eqRobCenterPos) {
            gameScene.eqRob.look(at: gameScene.madScientistNode) {
                let wait = SKAction.wait(forDuration: 1.0)
                gameScene.run(wait, completion: {
                    eqRobGoToAttak()
                })
            }
        }
    }
    
    private static func resetEnemy(enemy: Enemy) {
        enemy.zPosition = 4
        enemy.xValueLabel.isHidden = false
        enemy.variableExpressionLabel.color = UIColor.white
        if enemy.punchIntervalForCount == 0 && enemy.positionY != 0 {
            enemy.forcusForAttack(color: UIColor.red, value: gameScene.xValue)
        }
        let pos = VEEquivalentController.getPosOnGrid(x: enemy.positionX, y: enemy.positionY)
        enemy.calculatePunchLength(value: gameScene.xValue)
        let move = SKAction.move(to: pos, duration: 1.0)
        let scale = SKAction.scale(by: 0.5, duration: 1.0)
        let group = SKAction.group([move, scale])
        enemy.run(group)
        if enemy.state == .Defence {
            enemy.defend()
        } else if enemy.stateRecord.count < 1 {
            enemy.defend()
        }
    }
    
    public static func eqRobGoToAttak() {
        gameScene.eqRob.kill(enemy1) {
            gameScene.eqRob.kill(enemy2) {
                attackDone()
                gameScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {}
            }
        }
    }
    
    private static func attackDone() {
        if isCorrect {
            destroyEnemiesAtOnce()
            let wait = SKAction.wait(forDuration: 4.0)
            gameScene.run(wait, completion: {
                CharacterController.retreatDoctor()
                gameScene.itemType = .None
                ItemTouchController.othersTouched()
            })
        } else {
            doctorSays(in: .Wrong)
            let wait = SKAction.wait(forDuration: 2.0)
            gameScene.run(wait, completion: {
                doctorSays(in: .Check)
                gameScene.run(wait, completion: {
                    gameScene.itemType = .EqRob
                    VEEquivalentController.showEqGrid(enemies: [enemy1, enemy2], eqRob: nil)
                })
            })
        }
    }
    
    private static func destroyEnemiesAtOnce(delay: TimeInterval = 1.0) {
        let wait = SKAction.wait(forDuration: delay)
        gameScene.run(wait, completion: {
            doctorSays(in: .Correct)
            EnemyDeadController.hitEnemy(enemy: enemy1, gameScene: gameScene, isEqRob: true) {}
            EnemyDeadController.hitEnemy(enemy: enemy2, gameScene: gameScene, isEqRob: true) {}
        })
    }
    
    public static func checkDone() {
        VEEquivalentController.hideEqGrid()
        CharacterController.doctor.setScale(1.0)
        CharacterController.showDoctor()
        doctorSays(in: .CheckDone)
        let wait = SKAction.wait(forDuration: 3.0)
        gameScene.run(wait, completion: {
            CharacterController.retreatDoctor()
            gameScene.itemType = .None
            ItemTouchController.othersTouched()
        })
    }
    
    private static func doctorSays(in state: EqRobJudgeLinesState) {
        EqRobJudgeLines.doctorSays(in: state)
    }
}

enum EqRobJudgeLinesState {
    case Start, ScanDone, Choice, EqRobAttack, Correct, Wrong, Check, CheckDone
}

struct EqRobJudgeLines {
    
    public static func doctorSays(in state: EqRobJudgeLinesState) {
        CharacterController.doctor.balloon.isHidden = false
        getLines(state: state).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line, pos: 0)
        }
    }
    
    private static func getLines(state: EqRobJudgeLinesState) -> String {
        switch state {
        case .Start:
            return "エクロボが敵の文字式をスキャンするぞ"
        case .ScanDone:
            return "あの敵の文字式をスキャンしたようじゃ"
        case .Choice:
            return "エクロボに同じか違うかをインプットするのじゃ"
        case .EqRobAttack:
            return "エクロボが攻撃に行くぞ！"
        case .Correct:
            var value = "違う"
            if EqRobJudgeController.isEquivalent {
                value = "同じ"
            }
            return "さすがじゃ！やはり\(value)文字式だったようじゃな"
        case .Wrong:
            var value = "違う"
            if !EqRobJudgeController.isEquivalent {
                value = "同じ"
            }
            return "むむぅ。どうやら\(value)文字式ではなかったようじゃな"
        case .Check:
            var value = "違う"
            if EqRobJudgeController.isEquivalent {
                value = "同じ"
            }
            return "シミュレータで本当に\(value)文字式か確かめてみよう"
        case .CheckDone:
            return "次は間違えずに敵を倒そう！"
        }
    }
}


