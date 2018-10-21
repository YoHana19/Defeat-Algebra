//
//  SpeakInGameController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/23.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum CharacterSpeakContentType {
    case None, PlaneExplain, EqRobFirstly, LogDefenceFirstly, TimeBombGotFirstly, MoveExplain, SecondDay, EqRobReturn, VeScaleExplain
}

struct SpeakInGameController {
    static var currentContent = [[String]]()
    static var currentActionIndex = 0
    static var currentLineIndex = 0
    static var lastAction: CharacterSpeakContentType = .None
    static var gameScene: GameScene!
    static var waitingUserTouch = false
    static var keyTurn = -1
    
    public static func controlAction() {
        switch GameScene.stageLevel {
        case MainMenu.timeBombStartTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .TimeBombGotFirstly else { return }
                wait(length: 1.0) {
                    doAction(type: .TimeBombGotFirstly)
                }
                return
            }
            break;
        case MainMenu.moveExplainStartTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 4 {
                guard lastAction != .PlaneExplain else { return }
                wait(length: 1.0) {
                    doAction(type: .PlaneExplain)
                }
                return
            }
            break;
        case MainMenu.eqRobStartTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .EqRobFirstly else { return }
                wait(length: 1.0) {
                    doAction(type: .EqRobFirstly)
                }
                return
            }
            break;
        case MainMenu.showUnsimplifiedStartTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .VeScaleExplain else { return }
                wait(length: 1.0) {
                    doAction(type: .VeScaleExplain)
                }
                return
            }
            break;
        case MainMenu.secondDayStartTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .SecondDay else { return }
                wait(length: 1.0) {
                    doAction(type: .SecondDay)
                }
                return
            }
            break;
        case MainMenu.secondDayStartTurn+2:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .EqRobReturn else { return }
                wait(length: 1.0) {
                    doAction(type: .EqRobReturn)
                }
                return
            }
            break;
        case MainMenu.lastTurn:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .EqRobReturn else { return }
                wait(length: 1.0) {
                    doAction(type: .EqRobReturn)
                }
                return
            }
            break;
        default:
            break;
        }
    }
    
    static func nextLine() {
        if currentLineIndex < currentContent.count {
            let action = currentContent[currentLineIndex]
            if action[0] == "pause" {
                executeAction()
                return
            } else {
                ScenarioController.characterSpeak(chara: action[0], line: action[1])
            }
            if action.count >= 3 && action[2] == "user" {
                waitingUserTouch = true
                gameScene.isCharactersTurn = false
                gameScene.gridNode.isTutorial = false
                gameScene.gameState = .PlayerTurn
                gameScene.playerTurnState = .MoveState
            }
            currentLineIndex += 1
        } else {
            gameScene.gameState = .PlayerTurn
            gameScene.playerTurnState = .DisplayPhase
            gameScene.isCharactersTurn = false
            gameScene.gridNode.isTutorial = false
            CharacterController.retreatDoctor()
            CharacterController.retreatMadDoctor()
            CharacterController.retreatMainHero()
        }
    }
    
    static func characterComeNSpeakNOut() {
        let action = currentContent[currentLineIndex]
        ScenarioController.characterSpeak(chara: action[0], line: action[1])
        let wait = SKAction.wait(forDuration: 3.0)
        gameScene.run(wait, completion: {
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
        })
    }
    
    static func getContent(type: CharacterSpeakContentType) {
        switch type {
        case .PlaneExplain:
            currentContent = SpeakInGameProperty.planeExplain
            DAUserDefaultUtility.doneFirstly(name: "PlaneExplainFirst")
            break;
        case .TimeBombGotFirstly:
            currentContent = SpeakInGameProperty.timeBombGotFirstly
            break;
        case .VeScaleExplain:
            currentContent = SpeakInGameProperty.veScaleExplain
            break;
        case .LogDefenceFirstly:
            DAUserDefaultUtility.doneFirstly(name: "logDefenceFirst")
            currentContent = SpeakInGameProperty.logDefenceFirstly
            break;
        case .EqRobFirstly:
            currentContent = SpeakInGameProperty.eqRobFirstly
            break;
        case .SecondDay:
            currentContent = SpeakInGameProperty.secondDay
            break;
        case .EqRobReturn:
            currentContent = SpeakInGameProperty.eqRobReturn
            break;
        default:
            break;
        }
    }
    
    static func doAction(type: CharacterSpeakContentType) {
        lastAction = type
        getContent(type: type)
        currentLineIndex = 0
        currentActionIndex = 0
        if currentContent.count > 1 {
            gameScene.isCharactersTurn = true
            gameScene.gridNode.isTutorial = true
            gameScene.tutorialState = .Converstaion
            nextLine()
        } else {
            characterComeNSpeakNOut()
        }
        userActionDisable(type: type)
    }
    
    public static func userActionDisable(type: CharacterSpeakContentType) {
        switch type {
        case .PlaneExplain:
            gameScene.gridNode.isTutorial = true
            wait(length: 4.0) {
                gameScene.gridNode.isTutorial = false
            }
            break;
        default:
            break;
        }
    }
    
    public static func userTouch(on name: String?) -> Bool {
        if waitingUserTouch {
            if GameScene.stageLevel == MainMenu.showUnsimplifiedStartTurn && TutorialController.currentIndex < 2 {
                return false
            } else {
                waitingUserTouch = false
                return true
            }
        } else {
            return true
        }
    }
    
    private static func initialAction() {
        switch lastAction {
        default:
            break;
        }
    }
    
    private static func executeAction() {
        switch lastAction {
        case .PlaneExplain:
            switch currentActionIndex {
            case 0:
                CharacterController.retreatDoctor()
                TutorialController.currentIndex = 4
                TutorialController.enable()
                TutorialController.execute()
                break;
            default:
                break;
            }
            break;
        case .VeScaleExplain:
            switch currentActionIndex {
            case 0:
                gameScene.isCharactersTurn = false
                gameScene.gridNode.isTutorial = false
                gameScene.tutorialState = .None
                waitingUserTouch = true
                TutorialController.enable()
                TutorialController.execute()
                break;
            default:
                break;
            }
            break;
        case .SecondDay:
            CharacterController.retreatDoctor()
            CharacterController.retreatMainHero()
            gameScene.isCharactersTurn = false
            gameScene.gridNode.isTutorial = false
            break;
        default:
            break;
        }
    }
    
    private static func wait(length: TimeInterval, success: @escaping () -> Void) {
        let wait = SKAction.wait(forDuration: length)
        gameScene.run(wait, completion: {
            return success()
        })
    }
}
