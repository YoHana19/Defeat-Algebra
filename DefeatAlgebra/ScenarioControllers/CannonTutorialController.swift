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
                case 9:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 10:
                    if name == "button4" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 11:
                    return false
                case 12:
                    if name == "buttonTry" {
                        return true
                    } else {
                        return false
                    }
                case 13, 14, 17, 18, 19, 20, 21, 22, 23, 24, 27, 30, 31:
                    ScenarioController.controllActions()
                    return false
                case 32:
                    if name == "changeVeButton" {
                        return true
                    } else {
                        return false
                    }
                case 33:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 34:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 35:
                    if name == "buttonOK" {
                        return true
                    } else {
                        return false
                    }
                case 36, 38, 39, 40, 41, 42, 43:
                    ScenarioController.controllActions()
                    return false
                case 44:
                    if name == "changeVeButton" {
                        return true
                    } else {
                        return false
                    }
                case 45:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 46:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 47:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 48:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 49:
                    if name == "buttonOK" {
                        return true
                    } else {
                        return false
                    }
                case 51, 52:
                    ScenarioController.controllActions()
                    return false
                case 53:
                    if name == "tryDoneButton" {
                        ScenarioController.controllActions()
                    }
                    return false
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
                charaSpeakInTrying()
            }
        }
    }
    
    public static func charaSpeakInTrying() {
        switch ScenarioController.currentActionIndex {
        case 15, 16, 25, 26, 28, 29, 54:
            ScenarioController.controllActions()
            break;
        default:
            break;
        }
    }
}
