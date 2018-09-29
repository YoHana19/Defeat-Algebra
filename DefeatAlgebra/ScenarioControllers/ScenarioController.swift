//
//  ScenarioController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/12.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct ScenarioController {
    static var currentLineIndex = 0
    static var currentActionIndex = 0
    static var scenarioScene: ScenarioScene!
    static var duringGameActionsActive = false

    static func nextLine() {
        let currentScenario = getScenario()
        if currentLineIndex < currentScenario.count {
            let action = currentScenario[currentLineIndex]
            if action[0] == "pause" {
                scenarioScene.tutorialState = .Action
                currentActionIndex += 1
                controllActions()
            } else {
                characterSpeak(chara: action[0], line: action[1])
            }
            currentLineIndex += 1
        }
    }
    
    static func characterSpeak(chara: String, line: String) {
        switch chara {
        case "0":
            CharacterController.showDoctor()
            CharacterLinesController.doctorSay(line: line)
            break;
        case "1":
            CharacterController.showMadDoctor()
            CharacterLinesController.madDoctorSay(line: line)
            break;
        case "2":
            CharacterController.showMainHero()
            CharacterLinesController.mainHeroSay(line: line)
            break;
        default:
            break;
        }
    }
    
    static func nextLineWithoutMoving() {
        let currentScenario = getScenario()
        let action = currentScenario[currentLineIndex]
        if action[0] == "pause" {
            scenarioScene.tutorialState = .Action
            currentActionIndex += 1
            controllActions()
        } else {
            switch action[0] {
            case "0":
                CharacterLinesController.doctorSay(line: action[1])
                break;
            case "1":
                CharacterLinesController.madDoctorSay(line: action[1])
                break;
            case "2":
                CharacterLinesController.mainHeroSay(line: action[1])
                break;
            default:
                break;
            }
        }
        currentLineIndex += 1
    }
    
    static func characterComeNSpeakNOut() {
        let currentScenario = getScenario()
        if currentLineIndex < currentScenario.count {
            let action = currentScenario[currentLineIndex]
            characterSpeak(chara: action[0], line: action[1])
            wait(length: 3.0) {
                currentLineIndex += 1
                switch action[0] {
                case "0":
                    CharacterController.retreatDoctor()
                    break;
                case "1":
                    CharacterController.retreatMadDoctor()
                    break;
                case "2":
                    CharacterController.retreatMainHero()
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    static func getScenario() -> [[String]] {
        switch GameScene.stageLevel {
        case 0:
            return ScenarioProperty.scenario0
        case 2:
            return ScenarioProperty.scenario2
        case 4:
            return ScenarioProperty.scenario4
        case 6:
            return ScenarioProperty.scenario6
        case 7:
            return ScenarioProperty.scenario7
        default:
            return [[String]]()
        }
    }
    
    static func controllActions() {
        //print("currentActionIndex: \(currentActionIndex)")
        switch GameScene.stageLevel {
        case 0:
            excute0()
            break;
        case 2:
            excute2()
            break;
        case 4:
            excute4()
            break;
        case 6:
            excute6()
            break;
        case 7:
            excute7()
            break;
        default:
            break;
        }
    }
    
    static func excute0() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.heroEnter(x: 4, y: 2) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            controllActions()
            scenarioScene.hero.attack() {
                scenarioScene.hero.attack() {
                    scenarioScene.hero.direction = .right
                    scenarioScene.hero.attack() {
                        scenarioScene.hero.attack() {
                            scenarioScene.hero.direction = .front
                            scenarioScene.hero.attack() {
                                scenarioScene.hero.attack() {
                                    scenarioScene.hero.removeAllActions()
                                    scenarioScene.hero.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                                    scenarioScene.hero.size = CGSize(width: 50, height: 50)
                                    scenarioScene.hero.setTexture()
                                    scenarioScene.tutorialState = .Converstaion
                                    nextLine()
                                }
                            }
                        }
                    }
                }
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            if let shake: SKAction = SKAction.init(named: "Shake") {
                let dispatchGroup = DispatchGroup()
                for node in scenarioScene.children {
                    dispatchGroup.enter()
                    node.run(shake, completion: {
                        dispatchGroup.leave()
                    })
                }
                dispatchGroup.notify(queue: .main, execute: {
                    scenarioScene.madEnter()
                    currentActionIndex += 1
                    controllActions()
                })
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMadDoctor()
            scenarioScene.enemyEnter([(2,11,"x+1",1), (6,11,"x",2)]) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            scenarioScene.hero.resetHero()
            SignalController.madPos = scenarioScene.madScientistNode.absolutePos()
            currentActionIndex += 1
            break;
        case 8:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .SignalSending else { return }
            guard scenarioScene.countTurn == 1 else { return }
            wait(length: 0.8) {
                characterComeNSpeakNOut()
            }
            currentActionIndex += 1
            break;
        case 9:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .EnemyTurn else { return }
            guard scenarioScene.countTurn == 2 else { return }
            wait(length: 0.8) {
                characterComeNSpeakNOut()
            }
            currentActionIndex += 1
            break;
        case 10:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .AddItem else { return }
            guard scenarioScene.countTurn == 3 else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            scenarioScene.tutorialState = .Converstaion
            GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
            nextLine()
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.showX()
            wait(length: 1.0) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .DisplayPhase
            CharacterController.showMiniMainHero()
            CharacterLinesController.miniMainHeroSayLoop()
            currentActionIndex += 1
            break;
        case 14:
            guard !scenarioScene.isCharactersTurn else { return }
            if scenarioScene.gameState == .StageClear {
                currentActionIndex = 16
                scenarioScene.isCharactersTurn = true
                scenarioScene.gridNode.isTutorial = true
                CharacterLinesController.stopMiniMainHeroSayLoop()
                CharacterController.retreatMiniMainHero()
                controllActions()
            } else if scenarioScene.gameState == .GameOver {
                print("gameover")
            } else {
                return
            }
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            wait(length: 1.0) {
                nextLine()
            }
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.resetCharacter()
            DAUserDefaultUtility.doneFirstly(name: "initialScenarioFirst")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excute2() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.tutorialState = .Action
            wait(length: 1.0) {
                nextLine()
            }
            wait(length: 3.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.retreatMadDoctor()
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .MoveState
            scenarioScene.movingPointing()
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "moveExplainFirst")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excute4() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.tutorialState = .Action
            scenarioScene.enemyEnter([(1, 10, "2×x+1", 1), (3, 8, "2x+1", 2), (5, 8, "x+1+x", 1), (7, 10, "1+3x-x", 0)]) {
                nextLine()
                wait(length: 2.0) {
                    scenarioScene.tutorialState = .Converstaion
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
                let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                scenarioScene.eqRob.run(rotate, completion: {
                    scenarioScene.tutorialState = .Converstaion
                    nextLine()
                })
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingEqRob()
            charaSpeak(at: 12)
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.retreatMainHero()
            EqRobTutorialController.showInputPanel()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "2")
            currentActionIndex += 1
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "x")
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "+")
            currentActionIndex += 1
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "1")
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingInputButton(name: "OK")
            scenarioScene.pointingGridAt(x: 3, y: 8)
            currentActionIndex += 1
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            EqRobTutorialController.showSelectionPanel()
            nextLine()
            currentActionIndex += 1
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            currentActionIndex += 1
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.moveWithScaling(to: CGPoint(x: 630, y: 500), value: 0.75) {
                nextLineWithoutMoving()
            }
            currentActionIndex += 1
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 5, y: 8)
            charaSpeak(at: 25)
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            charaSpeak(at: 37)
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            currentActionIndex += 1
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobTutorialController.isPerfect = EqRobTutorialController.eqRobGoToAttack()
            currentActionIndex += 1
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            if EqRobTutorialController.isPerfect {
                nextLine()
                scenarioScene.tutorialState = .Converstaion
            } else {
                EqRobTutorialController.pointingMissedEnemies()
                currentActionIndex = 23
                currentLineIndex = 47
                nextLine()
            }
            break;
        case 22:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobExplainFirst")
            loadGameScene()
            break;
        case 23:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobTutorialController.makeInsturctionForMiss()
            currentActionIndex += 1
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 25:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobTutorialController.setDemoCalculation(value: 1)
            let line = "x=1のとき、2x+1は3、\(EqRobTutorialController.instructedEnemy!.variableExpressionString)は3で同じ値になるじゃろ"
            CharacterLinesController.doctorSay(line: line)
            currentActionIndex += 1
            break;
        case 26:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobTutorialController.setDemoCalculation(value: 3)
            let line = "x=3のとき、2x+1は7、\(EqRobTutorialController.instructedEnemy!.variableExpressionString)は7で同じ値になるじゃろ"
            CharacterLinesController.doctorSay(line: line)
            currentActionIndex += 1
            break;
        case 27:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.selectionPanel.isHidden = true
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 28:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobExplainFirst")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excute6() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.enemyEnter([(1,8,"x+2", 0)]) {
                SignalSendingTurnController.sendSignal(in: 2)
                currentActionIndex += 1
                wait(length: 2.5) {
                    controllActions()
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Action
            wait(length: 1.0) {
                nextLine()
            }
            wait(length: 3.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 1, y: 10)
            charaSpeak(at: 7)
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CannonTutorialController.showInputPanelWithDoctor()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.pointingInputButton(name: "x")
            currentActionIndex += 1
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "+")
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "4")
            currentActionIndex += 1
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingInputButton(name: "OK")
            scenarioScene.pointingGridAt(x: 1, y: 10)
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.setScale(1)
            scenarioScene.removePointing()
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
            scenarioScene.gameState = .EnemyTurn
            currentActionIndex += 1
            break;
        case 10:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 0 else { return }
            scenarioScene.isCharactersTurn = true
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "cannonExplainFirst")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excute7() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.enemyEnter([(1,11,"3x-x-1", 0), (7,11,"x+1", 0)]) {
                SignalSendingTurnController.invisibleSignal(in: 3)
                currentActionIndex += 1
                wait(length: 0.5) {
                    controllActions()
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Action
            wait(length: 1.0) {
                nextLine()
            }
            wait(length: 3.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMadDoctor()
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
            scenarioScene.gameState = .EnemyTurn
            currentActionIndex += 1
            break;
        case 3:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 0 else { return }
            scenarioScene.isCharactersTurn = true
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 7, y: 7)
            charaSpeak(at: 17)
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.showActiveArea(at: [(7,6),(7,5)], color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            nextLine()
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.showActiveArea(at: [(7,6),(7,5),(7,3),(7,4)], color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 9)
            GridActiveAreaController.showActiveArea(at: [(7,8),(7,7)], color: "purple", grid: scenarioScene.gridNode)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (8, 8), text: "2", arrowHeight: 40)
            charaSpeak(at: currentLineIndex)
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.changeBalloonTexture(index: 1)
            let _ = VeLength(grid: scenarioScene.gridNode, xPos: 7, yPos: 6, ve: "x+1")
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (6, 6.05), text: "x+3", arrowHeight: 200)
            scenarioScene.getCannon(pos: [7,9]) { cannon in
                cannon.setInputVE(value: "x+3")
            }
            charaSpeak(at: 28)
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            currentActionIndex += 1
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removeShowLengths()
            GridActiveAreaController.resetSquareArray(color: "purple", grid: scenarioScene.gridNode)
            GridActiveAreaController.showActiveArea(at: [(7,8),(7,7),(7,6),(7,5)], color: "blue", grid: scenarioScene.gridNode)
            GridActiveAreaController.showActiveArea(at: [(7,6),(7,5)], color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (8, 6), text: "2", arrowHeight: 40)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (6, 7), text: "4", arrowHeight: 120)
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removeShowLengths()
            GridActiveAreaController.showActiveArea(at: [(7,4),(7,3)], color: "blue", grid: scenarioScene.gridNode)
            GridActiveAreaController.showActiveArea(at: [(7,4),(7,3)], color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (8, 5), text: "4", arrowHeight: 120)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (6, 6), text: "6", arrowHeight: 200)
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removeShowLengths()
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
            GridActiveAreaController.showActiveArea(at: [(7,8),(7,7)], color: "purple", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            let _ = VeLength(grid: scenarioScene.gridNode, xPos: 7, yPos: 6, ve: "x+1")
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (6, 6.05), text: "x+3", arrowHeight: 200)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (8, 8), text: "2", arrowHeight: 40)
            scenarioScene.tutorialState = .Converstaion
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removeShowLengths()
            GridActiveAreaController.resetSquareArray(color: "purple", grid: scenarioScene.gridNode)
            scenarioScene.getCannon(pos: [7,9]) { cannon in
                cannon.resetInputVE()
            }
            currentActionIndex += 1
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            CharacterController.retreatMadDoctor()
            CharacterController.doctor.changeBalloonTexture(index: 0)
            nextLineWithoutMoving()
            currentActionIndex += 1
            CannonTutorialController.showInputPanelWithDoctor()
            controllActions()
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingInputButton(name: "x")
            currentActionIndex += 1
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 9)
            scenarioScene.pointingInputButton(name: "+")
            currentActionIndex += 1
            break;
        case 22:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 9)
            scenarioScene.pointingInputButton(name: "3")
            currentActionIndex += 1
            break;
        case 23:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 9)
            scenarioScene.pointingInputButton(name: "OK")
            currentActionIndex += 1
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 6)
            CharacterController.doctor.setScale(1)
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 25:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.retreatDoctor()
            GridActiveAreaController.showActiveArea(at: [(1,9),(1,8),(1,7),(1,6)], color: "purple", grid: scenarioScene.gridNode)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (2, 8), text: "4", arrowHeight: 120)
            let _ = VeLength(grid: scenarioScene.gridNode, xPos: 1, yPos: 5, ve: "3x-x-1")
            charaSpeak(at: 40)
            break;
        case 26:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.move(from: nil, to: CGPoint(x: 170, y: 230), duration: 0.5)
            let currentScenario = getScenario()
            let action = currentScenario[currentLineIndex]
            CharacterLinesController.doctorSay(line: action[1])
            currentLineIndex += 1
            currentActionIndex += 1
            break;
        case 27:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 28:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removeShowLengths()
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (2, 8), text: "4", arrowHeight: 120)
            let _ = VeLength(grid: scenarioScene.gridNode, xPos: 1, yPos: 5, ve: "2x-1")
            let currentScenario = getScenario()
            let action = currentScenario[49]
            CharacterLinesController.doctorSay(line: action[1])
            currentLineIndex += 1
            currentActionIndex += 1
            break;
        case 29:
            guard scenarioScene.isCharactersTurn else { return }
            charaSpeak(at: currentLineIndex)
            let _ = ShowLength(grid: scenarioScene.gridNode, gridAt: (0, 6.05), text: "2x+3", arrowHeight: 280)
            break;
        case 30:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 31:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            GridActiveAreaController.resetSquareArray(color: "purple", grid: scenarioScene.gridNode)
            scenarioScene.removeShowLengths()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            currentActionIndex += 1
            break;
        case 32:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            CannonTutorialController.showInputPanelWithDoctor()
            controllActions()
            break;
        case 33:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingInputButton(name: "2")
            currentActionIndex += 1
            break;
        case 34:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "x")
            currentActionIndex += 1
            break;
        case 35:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "+")
            currentActionIndex += 1
            break;
        case 36:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "3")
            currentActionIndex += 1
            break;
        case 37:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 1, y: 10)
            scenarioScene.pointingInputButton(name: "OK")
            currentActionIndex += 1
            break;
        case 38:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            CharacterController.doctor.setScale(1)
            CharacterController.retreatDoctor()
            scenarioScene.enemyTurnDoneFlag = false
            for enemy in scenarioScene.gridNode.enemyArray {
                enemy.turnDoneFlag = false
                enemy.myTurnFlag = false
            }
            SignalSendingTurnController.invisibleSignal(in: 2)
            wait(length: 0.1) {
                scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
                scenarioScene.gameState = .EnemyTurn
                scenarioScene.isCharactersTurn = false
                currentActionIndex += 1
            }
            break;
        case 39:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 0 else { return }
            scenarioScene.isCharactersTurn = true
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 40:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "invisibleSignalFirst")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    private static func charaSpeak(at i: Int) {
        let currentScenario = getScenario()
        let action = currentScenario[i]
        characterSpeak(chara: action[0], line: action[1])
        currentLineIndex += 1
        currentActionIndex += 1
    }
    
    private static func loadGameScene() {
        
        CharacterController.retreatMainHero()
        CharacterController.retreatDoctor()
        
        /* Grab reference to the SpriteKit view */
        let skView = scenarioScene.view as SKView?
        /* Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
            return
        }
        /* Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        /* Restart GameScene */
        skView?.presentScene(scene)
    }
    
    private static func wait(length: TimeInterval, success: @escaping () -> Void) {
        let wait = SKAction.wait(forDuration: length)
        scenarioScene.run(wait, completion: {
            return success()
        })
    }
}
