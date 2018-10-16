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
    
    static func addInitialEnemyAtGrid0(veCate: Int, enemyPosArray: [[Int]], grid: Grid, completion: @escaping () -> Void) {
        /* Add a new enemy at grid position*/
        let dispatchGroup = DispatchGroup()
        let veSource = VECategory.ves[veCate].shuffled
        for (i, posArray) in enemyPosArray.enumerated() {
            dispatchGroup.enter()
            /* New enemy object */
            let enemy = Enemy(variableExpressionSource: [veSource[i]], forEdu: false)
                
            /* set adding enemy movement */
            setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1], grid: grid) {
                    dispatchGroup.leave()
            }
            
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion()
        })
    }
    
    static func addInitialEnemyAtGrid1(enemyPosArray: [[Int]], grid: Grid, completion: @escaping () -> Void) {
        /* Add a new enemy at grid position*/
        let dispatchGroup = DispatchGroup()
        for posArray in enemyPosArray {
            dispatchGroup.enter()
            let veGroup = posArray[2]
            if !VECategory.unSFrom.contains(veGroup) {
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
    
    static func addInitialEnemyAtGrid2(veCate: Int, originInclude: Int, enemyPosArray: [[Int]], grid: Grid, completion: @escaping () -> Void) {
        
        getEqRobSource(veCate: veCate, numOfEnemy: enemyPosArray.count) { source in
            let dispatchGroup = DispatchGroup()
            let veSource = source.shuffled
            for (i, posArray) in enemyPosArray.enumerated() {
                dispatchGroup.enter()
                /* New enemy object */
                let enemy = Enemy(variableExpressionSource: [veSource[i]], forEdu: false)
                
                /* set adding enemy movement */
                setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1], grid: grid) {
                    dispatchGroup.leave()
                }
                
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion()
            })
        }
    }
    
    private static func getRatio() -> Int {
        let rand = Int(arc4random_uniform(100))
        if rand < 10 {
            return 0
        } else if rand < 35 {
            return 1
        } else if rand < 75 {
            return 2
        } else {
            return 3
        }
    }
    
    private static func getEqRobSource(veCate: Int, numOfEnemy: Int, completion: @escaping ([String]) -> Void) {
        let rand = getRatio()
        print(rand)
        let oneHalf = rand
        let secondHalf = numOfEnemy - rand
        let veSource = VECategory.ves[veCate]
        var cands = [String]()
        if oneHalf == 0 || oneHalf == 1 {
            let dispatchGroup = DispatchGroup()
            let rand = Int(arc4random_uniform(UInt32(veSource.count)))
            let origin = veSource[rand]
            cands.append(origin)
            VECategory.getUnsimplifiedSingle(source: origin) { source in
                DAUtility.getRandomNumbers(total: source.count, times: secondHalf-1) { rands in
                    for i in rands {
                        dispatchGroup.enter()
                        cands.append(source[i])
                        dispatchGroup.leave()
                    }
                }
                if oneHalf == 1 {
                    dispatchGroup.enter()
                    let others = veSource.filter({ $0 != origin })
                    let r = Int(arc4random_uniform(UInt32(others.count)))
                    VECategory.getUnsimplifiedSingle(source: others[r]) { s in
                        let o = Int(arc4random_uniform(UInt32(s.count)))
                        cands.append(s[o])
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    return completion(cands)
                })
            }
        } else if secondHalf == 0 || secondHalf == 1 {
            let dispatchGroup = DispatchGroup()
            let rand = Int(arc4random_uniform(UInt32(veSource.count)))
            let origin = veSource[rand]
            cands.append(origin)
            VECategory.getUnsimplifiedSingle(source: origin) { source in
                DAUtility.getRandomNumbers(total: source.count, times: oneHalf-1) { rands in
                    for i in rands {
                        dispatchGroup.enter()
                        cands.append(source[i])
                        dispatchGroup.leave()
                    }
                }
                if secondHalf == 1 {
                    dispatchGroup.enter()
                    let others = source.filter({ $0 != origin })
                    let r = Int(arc4random_uniform(UInt32(others.count)))
                    VECategory.getUnsimplifiedSingle(source: others[r]) { s in
                        let o = Int(arc4random_uniform(UInt32(s.count)))
                        cands.append(s[o])
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    return completion(cands)
                })
            }
        } else {
            let dispatchGroup = DispatchGroup()
            DAUtility.getRandomNumbers(total: veSource.count, times: 2) { rands in
                for (i, rand) in rands.enumerated() {
                    cands.append(veSource[rand])
                    if i == 0 {
                        VECategory.getUnsimplifiedSingle(source: veSource[rand]) { source in
                            DAUtility.getRandomNumbers(total: source.count, times: oneHalf-1) { rands2 in
                                for r in rands2 {
                                    dispatchGroup.enter()
                                    cands.append(source[r])
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    } else if i == 1 {
                        VECategory.getUnsimplifiedSingle(source: veSource[rand]) { source in
                            DAUtility.getRandomNumbers(total: source.count, times: secondHalf-1) { rands2 in
                                for r in rands2 {
                                    dispatchGroup.enter()
                                    cands.append(source[r])
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    return completion(cands)
                })
            }
        }
    }
    
    /* Add enemy in the middle of game */
    static func addEnemyAtGrid1(addIndex: Int, grid: Grid, completion: @escaping () -> Void) {
        let manager = EnemyProperty.addEnemyVEManager[GameStageController.adjustGameSceneLevel()][String(addIndex)]!
        
        let dispatchGroup1 = DispatchGroup()
        for array in manager {
            dispatchGroup1.enter()
            let dispatchGroup2 = DispatchGroup()
            let rand = Int(arc4random_uniform(UInt32(VECategory.ves[array[1]].count)))
            for _ in 1...array[0] {
                dispatchGroup2.enter()
                let veGroup = array[1]
                if !VECategory.unSFrom.contains(veGroup) {
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
                    VECategory.getUnsimplified(source: [VECategory.ves[veGroup][rand]]) { veSource in
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
    
    static func addEnemyAtGrid2(addIndex: Int, grid: Grid, completion: @escaping () -> Void) {
        let manager = EnemyProperty.addEnemyVEManager[GameStageController.adjustGameSceneLevel()][String(addIndex)]![0]
        
        getEqRobSource(veCate: manager[1], numOfEnemy: manager[0]) { source in
            let dispatchGroup = DispatchGroup()
            let veSource = source.shuffled
            for ve in veSource {
                dispatchGroup.enter()
                let enemy = Enemy(variableExpressionSource: [ve], forEdu: false)
                
                /* x position */
                let randX = Int(arc4random_uniform(UInt32(grid.startPosArray.count)))
                let startPositionX = grid.startPosArray[randX]
                /* Make sure not to overlap enemies */
                grid.startPosArray.remove(at: randX)
                
                /* y position */
                let randY = Int(arc4random_uniform(UInt32(manager[2])))
                
                /* set adding enemy movement */
                setAddEnemyMovement(enemy: enemy, posX: startPositionX, posY: 11-randY, grid: grid) {
                    dispatchGroup.leave()
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
        
        /* Add enemy to enemyArray */
        grid.enemyArray.append(enemy)
        
        /* Move enemy for startMoveDistance */
        let move = SKAction.moveTo(y: CGFloat((Double(enemy.positionY)+0.5)*grid.cellHeight), duration: startDulation)
        enemy.run(move, completion: {
            return completion()
        })
    }
}
