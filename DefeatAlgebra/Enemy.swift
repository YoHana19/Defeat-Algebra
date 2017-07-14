//
//  Enemy.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum PunchState {
    case punching, streachOut
}

class Enemy: SKSpriteNode {
    
    /* Enemy state management */
    var punchState: PunchState = .punching
    var circle = SKShapeNode(circleOfRadius: 20.0)
    
    /* Enemy property */
    var moveSpeed = 0.5
    var punchSpeed: CGFloat = 0.005
    var direction: Direction = .front
    
    /* Enemy variable for punch */
    var valueOfEnemy: Int = 0
    var firstPunchLength: CGFloat = 45
    var singlePunchLength: CGFloat = 61
    var punchLength: CGFloat! = 0
    var variableExpression: [Int]!
    var variableExpressionForLabel: String!
    let variableExpressionSource = [[1,0],[1,1],[1,2],[1,3],[1,4],[2,0],[2,1],[2,2]]
    
    /* For arms when punch hit wall */
    var armHitWallArray: [EnemyArm] = []
    
    /* Flags */
    var waitDoneFlag = false
    var hitWallFlag = true
    var punchDoneFlag = true
    var aliveFlag = true
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front155")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        /* Set variable expression */
        let rand = arc4random_uniform(UInt32(variableExpressionSource.count))
        variableExpression = variableExpressionSource[Int(rand)]
        if variableExpression[0] == 1 {
            if variableExpression[1] == 0 {
                variableExpressionForLabel = "x"
            } else {
                variableExpressionForLabel = "x+\(variableExpression[1])"
            }
        } else {
            if variableExpression[1] == 0 {
                variableExpressionForLabel = "\(variableExpression[0])x"
            } else {
                variableExpressionForLabel = "\(variableExpression[0])x+\(variableExpression[1])"
            }
        }
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* Set standing texture of enemy according to direction */
    func setStandingtexture() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "front155")
        case .back:
            self.texture = SKTexture(imageNamed: "back155")
        case .left:
            self.texture = SKTexture(imageNamed: "left155")
        case .right:
            self.texture = SKTexture(imageNamed: "right155")
        }
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
    
    /* Make enemy collide to wall */
    func setEnemyCollisionToWall() {
        self.physicsBody?.collisionBitMask = 1024
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
    
    func makeTriangle() {
        /* length of one side */
        let length: CGFloat = 7
        
        /* Set 4 points from start point to end point */
        var points = [CGPoint(x: 0.0, y: -length),
                      CGPoint(x: -length, y: length / 2.0),
                      CGPoint(x: length, y: length / 2.0),
                      CGPoint(x: 0.0, y: -length)]
        
        /* Make triangle */
        let triangle = SKShapeNode(points: &points, count: points.count)
        
        /* Set triangle position */
        triangle.position = CGPoint(x: 0, y: 40)
        triangle.zPosition = 4
        
        
        /* Colorlize triangle to red */
        triangle.fillColor = UIColor.red
        
        self.addChild(triangle)
    }
    
    func setVariableExpressionLabel(text: String) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "BiauKai")
        
        /* Set text */
        label.text = text
        
        /* Set font size */
        label.fontSize = 20
        
        /* Set zPosition */
        label.zPosition = 5
        
        /* Set position */
        label.position = CGPoint(x:0, y: 60)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    func calculatePunchLength(value: Int) {
        /* Calculate value of variable expression of enemy */
        self.valueOfEnemy = value*self.variableExpression[0]+variableExpression[1]
        
        /* Calculate length of punch */
        self.punchLength = self.firstPunchLength + CGFloat(self.valueOfEnemy-1) * self.singlePunchLength
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
        
        if arms.count > 0 {
            for fist in fists {
                fist.moveFistBackward(length: arms[0].size.height, speed: self.punchSpeed)
            }
        }
    }
    
    /* Set invisible node to destroy enemy */
    func setHitPoint(length: CGFloat) {

        switch self.direction {
        case .front:
            /* Set body size */
            let bodySize = CGSize(width: 55, height: 40)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: 0, y: -actLength)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .back:
            /* Set body size */
            let bodySize = CGSize(width: 55, height: 40)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: 0, y: actLength)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .left:
            /* Set body size */
            let bodySize = CGSize(width: 50, height: 45)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: -actLength, y: 0)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .right:
            /* Set body size */
            let bodySize = CGSize(width: 50, height: 45)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: actLength, y: 0)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        }
    }
}
