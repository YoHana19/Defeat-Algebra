//
//  Item.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/29.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Item: SKSpriteNode {
    
    var spotPos = [Int]()
    
    init(texture: SKTexture, size: CGSize) {
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 64
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
