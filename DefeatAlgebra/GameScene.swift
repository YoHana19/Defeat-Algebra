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
    var wall: SKShapeNode!
    
    /* Game constants */
    var moveTimer: CFTimeInterval = 0
    var singleMoveTime: CFTimeInterval = 0.5
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Game buttons */
    var test: MSButtonNode!
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    
    /* Game flags */
    var addEnemyDoneFlag = false
    
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
