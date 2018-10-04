//
//  SignalValueHolder.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/30.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class SignalValueHolder: SKSpriteNode {
    
    var xValue = SKLabelNode(fontNamed: DAFont.fontName)
    
    init(value: Int) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "siganlRound")
        let size = CGSize(width: 60, height: 60)
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        setXValueLabel(value: value)
        
        self.name = "signal"
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setXValueLabel(value: Int) {
        xValue.text = String(value)
        /* font size */
        xValue.fontSize = 45
        /* zPosition */
        xValue.zPosition = 5
        xValue.verticalAlignmentMode = .center
        xValue.horizontalAlignmentMode = .center
        /* position */
        xValue.position = CGPoint(x:0, y: 0)
        /* Add to Scene */
        self.addChild(xValue)
    }
    
}
