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

class EqVeUnitTutorial: EqVeUnit {
    
    override init(text: String, withX: Bool, isFront: Bool, isPositive: Bool, value: Int, isMultiplied: Bool, isFirst: Bool) {
        super.init(text: text, withX: withX, isFront: isFront, isPositive: isPositive, value: value, isMultiplied: isMultiplied, isFirst: isFirst)
        self.text = text
        self.fontSize = fSize
        self.fontName = DAFont.fontName
        self.verticalAlignmentMode = .center
        self.horizontalAlignmentMode = .left
        self.totalWidth = self.frame.width
        if withX {
            setXSim(isFront: isFront, isPositive: isPositive, keisu: value, isMultiplied: isMultiplied)
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
        self.zPosition = 15
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
        VEEquivalentController.activateVeSim()
    }
        
}
