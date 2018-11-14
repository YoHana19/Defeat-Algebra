//
//  EqVeUnit.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/04.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqVeUnit: SKLabelNode {
    
    var xSim: EqXSimulator?
    var isFront = true
    var label2: SKLabelNode?
    var totalWidth: CGFloat = 0
    var gap: CGFloat = 5
    var value: Int?
    var fSize: CGFloat = 70
    var xLabel: SKLabelNode?
    var isActive = false {
        didSet {
            if isActive {
                if let x = xSim {
                    VEEquivalentController.lineState = .PutX
                    x.blinkBgColor(color: UIColor.red)
                    changeTextColor(color: UIColor.red)
                    x.setPhysics(isActive: true)
                } else {
                    VEEquivalentController.lineState = .TouchNum
                    blinkTextColor(color: UIColor.yellow)
                }
            } else {
                if let x = xSim {
                    x.changeBgColor(color: UIColor.clear)
                    x.changeTextColor(color: UIColor.red)
                    x.setPhysics(isActive: false)
                    rePos()
                } else {
                    changeTextColor(color: UIColor.yellow)
                    VEEquivalentController.outPutNumValue += value!
                }
            }
        }
    }
    
    init(text: String, withX: Bool, isFront: Bool, isPositive: Bool, value: Int, isMultiplied: Bool, isFirst: Bool) {
        super.init()
        self.text = text
        self.fontSize = fSize
        self.fontName = DAFont.fontName
        self.verticalAlignmentMode = .center
        self.horizontalAlignmentMode = .left
        self.totalWidth = self.frame.width
        self.isFront = isFront
        if withX {
            setXSim(isFront: isFront, isPositive: isPositive, keisu: value, isMultiplied: isMultiplied, isFirst: isFirst)
            if isPositive {
                if value == 1 {
                    if isFirst {
                        setXLabel(text: "x")
                    } else {
                        setXLabel(text: "+x")
                    }
                } else {
                    if isFirst {
                        setXLabel(text: "\(value)x")
                    } else {
                        setXLabel(text: "+\(value)x")
                    }
                }
            } else {
                if value == 1 {
                    setXLabel(text: "-x")
                } else {
                    setXLabel(text: "-\(value)x")
                }
            }
        } else {
            if isPositive {
                self.value = value
            } else {
                self.value = -value
            }
        }
        self.zPosition = 50
        changeTextColor(color: UIColor.darkGray)
        isUserInteractionEnabled = true
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isActive else { return }
        guard xSim == nil else { return }
        SoundController.sound(scene: VEEquivalentController.gameScene, sound: .UtilButton)
        VEEquivalentController.activateVeSim()
        ScenarioFunction.eqRobSimulatorTutorialTrriger()
    }
    
    func setXSim(isFront: Bool, isPositive: Bool, keisu: Int, isMultiplied: Bool, isFirst: Bool) {
        if isMultiplied && !isFirst {
            xSim = EqXSimulator(isPositive: isPositive, keisu: keisu, isMultiplied: isMultiplied)
            label2 = SKLabelNode(fontNamed: DAFont.fontName)
            label2?.verticalAlignmentMode = .center
            label2?.horizontalAlignmentMode = .left
            label2?.fontSize = fSize
            label2?.text = self.text
            if isPositive {
                self.text = "+"
            } else {
                self.text = "-"
            }
            label2?.position = CGPoint(x: self.frame.width+xSim!.frame.width+gap*2, y: 0)
            addChild(label2!)
            xSim!.position = CGPoint(x: self.frame.width+gap, y: 0)
            addChild(xSim!)
            self.totalWidth = self.frame.width + label2!.frame.width + xSim!.frame.width + gap*2
            //print("\(text): THIS IS IT")
        } else {
            xSim = EqXSimulator(isPositive: isPositive, keisu: keisu, isMultiplied: isMultiplied)
            if isFront {
                xSim!.position = CGPoint(x: self.frame.width+gap, y: 0)
                //print("\(text): IS IT Fine Right?")
            } else {
                xSim!.position = CGPoint(x: -(xSim!.frame.width+gap), y: 0)
//                self.position = CGPoint(x: self.position.x+(xSim!.frame.width+gap), y: self.position.y)
                //print("\(text): Any Problem?")
            }
            addChild(xSim!)
            self.totalWidth += xSim!.frame.width+gap
        }
    }
    
    func blinkTextColor(color: UIColor) {
        let toColor = SKEase.tweenLabelColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: UIColor.clear, to: color)
        let fromColor = SKEase.tweenLabelColor(easeFunction: .curveTypeLinear, easeType: .easeTypeInOut, time: 1.5, from: color, to: UIColor.clear)
        let seq = SKAction.sequence([toColor, fromColor])
        let repeatedAction = SKAction.repeatForever(seq)
        self.run(repeatedAction)
    }
    
    func changeTextColor(color: UIColor) {
        removeAllActions()
        self.fontColor = color
        if let lv2 = label2 {
            lv2.fontColor = color
        }
    }
    
    func setXLabel(text: String) {
        xLabel = SKLabelNode(fontNamed: DAFont.fontName)
        xLabel?.horizontalAlignmentMode = .center
        xLabel?.verticalAlignmentMode = .center
        xLabel?.fontSize = 40
        xLabel?.fontColor = UIColor.red
        xLabel?.isHidden = true
        xLabel?.text = text
        xLabel?.zPosition = 15
        addChild(xLabel!)
    }
    
    func showXLabel() {
        xLabel?.position = CGPoint(x: self.totalWidth/2, y: 0)
        xLabel?.isHidden = false
        let move = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        xLabel?.run(move)
    }
    
    func rePos() {
        let _ = xSim!.getX()
        self.totalWidth = self.frame.width + xSim!.frame.width+gap
        if let additional = label2?.frame.width {
            self.totalWidth += additional+gap
        }
        showXLabel()
    }
    
    func reset() {
        changeTextColor(color: UIColor.darkGray)
        if let xSim = self.xSim {
            xSim.text = "x"
            xSim.setBg()
            xSim.changeTextColor(color: UIColor.darkGray)
            self.totalWidth = self.frame.width + xSim.frame.width+gap
            if let additional = label2?.frame.width {
                self.totalWidth += additional+gap
            }
            xLabel?.isHidden = true
        }
    }
    
}
