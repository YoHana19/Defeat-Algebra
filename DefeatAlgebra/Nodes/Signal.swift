//
//  Signal.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Signal: SKSpriteNode {
    
    let red = SKTexture(imageNamed: "signalRed")
    let yellow = SKTexture(imageNamed: "signalYellow")
    
    init(color: String) {
        /* Initialize with enemy asset */
        var texture = red
        if (color == "yellow") {
            texture = yellow
        }
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
