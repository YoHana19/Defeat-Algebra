//
//  Enemy.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    
    var direction: Direction = .front
    var moveSpeed = 0.5
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front155")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 2
        physicsBody?.contactTestBitMask = 2
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* Set Animation to enemy according to direction */
    func setMovingAnimation() {
        switch direction {
        case .front:
            let enemyMoveAnimation = SKAction(named: "enemyMoveForward")!
            self.run(enemyMoveAnimation)
        case .back:
            let enemyMoveAnimation = SKAction(named: "enemyMoveBackward")!
            self.run(enemyMoveAnimation)
        case .left:
            let enemyMoveAnimation = SKAction(named: "enemyMoveLeft")!
            self.run(enemyMoveAnimation)
        case .right:
            let enemyMoveAnimation = SKAction(named: "enemyMoveRight")!
            self.run(enemyMoveAnimation)
        }
    }
    
    /* Move enemy one cell by one cell */
    func enemyMove(lengthX: Int, lengthY: Int) {
        switch direction {
        case .front:
            let moveFrontByOneCell = SKAction.move(by: CGVector(dx: 0, dy: -lengthY), duration: moveSpeed)
            self.run(moveFrontByOneCell)
        case .back:
            let moveBackByOneCell = SKAction.move(by: CGVector(dx: 0, dy: lengthY), duration: moveSpeed)
            self.run(moveBackByOneCell)
        case .left:
            let moveLeftByOneCell = SKAction.move(by: CGVector(dx: -lengthX, dy: 0), duration: moveSpeed)
            self.run(moveLeftByOneCell)
        case .right:
            let moveRightByOneCell = SKAction.move(by: CGVector(dx: lengthX, dy: 0), duration: moveSpeed)
            self.run(moveRightByOneCell)
        }
    }
}
