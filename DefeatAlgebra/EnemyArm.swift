//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyArm: SKSpriteNode {
    
    var direction: Direction = .front
    
    init(direction: Direction) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "enemyArm")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set enemy direction */
        self.direction = direction
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Set physics properties
        let bodySize = CGSize(width: size.width, height: size.height)
        let centerPoint = CGPoint(x: size.width / 2 - (size.width * anchorPoint.x), y: size.height / 2 - (size.height * anchorPoint.y))
        physicsBody = SKPhysicsBody(rectangleOf: bodySize, center: centerPoint)
        physicsBody?.categoryBitMask = 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        setAngle()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /* Set texture to hero according to direction */
    func setAngle() {
        switch direction {
        case .front:
            self.zRotation = -.pi
            break;
        case .back:
            break;
        case .left:
            self.zRotation = CGFloat(.pi/2.0)
            break;
        case .right:
            self.zRotation = -CGFloat(.pi/2.0)
            break;
        }
    }
    
    /* Extend enemy arm */
    func extendArm(length: CGFloat, speed: CGFloat) {
        /* Calculate magnification */
        let magnification = length/self.size.height
        
        /* Extend arm */
        let extendArm = SKAction.scaleY(to: magnification, duration: TimeInterval(length*speed))
        self.run(extendArm)
    }
    
    /* Shrink back enemy arm */
    func ShrinkArm(length: CGFloat, speed: CGFloat) {
        /* Calculate magnification */
        let magnification = 1/length // Make arm shrink to length "1"
        
        /* Shrink arm */
        let shrinkArm = SKAction.scaleY(to: magnification, duration: TimeInterval(length*speed))
        self.run(shrinkArm)
    }
    
}
