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
        case MainMenu.changeMoveSpanStartTurn: //2
            return ScenarioProperty.scenarioChangeMoveSpan
        case MainMenu.timeBombStartTurn: //3
            return ScenarioProperty.scenarioTimeBombStartTurn
        case MainMenu.showUnsimplifiedStartTurn: //6
            return ScenarioProperty.scenarioUnsimplified
        case MainMenu.eqRobStartTurn: //7
            return ScenarioProperty.scenarioEqRobStartTurn
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
        case MainMenu.changeMoveSpanStartTurn: //2
            excuteChangeMoveSpan()
            break;
        case MainMenu.timeBombStartTurn: //3
            excuteTimeBombStartTurn()
            break;
        case MainMenu.moveExplainStartTurn: //5
            excuteMoveExplain()
            break;
        case MainMenu.showUnsimplifiedStartTurn: //6
            excuteUnsimplified()
            break;
        case MainMenu.eqRobStartTurn: //7
            excuteEqRobStartTurn()
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
            scenarioScene.enemyEnter([(4,10,"x",1)]) {
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
            currentActionIndex = 11
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .DisplayPhase
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            
            currentActionIndex += 1
            break;
        case 11:
            guard !scenarioScene.isCharactersTurn else { return }
            if scenarioScene.gameState == .GameOver {
                currentActionIndex += 1
                scenarioScene.isCharactersTurn = true
                scenarioScene.gridNode.isTutorial = true
                controllActions()
            } else {
                return
            }
            break;
        case 13: // Game Over
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            TutorialController.currentIndex = 9
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.resetEnemies()
            scenarioScene.resetHeroPos(x: 4, y: 2)
            scenarioScene.life = 5
            scenarioScene.setLife(numOflife: 5)
            currentActionIndex = 10
            controllActions()
            break;
        case 15: // Hero bumpped enemy
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            TutorialController.currentIndex = 12
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.hero.isHidden = false
            scenarioScene.unDo() {
                currentActionIndex = 10
                controllActions()
            }
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
            CharacterController.retreatMadDoctor()
            scenarioScene.enemyEnter([(2,10,"x+1",2), (6,10,"x",1)]) {
                currentActionIndex += 1
                scenarioScene.tutorialState = .Converstaion
                controllActions()
                scenarioScene.totalNumOfEnemy = 2
                scenarioScene.willFastForward = false
            }
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.showX()
            wait(length: 1.0) {
                currentActionIndex += 1
                controllActions()
            }
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            SignalController.sendHalf(target: scenarioScene.gridNode.enemyArray[0], num: 2) {
                scenarioScene.pointingSignal()
                scenarioScene.tutorialState = .Converstaion
                nextLine()
            }
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.getSignal() { signal in
                signal.xValue.isHidden = false
                charaSpeak(at: currentLineIndex)
                scenarioScene.tutorialState = .Converstaion
                currentActionIndex -= 1
            }
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.getSignal() { signal in
                SignalController.sendHalf2(signal: signal, target: scenarioScene.gridNode.enemyArray[0], num: 2) {
                    scenarioScene.xValue = 2
                    scenarioScene.valueOfX.fontColor = UIColor.red
                    scenarioScene.gridNode.enemyArray[0].punchIntervalForCount = 0
                    scenarioScene.gridNode.enemyArray[0].calculatePunchLength(value: scenarioScene.xValue)
                    scenarioScene.gridNode.numOfTurnEndEnemy = 0
                    scenarioScene.gridNode.enemyArray[0].xValueLabel.isHidden = false
                    scenarioScene.gridNode.enemyArray[1].xValueLabel.isHidden = false
                    scenarioScene.signalHolder.isHidden = false
                    scenarioScene.valueOfX.isHidden = false
                    scenarioScene.gridNode.enemyArray[0].variableExpressionLabel.fontColor = UIColor.red
                    charaSpeak(at: currentLineIndex)
                    scenarioScene.tutorialState = .Converstaion
                }
            }
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            scenarioScene.gameState = .PlayerTurn
            scenarioScene.playerTurnState = .DisplayPhase
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            currentActionIndex += 1
            break;
        case 10:
            guard !scenarioScene.isCharactersTurn else { return }
            if scenarioScene.gameState == .GameOver {
                currentActionIndex += 1
                scenarioScene.isCharactersTurn = true
                scenarioScene.gridNode.isTutorial = true
                controllActions()
            } else {
                return
            }
            break;
        case 11: // Game Over
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            TutorialController.currentIndex = 2
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.resetEnemies()
            scenarioScene.resetHeroPos(x: 4, y: 2)
            scenarioScene.life = 5
            scenarioScene.setLife(numOflife: 5)
            currentActionIndex = 9
            controllActions()
            break;
        case 13: // Hero bumpped enemy
            guard !scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            TutorialController.currentIndex = 5
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            wait(length: 1.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.hero.isHidden = false
            scenarioScene.unDo() {
                currentActionIndex = 9
                controllActions()
            }
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
                nextLine()
                wait(length: 2.0) {
                    scenarioScene.tutorialState = .Converstaion
                }
            }
            break;
        case 1:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 4, y: 10)
            charaSpeak(at: currentLineIndex)
            scenarioScene.tutorialState = .Converstaion
            currentActionIndex -= 1
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            SignalController.send(target: scenarioScene.gridNode.enemyArray[1], num: 2) {
                charaSpeak(at: currentLineIndex)
                currentActionIndex -= 1
                scenarioScene.tutorialState = .Converstaion
                scenarioScene.xValue = 2
                scenarioScene.gridNode.enemyArray[1].calculatePunchLength(value: 2)
            }
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.showActiveArea(at: [(4,9),(4,8),(4,7)], color: "red", grid: scenarioScene.gridNode)
            charaSpeak(at: currentLineIndex)
            scenarioScene.tutorialState = .Converstaion
            currentActionIndex -= 1
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            let enemy = scenarioScene.gridNode.enemyArray[1]
            enemy.punch() { armAndFist in
                enemy.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    enemy.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: enemy.valueOfEnemy) {
                        /* Keep track enemy position */
                        enemy.positionY -= enemy.valueOfEnemy
                        enemy.removeArmNFist()
                        enemy.xValueLabel.text = ""
                        enemy.setMovingAnimation()
                        enemy.variableExpressionLabel.fontColor = UIColor.white
                        GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
                        scenarioScene.removePointing()
                        currentActionIndex += 1
                        controllActions()
                    }
                }
            }
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            SignalController.send(target: scenarioScene.gridNode.enemyArray[1], num: 1) {
                scenarioScene.xValue = 1
                scenarioScene.gridNode.enemyArray[1].calculatePunchLength(value: 1)
                currentActionIndex += 1
                controllActions()
                CharacterController.retreatMainHero()
            }
            for _ in 0..<3 {
                scenarioScene.displayitem(name: "timeBomb")
            }
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.buttonItem.isHidden = false
            scenarioScene.buttonAttack.isHidden = false
            scenarioScene.pointingItmBtn()
            scenarioScene.tutorialState = .Action
            charaSpeak(at: currentLineIndex)
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.pointingLastGotItem()
            charaSpeak(at: currentLineIndex)
            scenarioScene.itemAreaCover.isHidden = true
            break;
        case 9:
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
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.tutorialState = .None
            GridActiveAreaController.resetSquareArray(color: "purple", grid: scenarioScene.gridNode)
            nextLineWithoutMoving()
            scenarioScene.pointingGridAt(x: 4, y: 7)
            scenarioScene.pointingGridAt(x: 4, y: 5)
            GridActiveAreaController.showActiveArea(at: [(4,6),(4,5)], color: "red", grid: scenarioScene.gridNode)
            currentActionIndex += 1
            wait(length: 2.0) {
                scenarioScene.tutorialState = .Action
            }
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
            nextLineWithoutMoving()
            scenarioScene.removePointing()
            GridActiveAreaController.showtimeBombSettingArea(grid: scenarioScene.gridNode)
            currentActionIndex += 1
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            ItemTouchController.AAForTimeBombTapped(gridX: 4, gridY: 5)
            scenarioScene.removePointing()
            scenarioScene.pointingYes()
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            currentActionIndex += 1
            scenarioScene.removePointing()
            wait(length: 1.0) {
                GridActiveAreaController.resetSquareArray(color: "blue", grid: scenarioScene.gridNode)
                controllActions()
            }
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            let enemy = scenarioScene.gridNode.enemyArray[1]
            enemy.punch() { armAndFist in
                enemy.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    enemy.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: enemy.valueOfEnemy) {
                        /* Keep track enemy position */
                        enemy.positionY -= enemy.valueOfEnemy
                        enemy.removeArmNFist()
                        enemy.xValueLabel.text = ""
                        enemy.setMovingAnimation()
                        enemy.variableExpressionLabel.fontColor = UIColor.white
                        GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
                        scenarioScene.removePointing()
                        currentActionIndex += 1
                        controllActions()
                    }
                }
            }
            break;
        case 15:
            if scenarioScene.gridNode.timeBombSetArray.count > 0 {
                if MainMenu.soundOnFlag {
                    let explode = SKAction.playSoundFileNamed("timeBombExplosion.mp3", waitForCompletion: true)
                    scenarioScene.run(explode)
                }
                let timeBomb = scenarioScene.gridNode.timeBombSetArray[0]
                timeBomb.explode {
                    nextLine()
                    scenarioScene.tutorialState = .Converstaion
                }
                scenarioScene.gridNode.timeBombSetArray.removeAll()
            }
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.gameState = .SignalSending
            scenarioScene.isCharactersTurn = false
            scenarioScene.gridNode.isTutorial = false
            currentActionIndex += 1
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            currentActionIndex += 1
            scenarioScene.tutorialState = .Action
            break;
        case 19:
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
        case 20:
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
            currentActionIndex = 17
            break;
        case 21: // clear
            guard !scenarioScene.isCharactersTurn && scenarioScene.gameState == .StageClear else { return }
            TutorialController.removeTutorialLabel()
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            scenarioScene.tutorialState = .Converstaion
            wait(length: 1.0) {
                nextLine()
            }
            break;
        case 22:
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
            scenarioScene.enemyEnter([(4, 9, "2×x+1", 1), (5, 9, "x+x+1", 1)]) {
                scenarioScene.gameState = .PlayerTurn
                scenarioScene.playerTurnState = .MoveState
                scenarioScene.isCharactersTurn = false
                scenarioScene.gridNode.isTutorial = false
                TutorialController.enable()
                TutorialController.execute()
                currentActionIndex += 1
            }
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
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingGridAt(x: 5, y: 8)
            charaSpeak(at: currentLineIndex)
            currentActionIndex -= 1
            scenarioScene.tutorialState = .Converstaion
            break;
        case 2:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            VEEquivalentController.showEqGrid(enemies: [scenarioScene.gridNode.enemyArray[1], scenarioScene.gridNode.enemyArray[2]])
            CharacterController.retreatMainHero()
            currentActionIndex += 1
            controllActions()
            break;
        case 3:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctor.position.x, y: CharacterController.doctor.position.y-300), duration: 1.0)
            nextLineWithoutMoving()
            scenarioScene.pointingEqSignal()
            currentActionIndex += 1
            break;
        case 4:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            CharacterController.doctor.changeBalloonTexture(index: 1)
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 5:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CharacterController.doctor.changeBalloonTexture(index: 0)
            CharacterController.doctor.move(from: nil, to: CGPoint(x: CharacterController.doctor.position.x, y: CharacterController.doctor.position.y-300), duration: 1.0)
            GridActiveAreaController.resetSquareArray(color: "green", grid: scenarioScene.eqGrid)
            scenarioScene.valueOfX.text = "x=1"
            let enemy1 = scenarioScene.gridNode.enemyArray[1]
            let enemy2 = scenarioScene.gridNode.enemyArray[2]
            enemy1.calculatePunchLength(value: 1)
            enemy1.xValueLabel.text = "x=1"
            for i in 1...enemy1.valueOfEnemy {
                GridActiveAreaController.showActiveArea(at: [(enemy1.eqPosX, enemy1.eqPosY-i)], color: "green", grid: scenarioScene.eqGrid, zPosition: 12)
            }
            enemy2.calculatePunchLength(value: 1)
            enemy2.xValueLabel.text = "x=1"
            for i in 1...enemy2.valueOfEnemy {
                GridActiveAreaController.showActiveArea(at: [(enemy2.eqPosX, enemy2.eqPosY-i)], color: "green", grid: scenarioScene.eqGrid, zPosition: 12)
            }
            nextLineWithoutMoving()
            scenarioScene.pointingGridAt(x: 4, y: 11)
            scenarioScene.pointingEqSignal1()
            currentActionIndex += 1
            scenarioScene.eqGrid.createLabel(text: "2x+1", posX: 1, posY: 7, redLetterPos: [1], greenLetterPos: [])
            scenarioScene.eqGrid.createLabel(text: "2×1+1=3", posX: 1, posY: 5, redLetterPos: [2], greenLetterPos: [6])
            break;
        case 6:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 11)
            currentActionIndex += 1
            scenarioScene.eqGrid.removeLabel()
            scenarioScene.eqGrid.createLabel(text: "x+1+x", posX: 1, posY: 7, redLetterPos: [0,4], greenLetterPos: [])
            scenarioScene.eqGrid.createLabel(text: "1+1+1=3", posX: 1, posY: 5, redLetterPos: [0,4], greenLetterPos: [6])
            break;
        case 7:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            GridActiveAreaController.resetSquareArray(color: "green", grid: scenarioScene.eqGrid)
            scenarioScene.valueOfX.text = "x=2"
            let enemy1 = scenarioScene.gridNode.enemyArray[1]
            let enemy2 = scenarioScene.gridNode.enemyArray[2]
            enemy1.calculatePunchLength(value: 2)
            enemy1.xValueLabel.text = "x=2"
            for i in 1...enemy1.valueOfEnemy {
                GridActiveAreaController.showActiveArea(at: [(enemy1.eqPosX, enemy1.eqPosY-i)], color: "green", grid: scenarioScene.eqGrid, zPosition: 12)
            }
            enemy2.calculatePunchLength(value: 2)
            enemy2.xValueLabel.text = "x=2"
            for i in 1...enemy2.valueOfEnemy {
                GridActiveAreaController.showActiveArea(at: [(enemy2.eqPosX, enemy2.eqPosY-i)], color: "green", grid: scenarioScene.eqGrid, zPosition: 12)
            }
            nextLineWithoutMoving()
            scenarioScene.eqGrid.removeLabel()
            scenarioScene.eqGrid.createLabel(text: "2x+1", posX: 1, posY: 7, redLetterPos: [1], greenLetterPos: [])
            scenarioScene.eqGrid.createLabel(text: "2×2+1=5", posX: 1, posY: 5, redLetterPos: [2], greenLetterPos: [6])
            scenarioScene.pointingGridAt(x: 4, y: 11)
            scenarioScene.pointingEqSignal2()
            currentActionIndex += 1
            break;
        case 8:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            scenarioScene.eqGrid.removeLabel()
            scenarioScene.eqGrid.createLabel(text: "x+1+x", posX: 1, posY: 7, redLetterPos: [0,4], greenLetterPos: [])
            scenarioScene.eqGrid.createLabel(text: "2+1+2=5", posX: 1, posY: 5, redLetterPos: [0,4], greenLetterPos: [6])
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 7, y: 11)
            currentActionIndex += 1
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.eqGrid.removeLabel()
            scenarioScene.eqGrid.createLabel(text: "2x+1", posX: 1, posY: 7, redLetterPos: [0,1], greenLetterPos: [])
            scenarioScene.eqGrid.createLabel(text: "x+1+x", posX: 1, posY: 6, redLetterPos: [0,4], greenLetterPos: [])
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            CharacterController.doctor.changeBalloonTexture(index: 1)
            scenarioScene.tutorialState = .Converstaion
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.eqGrid.removeLabel()
            GridActiveAreaController.resetSquareArray(color: "green", grid: scenarioScene.eqGrid)
            VEEquivalentController.hideEqGrid()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 11: // eqRob show up
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.eqRob.go(toPos: EqRobController.eqRobOriginPos) {
                let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
                scenarioScene.eqRob.run(rotate, completion: {
                    scenarioScene.tutorialState = .Converstaion
                    nextLine()
                })
            }
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingEqRob()
            charaSpeak(at: currentLineIndex)
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.retreatMainHero()
            EqRobTutorialController.showInputPanel()
            nextLineWithoutMoving()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "2")
            currentActionIndex += 2
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "x")
            currentActionIndex += 1
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "+")
            currentActionIndex += 1
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingGridAt(x: 3, y: 8)
            scenarioScene.pointingInputButton(name: "1")
            currentActionIndex += 1
            break;
        case 18:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            scenarioScene.removePointing()
            scenarioScene.pointingInputButton(name: "OK")
            scenarioScene.pointingGridAt(x: 3, y: 8)
            currentActionIndex += 1
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            EqRobTutorialController.showSelectionPanel()
            nextLine()
            currentActionIndex += 1
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.doctor.setScale(0.8)
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingGridAt(x: 5, y: 8)
            CharacterController.mainHero.moveWithScaling(to: CGPoint(x: 630, y: 500), value: 0.75) {
                nextLineWithoutMoving()
                currentActionIndex += 1
            }
            break;
        case 22:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 23:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 25:
            guard scenarioScene.isCharactersTurn else { return }
            TutorialController.enable()
            TutorialController.execute()
            CharacterController.doctor.setScale(1.0)
            CharacterController.mainHero.setScale(1.0)
            CharacterController.retreatMainHero()
            CharacterController.retreatDoctor()
            currentActionIndex += 1
            break;
        case 26:
            guard scenarioScene.isCharactersTurn else { return }
            let _ = TutorialController.userTouch(on: "")
            EqRobTutorialController.isPerfect = EqRobTutorialController.eqRobGoToAttack()
            currentActionIndex += 1
            break;
        case 27:
            guard scenarioScene.isCharactersTurn else { return }
            if EqRobTutorialController.isPerfect {
                nextLine()
                scenarioScene.tutorialState = .Converstaion
            } else {
                EqRobTutorialController.pointingMissedEnemies()
                currentActionIndex = 29
                currentLineIndex = 53
            }
            break;
        case 28: // clear
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobExplain")
            loadGameScene()
            break;
        case 29: // miss
            guard scenarioScene.isCharactersTurn else { return }
            EqRobTutorialController.makeInsturctionForMiss()
            EqRobController.doctorSays(in: .MissEnemiesInstruction, value: EqRobLines.subLinesForMissEnemiesInstruction())
            scenarioScene.tutorialState = .Action
            currentActionIndex += 1
            break;
        case 30:
            VEEquivalentController.hideEqGrid()
            scenarioScene.tutorialState = .Converstaion
            nextLine()
            break;
        case 31:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "eqRobExplain")
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
            print(scenarioScene.gridNode.enemyArray[0].valueOfEnemy)
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
            scenarioScene.enemyEnter([(2,11,"2x-1", 0), (6,11,"x+1", 0)]) {
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
            SignalSendingTurnController.sendSignal(in: 3) {
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
            SignalController.send(target: scenarioScene.gridNode.enemyArray[0], num: 1) {}
            SignalController.send(target: scenarioScene.gridNode.enemyArray[1], num: 1) {
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
            guard scenarioScene.tutorialState == .Action else { return }
            scenarioScene.tutorialState = .None
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            scenarioScene.pointingInputButtonForCannon(name: "Try")
            wait(length: 1.5) {
                CannonTouchController.state = .Trying
                currentActionIndex += 1
                scenarioScene.tutorialState = .Action
                controllActions()
            }
            break;
        case 9:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 10:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CharacterController.retreatMadDoctor()
            scenarioScene.pointingEqSignal1()
            currentActionIndex += 1
            wait(length: 1.0) {
                nextLineWithoutMoving()
            }
            break;
        case 11:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 12:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 13:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.mainHero.move(from: nil, to: CGPoint(x:600,y:CharacterController.mainHero.position.y), duration: 0.5)
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 14:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 15:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            CannonTryController.resetEnemy()
            nextLineWithoutMoving()
            scenarioScene.pointingEqSignal2()
            currentActionIndex += 1
            break;
        case 16:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 17:
            guard scenarioScene.isCharactersTurn else { return }
            nextLineWithoutMoving()
            break;
        case 18:
            CannonTryController.resetEnemy()
            nextLineWithoutMoving()
            scenarioScene.pointingEqSignal3()
            currentActionIndex += 1
            break;
        case 19:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.removePointing()
            CannonTryController.resetEnemy()
            nextLineWithoutMoving()
            scenarioScene.tutorialState = .Converstaion
            CharacterController.doctor.setScale(1.0)
            CharacterController.mainHero.setScale(1.0)
            break;
        case 20:
            guard scenarioScene.isCharactersTurn else { return }
            scenarioScene.pointingChangeVeButton()
            charaSpeak(at: currentLineIndex)
            break;
        case 21:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.retreatMainHero()
            scenarioScene.removePointing()
            CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
            nextLineWithoutMoving()
            currentActionIndex += 1
            break;
        case 22:
            guard scenarioScene.isCharactersTurn else { return }
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            currentActionIndex += 1
            break;
        case 23:
            break;
        case 24:
            guard scenarioScene.isCharactersTurn else { return }
            CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
            CharacterController.doctor.balloon.isHidden = true
            scenarioScene.gameState = .AddItem
            currentActionIndex += 1
            break;
        case 25:
            guard !scenarioScene.isCharactersTurn && scenarioScene.gameState == .AddItem && scenarioScene.countTurn == 0 else { return }
            CharacterController.doctor.setScale(1.0)
            nextLine()
            scenarioScene.tutorialState = .Converstaion
            scenarioScene.isCharactersTurn = true
            scenarioScene.gridNode.isTutorial = true
            break;
        case 26:
            guard scenarioScene.isCharactersTurn else { return }
            DAUserDefaultUtility.doneFirstly(name: "invisibleSignal")
            loadGameScene()
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
    
    public static func loadGameScene() {
        
        CharacterController.retreatMainHero()
        CharacterController.retreatDoctor()
        CharacterController.retreatMadDoctor()
        
        scenarioScene.main.stop()
        
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
