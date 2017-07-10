//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
    case AddEnemy, EnemyMoving
}

enum Direction: Int {
    case front = 1, back, left, right
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var wall: SKShapeNode!
    
    /* Game constants */
    var moveTimer: CFTimeInterval = 0
    var singleMoveTime: CFTimeInterval = 0.75
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Game buttons */
    var test: MSButtonNode!
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    
    /* Game flags */
    var addEnemyDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        
        /* Connect game buttons */
        test = childNode(withName: "test") as! MSButtonNode
        
        test.selectedHandler = {
            
            /* Remove wall */
            self.removeChildren(in: [self.wall])
            
            let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(3) })
            let wait = SKAction.wait(forDuration: 1.0)
            let addDone = SKAction.run({ self.addEnemyDoneFlag = true })
            let seq = SKAction.sequence([addEnemy, wait, addDone])
            self.run(seq)
            
            self.gameState = .EnemyMoving
        }
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self

        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set hero */
        hero = Hero()
        hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+gridNode.size.height/2)
        addChild(hero)
        
        /* Set invisible wall */
        setWall()

    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            break;
        case .EnemyMoving:
            if self.addEnemyDoneFlag {
                /* Set invisible wall */
                setWall()
                self.addEnemyDoneFlag = false
            }
            enemyMoveAround()
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!              // Get the first touch
        beganPos = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        /* Move hero */
        detectSwipeDirection(diffPos)
    }
    
    func detectSwipeDirection(_ diffPos: CGPoint) {
        
        var degree:Int
        
        if diffPos.x != 0 {
            /* horizontal move */
            let radian = atan(diffPos.y/fabs(diffPos.x)) // calculate radian by arctan
            degree = Int(radian * CGFloat(180 * M_1_PI)) // convert radian to degree
        } else {
            /* just touch */
            if diffPos.y == 0 {
                degree = 1000
            } else {
                /* vertical move */
                degree = diffPos.y < 0 ? -90:90;
            }
        }
        
        switch degree {
        case -90 ..< -45:
            /* Reset movement */
            hero.removeAllActions()
            
            hero.direction = .front
            hero.setTexture()
            hero.setMovingAnimation()
            
            /* Move hero forward */
            let moveOne = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
            let move = SKAction.repeatForever(moveOne)
            hero.run(move)
            
        case -45 ..< 45:
            if diffPos.x >= 0 {
                /* Reset movement */
                hero.removeAllActions()
                
                hero.direction = .right
                hero.setTexture()
                hero.setMovingAnimation()
                
                /* Move hero right */
                let moveOne = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                let move = SKAction.repeatForever(moveOne)
                hero.run(move)
                
            } else {
                /* Reset movement */
                hero.removeAllActions()
                
                hero.direction = .left
                hero.setTexture()
                hero.setMovingAnimation()
                
                /* Move hero left */
                let moveOne = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: hero.moveSpeed)
                let move = SKAction.repeatForever(moveOne)
                hero.run(move)
                
            }
        case 45 ... 90:
            /* Reset movement */
            hero.removeAllActions()
            
            hero.direction = .back
            hero.setTexture()
            hero.setMovingAnimation()
            
            /* Move hero backward */
            let moveOne = SKAction.moveBy(x: 0, y: CGFloat(gridNode.cellHeight), duration: hero.moveSpeed)
            let move = SKAction.repeatForever(moveOne)
            hero.run(move)
            
        default:
            /* Stop movement */
            hero.removeAllActions()
            hero.setTexture()
            break;
        }
        
    }
    
    func enemyMoveAround() {
        /* Time to move enemy */
        if moveTimer >= singleMoveTime {
            
            /* move Enemy */
            for enemy in gridNode.enemyArray {
                let directionIndex = arc4random_uniform(4)+1
                enemy.direction = Direction(rawValue: Int(directionIndex))!
                enemy.setMovingAnimation()
                enemy.enemyMove(lengthX: gridNode.cellWidth, lengthY: gridNode.cellHeight)
            }
            
            // Reset spawn timer
            moveTimer = 0
        }
        
        moveTimer += fixedDelta
    }
    
    func setWall() {
        
        /* Calculate size of wall */
        let size = CGSize(width: gridNode.cellWidth*10, height: gridNode.cellHeight*10)
        
        /* Calculate position of wall */
        let position = CGPoint(x: self.size.width/2, y: gridNode.size.height/2+gridNode.position.y)
        
        wall = SKShapeNode(rectOf: size)
        wall.strokeColor = SKColor.blue
        wall.lineWidth = 2.0
        wall.alpha = CGFloat(0)
        wall.physicsBody = SKPhysicsBody(edgeLoopFrom: wall.frame)
        wall.position = position
        self.addChild(wall)
    }

}
