//
//  EnemyMoveController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EnemyMoveController {
    static func move(enemy: Enemy, gridNode: Grid) {
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
    
    private static func moveAni(enemy: Enemy, gridNode: Grid) {
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
    
    private static func setDirection(enemy: Enemy, gridNode: Grid, success: @escaping (Bool) -> Void) {
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
    
    private static func getDirection(enemy: Enemy, gridNode: Grid, completion: @escaping (Direction) -> Void) {
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
    
    static func moveDuplicatedEnemies(enemiesArray: [Enemy], exsist: @escaping (Bool) -> Void) {
        getDuplicatedEnemies(enemiesArray: enemiesArray) { dupliDict in
            if dupliDict.count > 0 {
                for dupli in dupliDict {
                    moveDuplicatedEnemy(enemiesArray: enemiesArray, num: dupli.value, posString: dupli.key)
                }
                exsist(true)
            } else {
                exsist(false)
            }
        }
    }
    
    private static func moveDuplicatedEnemy(enemiesArray: [Enemy], num: Int, posString: String) {
        let pos: [String] = posString.components(separatedBy: "_")
        let dupliEnemies = enemiesArray.filter{ $0.positionX == Int(pos[0]) && $0.positionY == Int(pos[1]) }
        switch num {
        case 2:
            dupliEnemies[0].position = CGPoint(x:dupliEnemies[0].getPos().x+20, y: dupliEnemies[0].getPos().y+20)
            dupliEnemies[1].position = CGPoint(x:dupliEnemies[1].getPos().x-20, y: dupliEnemies[1].getPos().y-20)
            break;
        case 3:
            dupliEnemies[0].position = CGPoint(x:dupliEnemies[0].getPos().x+15, y: dupliEnemies[0].getPos().y+25)
            dupliEnemies[1].position = CGPoint(x:dupliEnemies[1].getPos().x-20, y: dupliEnemies[1].getPos().y-15)
            dupliEnemies[2].position = CGPoint(x:dupliEnemies[2].getPos().x+25, y: dupliEnemies[2].getPos().y-25)
            break;
        case 4:
            dupliEnemies[0].position = CGPoint(x:dupliEnemies[0].getPos().x+20, y: dupliEnemies[0].getPos().y+20)
            dupliEnemies[1].position = CGPoint(x:dupliEnemies[1].getPos().x-20, y: dupliEnemies[1].getPos().y-20)
            dupliEnemies[2].position = CGPoint(x:dupliEnemies[2].getPos().x-20, y: dupliEnemies[2].getPos().y+20)
            dupliEnemies[3].position = CGPoint(x:dupliEnemies[3].getPos().x+20, y: dupliEnemies[3].getPos().y-20)
            break;
        default:
            print("so many duplicated enemy !!!")
            break;
        }
    }
    
    private static func getDuplicatedEnemies(enemiesArray: [Enemy], completion: @escaping ([String: Int]) -> Void) {
        var result = [String: Int]()
        var temp = [String]()
        
        let dispatchGroup = DispatchGroup()
        updateEnemyPosition(enemiesArray: enemiesArray) { enemyPos in
            for i in enemyPos {
                dispatchGroup.enter()
                if temp.contains(i) {
                    if let v = result[i] {
                        result[i] = v+1
                        dispatchGroup.leave()
                    } else {
                        result[i] = 2
                        dispatchGroup.leave()
                    }
                } else {
                    temp.append(i)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(result)
            })
        }
    }
    
    private static func updateEnemyPosition(enemiesArray: [Enemy], completion: @escaping ([String]) -> Void) {
        var enemyPos = [String]()
        let dispatchGroup = DispatchGroup()
        for enemy in enemiesArray {
            dispatchGroup.enter()
            let posString = String(enemy.positionX) + "_" + String(enemy.positionY)
            enemyPos.append(posString)
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(enemyPos)
        })
    }
    
    static func rePosEnemies(enemiesArray: [Enemy], gridNode: Grid) {
        for enemy in enemiesArray {
            rePosEnemy(enemy: enemy, gridNode: gridNode)
        }
    }
    
    private static func rePosEnemy(enemy: Enemy, gridNode: Grid) {
        enemy.position = CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*gridNode.cellWidth), y: CGFloat((Double(enemy.positionY)+0.5)*gridNode.cellHeight))
    }
    
    /*== Enemy Position Management ==*/
    /* Reset enemy position array */
    static func resetEnemyPositon(grid: Grid) {
        for x in 0..<grid.columns {
            /* Loop through rows */
            for y in 0..<grid.rows {
                grid.positionEnemyAtGrid[x][y] = false
            }
        }
    }
    
    /* Update enemy position at grid */
    static func updateEnemyPositon(grid: Grid) {
        for enemy in grid.enemyArray {
            grid.positionEnemyAtGrid[enemy.positionX][enemy.positionY] = true
        }
    }
    
    /* Reposition enemy for checking variable exoression */
    static func rePosEnemy(enemy: Enemy, grid: Grid) {
        enemy.position = CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*grid.cellWidth), y: CGFloat((Double(enemy.positionY)+0.5)*grid.cellHeight))
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = 1
    }
    
    static func blowedToback(enemy: Enemy, grid: Grid) {
        enemy.positionY = 11
        let targetPoint = CGPoint(x: enemy.position.x, y: CGFloat((Double(11)+0.5)*grid.cellHeight))
        let move = SKEase.move(easeFunction: .curveTypeQuintic,
                               easeType: .easeTypeOut,
                               time: 3.5,
                               from: enemy.position,
                               to: targetPoint)
        enemy.run(move)
    }
}
