//
//  MadDoctor.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class MadDoctor: SKSpriteNode {
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "madScientist2")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 100
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
