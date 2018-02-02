//
//  EnemyMoveController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyMoveController {
    static func move(enemy: EnemyEasy, gridNode: GridEasy) {
        if enemy.forEduBranchFlag {
            moveAni(enemy: enemy, gridNode: gridNode)
        } else {
            setDirection(enemy: enemy, gridNode: gridNode) { success in
                if success {
                    moveAni(enemy: enemy, gridNode: gridNode)
                } else {
                    print("somthing wrong in EnemyMoveController.move")
                }
            }
        }
    }
    
    private static func moveAni(enemy: EnemyEasy, gridNode: GridEasy) {
        enemy.setMovingAnimation()
        switch enemy.direction {
        case .front:
            let move = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: enemy.moveSpeed)
            enemy.run(move)
            /* Keep track enemy position */
            enemy.positionY -= 1
            break;
        case .left:
            let move = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: enemy.moveSpeed)
            enemy.run(move)
            /* Keep track enemy position */
            enemy.positionX -= 1
            break;
        case .right:
            let move = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: enemy.moveSpeed)
            enemy.run(move)
            /* Keep track enemy position */
            enemy.positionX += 1
            break;
        case .back:
            break;
        }
    }
    
    private static func setDirection(enemy: EnemyEasy, gridNode: GridEasy, success: @escaping (Bool) -> Void) {
        getDirection(enemy: enemy, gridNode: gridNode) { direction in
            enemy.direction = direction
            if let branch = gridNode.enemySUPairDict[enemy] {
                branch.direction = direction
                success(true)
            } else {
                success(true)
            }
        }
    }
    
    private static func getDirection(enemy: EnemyEasy, gridNode: GridEasy, completion: @escaping (Direction) -> Void) {
        /* Determine direction to move */
        let directionRand = arc4random_uniform(100)
        
        /* Left edge */
        if enemy.positionX <= 0 {
            /* Go forward with 70% */
            if directionRand < 70 {
                return completion(.front)
            /* Go right with 30% */
            } else if directionRand < 100 {
                return completion(.right)
            }
        /* Right edge */
        } else if enemy.positionX >= gridNode.columns-1 {
            /* Go forward with 70% */
            if directionRand < 70 {
                return completion(.front)
            /* Go left with 30% */
            } else if directionRand < 100 {
                return completion(.left)
            }
        /* Middle */
        } else {
            /* Go forward with 60% */
            if directionRand < 60 {
                return completion(.front)
            /* Go left with 20% */
            } else if directionRand < 80 {
                return completion(.left)
            /* Go right with 20% */
            } else if directionRand < 100 {
                return completion(.front)
            }
        }
    }
}
