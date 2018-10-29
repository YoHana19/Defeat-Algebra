//
//  EnemyAttackController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension Enemy {
    /* Calculate punch length */
    func calculatePunchLength(value: Int) {
        if self.positionY == 0 {
            self.punchLength = CGFloat(gameScene.gridNode.cellHeight/2) + gameScene.bottomGap + 5
        } else {
            /* Calculate value of variable expression of enemy */
            self.valueOfEnemy = VECategory.calculateValue(veCategory: self.vECategory, value: value)
            
            if self.positionY < self.valueOfEnemy {
                /* punch length to castle */
                self.punchLength  = (CGFloat(self.positionY)+0.5)*CGFloat(gridNode.cellHeight)+gameScene.bottomGap + 5
            } else {
                /* Calculate length of punch */
                self.punchLength = CGFloat(self.valueOfEnemy) * CGFloat(gridNode.cellHeight)
            }
        }
    }
    
    /* Enemy punch and move to the position of fist */
    public func punchAndMove() {
        
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        /* Enemy punch beyond edge of grid */
        if self.positionY < self.valueOfEnemy {
            /* Do punch */
            punch() { armAndFist in
                /* Decrese life */
                self.gameScene.life -= 1
                self.gameScene.setLife(numOflife: self.gameScene.life)
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("castleWallHit.mp3", waitForCompletion: true)
                    self.gameScene.run(sound)
                }
                
                self.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    self.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: self.positionY) {
                        /* Set enemy position to edge */
                        self.positionY = 0
                        self.turnEnd()
                    }
                }
            }
        } else {
            /* Do punch */
            punch() { armAndFist in
                self.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    self.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: self.valueOfEnemy) {
                        /* Keep track enemy position */
                        self.positionY -= self.valueOfEnemy
                        self.turnEnd()
                    }
                }
            }
        }
    }
    
    /* Do punch */
    func punch(completion: @escaping ((arm: [EnemyArm], fist: [EnemyFist])) -> Void) {
        /* Make sure enemy punch front direction */
        self.direction = .front
        
        /* Stop animation of enemy */
        self.removeAllActions()
        
        /* Set texture according to direction of enemy */
        self.setTextureInPunch()
        
        /* Set arm */
        let arm1 = EnemyArm(direction: self.direction)
        let arm2 = EnemyArm(direction: self.direction)
        setArm(arm: [arm1, arm2])
        
        /* Set fist */
        let fist1 = EnemyFist(direction: self.direction)
        let fist2 = EnemyFist(direction: self.direction)
        setFist(fist: [fist1, fist2])
        
        /* Move Fist */
        fist1.moveFistForward(length: punchLength, speed: self.punchSpeed)
        fist2.moveFistForward(length: punchLength, speed: self.punchSpeed)
        
        /* Extend arm */
        arm1.extendArm(length: punchLength, speed: self.punchSpeed)
        arm2.extendArm(length: punchLength, speed: self.punchSpeed)
        
        /* Store reference for func drawPunch */
        let wait = SKAction.wait(forDuration: TimeInterval(punchLength*punchSpeed))
        self.run(wait, completion: {
            return completion(([arm1, arm2], [fist1, fist2]))
        })
    }
    
    /* Set texture in punching */
    func setTextureInPunch() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "frontPunch")
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
    func setArm(arm: [EnemyArm]) {
        let armPos1 = CGPoint(x: -18, y: 5)
        let armPos2 = CGPoint(x: 18, y: 5)
        arm[0].position = armPos1
        arm[1].position = armPos2
        
        /* Add arm as enemy child */
        addChild(arm[0])
        addChild(arm[1])
    }
    
    /* Set position of fist */
    func setFist(fist: [EnemyFist]) {
        let fistPos1 = CGPoint(x: -20, y: 5)
        let fistPos2 = CGPoint(x: 19, y: 5)
        fist[0].position = fistPos1
        fist[1].position = fistPos2
        fist[1].texture = SKTexture(imageNamed: "frontFistLeft")
    
        /* Add arm as enemy child */
        addChild(fist[0])
        addChild(fist[1])
    }
    
    func subSetArm(arms: [EnemyArm], competion: @escaping ([EnemyArm]) -> Void) {
        let dispatchgroup = DispatchGroup()
        var newArms = [EnemyArm]()
        for arm in arms {
            dispatchgroup.enter()
            let size = arm.size
            let posX = arm.position.x
            let posY = arm.position.y-size.height
            let newArm = EnemyArm(direction: self.direction)
            newArm.yScale = (size.height)/newArm.size.height
            newArm.position = CGPoint(x: posX, y: posY)
            newArm.anchorPoint = CGPoint(x: 0.5, y: 1)
            newArm.physicsBody = nil
            newArms.append(newArm)
            self.addChild(newArm)
            dispatchgroup.leave()
        }
        dispatchgroup.notify(queue: .main, execute: {
            return competion(newArms)
        })
    }
    
    func drawPunchNMove(arms: [EnemyArm], fists: [EnemyFist], num: Int, completion: @escaping () -> Void) {
        let duration = TimeInterval(self.punchLength*self.punchSpeed)
        let moveLength = CGFloat(num)*CGFloat(gridNode.cellHeight)
        let durationForBody = TimeInterval(moveLength*self.punchSpeed)
        for arm in arms {
            let moveArm = SKAction.moveBy(x: 0, y: self.punchLength, duration:
                duration)
            let shrinkArm = SKAction.scaleY(to: 1/arm.yScale, duration: duration)
            let group = SKAction.group([moveArm, shrinkArm])
            arm.run(group)
        }
        for fist in fists {
            let moveFist = SKAction.moveBy(x: 0, y: self.punchLength, duration: duration)
            fist.run(moveFist)
        }
        let moveBody = SKAction.moveBy(x: 0, y: -moveLength, duration: durationForBody)
        
        self.run(moveBody, completion: {
            return completion()
        })
    }
    
    func turnEnd() {
        removeArmNFist()
        
        self.setMovingAnimation()
        self.myTurnFlag = false
        if self.positionY > 0 {
            /* Reset count down punchInterval */
            self.punchIntervalForCount = self.punchInterval
        }
        
        if self.gridNode.turnIndex < self.gridNode.enemyArray.count-1 {
            self.gridNode.turnIndex += 1
            self.gridNode.enemyArray[self.gridNode.turnIndex].myTurnFlag = true
        }
        
        /* To check all enemy turn done */
        self.gridNode.numOfTurnEndEnemy += 1
        
        self.gameScene.hitCastleWallSoundDone = false
        
        self.xValueLabel.text = ""
    }
    
    public func removeArmNFist() {
        for child in self.children {
            if child.name == "arm" || child.name == "fist" {
                child.removeFromParent()
            }
        }
    }
    
    /* Punch when enemy reach to castle */
    public func punchToCastle() {
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        
        self.punch() { armAndFist in
            /* Decrese life */
            self.gameScene.life -= 1
            self.gameScene.setLife(numOflife: self.gameScene.life)
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("castleWallHit.mp3", waitForCompletion: true)
                self.gameScene.run(sound)
            }
            
            self.drawPunch(arms: armAndFist.arm, fists: armAndFist.fist) {
                self.turnEnd()
            }
        }
    }
    
    func drawPunch(arms: [EnemyArm], fists: [EnemyFist], completion: @escaping () -> Void) {
        for arm in arms {
            arm.ShrinkArm(length: self.punchLength, speed: self.punchSpeed)
        }
        if arms.count > 0 {
            for fist in fists {
                fist.moveFistBackward(length: arms[0].size.height, speed: self.punchSpeed)
            }
        }
        let wait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed))
        self.run(wait, completion: {
            return completion()
        })
    }
    
    private func getArmsNFists(completion: @escaping (([EnemyArm], [EnemyFist])) -> Void) {
        let dispatchGroup = DispatchGroup()
        var arms = [EnemyArm]()
        var fists = [EnemyFist]()
        for child in self.children {
            dispatchGroup.enter()
            if child.name == "arm" {
                arms.append(child as! EnemyArm)
            } else if child.name == "fist" {
                fists.append(child as! EnemyFist)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion((arms, fists))
        })
    }
}
