//
//  EqVESimulator.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/04.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqVESimulatorTutorial: EqVESimulator {
    
    override init(text: String) {
        super.init(text: text)
        setVe(text: text) {
            self.positioning()
        }
        self.fontName = DAFont.fontName
        zPosition = 3
        setResult()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
