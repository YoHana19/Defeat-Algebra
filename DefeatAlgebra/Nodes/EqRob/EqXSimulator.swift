//
//  EqXSimulator.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/04.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqXSimulator: SKLabelNode {
    
    var isPositive: Bool = true
    var keisu: Int = 0
    var veBG = SKShapeNode(rectOf: CGSize(width: 0, height: 0))
    var isMultiplied = false
    var fSize: CGFloat = 70
    
    init(isPositive: Bool, keisu: Int, isMultiplied: Bool) {
        super.init()
        self.isPositive = isPositive
        self.keisu = keisu
        self.isMultiplied = isMultiplied
        self.text = "x"
        self.fontSize = fSize
        self.fontName = DAFont.fontName
        self.verticalAlignmentMode = .center
        self.horizontalAlignmentMode = .left
        self.position = CGPoint(x: 0, y: 0)
        self.zPosition = 15
        setBg()
        changeTextColor(color: UIColor.darkGray)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPhysics(isActive: Bool) {
        if isActive {
            physicsBody = SKPhysicsBody(rectangleOf: veBG.frame.size, center: CGPoint(x: self.frame.width/2, y: 0))
            physicsBody?.categoryBitMask = 128
            physicsBody?.collisionBitMask = 0
            physicsBody?.contactTestBitMask = 1024
        } else {
            physicsBody = nil
        }
    }
    
    func blinkBgColor(color: UIColor) {
        let toColor = SKEase.tweenShapeFillColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: UIColor.clear, to: color)
        let fromColor = SKEase.tweenShapeFillColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: color, to: UIColor.clear)
        let seq = SKAction.sequence([toColor, fromColor])
        let repeatedAction = SKAction.repeatForever(seq)
        veBG.run(repeatedAction)
    }
    
    func blinkTextColor(color: UIColor) {
        let toColor = SKEase.tweenLabelColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: UIColor.clear, to: color)
        let fromColor = SKEase.tweenLabelColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: color, to: UIColor.clear)
        let seq = SKAction.sequence([toColor, fromColor])
        let repeatedAction = SKAction.repeatForever(seq)
        self.run(repeatedAction)
    }
    
    func changeBgColor(color: UIColor) {
        veBG.removeAllActions()
        veBG.fillColor = color
    }
    
    func changeTextColor(color: UIColor) {
        self.fontColor = color
    }
    
    func setBg() {
        veBG = SKShapeNode(rectOf: CGSize(width: self.frame.height+10, height: self.frame.width+10))
        veBG.fillColor = UIColor.clear
        veBG.strokeColor = UIColor.clear
        veBG.zPosition = -1
        veBG.position = CGPoint(x: self.frame.width/2, y: 0)
        veBG.name = "eqXBG"
        addChild(veBG)
    }
    
    func getX() {
        let value = VEEquivalentController.xValue
        if keisu == 1 || isMultiplied {
            self.text = String(value)
        } else {
            self.text = "×\(value)"
        }
        SoundController.sound(scene: VEEquivalentController.gameScene, sound: .ItemGet)
        setBg()
        outPut()
    }
    
    func outPut() {
        let v = VEEquivalentController.xValue * keisu
        if isPositive {
            VEEquivalentController.outPutXValue += v
        } else {
            VEEquivalentController.outPutXValue -= v
        }
    }
}
