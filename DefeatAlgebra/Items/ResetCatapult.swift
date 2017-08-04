//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ResetCatapult: SKSpriteNode {
    
    var posX = 0
    var posY = 0
    
    init() {
        /* Initialize with 'mine' asset */
        let texture = SKTexture(imageNamed: "resetCatapult")
        let bodySize = CGSize(width: 60, height: 60)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to center */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.categoryBitMask = 64
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        /* For detect what object to tougch */
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "resetCatapult"
    }
}
