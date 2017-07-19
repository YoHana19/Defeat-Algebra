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
    var moveSpeed = 0.5
    var heroMoveAnimation: SKAction!
    var moveLevel: Int = 1
    
    /* position at grid */
    var positionX: Int = 4
    var positionY: Int = 3
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "heroFront")
        let heroSize = CGSize(width: 50, height: 50)
        super.init(texture: texture, color: UIColor.clear, size: heroSize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 4
        
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
    
    /* Move hero */
    func heroSingleMove() {
        /* Get parent Scene */
        let gameScene = self.parent as! GameScene
        
        /* Set texture and animation */
        self.setTexture()
        self.setMovingAnimation()

        switch direction {
        case .front:
            /* Move hero backward */
            let move = SKAction.moveBy(x: 0, y: -CGFloat(gameScene.gridNode.cellHeight), duration: self.moveSpeed)
            self.run(move)
            break;
        case .back:
            /* Move hero forward */
            let move = SKAction.moveBy(x: 0, y: CGFloat(gameScene.gridNode.cellHeight), duration: self.moveSpeed)
            self.run(move)
            break;
        case .left:
            /* Move hero left */
            let move = SKAction.moveBy(x: -CGFloat(gameScene.gridNode.cellWidth), y: 0, duration: self.moveSpeed)
            self.run(move)
            break;
        case .right:
            /* Move hero right */
            let move = SKAction.moveBy(x: CGFloat(gameScene.gridNode.cellWidth), y: 0, duration: self.moveSpeed)
            self.run(move)
            break;
        }
    }
    
    func heroMoveToDest(posX: Int, posY: Int) {
        /* Calculate difference between current position and destination */
        let diffX = posX - self.positionX
        let diffY = posY - self.positionY
        
        /* Move right */
        if diffX > 0 {
            self.direction = .right
            
            /* Move forward */
            if diffY > 0 {
                /* Move horizontaly */
                let singleMoveH = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                
                /* Wait for move horizotaly done */
                let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffX)+0.3)) /* 0.3 is buffer */
                
                /* Move verticaly */
                let changeDirect = SKAction.run({ self.direction = .back })
                let singleMoveV = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                
                let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                self.run(seq)
                
            /* Move backward */
            } else if diffY < 0 {
                /* Move horizontaly */
                let singleMoveH = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                
                /* Wait for move horizotaly done */
                let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffX)+0.3)) /* 0.3 is buffer */
                
                /* Move verticaly */
                let changeDirect = SKAction.run({ self.direction = .front })
                let singleMove = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                
                let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                self.run(seq)
            
            /* Only move horizontaly */
            } else {
                let singleMove = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMove, count: diffX)
                self.run(moveToDestX)
            }

        /* Move Left */
        } else if diffX < 0 {
            self.direction = .left
            
            /* Move forward */
            if diffY > 0 {
                /* Move horizontaly */
                let singleMoveH = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                
                /* Wait for move horizotaly done */
                let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffX)+0.3)) /* 0.3 is buffer */
                
                /* Move verticaly */
                let changeDirect = SKAction.run({ self.direction = .back })
                let singleMoveV = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                
                let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                self.run(seq)
                
                /* Move backward */
            } else if diffY < 0 {
                /* Move horizontaly */
                let singleMoveH = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                
                /* Wait for move horizotaly done */
                let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffX)+0.3)) /* 0.3 is buffer */
                
                /* Move verticaly */
                let changeDirect = SKAction.run({ self.direction = .front })
                let singleMove = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                
                let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                self.run(seq)
                
            /* Only move horizontaly */
            } else {
                let singleMove = SKAction.run({ self.heroSingleMove() })
                let moveToDestX = SKAction.repeat(singleMove, count: -diffX)
                self.run(moveToDestX)
            }
        /* Only move vertically */
        } else {
            /* Move forward */
            if diffY > 0 {
                /* Move verticaly */
                self.direction = .back
                let singleMoveV = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                self.run(moveToDestY)
                
                /* Move backward */
            } else if diffY < 0 {
                /* Move verticaly */
                self.direction = .front
                let singleMove = SKAction.run({ self.heroSingleMove() })
                let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                self.run(moveToDestY)
            }
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
