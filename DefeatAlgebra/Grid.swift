//
//  Grid.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    
    /* Grid array dimensions */
    let rows = 10
    let columns = 10
    
    /* Individual cell dimension, auto-calculated */
    var cellWidth = 0
    var cellHeight = 0
    
    /* Enemy Array */
    var enemyArray = [Enemy]()
    
    /* For confirm all punches finish */
    var maxDuration: CGFloat = 0
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / (columns+2)
        cellHeight = Int(size.height) / (rows+2)
    }

    
    func addEnemyAtGrid(_ numberOfEnemy: Int) {
        /* Add a new enemy at grid position*/
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = Enemy()
        
            /* Set direction of enemy randomly*/
            let directionIndex = Int(arc4random_uniform(4))+1
            enemy.direction = Direction(rawValue: directionIndex)!
            enemy.setMovingAnimation()
        
            /* Set position on screen */
            /* Enemy come into grid from out of it */
            let startPosition = Int(arc4random_uniform(10))+1
            
            /* Set enemy's move distance when showing up randomly */
            let rand = Int(arc4random_uniform(4))+2
            let startMoveDistanceHeight = CGFloat(rand*self.cellHeight+self.cellHeight/2)
            let startMoveDistanceWidth = CGFloat(rand*self.cellWidth+self.cellWidth/2)
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(Double(rand)*enemy.moveSpeed+enemy.moveSpeed/2)
            
            switch Int(directionIndex) {
            /* From top */
            case 1:
                let gridPosition = CGPoint(x: startPosition*cellWidth+cellWidth/2, y: Int(size.height))
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: 0, y: -startMoveDistanceHeight, duration: startDulation)
                enemy.run(move)
                break;
            /* From bottom */
            case 2:
                let gridPosition = CGPoint(x: startPosition*cellWidth+cellWidth/2, y: 0)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: 0, y: startMoveDistanceHeight, duration: startDulation)
                enemy.run(move)
                break;
            /* From right */
            case 3:
                let gridPosition = CGPoint(x: Int(size.width), y: startPosition*cellHeight+cellHeight/2)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: -startMoveDistanceWidth, y: 0, duration: startDulation)
                enemy.run(move)
                break;
            /* From left */
            case 4:
                let gridPosition = CGPoint(x: 0, y: startPosition*cellHeight+cellHeight/2)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: startMoveDistanceWidth, y: 0, duration: startDulation)
                enemy.run(move)
                break;
            default:
                break;
            }
        
            /* Add enemy to grid node */
            addChild(enemy)
        
        
//          let moveRight = SKAction.repeatForever(moveRightByOneCell)
        
            /* Add creature to grid array */
            enemyArray.append(enemy)
        }
        
        maxDuration = 2.9*2+0.3
    }
    
}

