//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum HeroState {
    case Move, Attack
}

class Hero: SKSpriteNode {
    
    var heroState: HeroState = .Move
    var direction: Direction = .back
    var moveSpeed = 0.15
    var heroMoveAnimation: SKAction!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "heroFront")
        let heroSize = CGSize(width: 50, height: 50)
        super.init(texture: texture, color: UIColor.clear, size: heroSize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /* Set physics property */
        physicsBody = SKPhysicsBody(rectangleOf: heroSize)
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 4294967291

                
        setTexture()
        setMovingAnimation()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /* Set texture to hero according to direction */
    func setTexture() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "heroFront")
        case .back:
            self.texture = SKTexture(imageNamed: "heroBack")
        case .left:
            self.texture = SKTexture(imageNamed: "heroLeft")
        case .right:
            self.texture = SKTexture(imageNamed: "heroRight")
        }
    }
    /* Set animation to hero according to direction */
    func setMovingAnimation() {
        switch direction {
        case .front:
            self.heroMoveAnimation = SKAction(named: "heroMoveForward")!
            self.run(heroMoveAnimation)
        case .back:
            self.heroMoveAnimation = SKAction(named: "heroMoveBackward")!
            self.run(heroMoveAnimation)
        case .left:
            self.heroMoveAnimation = SKAction(named: "heroMoveLeft")!
            self.run(heroMoveAnimation)
        case .right:
            self.heroMoveAnimation = SKAction(named: "heroMoveRight")!
            self.run(heroMoveAnimation)
        }
    }
    
    /* Set hero sword attack animation */
    func setSwordAnimation() {
        switch direction {
        case .front:
            self.anchorPoint = CGPoint(x: 0.5, y: 1)
            let heroSwordAnimation = SKAction(named: "heroSwordBackward")!
            self.run(heroSwordAnimation)
        case .back:
            self.anchorPoint = CGPoint(x: 0.5, y: 0)
            let heroSwordAnimation = SKAction(named: "heroSwordForward")!
            self.run(heroSwordAnimation)
        case .left:
            self.anchorPoint = CGPoint(x: 1, y: 0.5)
            let heroSwordAnimation = SKAction(named: "heroSwordLeft")!
            self.run(heroSwordAnimation)
        case .right:
            self.anchorPoint = CGPoint(x: 0, y: 0.5)
            let heroSwordAnimation = SKAction(named: "heroSwordRight")!
            self.run(heroSwordAnimation)
        }
    }
    
    /* Reset hero position and animation */
    func resetHero() {
        self.direction = .back
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setTexture()
        self.setMovingAnimation()
    }
    
}
