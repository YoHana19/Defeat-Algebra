//
//  GameStageController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/30.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct GameStageController {
    static var gameScene: GameScene!
    
    public static func stageManager(scene: SKScene?, next: Int) {
        ResetController.reset()
        GameScene.stageLevel += next
        if let gamescene = scene as? GameScene {
            DAUserDefaultUtility.SetData(gameScene: gamescene)
        }
        print(GameScene.stageLevel)
        switch GameScene.stageLevel {
        case 0:
            loadScenarioScene(scene: scene)
            break;
        case MainMenu.uncoverSignalStartTurn: //1
            loadScenarioScene(scene: scene)
            break;
        case MainMenu.changeMoveSpanStartTurn: //2
            loadScenarioScene(scene: scene)
            break;
        case MainMenu.timeBombStartTurn: //3
            loadScenarioScene(scene: scene)
            break;
        case 4:
            loadGameScene(scene: scene)
            break;
        case MainMenu.moveExplainStartTurn: //5
            loadScenarioScene(scene: scene)
            break;
        case MainMenu.showUnsimplifiedStartTurn: //6
            loadScenarioScene(scene: scene)
            break;
        case MainMenu.eqRobStartTurn: //7
            loadScenarioScene(scene: scene)
            break;
        case 8:
            loadGameScene(scene: scene)
            break;
        case MainMenu.cannonStartTurn:
            loadScenarioScene(scene: scene)
            break;
        case 10:
            loadGameScene(scene: scene)
            break;
        case 11:
            loadGameScene(scene: scene)
            break;
        case MainMenu.invisivleStartTurn: //14
            loadScenarioScene(scene: scene)
            break;
        case 13:
            loadGameScene(scene: scene)
            break;
        case MainMenu.lastTurn: //16
            loadScenarioScene(scene: scene)
            break;
        default:
            break;
        }
    }
    
    private static func loadGameScene(scene: SKScene?) {
        /* Grab reference to the SpriteKit view */
        let skView = scene?.view as SKView?
        /* Load Game scene */
        guard let nextScene = GameScene(fileNamed:"GameScene") as GameScene? else { return }
        /* Ensure correct aspect mode */
        nextScene.scaleMode = .aspectFit
        /* Restart GameScene */
        skView?.presentScene(nextScene)
    }
    
    private static func loadScenarioScene(scene: SKScene?) {
        /* Grab reference to the SpriteKit view */
        let skView = scene?.view as SKView?
        /* Load Game scene */
        guard let nextScene = ScenarioScene(fileNamed:"ScenarioScene") as ScenarioScene? else { return }
        /* Ensure correct aspect mode */
        nextScene.scaleMode = .aspectFit
        /* Restart GameScene */
        skView?.presentScene(nextScene)
    }
    
    public static func initialize() {
        moveLevel()
        timeBomb()
        stageLabel()
        eqRob()
        cannon()
    }
    
    private static func moveLevel() {
        if GameScene.stageLevel < 2 {
            gameScene.moveLevel = 3
        } else {
            gameScene.moveLevel = 4
        }
    }
    
    private static func timeBomb() {
        if GameScene.stageLevel == MainMenu.timeBombStartTurn {
            gameScene.handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        } else if GameScene.stageLevel == MainMenu.timeBombStartTurn+1 {
            gameScene.handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        } else if GameScene.stageLevel == MainMenu.timeBombStartTurn+2 {
            gameScene.handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        } else if GameScene.stageLevel == MainMenu.timeBombStartTurn+3 {
            gameScene.handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb", "timeBomb"]
        } else if GameScene.stageLevel == MainMenu.secondDayStartTurn {
            gameScene.handedItemNameArray = ["timeBomb", "timeBomb", "timeBomb"]
        } else {
            gameScene.handedItemNameArray = [String]()
        }
    }
    
    private static func stageLabel() {
        if GameScene.stageLevel == MainMenu.lastTurn {
            gameScene.levelLabel.text = "ラスト"
            gameScene.levelLabel.fontSize = 20
        }
    }
    
    private static func eqRob() {
        if GameScene.stageLevel < MainMenu.eqRobStartTurn {
            gameScene.eqRob.isHidden = true
        } else if GameScene.stageLevel >= MainMenu.cannonStartTurn && GameScene.stageLevel < MainMenu.invisivleStartTurn+2 {
            gameScene.eqRob.isHidden = true
        } else {
            gameScene.eqRob.isHidden = false
            EqRobTouchController.state = .Ready
        }
    }
    
    private static func cannon() {
        if GameScene.stageLevel >= MainMenu.cannonStartTurn {
            setCannon(positions: [[0,9],[1,11],[2,9],[3,11],[4,9],[5,11],[6,9],[7,11],[8,9]])
        }
    }
    
    private static func setCannon(positions: [[Int]]) {
        for pos in positions {
            CannonController.add(type: 0, pos: pos)
        }
    }
    
    public static func initializeForScenario() {
        moveLevel()
        madPos()
        eqRobForScenario()
        cannon()
        enemyNum()
        xLabel()
        skipButton()
    }
    
    private static func madPos() {
        if GameScene.stageLevel > 0 {
            gameScene.madScientistNode.position = CGPoint(x: 374.999, y: 1282.404)
            SignalController.madPos = gameScene.madScientistNode.absolutePos()
        }
    }
    
    private static func eqRobForScenario() {
        if GameScene.stageLevel < MainMenu.eqRobStartTurn {
            gameScene.eqRob.isHidden = true
        } else if GameScene.stageLevel >= MainMenu.cannonStartTurn && GameScene.stageLevel < MainMenu.invisivleStartTurn+2 {
            gameScene.eqRob.isHidden = true
        } else {
            if GameScene.stageLevel == MainMenu.eqRobStartTurn {
                gameScene.eqRob.position = CGPoint(x: gameScene.eqRob.position.x-200, y: gameScene.eqRob.position.y)
                gameScene.selectionPanel.againButton.isHidden = true
            }
            gameScene.eqRob.isHidden = false
            EqRobTouchController.state = .Ready
        }
    }
    
    private static func enemyNum() {
        if GameScene.stageLevel == 0 {
            gameScene.totalNumOfEnemy = 1
        } else if GameScene.stageLevel == 1 {
            gameScene.totalNumOfEnemy = 2
        } else if GameScene.stageLevel == MainMenu.timeBombStartTurn {
            gameScene.totalNumOfEnemy = 3
        } else if GameScene.stageLevel == 6 {
            gameScene.totalNumOfEnemy = 4
        } else if GameScene.stageLevel == MainMenu.cannonStartTurn {
            gameScene.totalNumOfEnemy = 2
        } else {
            gameScene.totalNumOfEnemy = 1
        }
    }
    
    private static func xLabel() {
        if GameScene.stageLevel <= 1 {
            gameScene.signalHolder.isHidden = true
            gameScene.valueOfX.isHidden = true
        }
    }
    
    private static func skipButton() {
        guard let scenarioScene = gameScene as? ScenarioScene else { return }
        if GameScene.stageLevel == 0 {
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.initialScenario
        } else if GameScene.stageLevel == MainMenu.uncoverSignalStartTurn { //1
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.uncoverSignal
        } else if GameScene.stageLevel == MainMenu.changeMoveSpanStartTurn { //2
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.changeMoveSpan
        } else if GameScene.stageLevel == MainMenu.timeBombStartTurn { //3
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.timeBombExplain
        } else if GameScene.stageLevel == MainMenu.showUnsimplifiedStartTurn { //6
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.showUnsimplified
        } else if GameScene.stageLevel == MainMenu.eqRobStartTurn { //7
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.eqRobExplain
        } else if GameScene.stageLevel == MainMenu.cannonStartTurn { //11
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.cannonExplain
        } else if GameScene.stageLevel == MainMenu.invisivleStartTurn { //14
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.invisibleSignal
        } else if GameScene.stageLevel == MainMenu.lastTurn { //16
            scenarioScene.skipButton.isHidden = !DAUserDefaultUtility.lastScenario
        }
    }
    
    public static func enemyProperty(enemy: Enemy) {
        if GameScene.stageLevel < 2 {
            enemy.moveSpeed = 0.2
            enemy.punchSpeed = 0.0025
            enemy.singleTurnDuration = 1.0
            enemy.variableExpressionLabel.isHidden = true
        }
    }
    
    public static func signalVale() -> Int {
        if GameScene.stageLevel == 0 {
            return 3
        } else if GameScene.stageLevel < 4 {
            return 2
        } else {
            return 3
        }
    }
    
    public static func signalVisibility(signal: SignalValueHolder) {
        if GameScene.stageLevel < 1, ScenarioController.currentActionIndex < MainMenu.invisivleStartTurn+1, let _ = gameScene as? ScenarioScene {
            signal.xValue.isHidden = true
        } else if GameScene.stageLevel >= MainMenu.invisivleStartTurn {
            if CannonTouchController.state != .Trying && EqRobTouchController.state != .DeadInstruction && EqRobTouchController.state != .AliveInstruction  {
                signal.xValue.isHidden = true
            }
        }
    }
    
    public static func signalVisibilityForCannon(signal: SignalValueHolder) {
        if GameScene.stageLevel >= MainMenu.invisivleStartTurn {
            if CannonTouchController.state != .Trying {
                signal.xValue.isHidden = true
            }
        }
    }
    
    public static func adjustGameSceneLevel() -> Int {
        if GameScene.stageLevel < MainMenu.cannonStartTurn {
            return GameScene.stageLevel - 2
        } else {
            return GameScene.stageLevel - 3
        }
    }
}
