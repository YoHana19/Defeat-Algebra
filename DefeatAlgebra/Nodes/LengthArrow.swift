//
//  LengthArrow.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class LengthArrow: SKSpriteNode {
    
    init(height: CGFloat?) {
        /* Initialize with 'mine' asset */
        let texture = SKTexture(imageNamed: "whiteArrow")
        if let h = height {
            let bodySize = CGSize(width: texture.size().width, height: h)
            super.init(texture: texture, color: UIColor.clear, size: bodySize)
        } else {
            super.init(texture: texture, color: UIColor.clear, size: texture.size())
        }
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 12
        
        /* Set anchor point to center */
        anchorPoint = CGPoint(x: 0.5, y: 1)
        
        self.name = "lengthArrow"
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
