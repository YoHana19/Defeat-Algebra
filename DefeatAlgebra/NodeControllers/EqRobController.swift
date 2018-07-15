//
//  EqRobController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import UIKit

struct EqRobController {
    public static var gameScene: GameScene!
    private static var eqRob: EqRob = gameScene.eqRob
    private static var inputPanel: InputPanel = gameScene.inputPanel
    private static var doctorOffPos = CGPoint(x: -100, y: 170)
    private static var doctorOnPos = CGPoint(x: 150, y: 170)
    private static var doctorScale: CGFloat = 0.85
    
    public static func showInputPanel() {
       inputPanel.isHidden = false
    }
    
    public static func hideInputPanel() {
        inputPanel.isHidden = true
    }
    
    private static func reSizeDoctor() {
        CharacterController.doctor.setScale(doctorScale)
    }
    
    private static func originSizeDoctor() {
        CharacterController.doctor.setScale(1/doctorScale)
    }
    
    public static func inputPanelWithDoctor() {
        showInputPanel()
        reSizeDoctor()
        CharacterController.doctor.balloon.isHidden = false
        CharacterController.doctor.move(from: doctorOffPos, to: doctorOnPos)
    }
}
