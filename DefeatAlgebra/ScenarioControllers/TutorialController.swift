//
//  TutorialController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/19.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum TutorialLabelState {
    case WillShow, Show, Waiting, Pending
}

struct TutorialController {
    public static var scene: GameScene!
    private static var currentIndex = 0
    private static var currentLabel = SKLabelNode()
    private static var state: TutorialLabelState = .Pending
    
    public static func execute() {
        guard state == .Show else { return }
        switch GameScene.stageLevel {
        case 0:
            switch currentIndex {
            case 0:
                createTutorialLabel(text: "青い部分をタッチすると移動できるぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 1:
                createTutorialLabel(text: "攻撃は、下のアタックボタンをタッチしよう", posY: Int(scene.size.height/2+100))
                if let scenarioScene = scene as? ScenarioScene {
                    scenarioScene.pointingAtkBtn()
                }
                state = .Waiting
                break;
            case 2:
                createTutorialLabel(text: "赤い部分をタッチすると攻撃するぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 3:
                createTutorialLabel(text: "移動したら自分のターンは終わりだ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            default:
                break;
            }
            break;
        case 2:
            switch currentIndex {
            case 0:
                createTutorialLabel(text: "指でなぞれば、移動のルートを指定できるぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 1:
                createTutorialLabel(text: "ルートを指定して効果的に移動しよう", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }
    
    public static func userTouch(on name: String?) -> Bool {
        guard let name = name, state == .Waiting else { return true }
        switch GameScene.stageLevel {
        case 0:
            switch currentIndex {
            case 0:
                guard scene.playerTurnState == .MoveState && name == "activeArea" else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .WillShow
                return true
            case 1:
                guard name == "buttonAttack" else { return false }
                removeTutorialLabel()
                if let scenarioScene = scene as? ScenarioScene {
                    scenarioScene.removePointing()
                }
                currentIndex += 1
                state = .Show
                return true
            case 2:
                guard scene.playerTurnState == .AttackState && name == "activeArea" else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Pending
                return true
            case 3:
                guard scene.playerTurnState == .MoveState && name == "activeArea" else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Pending
                return true
            default:
                return true
            }
        case 2:
            switch currentIndex {
            case 0:
                guard scene.playerTurnState == .MoveState && name == "activeArea" else { return false }
                scene.removePointing()
                //GridActiveAreaController.resetSquareArray(color: "blue", grid: scene.gridNode)
                removeTutorialLabel()
                currentIndex += 1
                state = .Show
                execute()
                scene.tutorialState = .Converstaion
                scene.isCharactersTurn = true
                scene.gridNode.isTutorial = true
                return true
            default:
                return true
            }
        default:
            return true
        }
    }
    
    public static func enable() {
        guard state == .Pending else { return }
        switch GameScene.stageLevel {
        case 0:
            switch currentIndex {
            case 0:
                guard scene.playerTurnState == .MoveState else { return }
                state = .Show
                break;
            case 3:
                guard scene.playerTurnState == .MoveState else { return }
                state = .Show
                break;
            default:
                break;
            }
            break;
        case 2:
            switch currentIndex {
            case 0:
                guard scene.playerTurnState == .MoveState else { return }
                state = .Show
                break;
            default:
                break;
            }
            break;
        default:
            break;
        }
    }
    
    public static func active() {
        guard state == .WillShow else { return }
        state = .Show
    }
    
    public static func initialize() {
        currentIndex = 0
        state = .Pending
    }
    
    private static func createTutorialLabel(text: String, posY: Int) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        /* Set text */
        label.text = text
        /* Set name */
        label.name = "tutorialLabel"
        /* Set font size */
        label.fontSize = 35
        /* Set zPosition */
        label.zPosition = 50
        /* Set position */
        label.position = CGPoint(x: scene.size.width/2, y: CGFloat(posY))
        currentLabel = label
        /* Add to Scene */
        scene.addChild(label)
    }
    
    private static func removeTutorialLabel() {
        currentLabel.removeFromParent()
    }
}
