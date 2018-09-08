//
//  EnemyAddController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class EnemyAddController {
    static func setSUEnemyPair(origin: Enemy, branch: Enemy, gridNode: Grid) {
        origin.forEduOriginFlag = true
        branch.forEduBranchFlag = true
        gridNode.enemySUPairDict[origin] = branch
    }
    
    /* Add initial enemy */
    static func addInitialEnemyAtGrid(enemyPosArray: [[Int]], grid: Grid, completion: @escaping () -> Void) {
        /* Add a new enemy at grid position*/
        let dispatchGroup = DispatchGroup()
        for posArray in enemyPosArray {
            dispatchGroup.enter()
            let veGroup = posArray[2]
            if veGroup < VECategory.unSFrom {
                let veSource = VECategory.ves[veGroup]
                /* New enemy object */
                let enemy = Enemy(variableExpressionSource: veSource, forEdu: false)
                
                /* set adding enemy movement */
                setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1], grid: grid) {
                    dispatchGroup.leave()
                }
            } else {
                VECategory.getUnsimplified(source: VECategory.ves[veGroup]) { veSource in
                    /* New enemy object */
                    let enemy = Enemy(variableExpressionSource: veSource, forEdu: false)
                    
                    /* Set enemy speed according to stage level */
                    if GameScene.stageLevel < 1 {
                        enemy.moveSpeed = 0.2
                        enemy.punchSpeed = 0.0025
                        enemy.singleTurnDuration = 1.0
                    }
                    
                    /* set adding enemy movement */
                    setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1], grid: grid) {
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion()
        })
    }
    
    /* Add enemy in the middle of game */
    static func addEnemyAtGrid(addIndex: Int, grid: Grid, completion: @escaping () -> Void) {
        let manager = EnemyProperty.addEnemyVEManager[GameScene.stageLevel][String(addIndex)]!
        
        let dispatchGroup1 = DispatchGroup()
        for array in manager {
            dispatchGroup1.enter()
            let dispatchGroup2 = DispatchGroup()
            for _ in 1...array[0] {
                dispatchGroup2.enter()
                let veGroup = array[1]
                if veGroup < VECategory.unSFrom {
                    let veSource = VECategory.ves[veGroup]
                    /* New enemy object */
                    let enemy = Enemy(variableExpressionSource: veSource, forEdu: false)
                    
                    /* x position */
                    let randX = Int(arc4random_uniform(UInt32(grid.startPosArray.count)))
                    let startPositionX = grid.startPosArray[randX]
                    /* Make sure not to overlap enemies */
                    grid.startPosArray.remove(at: randX)
                    
                    /* y position */
                    let randY = Int(arc4random_uniform(UInt32(array[2])))
                    
                    /* set adding enemy movement */
                    setAddEnemyMovement(enemy: enemy, posX: startPositionX, posY: 11-randY, grid: grid) {
                        dispatchGroup2.leave()
                    }
                } else {
                    VECategory.getUnsimplified(source: VECategory.ves[veGroup]) { veSource in
                        /* New enemy object */
                        let enemy = Enemy(variableExpressionSource: veSource, forEdu: false)
                        
                        /* x position */
                        let randX = Int(arc4random_uniform(UInt32(grid.startPosArray.count)))
                        let startPositionX = grid.startPosArray[randX]
                        /* Make sure not to overlap enemies */
                        grid.startPosArray.remove(at: randX)
                        
                        /* y position */
                        let randY = Int(arc4random_uniform(UInt32(array[2])))
                        
                        /* set adding enemy movement */
                        setAddEnemyMovement(enemy: enemy, posX: startPositionX, posY: 11-randY, grid: grid) {
                            dispatchGroup2.leave()
                        }
                    }
                }
                
            }
            dispatchGroup2.notify(queue: .main, execute: {
                dispatchGroup1.leave()
            })
        }
        dispatchGroup1.notify(queue: .main, execute: {
            return completion()
        })
    }
    
    /* Add enemy for education */
    static func addEnemyForEdu(addIndex: Int, grid: Grid, completion: @escaping () -> Void) {
        
        let manager = EnemyProperty.addEnemyForEduManager[GameScene.stageLevel][String(addIndex)]
        let ves = VECategory.ves[manager![0]]
        let num = manager![1]
        let yRange = manager![2]
        
        DAUtility.getRandomNumbers(total: ves.count, times: num) { (nums) in
            let dispatchGroup = DispatchGroup()
            for i in nums {
                dispatchGroup.enter()
                /* Select origin Enemy */
                let variableExpression = ves[i]
                VECategory.getCategory(ve: variableExpression) { cate in
                    /* Select branch Enemy */
                    let branchGroup = VECategory.unSimplifiedVEs(veCate: cate)
                    /* New enemy object */
                    let enemyOrigin = Enemy(variableExpressionSource: [variableExpression], forEdu: true)
                    let enemyBranch = Enemy(variableExpressionSource: branchGroup, forEdu: true)
                    EnemyAddController.setSUEnemyPair(origin: enemyOrigin, branch: enemyBranch, gridNode: grid)
                    
                    /* Set punch inteval */
                    let randPI = Int(arc4random_uniform(100))
                    
                    /* punchInterval is 1 with 40% */
                    if randPI < 45 {
                        enemyOrigin.punchInterval = 1
                        enemyOrigin.punchIntervalForCount = 1
                        enemyBranch.punchInterval = 1
                        enemyBranch.punchIntervalForCount = 1
                        
                        /* punchInterval is 2 with 40% */
                    } else if randPI < 90 {
                        enemyOrigin.punchInterval = 2
                        enemyOrigin.punchIntervalForCount = 2
                        enemyBranch.punchInterval = 2
                        enemyBranch.punchIntervalForCount = 2
                        
                        /* punchInterval is 0 with 20% */
                    } else {
                        enemyOrigin.punchInterval = 0
                        enemyOrigin.punchIntervalForCount = 0
                        enemyBranch.punchInterval = 0
                        enemyBranch.punchIntervalForCount = 0
                    }
                    
                    /* x position */
                    /* First enemy set will be placed left half part */
                    if i == 0 {
                        let randX = Int(arc4random_uniform(3))
                        let startPositionX = grid.startPosArray[randX]
                        /* set adding enemy movement */
                        self.setAddEnemyMovement(enemy: enemyOrigin, posX: startPositionX, posY: 11-yRange, grid: grid) {}
                        self.setAddEnemyMovement(enemy: enemyBranch, posX: startPositionX+1, posY: 11-yRange, grid: grid) {
                            dispatchGroup.leave()
                        }
                        /* First enemy set will be placed right half part */
                    } else {
                        let randX = Int(arc4random_uniform(3))
                        let startPositionX = grid.startPosArray[randX+5]
                        /* set adding enemy movement */
                        self.setAddEnemyMovement(enemy: enemyOrigin, posX: startPositionX, posY: 11-yRange, grid: grid) {}
                        self.setAddEnemyMovement(enemy: enemyBranch, posX: startPositionX+1, posY: 11-yRange, grid: grid) {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion()
            })
        }
    }
    
    /* Make common stuff for adding enemy */
    private static func setAddEnemyMovement(enemy: Enemy, posX: Int, posY: Int, grid: Grid, completion: @escaping () -> Void) {
        /* Get gameScene */
        let gameScene = grid.parent as! GameScene
        
        /* Store variable expression as origin */
        enemy.originVariableExpression = enemy.variableExpressionString
        
        /* Set direction of enemy */
        enemy.direction = .front
        enemy.setMovingAnimation()
        
        /* Set position on screen */
        
        /* Keep track enemy position */
        enemy.positionX = posX
        enemy.positionY = posY
        
        /* Calculate gap between top of grid and gameScene */
        let gridPosition = CGPoint(x: (Double(posX)+0.5)*grid.cellWidth, y: Double(gameScene.topGap+grid.size.height))
        enemy.position = gridPosition
        
        /* Set enemy's move distance when showing up */
        let startMoveDistance = Double(gameScene.topGap)+grid.cellHeight*(Double(11-posY)+0.5)
        
        /* Calculate relative duration with distance */
        let startDulation = TimeInterval(startMoveDistance/Double(grid.cellHeight)*grid.addingMoveSpeed)
        
        /* Add enemy to grid node */
        grid.addChild(enemy)
        enemy.adjustLabelSize()
        
        /* Add enemy to enemyArray */
        grid.enemyArray.append(enemy)
        
        /* Move enemy for startMoveDistance */
        let move = SKAction.moveTo(y: CGFloat((Double(enemy.positionY)+0.5)*grid.cellHeight), duration: startDulation)
        enemy.run(move, completion: {
            return completion()
        })
    }
}
