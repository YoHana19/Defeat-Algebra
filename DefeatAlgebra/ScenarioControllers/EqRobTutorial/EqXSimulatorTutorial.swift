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

class EqXSimulatorTutorial: EqXSimulator {
    
    override init(isPositive: Bool, keisu: Int, isMultiplied: Bool) {
        super.init(isPositive: isPositive, keisu: keisu, isMultiplied: isMultiplied)
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
    
}
