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
    static var keyTouchPos: (Int, Int) = (100, 100)

    static func nextLine() {
        let currentScenario = getScenario()
        if currentLineIndex < currentScenario.count {
            let action = currentScenario[currentLineIndex]
            if action[0] == "pause" {
                scenarioScene.tutorialState = .Action
                currentActionIndex += 1
                currentLineIndex += 1
                controllActions()
            } else {
                characterSpeak(chara: action[0], line: action[1])
                currentLineIndex += 1
            }
        }
    }
    
    static func characterSpeak(chara: String, line: String) {
        SoundController.sound(scene: scenarioScene, sound: .CharaLine)
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
            currentLineIndex += 1
            controllActions()
        } else {
            currentLineIndex += 1
            SoundController.sound(scene: scenarioScene, sound: .CharaLine)
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
        case MainMenu.uncoverSignalStartTurn: //1
            return ScenarioProperty.scenarioUncoverSignal
        case MainMenu.timeBombStartTurn: //3
            return ScenarioProperty.scenarioTimeBombStartTurn
        case MainMenu.showUnsimplifiedStartTurn: //6
            return ScenarioProperty.scenarioUnsimplified
        case MainMenu.eqRobStartTurn: //7
            return ScenarioProperty.scenarioEqRobStartTurn
        case MainMenu.eqRobNewStartTurn: //9
            return ScenarioProperty.scenarioEqRobNewStartTurn
        case MainMenu.cannonStartTurn: //11
            return ScenarioProperty.scenarioCannonStartTurn
        case MainMenu.invisibleStartTurn: //14
            return ScenarioProperty.scenarioInvisibleStartTurn
        case MainMenu.lastTurn: //16
            return ScenarioProperty.scenarioLastTurn
        default:
            return [[String]]()
        }
    }
    
    static func controllActions() {
//        print(scenarioScene.tutorialState)
//        print("currentActionIndex: \(currentActionIndex)")
//        print("currentLineIndex: \(currentLineIndex)")
        switch GameScene.stageLevel {
        case 0:
            excute0()
            break;
        case MainMenu.uncoverSignalStartTurn: //1
            excuteUncoverSignal()
            break;
        case MainMenu.timeBombStartTurn: //3
            excuteTimeBombStartTurn()
            break;
        case MainMenu.showUnsimplifiedStartTurn: //6
            excuteUnsimplified()
            break;
        case MainMenu.eqRobStartTurn: //7
            excuteEqRobStartTurn()
            break;
        case MainMenu.eqRobNewStartTurn: //7
            excuteEqRobNewStartTurn()
            break;
        case MainMenu.cannonStartTurn: //11
            excuteCannonStartTurn()
            break;
        case MainMenu.invisibleStartTurn: //14
            excuteInvisibleStartTurn()
            break;
        case MainMenu.lastTurn: //16
            excuteLastTurn()
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
            SoundController.sound(scene: scenarioScene, sound: .SwordSound)
            scenarioScene.hero.attack() {
                SoundController.sound(scene: scenarioScene, sound: .SwordSound)
                scenarioScene.hero.attack() {
                    scenarioScene.hero.direction = .right
                    SoundController.sound(scene: scenarioScene, sound: .SwordSound)
                    scenarioScene.hero.attack() {
                        SoundController.sound(scene: scenarioScene, sound: .SwordSound)
                        scenarioScene.hero.attack() {
                            scenarioScene.hero.direction = .front
                            SoundController.sound(scene: scenarioScene, sound: .SwordSound)
                            scenarioScene.hero.attack() {
                                SoundController.sound(scene: scenarioScene, sound: .SwordSound)
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
            SoundController.sound(scene: scenarioScene, sound: .ShowMad)
            SoundController.stopBGM()
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
            scenarioScene.enemyEnter([(4,10,"x+1",1)]) {
                SoundController.playBGM(bgm: .Game1, isLoop: true)
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
            scenarioScene.hero.resetHero()
            SignalController.madPos = scenarioScene.madScientistNode.absolutePos()
            currentActionIndex += 1
            controllActions()
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            SignalController.send(target: scenarioScene.gridNode.enemyArray[0], num: 1) {
                TutorialController.enable()
                TutorialController.execute()
                ScenarioFunction.startPlayerTurn(phase: .DisplayPhase)
                currentActionIndex += 1
            }
            wait(length: 0.8) {
                characterComeNSpeakNOut()
            }
            break;
        case 9:
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.isCharactersTurn = true
            wait(length: 0.5) {
                ScenarioFunction.showNHideEnemyPhase() {
                    wait(length: 0.8) {
                        characterComeNSpeakNOut()
                    }
                    ScenarioFunction.enemyPunchNMove(enemy: scenarioScene.gridNode.enemyArray[0], num: 1) {
                        TutorialController.state = .Show
                        TutorialController.execute()
                        ScenarioFunction.startPlayerTurn(phase: .DisplayPhase)
                        currentActionIndex += 1
                    }
                }
            }
        case 10:
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.removePointing()
            wait(length: 0.5) {
                ScenarioFunction.showNHideEnemyPhase() {
                    ScenarioFunction.enemyMoveNDefend(enemy: scenarioScene.gridNode.enemyArray[0], direction: .right) {
                        currentActionIndex += 1
                        controllActions()
                    }
                }
            }
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            wait(length: 1.0) {
                scenarioScene.gridNode.isTutorial = true
                scenarioScene.tutorialState = .Converstaion
                nextLine()
            }
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.showX()
            SoundController.sound(scene: scenarioScene, sound: .ShowVe)
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Converstaion
                nextLine()
            }
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.showVE()
            SoundController.sound(scene: scenarioScene, sound: .ShowVe)
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Converstaion
                nextLine()
            }
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            SignalController.sendHalf(target: scenarioScene.gridNode.enemyArray[0], num: 2) {
                scenarioScene.pointingSignal()
                charaJustSpeak(at: currentLineIndex)
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.getSignal() { signal in
                SoundController.sound(scene: scenarioScene, sound: .ShowVe)
                signal.xValue.isHidden = false
                charaJustSpeak(at: currentLineIndex)
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.getSignal() { signal in
                SignalController.sendHalf2(signal: signal, target:
                scenarioScene.gridNode.enemyArray[0], num: 2) {
                    SoundController.sound(scene: scenarioScene, sound: .ShowVe)
                    scenarioScene.xValue = 2
                    scenarioScene.valueOfX.fontColor = UIColor.red
                    scenarioScene.gridNode.enemyArray[0].punchIntervalForCount = 0
                    scenarioScene.gridNode.enemyArray[0].calculatePunchLength(value: scenarioScene.xValue)
                    scenarioScene.gridNode.enemyArray[0].xValueLabel.isHidden = false
                    scenarioScene.signalHolder.isHidden = false
                    scenarioScene.valueOfX.isHidden = false
                    scenarioScene.gridNode.enemyArray[0].variableExpressionLabel.fontColor = UIColor.red
                    charaJustSpeak(at: currentLineIndex)
                    scenarioScene.tutorialState = .Converstaion
                    CharacterController.doctor.changeBalloonTexture(index: 1)
                    scenarioScene.changeVE(txt: "2+1", redPos: [0])
                }
            }
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.changeVE(txt: "2+1=3", redPos: [0,4])
            GridActiveAreaController.showActiveArea(at: [(5,7),(5,6),(5,5)], color: "red", grid: scenarioScene.gridNode)
            scenarioScene.tutorialState = .Converstaion
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            ScenarioFunction.enemyPunch(enemy: scenarioScene.gridNode.enemyArray[0], num: 2) {
                charaJustSpeak(at: currentLineIndex)
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            ScenarioFunction.enemyDrawPunch(enemy: scenarioScene.gridNode.enemyArray[0]) {
                charaJustSpeak(at: currentLineIndex)
                scenarioScene.changeVE(txt: "x+1", redPos: nil)
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            ScenarioFunction.enemyMoveNDefend(enemy: scenarioScene.gridNode.enemyArray[0], direction: .right) {
                SignalController.send(target: scenarioScene.gridNode.enemyArray[0], num: 1) {
                    charaJustSpeak(at: currentLineIndex)
                    scenarioScene.xValue = 1
                    scenarioScene.tutorialState = .Converstaion
                    scenarioScene.changeVE(txt: "1+1", redPos: [0])
                }
            }
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 5, y: 3)
            scenarioScene.changeVE(txt: "1+1=2", redPos: [0,4])
            charaJustSpeak(at: currentLineIndex)
            CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctor.position.x, y: CharacterController.doctor.position.y-250), duration: 0.5)
            GridActiveAreaController.showMoveArea(posX: scenarioScene.hero.positionX, posY: scenarioScene.hero.positionY, moveLevel: scenarioScene.hero.moveLevel, grid: scenarioScene.gridNode)
            break;
        case 22:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            ScenarioFunction.enemyPunchNMove(enemy: scenarioScene.gridNode.enemyArray[0], num: 1) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 23:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            scenarioScene.changeVE(txt: "x+1", redPos: nil)
            scenarioScene.pointingAtkBtn()
            charaJustSpeakWithoutMoving(at: currentLineIndex)
            CharacterController.doctor.setScale(0.8)
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 6, y: 3)
            break;
        case 25:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            CharacterController.doctor.setScale(1.0)
            nextLine()
            break;
        case 26:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.balloon.isHidden = true
            scenarioScene.gameState = .StageClear
            scenarioScene.isCharactersTurn = false
            break;
        default:
            break;
        }
    }
    
    static func excuteUncoverSignal() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.enemyEnter([(4,9,"x+2",0)]) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            scenarioScene.gameState = .SignalSending
            scenarioScene.playerTurnState = .DisplayPhase
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            currentActionIndex += 1
            break;
        case 2: // Hero bumpped enemy
            guard !scenarioScene.isCharactersTurn, scenarioScene.gameState == .GameOver else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            scenarioScene.tutorialState = .None
            TutorialController.currentIndex = 4
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            wait(length: GameOverTurnController.calculateWaitTime(enemy: scenarioScene.gridNode.enemyArray[0])) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.hero.isHidden = false
            currentActionIndex = 6
            controllActions()
            break;
        case 4: // Success
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            EnemyMoveController.updateEnemyPositon(grid: scenarioScene.gridNode)
            ScenarioFunction.startPlayerTurn(phase: .MoveState)
            break;
        case 5: // fail
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Action
            TutorialController.currentIndex = 3
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.resetEnemies()
            scenarioScene.resetHeroPos(x: 4, y: 3)
            currentActionIndex = 1
            controllActions()
            break;
        default:
            break;
        }
    }
            
    static func excuteChangeMoveSpan() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            wait(length: 0.5) {
                nextLine()
            }
            wait(length: 2.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "changeMoveSpan")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteTimeBombStartTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.tutorialState = .None
            scenarioScene.enemyEnter([(1, 10, "2x+1", 0), (4, 10, "x+1", 0), (7, 10, "2×x", 0)]) {
                SignalController.send(target: scenarioScene.gridNode.enemyArray[1], num: 1) {
                    scenarioScene.xValue = 1
                    scenarioScene.gridNode.enemyArray[1].calculatePunchLength(value: 1)
                    currentActionIndex += 1
                    controllActions()
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            for _ in 0..<3 {
                scenarioScene.displayitem(name: "timeBomb")
            }
            scenarioScene.pointingLastGotItem()
            charaJustSpeak(at: currentLineIndex)
            currentActionIndex += 1
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.usingItemIndex = Int((scenarioScene.itemArray.last!.position.x-56.5)/91)
            CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctor.position.x, y: CharacterController.doctor.position.y-300), duration: 1.0)
            scenarioScene.removePointing()
            GridActiveAreaController.showtimeBombSettingArea(grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            wait(length: 2.0) {
                controllActions()
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            GridActiveAreaController.resetSquareArray(color: "purple", grid: scenarioScene.gridNode)
            nextLineWithoutMoving()
            scenarioScene.pointingGridAt(x: 4, y: 10)
            scenarioScene.pointingGridAt(x: 4, y: 8)
            GridActiveAreaController.showActiveArea(at: [(4,9),(4,8)], color: "red", grid: scenarioScene.gridNode)
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            nextLineWithoutMoving()
            scenarioScene.removePointing()
            GridActiveAreaController.showtimeBombSettingArea(grid: scenarioScene.gridNode)
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            ItemTouchController.AAForTimeBombTapped(gridX: 4, gridY: 8)
            scenarioScene.removePointing()
            scenarioScene.pointingYes()
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            scenarioScene.removePointing()
            wait(length: 1.0) {
                GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
                controllActions()
            }
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            let enemy = scenarioScene.gridNode.enemyArray[1]
            enemy.isAttackable = true
            ScenarioFunction.enemyPunchNMove(enemy: enemy, num: 1) {
                GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
                scenarioScene.removePointing()
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 9:
            if scenarioScene.gridNode.timeBombSetArray.count > 0 {
                SoundController.sound(scene: scenarioScene, sound: .TimeBombExplosion)
                let timeBomb = scenarioScene.gridNode.timeBombSetArray[0]
                timeBomb.explode {
                    nextLine()
                    scenarioScene.tutorialState = .Converstaion
                }
                scenarioScene.gridNode.timeBombSetArray.removeAll()
            }
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.gameState = .SignalSending
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            scenarioScene.pointingAllGotItems()
            currentActionIndex += 1
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            scenarioScene.tutorialState = .Action
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.unDoTimeBomb(num: scenarioScene.gridNode.enemyArray.count) {
                for enemy in scenarioScene.gridNode.enemyArray {
                    for i in 1...enemy.valueOfEnemy {
                        GridActiveAreaController.showActiveArea(at: [(enemy.positionX, enemy.positionY-i)], color: "red", grid: scenarioScene.gridNode)
                    }
                    scenarioScene.pointingGridAt(x: enemy.positionX, y: enemy.positionY-enemy.valueOfEnemy)
                }
            }
            currentActionIndex += 1
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            for enemy in scenarioScene.gridNode.enemyArray {
                enemy.xValueLabel.text = ""
                enemy.variableExpressionLabel.color = UIColor.white
            }
            scenarioScene.countTurnDone = false
            scenarioScene.countTurn = 0
            currentActionIndex = 11
            break;
        case 15: // clear
            guard !scenarioScene.isCharactersTurn && scenarioScene.gameState == .StageClear else { return }
            TutorialController.removeTutorialLabel()
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            scenarioScene.tutorialState = .Converstaion
            wait(length: 1.0) {
                nextLine()
            }
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "timeBombExplain")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteMoveExplain() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.tutorialState = .None
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .MoveState
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "moveExplain")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteUnsimplified() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            wait(length: 0.5) {
                nextLine()
            }
            wait(length: 2.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "showUnsimplified")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteEqRobStartTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobJudgeController.isEquivalent = true
            scenarioScene.setHero()
            scenarioScene.tutorialState = .Action
            scenarioScene.enemyEnter([(2, 9, "2x+1", 2), (6, 9, "x+x+1", 1)]) {
                nextLine()
                wait(length: 2.0) {
                    scenarioScene.tutorialState = .Converstaion
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            SoundController.sound(scene: scenarioScene, sound: .ShowVe)
            scenarioScene.gridNode.enemyArray[0].pointing()
            scenarioScene.gridNode.enemyArray[1].pointing()
            charaSpeak(at: currentLineIndex)
            currentActionIndex -= 1
            scenarioScene.tutorialState = .Converstaion
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.playerTurnState = .UsingItem
            scenarioScene.itemType = .EqRob
            scenarioScene.gridNode.enemyArray[0].removePointing()
            scenarioScene.gridNode.enemyArray[1].removePointing()
            VEEquivalentController.showEqGrid(enemies: [scenarioScene.gridNode.enemyArray[0], scenarioScene.gridNode.enemyArray[1]])
            CharacterController.retreatMainHero()
            currentActionIndex += 1
            controllActions()
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.setScale(0.8)
            CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctor.position.x, y: CharacterController.doctor.position.y-300), duration: 1.0)
            nextLineWithoutMoving()
            wait(length: 1.5) {
                currentActionIndex += 1
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            VEEquivalentController.getBG() { b in
                b?.pointingSignalToX()
                VEEquivalentController.activateVeSim()
            }
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            VEEquivalentController.getBG() { b in
                b?.removePointing()
                b?.pointingNumToTouch()
            }
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            VEEquivalentController.getBG() { b in
                b?.removePointing()
            }
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            VEEquivalentController.hideEqGrid()
            CharacterController.doctor.setScale(1.0)
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 14: // eqRob show up
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.eqRob.go(toPos: EqRobController.eqRobCenterPos) {
                SoundController.sound(scene: scenarioScene, sound: .ShowVe)
                scenarioScene.eqRob.look(at: scenarioScene.madScientistNode) {
                    scenarioScene.tutorialState = .Converstaion
                    nextLine()
                }
            }
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            EqRobJudgeController.isEquivalent = true
            EqRobJudgeController.enemy1 = scenarioScene.gridNode.enemyArray[0]
            EqRobJudgeController.enemy2 = scenarioScene.gridNode.enemyArray[1]
            EqRobJudgeController.eqRobGoToScan()
            currentActionIndex += 1
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            scenarioScene.tutorialState = .None
            wait(length: 3.0) {
                nextLineWithoutMoving()
                wait(length: 3.0) {
                    scenarioScene.tutorialState = .Action
                }
            }
            break;
        case 17:
            guard scenarioScene.isCharactersTurn && scenarioScene.tutorialState == .Action  else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            scenarioScene.pointingEqButton()
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            scenarioScene.removePointing()
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.setScale(1.0)
            CharacterController.doctor.changeBalloonTexture(index: 0)
            nextLine()
            currentActionIndex += 1
            scenarioScene.tutorialState = .Converstaion
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobExplain")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteEqRobNewStartTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.tutorialState = .Action
            scenarioScene.enemyEnter([(2, 8, "x+2", 2), (6, 8, "3x-2x+2", 1), (2, 10, "x+4-2", 0), (6, 10, "2x", 1)]) {
                nextLine()
                wait(length: 2.0) {
                    scenarioScene.tutorialState = .Converstaion
                }
            }
            scenarioScene.eqRob.colorize()
            break;
        case 1: // eqRob show up
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.balloon.isHidden = true
            scenarioScene.playerTurnState = .UsingItem
            scenarioScene.itemType = .EqRob
            scenarioScene.eqRob.go(toPos: EqRobController.eqRobCenterPos) {
                SoundController.sound(scene: scenarioScene, sound: .ShowVe)
                scenarioScene.eqRob.look(at: scenarioScene.madScientistNode) {
                    scenarioScene.tutorialState = .Converstaion
                    nextLine()
                }
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.setScale(EqRobController.doctorScale[0])
            CharacterController.doctor.changeBalloonTexture(index: 1)
            CharacterController.doctor.balloon.isHidden = false
            CharacterController.doctor.move(from: EqRobController.doctorOffPos, to: EqRobController.doctorOnPos[0])
            EqRobController.scannedVECategory = 4
            EqRobController.scan()
            CharacterController.retreatMainHero()
            currentActionIndex += 1
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            wait(length: 0.5) {
                nextLineWithoutMoving()
                currentActionIndex += 1
                scenarioScene.gridNode.enemyArray[0].pointing()
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.gridNode.enemyArray[0].removePointing()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            CharacterController.mainHero.setScale(1.0)
            CharacterController.retreatMainHero()
            CharacterController.doctor.move(from: nil, to: EqRobController.doctorOnPos[0])
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .UsingItem
            scenarioScene.itemType = .EqRob
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            currentActionIndex += 1
            break;
        case 6:
            guard !scenarioScene.isCharactersTurn else { return }
            TutorialController.currentIndex = 1
            let _ = TutorialController.userTouch(on: "")
            currentActionIndex += 1
            break;
        case 7: // Miss
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            VEEquivalentController.hideEqGrid()
            EqRobController.back(3)
            GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
            wait(length: 1.0) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.buttonAttack.isHidden = true
            scenarioScene.playerTurnState = .UsingItem
            scenarioScene.itemType = .EqRob
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            TutorialController.currentIndex = 0
            TutorialController.state = .Show
            TutorialController.execute()
            GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
            EqRobController.execute(0, enemy: nil)
            currentActionIndex = 6
            break;
        case 9: //clear
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 10: // clear
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobNewExplain")
            loadGameScene()
            break;
        default:
            break;
        }
    }
    
    static func excuteCannonStartTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.enemyEnter([(1,9,"x+2", 0), (7,8,"2x", 1)]) {
                SignalSendingTurnController.sendSignal(in: 2) {}
                currentActionIndex += 1
                wait(length: 2.5) {
                    controllActions()
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            wait(length: 0.5) {
                nextLine()
            }
            wait(length: 2.0) {
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            SoundController.sound(scene: scenarioScene, sound: .ShowVe)
            scenarioScene.pointingGridAt(x: 1, y: 11)
            charaSpeak(at: currentLineIndex)
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CannonTutorialController.showInputPanelWithDoctor()
            nextLineWithoutMoving()
            currentActionIndex += 1
            scenarioScene.tutorialState = .None
            wait(length: 2.5) {
                scenarioScene.tutorialState = .Action
                controllActions()
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            scenarioScene.inputPanelForCannon.isActive = false
            scenarioScene.gridNode.enemyArray[0].pointing()
            currentActionIndex += 1
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            GridActiveAreaController.showActiveArea(at: [(1,8),(1,7),(1,6),(1,5)], color: "red", grid: scenarioScene.gridNode)
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            nextLineWithoutMoving()
            scenarioScene.inputPanelForCannon.isActive = true
            scenarioScene.gridNode.enemyArray[0].removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "6")
            currentActionIndex += 1
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "OK")
            scenarioScene.pointingGridAt(x: 1, y: 11)
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
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            CannonTutorialController.keyPos = scenarioScene.gridNode.enemyArray[0].position
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            TutorialController.enable()
            TutorialController.execute()
            scenarioScene.gameState = .SignalSending
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            currentActionIndex += 1
            break;
        case 12:
            break;
        case 13:
            guard !scenarioScene.isCharactersTurn else { return }
//            print(scenarioScene.gridNode.enemyArray[0].valueOfEnemy)
            scenarioScene.gridNode.enemyArray[0].calculatePunchLength(value: scenarioScene.xValue)
            scenarioScene.gridNode.enemyArray[0].turnDoneFlag = false
            scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
            scenarioScene.gameState = .EnemyTurn
            currentActionIndex += 1
            break;
        case 14: // fail
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.currentIndex = 2
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.gridNode.enemyArray[0].position = CannonTutorialController.keyPos
            scenarioScene.gridNode.enemyArray[0].positionY += scenarioScene.gridNode.enemyArray[0].valueOfEnemy
            scenarioScene.gridNode.enemyArray[0].punchIntervalForCount = 0
            currentActionIndex = 11
            controllActions()
            break;
        default:
            break;
        }
    }
    
    static func excuteInvisibleStartTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            scenarioScene.enemyEnter([(6,11,"2x", 0)]) {
                currentActionIndex += 1
                controllActions()
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
            SignalSendingTurnController.sendSignal(in: 2) {
                scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
                scenarioScene.gameState = .EnemyTurn
                scenarioScene.isCharactersTurn = false
                currentActionIndex += 1
            }
            break;
        case 3:
            guard !scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 0 else { return }
            scenarioScene.isCharactersTurn = true
            SignalController.send(target: scenarioScene.gridNode.enemyArray[0], num: 1) {
                SoundController.playBGM(bgm: .Opening2, isLoop: true)
                nextLine()
                scenarioScene.tutorialState = .Converstaion
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 6, y: 9)
            charaSpeak(at: currentLineIndex)
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            SoundController.sound(scene: scenarioScene, sound: .ShowVe)
            CharacterController.retreatMainHero()
            CannonTutorialController.showInputPanelWithDoctor()
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            scenarioScene.pointingInputButtonForCannon(name: "x")
            currentActionIndex += 1
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.setScale(0.85)
            CharacterController.mainHero.move(from: nil, to: CGPoint(x:600,y:CharacterController.mainHero.position.y), duration: 0.5)
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            let currentScenario = getScenario()
            let action = currentScenario[currentLineIndex]
            CharacterLinesController.doctorSay(line: action[1])
            scenarioScene.pointingInputButtonForCannon(name: "x")
            currentLineIndex += 1
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "+")
            currentActionIndex += 1
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "4")
            currentActionIndex += 1
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            guard scenarioScene.tutorialState == .Action else { return }
            scenarioScene.tutorialState = .None
            currentActionIndex += 1
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            scenarioScene.pointingInputButtonForCannon(name: "Try")
            wait(length: 1.5) {
                CannonTouchController.state = .Trying
                scenarioScene.tutorialState = .Action
                controllActions()
            }
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            CannonController.hideInputPanel()
            CannonController.selectedCannon.isActive = true
            scenarioScene.gridNode.isTutorial = true
            CannonTryController.showEqGrid(enemy: scenarioScene.gridNode.enemyArray[0], cannon: CannonController.selectedCannon)
            nextLineWithoutMoving()
            scenarioScene.removePointing()
            CharacterController.retreatMadDoctor()
            wait(length: 2.0) {
                currentActionIndex += 1
            }
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            CannonTryController.getBG() { b in
                guard let bg = b else { return }
                bg.signalTappedForScenario(value: 1) {}
            }
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.move(from: nil, to: CGPoint(x:600,y:CharacterController.mainHero.position.y), duration: 0.5)
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 16, 17:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointing(pos: CGPoint(x: 150, y: 900))
            scenarioScene.pointing(pos: CGPoint(x: 320, y: 1200))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointing(pos: CGPoint(x: 120, y: 750))
            scenarioScene.pointing(pos: CGPoint(x: 170, y: 1150))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointing(pos: CGPoint(x: 150, y: 820))
            scenarioScene.pointing(pos: CGPoint(x: 250, y: 1150))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 22, 23:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            CannonTryController.getBG() { b in
                guard let bg = b else { return }
                bg.signalTappedForScenario(value: 2) {}
            }
            break;
        case 25, 26:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 27:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            CannonTryController.getBG() { b in
                guard let bg = b else { return }
                bg.signalTappedForScenario(value: 3) {
                    bg.isTrying = false
                }
            }
            break;
        case 28:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 29:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            nextLineWithoutMoving()
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 30:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 31:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            scenarioScene.pointingChangeVeButton()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 32:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
            nextLineWithoutMoving()
            scenarioScene.pointingInputButtonForCannon(name: "2")
            currentActionIndex += 1
            break;
        case 33:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "x")
            currentActionIndex += 1
            break;
        case 34:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "OK")
            currentActionIndex += 1
            break;
        case 35:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 36:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            CannonTryController.getBG() { b in
                guard let bg = b else { return }
                bg.doTryForScenario {
                    controllActions()
                }
            }
            break;
        case 37:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.move(from: nil, to: CGPoint(x:600,y:CharacterController.mainHero.position.y), duration: 0.5)
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 38:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 39:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointing(pos: CGPoint(x: 170, y: 1150))
            scenarioScene.pointing(pos: CGPoint(x: 250, y: 1150))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 40:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointing(pos: CGPoint(x: 160, y: 1100))
            scenarioScene.pointing(pos: CGPoint(x: 160, y: 1050))
            scenarioScene.pointing(pos: CGPoint(x: 160, y: 1000))
            scenarioScene.pointing(pos: CGPoint(x: 230, y: 1100))
            scenarioScene.pointing(pos: CGPoint(x: 230, y: 1050))
            scenarioScene.pointing(pos: CGPoint(x: 230, y: 1000))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 41:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointing(pos: CGPoint(x: 300, y: 1100))
            scenarioScene.pointing(pos: CGPoint(x: 300, y: 1050))
            scenarioScene.pointing(pos: CGPoint(x: 300, y: 1000))
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 42:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 43:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            CharacterController.retreatMainHero()
            scenarioScene.pointingChangeVeButton()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 44:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
            nextLineWithoutMoving()
            scenarioScene.pointingInputButtonForCannon(name: "2")
            currentActionIndex += 1
            break;
        case 45:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "x")
            currentActionIndex += 1
            break;
        case 46:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "+")
            currentActionIndex += 1
            break;
        case 47:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "2")
            currentActionIndex += 1
            break;
        case 48:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingInputButtonForCannon(name: "OK")
            currentActionIndex += 1
            break;
        case 49:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            currentActionIndex += 1
            CannonTryController.getBG() { b in
                guard let bg = b else { return }
                bg.doTryForScenario {
                    controllActions()
                }
            }
            break;
        case 50:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.move(from: nil, to: CGPoint(x:600,y:CharacterController.mainHero.position.y), duration: 0.5)
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 51:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 52:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingTryDoneButton()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 53:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            CannonTutorialController.hideEqGrid()
            currentActionIndex += 1
            break;
        case 54:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.balloon.isHidden = true
            scenarioScene.enemyTurnDoneFlag = false
            scenarioScene.gridNode.numOfTurnEndEnemy = 0
            scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
            scenarioScene.gameState = .EnemyTurn
            scenarioScene.isCharactersTurn = false
            currentActionIndex += 1
            break;
        case 55:
            guard !scenarioScene.isCharactersTurn && scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 0 else { return }
            nextLine()
            CharacterController.mainHero.setScale(1.0)
            scenarioScene.tutorialState = .Converstaion
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            break;
        case 56:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            scenarioScene.enemyEnter([(6,8,"x+3", 0),(1,9,"2x-1", 0)]) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 57:
            guard scenarioScene.isCharactersTurn else { return }
            SoundController.playBGM(bgm: .Game1, isLoop: true)
            TutorialController.enable()
            TutorialController.execute()
            scenarioScene.countTurn = 0
            scenarioScene.willFastForward = false
            scenarioScene.gameState = .SignalSending
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            break;
        case 58: // fail
            guard scenarioScene.totalNumOfEnemy > 0 else { return }
            guard !scenarioScene.isCharactersTurn && scenarioScene.gameState == .AddEnemy && scenarioScene.countTurn == 1 else { return }
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            TutorialController.currentIndex = 2
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 59:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            let dispatchGroup = DispatchGroup()
            for enemy in scenarioScene.gridNode.enemyArray {
                dispatchGroup.enter()
                let enemyLastPos = enemy.posRecord[enemy.posRecord.count-1]
                scenarioScene.resetEnemyPos(enemy: enemy, x: enemyLastPos.0, y: enemyLastPos.1, punchInterval: enemyLastPos.2)
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main, execute: {
                EnemyMoveController.updateEnemyPositon(grid: scenarioScene.gridNode)
                scenarioScene.enemyTurnDoneFlag = false
                scenarioScene.gridNode.numOfTurnEndEnemy = 0
                scenarioScene.gridNode.enemyArray[0].myTurnFlag = true
                currentActionIndex = 57
                controllActions()
            })
            break;
        default:
            break;
        }
    }
    
    static func excuteLastTurn() {
        switch currentActionIndex {
        case 0:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.setHero()
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            SpeakInGameController.lastAction = .None
            DAUserDefaultUtility.doneFirstly(name: "lastScenario")
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
    
    private static func charaJustSpeak(at i: Int) {
        let currentScenario = getScenario()
        let action = currentScenario[i]
        characterSpeak(chara: action[0], line: action[1])
        currentLineIndex += 1
    }
    
    static func charaJustSpeakWithoutMoving(at i: Int) {
        let currentScenario = getScenario()
        let action = currentScenario[i]
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
        currentLineIndex += 1
        SoundController.sound(scene: scenarioScene, sound: .CharaLine)
    }
    
    public static func loadGameScene() {
        
        CharacterController.retreatMainHero()
        CharacterController.retreatDoctor()
        CharacterController.retreatMadDoctor()
        
        SoundController.stopBGM()
        
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
