//
//  CannonController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/22.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct CannonController {
    public static var gameScene: GameScene!
    public static var selectedCannon = Cannon(type: 0)
    public static var willFireCannon = [Cannon]()
    private static var doctorOffPos = CGPoint(x: -200, y: 170)
    private static var doctorOnPos: [CGPoint] = [
        CGPoint(x: 150, y: 170),
        CGPoint(x: 90, y: 100),
        CGPoint(x: 150, y: -370)
    ]
    private static var doctorScale: [CGFloat] = [
        0.85,
        0.6,
        0.75
    ]
    
    public static func execute(_ index: Int, cannon: Cannon?) {
        switch index {
        case 0:
            showInputPanelWithDoctor()
            selectedCannon = cannon!
            willFireCannon.append(cannon!)
            break;
        case 1:
            doneInput()
            break;
        default:
            break;
        }
    }
    
    public static func back(_ index: Int) {
        switch index {
        case 0:
            hideInputPanelWithDoctor()
            willFireCannon.removeLast()
            break;
        default:
            break;
        }
    }
    
    private static func showInputPanelWithDoctor() {
        resetAll()
        showInputPanel()
        CannonTouchController.state = .Pending
        CharacterController.doctor.setScale(doctorScale[0])
        CharacterController.doctor.balloon.isHidden = false
        doctorSays(in: .WillInput, value: nil)
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos[0])
    }
    
    private static func hideInputPanelWithDoctor() {
        hideInputPanel()
        CannonTouchController.state = .Ready
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
    }
    
    private static func doneInput() {
        hideInputPanel()
        CannonTouchController.state = .WillFire
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
        ItemTouchController.othersTouched()
    }
    
    public static func fire(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        for cannon in willFireCannon {
            dispatchGroup.enter()
            cannon.throwBomb(value: gameScene.xValue) {
                cannon.resetInputVE()
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            willFireCannon.removeAll()
            CannonTouchController.state = .Ready
            return completion()
        })
    }
    
    private static func resetAll() {
        CannonTouchController.state = .Ready
    }
    
    private static func doctorSays(in state: CannonLinesState, value: String?) {
        CannonLines.getLines(state: state, value: value).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line, pos: 0)
        }
    }
    
    private static func showInputPanel() {
        gameScene.inputPanelForCannon.isHidden = false
    }
    
    private static func hideInputPanel() {
        gameScene.inputPanelForCannon.isHidden = true
    }
    
    public static func add(type: Int, pos: [Int]) {
        let cannon = Cannon(type: type)
        gameScene.gridNode.addObjectAtGrid(object: cannon, x: pos[0], y: pos[1])
    }
    
}

struct CannonTouchController {
    
    public static var state: CannonState = .Ready
    
    public static func onEvent(cannon: Cannon?) {
        switch state {
        case .Ready:
            CannonController.execute(0, cannon: cannon!)
            break;
        case .Charging:
            break;
        default:
            break;
        }
    }
}

enum CannonLinesState {
    case WillInput, Inputing, InputDone
}

struct CannonLines {
    static func getLines(state: CannonLinesState, value: String?) -> String {
        switch state {
        case .WillInput:
            return "砲撃の飛距離を入力するのじゃ！"
        default:
            return ""
        }
    }
}

