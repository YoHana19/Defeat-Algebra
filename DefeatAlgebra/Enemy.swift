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
    
    /* Enemy property */
    var moveSpeed = 0.5
    var punchSpeed: CGFloat = 0.01

    /* Enemy variable for punch */
    var valueOfEnemy: Int = 5
    var firstPunchLength: CGFloat = 45
    var singlePunchLength: CGFloat = 61
    var punchLength: CGFloat!
    
    /* For arms when punch hit wall */
    var armHitWallArray: [EnemyArm] = []
    
    /* Flags */
    var waitDoneFlag = false
    var hitWallFlag = true
    var punchDoneFlag = true
    
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
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 16
        physicsBody?.contactTestBitMask = 1
        
        /* calculate punch length */
        punchLength = firstPunchLength + CGFloat(valueOfEnemy-1) * singlePunchLength
        
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
    
    /* Set texture in punching */
    func setTextureInPunch() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "frontPunch55")
        case .back:
            self.texture = SKTexture(imageNamed: "backPunch55")
        case .left:
            self.texture = SKTexture(imageNamed: "leftPunch55")
            break;
        case .right:
            self.texture = SKTexture(imageNamed: "rightPunch55")
            break;
        }

    }
    
    /* Set position of arm */
    func setArm(arm: [EnemyArm], direction: Direction) {
        
        switch direction {
        case .front:
            let armPos1 = CGPoint(x: -13, y: 5)
            let armPos2 = CGPoint(x: 13, y: 5)
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .back:
            let armPos1 = CGPoint(x: -13, y: 10)
            let armPos2 = CGPoint(x: 13, y: 10)
            arm[0].zPosition = -1
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .left:
            let armPos1 = CGPoint(x: 0, y: 3)
            let armPos2 = CGPoint(x: 0, y: -10)
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .right:
            let armPos1 = CGPoint(x: 0, y: 3)
            let armPos2 = CGPoint(x: 0, y: -10)
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        }
    }
    
    /* Do punch */
    func punch() -> (arm: [EnemyArm], fist: [EnemyFist]) {
        /* Set arm */
        let arm1 = EnemyArm(direction: self.direction)
        let arm2 = EnemyArm(direction: self.direction)
        setArm(arm: [arm1, arm2], direction: self.direction)
        
        /* Add arm as enemy child */
        addChild(arm1)
        addChild(arm2)
        
        /* Attach fist on arm */
        let fist1 = EnemyFist(direction: self.direction)
        let fist2 = EnemyFist(direction: self.direction)
        switch direction {
        case .front:
            let fistPos1 = CGPoint(x: -13, y: 5-15)
            let fistPos2 = CGPoint(x: 13, y: 5-15)
            fist1.position = fistPos1
            fist2.position = fistPos2
        case .back:
            let fistPos1 = CGPoint(x: -13, y: 10+5)
            let fistPos2 = CGPoint(x: 13, y: 10+5)
            fist1.position = fistPos1
            fist2.position = fistPos2
        case .left:
            let fistPos1 = CGPoint(x: 0-15, y: 3)
            let fistPos2 = CGPoint(x: 0-15, y: -10)
            fist1.position = fistPos1
            fist2.position = fistPos2
        case .right:
            let fistPos1 = CGPoint(x: 0+15, y: 3)
            let fistPos2 = CGPoint(x: 0+15, y: -10)
            fist1.position = fistPos1
            fist2.position = fistPos2
        }
        
        /* Add arm as fist child */
        addChild(fist1)
        addChild(fist2)
        
        /* Move Fist */
        fist1.moveFistForward(length: punchLength, speed: self.punchSpeed)
        fist2.moveFistForward(length: punchLength, speed: self.punchSpeed)
        
        /* Extend arm */
        arm1.extendArm(length: punchLength, speed: self.punchSpeed)
        arm2.extendArm(length: punchLength, speed: self.punchSpeed)
        
        /* Store reference for func drawPunch */
        return ([arm1, arm2], [fist1, fist2])
    }
    
    func drawPunch(arms: [EnemyArm], fists: [EnemyFist], length: CGFloat) {
        for arm in arms {
            arm.ShrinkArm(length: length, speed: self.punchSpeed)
        }
        
        for fist in fists {
            fist.moveFistBackward(length: arms[0].size.height, speed: self.punchSpeed)
        }
    }
}
