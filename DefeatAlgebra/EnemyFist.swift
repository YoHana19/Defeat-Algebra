//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyFist: SKSpriteNode {
    
    var direction: Direction = .front
    var extendSpeed = 0.5
    var circle = SKShapeNode(circleOfRadius: 20.0)
    
    init(direction: Direction) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "enemyFist")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set enemy direction */
        self.direction = direction
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 4
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = 8
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
            break;
        case .back:
            self.zRotation = -.pi
            break;
        case .left:
            self.zRotation = -CGFloat(.pi/2.0)
            break;
        case .right:
            self.zRotation = CGFloat(.pi/2.0)
            break;
        }
    }
    
    /* Move enemy fist when arm extending */
    func moveFistForward(length: CGFloat, speed: CGFloat) {
        /* Move fist */
        switch direction {
        case .front:
            let moveFist = SKAction.moveBy(x: 0, y: -length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .back:
            let moveFist = SKAction.moveBy(x: 0, y: length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .left:
            let moveFist = SKAction.moveBy(x: -length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .right:
            let moveFist = SKAction.moveBy(x: length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        }
    }
    
    /* Move enemy fist when arm shrinking back */
    func moveFistBackward(length: CGFloat, speed: CGFloat) {
        /* Move fist */
        switch direction {
        case .front:
            let moveFist = SKAction.moveBy(x: 0, y: length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .back:
            let moveFist = SKAction.moveBy(x: 0, y: -length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .left:
            let moveFist = SKAction.moveBy(x: length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .right:
            let moveFist = SKAction.moveBy(x: -length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        }
    }
    
    /* Set hit point when punch goes around */
    func setHitPoint() {
        /* Set body size */
        let bodySize = CGSize(width: 32, height: 34)
        
        /* Set invisible hit point */
        circle = SKShapeNode(rectOf: bodySize)
        circle.position = self.position
        circle.zPosition = 5
        
        /* Make hit point invisible */
        circle.fillColor = SKColor.red
        circle.alpha = CGFloat(0.1)
        
        /* Set physics property */
        circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        circle.physicsBody?.categoryBitMask = 64
        circle.physicsBody?.collisionBitMask = 0
        circle.physicsBody?.contactTestBitMask = 33
        self.parent?.addChild(circle)
    }
}
