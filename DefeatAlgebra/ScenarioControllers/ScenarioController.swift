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
    static var allDone = false
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
        } else {
            allDone = true
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
        default:
            return [[String]]()
        }
    }
    
    static func controllActions() {
        switch GameScene.stageLevel {
        case 0:
            excute0()
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
            scenarioScene.enemyEnter {
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
                currentActionIndex = 15
                scenarioScene.isCharactersTurn = true
                scenarioScene.gridNode.isTutorial = true
                controllActions()
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
            break;
        default:
            break;
        }
    }
    
    private static func wait(length: TimeInterval, success: @escaping () -> Void) {
        let wait = SKAction.wait(forDuration: length)
        scenarioScene.run(wait, completion: {
            return success()
        })
    }
}
