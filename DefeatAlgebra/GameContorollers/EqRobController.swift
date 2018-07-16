//
//  EqRobController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct EqRobController {
    public static var gameScene: GameScene!
    public static var eqRobOriginPos: CGPoint!
    private static var lines = [SKShapeNode]()
    private static var selectedEnemies = [Enemy]()
    private static var selectedEnemyIndex: Int = 0
    private static var doctorOffPos = CGPoint(x: -200, y: 170)
    private static var doctorOnPos: [CGPoint] = [
        CGPoint(x: 150, y: 170),
        CGPoint(x: 90, y: 100)
    ]
    private static var doctorScale: [CGFloat] = [
        0.85,
        0.6
    ]
    
    public static func execute(_ index: Int, enemy: Enemy?) {
        switch index {
        case 0:
            showInputPanelWithDoctor()
            break;
        case 1:
            showSelectionPanelWithDoctor()
            break;
        case 2:
            setSelectedEnemyOnPanel(enemy: enemy!)
            break;
        default:
            break;
        }
    }
    
    public static func back(_ index: Int) {
        switch index {
        case 0:
            hideInputPanelWithDoctor()
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
        }
    }
    
    private static func showInputPanelWithDoctor() {
        showInputPanel()
        gameScene.eqRob.go(to: gameScene.inputPanel.eqRobPoint, completion: {
            gameScene.eqRob.rotateForever()
        })
        CharacterController.doctor.setScale(doctorScale[0])
        CharacterController.doctor.balloon.isHidden = false
        doctorSays(in: .WillInput, value: nil)
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos[0])
    }
    
    private static func hideInputPanelWithDoctor() {
        hideInputPanel()
        gameScene.eqRob.stopAction()
        gameScene.eqRob.go(toPos: eqRobOriginPos) {
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            gameScene.eqRob.run(rotate)
        }
        CharacterController.doctor.setScale(1)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.doctor.move(from: nil, to: doctorOffPos)
    }
    
    private static func showSelectionPanelWithDoctor() {
        hideInputPanel()
        showSelectionPanel()
        gameScene.eqRob.stopAction()
        gameScene.eqRob.go(toPos: eqRobOriginPos) {
            let rotate = SKAction.rotate(toAngle: .pi * -1/2, duration: 1.0)
            gameScene.eqRob.run(rotate)
        }
        CharacterController.doctor.setScale(doctorScale[1])
        doctorSays(in: .WillSelectEnemies, value: gameScene.inputPanel.confirmedVE)
        gameScene.selectionPanel.veLabel.text = gameScene.inputPanel.confirmedVE
        CharacterController.doctor.move(from: nil, to: doctorOnPos[1])
    }
    
    private static func setSelectedEnemyOnPanel(enemy: Enemy) {
        guard selectedEnemyIndex < 8 else {
            doctorSays(in: .WarnSelection, value: nil)
            return
        }
        if selectedEnemyIndex < 1 {
            drawLine(start: gameScene.eqRob.absolutePos(), end: enemy.absolutePos())
        } else {
            drawLine(start: selectedEnemies[selectedEnemyIndex-1].absolutePos(), end: enemy.absolutePos())
        }
        selectedEnemies.append(enemy)
        gameScene.selectionPanel.setSelectedEnemy(target: enemy, index: selectedEnemyIndex)
        selectedEnemyIndex += 1
    }
    
    public static func resetSelectedEnemyOnPanel() {
        lines.forEach { $0.removeFromParent() }
        selectedEnemies.forEach { $0.isSelectedForEqRob = false }
        selectedEnemyIndex = 0
        doctorSays(in: .WillSelectEnemies, value: gameScene.inputPanel.confirmedVE)
        selectedEnemies = [Enemy]()
        lines = [SKShapeNode]()
        gameScene.selectionPanel.resetAllEnemies()
    }
    
    private static func showInputPanel() {
       gameScene.inputPanel.isHidden = false
    }
    
    private static func hideInputPanel() {
        gameScene.inputPanel.isHidden = true
    }
    
    private static func showSelectionPanel() {
        gameScene.selectionPanel.isHidden = false
    }
    
    private static func hideSelectionPanel() {
        gameScene.selectionPanel.isHidden = true
    }
    
    private static func doctorSays(in state: EqRobLinesState, value: String?) {
        EqRobLines.getLines(state: state, value: value).DAMultilined() { line in
            CharacterController.doctor.balloon.setLines(with: line)
        }
    }
    
    private static func drawLine(start: CGPoint, end: CGPoint) {
        let line = Line(startPoint: start, endPoint: end)
        lines.append(line)
        gameScene.addChild(line)
    }
    
}

enum EqRobLinesState {
    case WillInput, ConfirmInput, WillSelectEnemies, SelectingEnemies, AdviceForSelect, ConfirmSelection, WarnSelection
}

struct EqRobLines {
    static func getLines(state: EqRobLinesState, value: String?) -> String {
        switch state {
        case .WillInput:
            return "エクロボに文字式を入力するのじゃ！"
        case .ConfirmInput:
            return ""
        case .WillSelectEnemies:
            return value! + "と同じ文字式を持つ敵を選ぶのじゃ！"
        case .SelectingEnemies:
            return ""
        case .AdviceForSelect:
            return ""
        case .ConfirmSelection:
            return ""
        case .WarnSelection:
            return "すまぬ!\n8体までしか選択できんのじゃ"
        }
    }
}
