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
            scenarioScene0()
            break;
        case 1:
            scenarioScene1()
            break;
        case MainMenu.timeBombStartTurn:
            scenarioSceneTimeBombStartTurn(name: name)
            break;
        case MainMenu.eqRobStartTurn:
            scenarioSceneEqRobStartTurn(name: name)
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
            grid0()
            break;
        case 1:
            grid1()
            break;
        case MainMenu.timeBombStartTurn:
            gridTimeBombStartTurn(location: location, nodeAtPoint: nodeAtPoint)
            break;
        case MainMenu.eqRobStartTurn:
            gridEqRobStartTurn(nodeAtPoint: nodeAtPoint)
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
    
    private static func scenarioScene0() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func scenarioScene1() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func scenarioSceneTimeBombStartTurn(name: String?) {
        if ScenarioController.currentActionIndex == 8 {
            if let name = name, name == "buttonItem" {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex == 9 {
            if let name = name, name == "timeBomb" {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex == 11 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex > 15 {
            guard TutorialController.userTouch(on: "") else { return }
        }
    }
    
    private static func scenarioSceneEqRobStartTurn(name: String?) {
        if ScenarioController.currentActionIndex == 13 {
            if let name = name, name == "eqRob" {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex == 22 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 24 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 26 {
            if let name = name, name == "eqRob" {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex == 29 {
            ScenarioController.controllActions()
        }
    }
    
    private static func scenarioSceneInvisibleStartTurn() {
        if ScenarioController.currentActionIndex == 6 || ScenarioController.currentActionIndex == 7 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex >= 12 && ScenarioController.currentActionIndex <= 14 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 17 {
            ScenarioController.controllActions()
        }
    }
    
    private static func grid0() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func grid1() {
        guard TutorialController.userTouch(on: "") else { return }
    }
    
    private static func gridTimeBombStartTurn(location: CGPoint?, nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 11 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 12 {
            guard let loca = location else { return }
            let gridX = Int(Double(loca.x) / gameScene.gridNode.cellWidth)
            let gridY = Int(Double(loca.y) / gameScene.gridNode.cellHeight)
            if gridX == 4 && gridY == 5 {
                ScenarioController.controllActions()
            }
        } else if ScenarioController.currentActionIndex > 15 {
            guard let node = nodeAtPoint else { return }
            guard TutorialController.userTouch(on: node.name) else { return }
        }
    }
    
    private static func gridEqRobStartTurn(nodeAtPoint: SKNode?) {
        if ScenarioController.currentActionIndex == 20 {
            if let enemy = nodeAtPoint as? Enemy {
                if enemy.positionX == 3 && enemy.positionY == 8 {
                    enemy.isSelectedForEqRob = true
                    EqRobTutorialController.setSelectedEnemyOnPanel(enemy: enemy)
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex == 22 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 23 {
            if let enemy = nodeAtPoint as? Enemy {
                if enemy.positionX == 5 && enemy.positionY == 8 {
                    enemy.isSelectedForEqRob = true
                    EqRobTutorialController.setSelectedEnemyOnPanel(enemy: enemy)
                    ScenarioController.controllActions()
                }
            }
        } else if ScenarioController.currentActionIndex == 24 {
            ScenarioController.controllActions()
        } else if ScenarioController.currentActionIndex == 26 {
            if let enemy = nodeAtPoint as? Enemy {
                guard !enemy.isSelectedForEqRob else { return }
                enemy.isSelectedForEqRob = true
                EqRobTutorialController.setSelectedEnemyOnPanel(enemy: enemy)
            }
        } else if ScenarioController.currentActionIndex == 29 {
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
        }
    }
}
