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
                case 21:
                    if name == "changeVeButton" {
                        return true
                    } else {
                        return false
                    }
                case 22:
                    if name == "signal1" || name == "label1" || name == "signal2" || name == "label2" || name == "signal3" || name == "label3" || name == "changeVeButton" || name == "tryDoneButton" {
                        return false
                    } else if name == "buttonOK" {
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
        default:
            return true
        }
    }
    
    public static func showInputPanelWithDoctor() {
        CannonController.gameScene.inputPanelForCannon.isActive = true
        CharacterController.doctor.setScale(CannonController.doctorScale[0])
        CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
    }
}
