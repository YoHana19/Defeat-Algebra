//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Teleport: SKSpriteNode {
    
    var spotPos = [Int]()
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "teleport")
        let bodySize = CGSize(width: 60, height: 60)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.categoryBitMask = 64
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "teleport"
    }
}
