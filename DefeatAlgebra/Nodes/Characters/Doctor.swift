//
//  Doctor.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Doctor: SKSpriteNode {
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "goodDoctorDefault")
        let bodySize = CGSize(width: 264, height: 310.4)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
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
