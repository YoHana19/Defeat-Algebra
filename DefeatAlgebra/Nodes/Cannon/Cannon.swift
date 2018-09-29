//
//  Cannon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/21.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum CannonState {
    case Ready, Pending, WillFire, Miss, Instruction, Dead, Charging
}

class Cannon: Item {
    
    let frontTexture = SKTexture(imageNamed: "cannonFront")
    let backTexture = SKTexture(imageNamed: "cannonBack")
    var variableExpressionLabel = SKLabelNode(fontNamed: "GillSans-Bold")
    var isFront = true
    var state: CannonState = .Ready
    
    var constantsArray = [Int]()
    var coefficientArray = [Int]()
    
    let bombSpan: TimeInterval = 3.0
    
    init(type: Int) {
        /* Initialize with enemy asset */
        if type == 0 {
            isFront = true
            super.init(texture: frontTexture, size: frontTexture.size())
        } else {
            isFront = false
            super.init(texture: backTexture, size: backTexture.size())
        }
        
        setName()
        setVariableExpressionLabel(type: type)
        self.zPosition = 5
        
        self.physicsBody = nil
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "cannon"
    }
    
    func setVariableExpressionLabel(type: Int) {
        /* text */
        variableExpressionLabel.text = ""
        variableExpressionLabel.fontColor = UIColor.red
        /* name */
        variableExpressionLabel.name = "variableExpressionLabel"
        /* font size */
        variableExpressionLabel.fontSize = 35
        /* zPosition */
        variableExpressionLabel.zPosition = 5
        /* position */
        if type == 0 {
            variableExpressionLabel.position = CGPoint(x:0, y: -30)
        } else {
            variableExpressionLabel.position = CGPoint(x:0, y: 30)
        }
        /* Add to Scene */
        self.addChild(variableExpressionLabel)
    }
    
    func setInputVE(value: String) {
        variableExpressionLabel.text = value
    }
    
    func resetInputVE() {
        variableExpressionLabel.text = ""
    }
    
    /* Calculate the distance to throw bomb */
    func calculateValue(value: Int) -> Int {
        var outPut = 0
        for constant in constantsArray {
            outPut += constant
        }
        for coeffcient in coefficientArray {
            outPut += coeffcient*value
        }
        print("x: \(value), value: \(outPut), ve: \(variableExpressionLabel.text)")
        return outPut
    }
    
    func resetVEElementArray() {
        constantsArray.removeAll()
        coefficientArray.removeAll()
    }
    
}

// Throw bomb Animation
extension Cannon {
    func throwBomb(value: Int, completion: @escaping () -> Void) {
        bombFlying(xValue: value) { bomb in
            self.bombExplode(bomb: bomb) {
                self.hitEnemy(xValue: value) {
                    self.resetInputVE()
                    self.resetVEElementArray()
                    return completion()
                }
            }
        }
    }
    
    func bombFlying(xValue: Int, completion: @escaping (SKNode) -> Void) {
        guard let gridNode = self.parent as? Grid else { return }
        let value = calculateValue(value: xValue)
        
        /* Create bomb */
        let bomb = SKSpriteNode(imageNamed: "cannonBomb")
        bomb.size = CGSize(width: 10, height: 10)
        bomb.zPosition = 10
        bomb.position = CGPoint(x: 0, y: 0)
        self.addChild(bomb)
        
        var distance = CGFloat(Double(value) * gridNode.cellHeight)
        if isFront {
            distance = -1 * distance
        }
        
        let throwStone = SKAction.moveBy(x: 0, y: distance, duration: self.bombSpan)
        let scale1 = SKAction.scale(by: 7.0, duration: self.bombSpan/2)
        let scale2 = SKAction.scale(by: 0.5, duration: self.bombSpan/2)
        let seq = SKAction.sequence([scale1, scale2])
        let group = SKAction.group([throwStone, seq])
        bomb.run(group, completion: {
            return completion(bomb)
        })
    }
    
    func bombExplode(bomb: SKNode, completion: @escaping () -> Void) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "TimeBombExplode")!
        particles.position = CGPoint(x: 0, y: 0)
        particles.zPosition = 10
        particles.setScale(1/3)
        /* Add particles to scene */
        bomb.addChild(particles)
        let waitEffectRemove = SKAction.wait(forDuration: 1.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitEffectRemove, removeParticles])
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let dead = SKAction.playSoundFileNamed("catapultBomb.mp3", waitForCompletion: true)
            bomb.run(dead)
        }
        particles.run(seqEffect, completion: {
            bomb.removeFromParent()
            return completion()
        })
    }
    
    func hitEnemy(xValue: Int, completion: @escaping () -> Void) {
        guard let gridNode = self.parent as? Grid else { return }
        guard let gameScene = gridNode.parent as? GameScene else { return }
        let value = calculateValue(value: xValue)
        let xPos = spotPos[0]
        let yPos = spotPos[1]
        if isFront {
            if yPos-value < 0 {
                return completion()
            } else {
                let dispatchGroup = DispatchGroup()
                let hitPos = [xPos, yPos-value]
                /* Look for the enemy to destroy */
                for enemy in gridNode.enemyArray {
                    dispatchGroup.enter()
                    if enemy.positionX == hitPos[0] && enemy.positionY == hitPos[1] {
                        EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene) {
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    return completion()
                })
            }
        } else {
            if yPos+value > gridNode.rows-1 {
                return completion()
            } else {
                let dispatchGroup = DispatchGroup()
                let hitPos = [xPos, yPos-value]
                /* Look for the enemy to destroy */
                for enemy in gridNode.enemyArray {
                    dispatchGroup.enter()
                    if enemy.positionX == hitPos[0] && enemy.positionY == hitPos[1] {
                        EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene) {
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    return completion()
                })
            }
        }
    }
    
    /*
    func detectHighestCatapultValue() {
        for catapult in setCatapultArray {
            let catapultValue = catapult.calculateCatapultValue()
            if highestCatapultValue < catapultValue {
                highestCatapultValue = catapultValue
            }
        }
    }
    
    /* Check within grid for catapult */
    func checkWithinGrid() -> (Int, Int, Int, Int) {
        /* Calculate hit spots */
        /* Make sure hit spots within grid */
        if hero.positionX == 0 {
            let hitSpotXLeft = 0
            let hitSpotXRight = hero.positionX+1
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else if hero.positionX == 8 {
            let hitSpotXLeft = hero.positionX-1
            let hitSpotXRight = 8
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        } else {
            let hitSpotXLeft = hero.positionX-1
            let hitSpotXRight = hero.positionX+1
            if hero.positionY == 0 {
                let hitSpotYDown = 0
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else if hero.positionX == 8 {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = 11
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            } else {
                let hitSpotYDown = hero.positionY-1
                let hitSpotYUp = hero.positionY+1
                return (hitSpotXLeft, hitSpotXRight, hitSpotYDown, hitSpotYUp)
            }
        }
    }
    */
}
