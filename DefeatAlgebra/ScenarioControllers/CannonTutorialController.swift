//
//  CannonTutorialController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/26.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct CannonTutorialController {
    
    public static var keyPos = CGPoint(x: 0, y: 0)
    public static var isTouchEnable = true
    
    static func userTouch(on name: String?) -> Bool {
        switch GameScene.stageLevel {
        case MainMenu.cannonStartTurn:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 4:
                    return false
                case 7:
                    if name == "button6" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 8:
                    if name == "buttonOK" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 12:
                    if name == "buttonOK" {
                        CharacterController.retreatDoctor()
                        ScenarioController.currentActionIndex += 1
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return true
                    }
                default:
                    return true
                }
            } else {
                return true
            }
        case MainMenu.invisibleStartTurn:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 6:
                    ScenarioController.controllActions()
                    return false
                case 8:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 10:
                    if name == "buttonTry" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 11:
                    if name == "signal1" || name == "label1" {
                        return true
                    } else {
                        return false
                    }
                case 12:
                    ScenarioController.controllActions()
                    return false
                case 13:
                    ScenarioController.controllActions()
                    return false
                case 14:
                    ScenarioController.controllActions()
                    return false
                case 16:
                    if name == "signal2" || name == "label2" {
                        return true
                    } else {
                        return false
                    }
                case 17:
                    ScenarioController.controllActions()
                    return false
                case 19:
                    if name == "signal3" || name == "label3" {
                        return true
                    } else {
                        return false
                    }
                case 23:
                    if name == "changeVeButton" {
                        return true
                    } else {
                        return false
                    }
                case 24:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 25:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 26:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 27:
                    if name == "buttonOK" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 28:
                    if name == "signal1" || name == "label1" || name == "signal2" || name == "label2" || name == "signal3" || name == "label3" {
                        guard isTouchEnable else { return false }
                        CannonTryController.resetEnemy()
                        return true
                    } else {
                        return false
                    }
                case 29:
                    if name == "signal1" || name == "label1" || name == "signal2" || name == "label2" || name == "signal3" || name == "label3" {
                        guard isTouchEnable else { return false }
                        CannonTryController.resetEnemy()
                        return true
                    } else {
                        return false
                    }
                case 30:
                    if name == "signal1" || name == "label1" || name == "signal2" || name == "label2" || name == "signal3" || name == "label3" {
                        guard isTouchEnable else { return false }
                        CannonTryController.resetEnemy()
                        return true
                    } else {
                        return false
                    }
                case 32:
                    if name == "tryDoneButton" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                default:
                    return true
                }
            } else {
                return true
            }
        default:
            return true
        }
    }
    
    public static func showInputPanelWithDoctor() {
        CannonController.gameScene.inputPanelForCannon.isActive = true
        CharacterController.doctor.setScale(CannonController.doctorScale[0])
        CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
    }
    
    public static func hideEqGrid() {
        GameStageController.soundForScenario()
        CannonController.gameScene.hero.setPhysics(isActive: true)
        CannonController.selectedCannon.zPosition = 6
        CannonController.gameScene.eqGrid.isHidden = true
        CannonController.gameScene.eqGrid.zPosition = -1
        CannonController.gameScene.eqRob.zPosition = 11
        CannonController.gameScene.inputPanelForCannon.zPosition = 10
        SignalController.speed = 0.006
        CharacterController.doctor.changeBalloonTexture(index: 0)
        CannonController.gameScene.signalHolder.zPosition = 0
        CannonController.gameScene.valueOfX.zPosition = 1
        CannonTryController.numOfCheck = 0
        CannonTryController.numOfChangeVE = 0
        CannonController.gameScene.valueOfX.text = ""
        CannonTryController.backEnemy()
        CannonTryController.getBG(completion: { bg in
            bg?.removeFromParent()
        })
        
        CannonController.hideInputPanel()
        CannonTouchController.state = .Ready
        CharacterController.doctor.setScale(1)
        let cands = CannonController.gameScene.gridNode.enemyArray.filter({ $0.state == .Attack && $0.positionX == CannonController.selectedCannon.spotPos[0] })
        for enemy in cands {
            SignalController.sendToCannon(target: CannonController.selectedCannon, num: CannonController.gameScene.xValue, from: enemy.absolutePos()) {
            }
        }
    }
}
