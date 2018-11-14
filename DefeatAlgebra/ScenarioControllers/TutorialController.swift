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
    public static var currentIndex = 0
    private static var currentLabel = SKLabelNode()
    public static var state: TutorialLabelState = .Pending
    private static var keyCount = 0
    
    public static func execute() {
        guard state == .Show else { return }
        switch GameScene.stageLevel {
        case 0:
            switch currentIndex {
            case 0:
                createTutorialLabel(text: "青い部分をタッチすると移動できるぞ", posY: Int(scene.size.height/2+100))
                ScenarioController.keyTouchPos = (2, 3)
                scene.pointingGridAt(x: ScenarioController.keyTouchPos.0, y: ScenarioController.keyTouchPos.1)
                state = .Waiting
                break;
            case 1:
                createTutorialLabel(text: "攻撃は、下のアタックボタンをタッチしよう", posY: Int(scene.size.height/2+100))
                scene.pointingAtkBtn()
                state = .Waiting
                break;
            case 2:
                createTutorialLabel(text: "赤い部分をタッチすると攻撃するぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 3:
                createTutorialLabel(text: "移動したら自分のターンは終わりだ", posY: Int(scene.size.height/2+100))
                ScenarioController.keyTouchPos = (4, 4)
                scene.pointingGridAt(x: ScenarioController.keyTouchPos.0, y: ScenarioController.keyTouchPos.1)
                state = .Waiting
                break;
            default:
                break;
            }
            break;
        case MainMenu.uncoverSignalStartTurn: //1
            switch currentIndex {
            case 0:
                createMultiTutorialLabel(text: "敵がどこにくるか予測して\n待ち伏せよう！", posY: Int(scene.size.height/2+460))
                currentIndex += 1
                state = .Pending
                break;
            case 1:
                removeTutorialLabel()
                createTutorialLabel(text: "今だ！攻撃しよう！", posY: Int(scene.size.height/2+400))
                scene.pointingAtkBtn()
                state = .Waiting
                break;
            case 2:
                ScenarioController.keyTouchPos = (ScenarioController.scenarioScene.gridNode.enemyArray[0].positionX, ScenarioController.scenarioScene.gridNode.enemyArray[0].positionY)
                scene.pointingGridAt(x: ScenarioController.keyTouchPos.0, y: ScenarioController.keyTouchPos.1)
                state = .Waiting
                break;
            case 3:
                removeTutorialLabel()
                createTutorialLabel(text: "ここからじゃ攻撃が届かない！", posY: Int(scene.size.height/2+400))
                GridActiveAreaController.showAttackArea(posX: ScenarioController.scenarioScene.hero.positionX, posY: ScenarioController.scenarioScene.hero.positionY, grid: ScenarioController.scenarioScene.gridNode)
                state = .Waiting
                break;
            case 4:
                removeTutorialLabel()
                createTutorialLabel(text: "敵にぶつかると死んでしまうぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 8:
                removeTutorialLabel()
                createMultiTutorialLabel(text: "敵の攻撃が町まで届くと\nライフが減っていくぞ", posY: Int(scene.size.height/2+100))
                if let scenarioScene = scene as? ScenarioScene {
                    GridActiveAreaController.resetSquareArray(color: "red", grid: scenarioScene.gridNode)
                    scenarioScene.pointingHeart()
                    scenarioScene.isCharactersTurn = true
                    scenarioScene.gridNode.isTutorial = true
                    scenarioScene.tutorialState = .Action
                }
                state = .Waiting
                break;
            case 9:
                createTutorialLabel(text: "ライフが0になったらゲームオーバーだ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 11:
                removeTutorialLabel()
                currentIndex += 1
                state = .Waiting
                break;
            default:
                break;
            }
            break;
        case MainMenu.timeBombStartTurn: //3
            switch currentIndex {
            case 0:
                createTutorialLabel(text: "敵の動きを予測して爆弾を仕掛けよう！", posY: Int(scene.size.height/2-250))
                state = .Waiting
                break;
            case 1:
                removeTutorialLabel()
                createTutorialLabel(text: "取り逃がしてしまった！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 2:
                guard let scenarioScene = scene as? ScenarioScene else { return }
                createMultiTutorialLabel(text: "信号はx=\(scenarioScene.xValue)だったから\nロボットはここまでパンチしてきたぞ", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            default:
                break;
            }
        case MainMenu.showUnsimplifiedStartTurn: //5
            switch currentIndex {
            case 0:
                createMultiTutorialLabel(text: "敵をタッチすれば\n文字式の表示の大きさを変えられるぞ", posY: Int(scene.size.height/2+100))
                scene.gridNode.enemyArray.forEach({ $0.pointing() })
                state = .Waiting
                break;
            default:
                break;
            }
        case MainMenu.eqRobNewStartTurn:
            switch currentIndex {
            case 0:
                createMultiTutorialLabel(text: "x+2と同じ文字式を持つ敵を全て選択し\n最後にエクロボをタッチして攻撃せよ！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            default:
                break;
            }
        case MainMenu.cannonStartTurn:
            switch currentIndex {
            case 0:
                createTutorialLabel(text: "アルジェ砲を使って敵を倒せ！", posY: Int(scene.size.height/2+440))
                state = .Pending
                break;
            case 2:
                removeTutorialLabel()
                createTutorialLabel(text: "外してしまった！！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 3:
                createTutorialLabel(text: "敵の移動距離を予測して飛距離を入力しよう！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 4:
                removeTutorialLabel()
                currentIndex += 1
                state = .Waiting
            default:
                break;
            }
        case MainMenu.invisibleStartTurn:
            switch currentIndex {
            case 0:
                createMultiTutorialLabel(text: "改良されたアルジェ砲を使って\n敵ロボットを倒せ！", posY: Int(scene.size.height/2+100))
                currentIndex += 1
                state = .Pending
                break;
            case 2:
                removeTutorialLabel()
                createTutorialLabel(text: "外してしまった！！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            case 3:
                createMultiTutorialLabel(text: "試し撃ち機能を使いながら\n確実に倒せる飛距離を見つけよう！", posY: Int(scene.size.height/2+100))
                state = .Waiting
                break;
            default:
                break;
            }
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
                guard scene.gridNode.touchedGridPos == ScenarioController.keyTouchPos else { return false }
                scene.removePointing()
                removeTutorialLabel()
                currentIndex += 1
                state = .WillShow
                ScenarioFunction.heroMove(gridX: ScenarioController.keyTouchPos.0, gridY: ScenarioController.keyTouchPos.1) {
                    ScenarioController.controllActions()
                }
                return false
            case 1:
                guard name == "buttonAttack" else { return false }
                scene.playerTurnState = .UsingItem
                removeTutorialLabel()
                scene.removePointing()
                currentIndex += 1
                state = .Show
                return true
            case 2:
                guard scene.playerTurnState == .AttackState && name == "activeArea" else { return false }
                removeTutorialLabel()
                let wait = SKAction.wait(forDuration: 1.5)
                scene.run(wait, completion: {
                    currentIndex += 1
                    state = .Show
                })
                return true
            case 3:
                guard scene.playerTurnState == .MoveState && name == "activeArea" else { return false }
                guard scene.gridNode.touchedGridPos == ScenarioController.keyTouchPos else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Pending
                ScenarioFunction.heroMove(gridX: ScenarioController.keyTouchPos.0, gridY: ScenarioController.keyTouchPos.1) {
                    ScenarioController.controllActions()
                }
                return false
            default:
                return true
            }
        case MainMenu.uncoverSignalStartTurn: //1
            switch currentIndex {
            case 1:
                guard name == "buttonAttack" else { return false }
                scene.removePointing()
                currentIndex += 1
                state = .Show
                execute()
                return true
            case 2: // beat
                guard scene.playerTurnState == .AttackState && name == "activeArea" else { return false }
                guard scene.gridNode.touchedGridPos == ScenarioController.keyTouchPos else { return false }
                removeTutorialLabel()
                scene.removePointing()
                state = .Pending
                currentIndex += 1
                return true
            case 3: // miss
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                GridActiveAreaController.resetSquareArray(color: "red", grid: ScenarioController.scenarioScene.gridNode)
                currentIndex = 0
                state = .Pending
                ScenarioController.controllActions()
                return true
            case 4: // bumpped
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                currentIndex = 0
                state = .Pending
                ScenarioController.controllActions()
                return true
            case 5: // hero dead
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Show
                execute()
                return true
            case 6:
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                currentIndex = 0
                state = .Pending
                ScenarioController.controllActions()
                return true
            case 8: // castle attacked
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                if let scenarioScene = scene as? ScenarioScene {
                    scenarioScene.removePointing()
                }
                currentIndex += 1
                state = .Show
                execute()
                return true
            case 9:
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return false }
                removeTutorialLabel()
                currentIndex = 0
                state = .Pending
                if let scenarioScene = scene as? ScenarioScene {
                    scenarioScene.isCharactersTurn = false
                    scenarioScene.gridNode.isTutorial = false
                }
                return false
            default:
                return true
            }
        case MainMenu.timeBombStartTurn: //4
            switch currentIndex {
            case 0:
                guard scene.isCharactersTurn else { return false }
                currentIndex += 1
                state = .Pending
                ScenarioController.controllActions()
                return true
            case 1:
                guard scene.isCharactersTurn else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Show
                ScenarioController.controllActions()
                execute()
                return true
            case 2:
                guard scene.isCharactersTurn else { return false }                
                removeTutorialLabel()
                state = .Show
                ScenarioController.controllActions()
                currentIndex = 0
                execute()
                return true
            default:
                return true
            }
        case MainMenu.showUnsimplifiedStartTurn:
            switch currentIndex {
            case 0:
                guard scene.playerTurnState == .MoveState && name == "enemy" else { return false }
                keyCount += 1
                currentIndex += 1
                return true
            case 1:
                guard scene.playerTurnState == .MoveState && name == "enemy" else { return false }
                keyCount += 1
                if (keyCount > 4) {
                    removeTutorialLabel()
                    currentIndex += 1
                    scene.gridNode.enemyArray.forEach({ $0.removePointing() })
                }
                return true
            default:
                return true
            }
        case MainMenu.eqRobNewStartTurn:
            switch currentIndex {
            case 1:
                removeTutorialLabel()
                currentIndex += 1
                state = .Pending 
                return true
            default:
                return true
            }
        case MainMenu.cannonStartTurn:
            switch currentIndex {
            case 2:
                guard scene.isCharactersTurn else { return false }
                removeTutorialLabel()
                currentIndex += 1
                state = .Show
                execute()
                return true
            case 3:
                guard scene.isCharactersTurn else { return false }
                removeTutorialLabel()
                currentIndex = 0
                state = .Pending
                ScenarioController.controllActions()
                return true
            default:
                return true
            }
        case MainMenu.invisibleStartTurn:
            switch currentIndex {
            case 2:
                guard scene.isCharactersTurn else { return false } 
                removeTutorialLabel()
                currentIndex += 1
                state = .Show
                execute()
                return true
            case 3:
                guard scene.isCharactersTurn else { return false }
                removeTutorialLabel()
                currentIndex = 0
                state = .Pending
                ScenarioController.controllActions()
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
                state = .Show
                break;
            case 1:
                state = .Show
                break;
            default:
                break;
            }
            break;
        case MainMenu.uncoverSignalStartTurn:
            switch currentIndex {
            case 0:
                state = .Show
                break;
            case 1:
                guard scene.isCharactersTurn, scene.tutorialState == .None else { return }
                state = .Show
                break;
            case 3:
                guard scene.isCharactersTurn, scene.tutorialState == .Action else { return }
                state = .Show
                break;
            case 4:
                guard scene.isCharactersTurn, scene.tutorialState == .None else { return }
                state = .Show
                break;
            case 8:
                guard scene.gameState == .EnemyTurn else { return }
                state = .Show
                break;
            case 11:
                guard scene.gameState == .StageClear else { return }
                state = .Show
                break;
            default:
                break;
            }
            break;
        case MainMenu.timeBombStartTurn:
            switch currentIndex {
            case 0:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            case 1:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            case 3:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            default:
                break;
            }
        case MainMenu.showUnsimplifiedStartTurn:
            switch currentIndex {
            case 0:
                guard !scene.isCharactersTurn else { return }
                state = .Show
                break;
            default:
                break;
            }
        case MainMenu.eqRobNewStartTurn:
            switch currentIndex {
            case 0:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            default:
                break;
            }
        case MainMenu.cannonStartTurn:
            switch currentIndex {
            case 0:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            case 2:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            case 4:
                guard !scene.isCharactersTurn else { return }
                state = .Show
                break;
            default:
                break;
            }
        case MainMenu.invisibleStartTurn:
            switch currentIndex {
            case 0:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            case 2:
                guard scene.isCharactersTurn else { return }
                state = .Show
                break;
            default:
                break;
            }
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
        let label = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
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
    
    public static func createMultiTutorialLabel(text: String, posY: Int) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        /* Set text */
        label.text = text
        /* Set font size */
        label.fontSize = 35
        
        let multi = label.multilined()
        /* Set name */
        multi.name = "tutorialLabel"
        /* Set zPosition */
        multi.zPosition = 50
        /* Set position */
        multi.position = CGPoint(x: scene.size.width/2, y: CGFloat(posY))
        currentLabel = multi
        /* Add to Scene */
        scene.addChild(multi)
    }
    
    public static func removeTutorialLabel() {
        currentLabel.removeFromParent()
    }
    
    public static func visibleTutorialLabel(_ isVisible: Bool) {
        currentLabel.isHidden = !isVisible
    }
}
