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
    case None, PlaneExplain, LogDefenceFirstly, BootsGotFirstly, TimeBombGotFirstly, TimeBombGotFirstly2, HeartGotFirstly, WallGotFirstly, CaneGotFirstly
}

struct SpeakInGameController {
    static var currentContent = [[String]]()
    static var currentActionIndex = 0
    static var currentLineIndex = 0
    static var lastAction: CharacterSpeakContentType = .None
    static var gameScene: GameScene!
    static var waitingUserTouch = false {
        didSet {
            if waitingUserTouch {
                initialAction()
            }
        }
    }
    static var keyTurn = -1
    
    public static func controlAction() {
        switch GameScene.stageLevel {
        case 0:
            if gameScene.gameState == .AddItem && gameScene.countTurn == 0 {
                guard lastAction != .PlaneExplain else { return }
                wait(length: 1.0) {
                    doAction(type: .PlaneExplain)
                }
                return
            }
            if gameScene.gameState == .PlayerTurn && gameScene.playerTurnState == .ItemOn && gameScene.countTurn == keyTurn {
                guard lastAction != .TimeBombGotFirstly2 else { return }
                wait(length: 1.0) {
                    doAction(type: .TimeBombGotFirstly2)
                    keyTurn = -1
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
            break;
        case .LogDefenceFirstly:
            DAUserDefaultUtility.doneFirstly(name: "logDefenceFirst")
            currentContent = SpeakInGameProperty.logDefenceFirstly
            break;
        case .BootsGotFirstly:
            DAUserDefaultUtility.doneFirstly(name: "bootsGotFirst")
            currentContent = SpeakInGameProperty.bootsGotFirstly
            break;
        case .TimeBombGotFirstly:
            DAUserDefaultUtility.doneFirstly(name: "timeBombGotFirst")
            currentContent = SpeakInGameProperty.timeBombGotFirstly
            break;
        case .TimeBombGotFirstly2:
            currentContent = SpeakInGameProperty.timeBombGotFirstly2
            break;
        case .HeartGotFirstly:
            DAUserDefaultUtility.doneFirstly(name: "heartGotFirst")
            currentContent = SpeakInGameProperty.heartGotFirstly
            break;
        case .WallGotFirstly:
            DAUserDefaultUtility.doneFirstly(name: "wallGotFirst")
            currentContent = SpeakInGameProperty.wallGotFirstly
            break;
        case .CaneGotFirstly:
            DAUserDefaultUtility.doneFirstly(name: "caneGotFirst")
            currentContent = SpeakInGameProperty.caneGotFirstly
            break;
        default:
            break;
        }
    }
    
    static func doAction(type: CharacterSpeakContentType) {
        lastAction = type
        userActionDisable(type: type)
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
    }
    
    public static func userActionDisable(type: CharacterSpeakContentType) {
        switch type {
        case .PlaneExplain:
            gameScene.gridNode.isTutorial = true
            wait(length: 5.0) {
                gameScene.gridNode.isTutorial = false
            }
            break;
        default:
            break;
        }
    }
    
    public static func userTouch(on name: String?) -> Bool {
        if waitingUserTouch {
            guard let name = name else { return false }
            switch lastAction {
            case .TimeBombGotFirstly:
                switch currentActionIndex {
                case 0:
                    guard gameScene.gameState == .PlayerTurn, name == "buttonItem" else { return false }
                    currentActionIndex += 1
                    gameScene.removePointing()
                    gameScene.pointingLastGotItem()
                    nextLine()
                    return true
                case 1:
                    guard gameScene.gameState == .PlayerTurn, name == "timeBomb" else { return false }
                    currentActionIndex += 1
                    gameScene.removePointing()
                    nextLine()
                    return true
                case 2:
                    guard gameScene.gameState == .PlayerTurn, name == "activeArea" else { return false }
                    currentActionIndex += 1
                    nextLine()
                    return true
                case 3:
                    gameScene.playerTurnState = .TurnEnd
                    currentActionIndex += 1
                    CharacterController.retreatDoctor()
                    waitingUserTouch = false
                    keyTurn = gameScene.countTurn + 1
                    return false
                default:
                    return true
                }
            default:
                return true
            }
        } else {
            return true
        }
    }
    
    private static func initialAction() {
        switch lastAction {
        case .TimeBombGotFirstly:
            gameScene.pointingItmBtn()
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
