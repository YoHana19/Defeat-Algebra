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
    
    static func userTouch(on name: String?) -> Bool {
        switch GameScene.stageLevel {
        case 6:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 3:
                    ScenarioController.controllActions()
                    return false
                case 4:
                    ScenarioController.controllActions()
                    return false
                case 5:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 6:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 7:
                    if name == "button4" {
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
                default:
                    return true
                }
            } else {
                return true
            }
        case 7:
            if let name = name {
                switch ScenarioController.currentActionIndex {
                case 21:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 22:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 23:
                    if name == "button3" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 24:
                    if name == "buttonOK" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 34:
                    if name == "button2" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 35:
                    if name == "buttonX" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 36:
                    if name == "button+" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 37:
                    if name == "button3" {
                        ScenarioController.controllActions()
                        return true
                    } else {
                        return false
                    }
                case 38:
                    if name == "buttonOK" {
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
        CannonController.gameScene.inputPanelForCannon.isHidden = false
        CharacterController.doctor.setScale(CannonController.doctorScale[0])
        CharacterController.doctor.move(from: nil, to: CannonController.doctorOnPos[0])
    }
}
