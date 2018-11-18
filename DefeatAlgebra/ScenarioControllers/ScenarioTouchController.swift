//
//  ScenarioTouchController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ScenarioTouchController {
    
    public static var gameScene: GameScene!
    
    public static func controllerForScenarioScene(name: String?) {
        switch GameScene.stageLevel {
        case 0:
            scenarioScene0(name: name)
            break;
        case 1:
            scenarioScene1()
            break;
        case MainMenu.timeBombStartTurn:
            scenarioSceneTimeBombStartTurn(name: name)
            break;
        case MainMenu.eqRobNewStartTurn:
            scenarioSceneEqRobNewStartTurn(name: name)
            break;
        case MainMenu.invisibleStartTurn:
            scenarioSceneInvisibleStartTurn()
            break;
        default:
            break;
        }
    }
    
    public static func controllerForGrid(location: CGPoint?, nodeAtPoint: SKNode?) {
        switch GameScene.stageLevel {
        case 0:
            grid0(location: location)
            break;
        case 1:
            grid1()
            break;
        case MainMenu.timeBombStartTurn:
            gridTimeBombStartTurn(location: location, nodeAtPoint: nodeAtPoint)
            break;
        case MainMenu.eqRobNewStartTurn:
            gridEqRobNewStartTurn(nodeAtPoint: nodeAtPoint)
            break;
        case MainMenu.cannonStartTurn:
            gridCannonStartTurn(nodeAtPoint: nodeAtPoint)
            break;
        case MainMenu.invisibleStartTurn:
            gridInvisibleStartTurn(nodeAtPoint: nodeAtPoint)
            break;
        default:
            break;
        }
    }
    
    private static func scenarioScene0(name: String?) {
        guard let name = name else { return }
        if ScenarioController.currentActionIndex == 23 {
            guard name == "buttonAttack" else { return }
            ScenarioController.currentActionIndex += 1
            GridActiveAreaController.showAttackArea(posX: ScenarioController.scenarioScene.hero.positionX, posY: ScenarioController.scenarioScene.hero.positionY, grid: ScenarioController.scenarioScene.gridNode)
            ScenarioController.controllActions()
        }
    }
    
    private static func scenarioScene1() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func scenarioSceneTimeBombStartTurn(name: String?) {
        if ScenarioController.currentActionIndex == 3 {
            if let name = name, name == "timeBomb" {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex == 11 {
            let _ = TutorialController.userTouch(on: "")
        } else if ScenarioController.currentActionIndex > 15 {
            guard TutorialController.userTouch(on: "") else { return }
        }
    }
    
    private static func scenarioSceneEqRobNewStartTurn(name: String?) {
        if ScenarioController.currentActionIndex == 8 {
            ScenarioController.controllActions()
        }
    }
    
    private static func scenarioSceneInvisibleStartTurn() {
        if ScenarioController.currentActionIndex == 6 || ScenarioController.currentActionIndex == 7 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex < 39 {
            let _ = CannonTutorialController.userTouch(on: "")
        } else if ScenarioController.currentActionIndex == 59 {
            let _ = TutorialController.userTouch(on: "")
        }
    }
    
    private static func grid0(location: CGPoint?) {
        guard let loca = location else { return }
        if ScenarioController.currentActionIndex == 21 {
            let gridX = Int(Double(loca.x) / gameScene.gridNode.cellWidth)
            let gridY = Int(Double(loca.y) / gameScene.gridNode.cellHeight)
            if gridX == 5 && gridY == 3 {
                ScenarioController.currentActionIndex += 1
                ScenarioFunction.heroMove(gridX: gridX, gridY: gridY) {
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex == 24 {
            let gridX = Int(Double(loca.x) / gameScene.gridNode.cellWidth)
            let gridY = Int(Double(loca.y) / gameScene.gridNode.cellHeight)
            if gridX == 6 && gridY == 3 {
                ScenarioController.currentActionIndex += 1
                ScenarioController.scenarioScene.removePointing()
                CharacterController.doctor.balloon.isHidden = true
                ScenarioController.scenarioScene.gridNode.enemyArray[0].isAttackable = true
                GridActiveAreaController.resetSquareArray(color: "red", grid: ScenarioController.scenarioScene.gridNode)
                ScenarioController.scenarioScene.hero.direction = .right
                ScenarioController.scenarioScene.hero.setSwordAnimation() {
                    ScenarioController.scenarioScene.hero.resetHero()
                    EnemyDeadController.hitEnemy(enemy: ScenarioController.scenarioScene.gridNode.enemyArray[0], gameScene: ScenarioController.scenarioScene) {
                        ScenarioController.controllActions()
                    }
                }
            }
        }
    }
    
    private static func grid1() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func gridTimeBombStartTurn(location: CGPoint?, nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 5 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 6 {
            guard let loca = location else { return }
            let gridX = Int(Double(loca.x) / gameScene.gridNode.cellWidth)
            let gridY = Int(Double(loca.y) / gameScene.gridNode.cellHeight)
            if gridX == 4 && gridY == 8 {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex > 9 {
            guard let node = nodeAtPoint else { return }
            guard TutorialController.userTouch(on: node.name) else { return }
        }
    }
    
    private static func gridEqRobNewStartTurn(nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 4 {
            if let enemy = nodeAtPoint as? Enemy {
                if enemy.positionX == 2 && enemy.positionY == 8 {
                    enemy.isSelectedForEqRob = true
                    EqRobController.execute(1, enemy: enemy)
                    ScenarioController.controllActions()
                }
            } else if let enemy = nodeAtPoint?.parent as? Enemy {
                if enemy.positionX == 2 && enemy.positionY == 8 {
                    enemy.isSelectedForEqRob = true
                    EqRobController.execute(1, enemy: enemy)
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex == 6 {
            if let enemy = nodeAtPoint as? Enemy {
                guard !enemy.isSelectedForEqRob else { return }
                enemy.isSelectedForEqRob = true
                EqRobTutorialController.setSelectedEnemyOnPanel(enemy: enemy)
            }
        } else if ScenarioController.currentActionIndex == 8 {
            ScenarioController.controllActions()
        }
    }
    
    private static func gridCannonStartTurn(nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 3 {
            if let cannon = nodeAtPoint as? Cannon {
                if cannon.spotPos == [1,11] {
                    CannonController.selectedCannon = cannon
                    CannonController.willFireCannon.append(cannon)
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex >= 4 && ScenarioController.currentActionIndex <= 6 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex > 12 {
            guard TutorialController.userTouch(on: "") else { return }
        }
    }
    
    private static func gridInvisibleStartTurn(nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 5 {
            if let cannon = nodeAtPoint as? Cannon {
                if cannon.spotPos == [6,9] {
                    CannonController.selectedCannon = cannon
                    CannonController.willFireCannon.append(cannon)
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex == 6 || ScenarioController.currentActionIndex == 7 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 59 {
            let _ = TutorialController.userTouch(on: "")
        }
    }
    
    public static func eqRobSimulatorTutorialTouch(value: String? = "") -> Bool {
        if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = EqRobJudgeController.gameScene as? ScenarioScene {
            if ScenarioController.currentActionIndex == 3 {
                return false
            } else if ScenarioController.currentActionIndex == 4 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 7 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 9 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 11 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 16 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 17 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 18 {
                guard value == "equivalent" else { return false }
                ScenarioController.controllActions()
                return true
            } else if ScenarioController.currentActionIndex == 19 {
                ScenarioController.controllActions()
                return false
            } else if ScenarioController.currentActionIndex == 20 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
}
