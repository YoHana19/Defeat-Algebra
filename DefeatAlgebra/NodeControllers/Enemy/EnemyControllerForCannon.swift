//
//  EnemyControllerForCannon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension Enemy {
    
    func calculatePunchLengthForCannon(value: Int) {
        /* Calculate value of variable expression of enemy */
        self.valueOfEnemy = VECategory.calculateValue(veCategory: self.vECategory, value: value)
        /* Calculate length of punch */
        self.punchLength = self.firstPunchLength + CGFloat(self.valueOfEnemy-1) * self.singlePunchLength
    }
    
    public func punchAndMoveForCannon(completion: @escaping () -> Void) {
        /* Do punch */
        punch() { armAndFist in
            self.subSetArm(arms: armAndFist.arm) { (newArms) in
                for arm in armAndFist.arm {
                    arm.removeFromParent()
                }
                self.drawPunchNMove(arms: newArms, fists: armAndFist.fist, num: self.valueOfEnemy) {
                    /* Keep track enemy position */
                    self.cannonPosY -= self.valueOfEnemy
                    self.removeArmNFist()
                    self.setMovingAnimation()
                    return completion()
                }
            }
        }
    }
    
    public func hit(completion: @escaping () -> Void) {
        /* Effect */
        enemyDestroyEffect() {
            self.isHidden = true
            return completion()
        }
    }
    
    public func enemyDestroyEffect(completion: @escaping () -> Void) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "DestroyEnemy")!
        particles.position = CGPoint(x: self.position.x, y: self.position.y-20)
        particles.zPosition = 12
        /* Add particles to scene */
        self.parent!.addChild(particles)
        let waitEffectRemove = SKAction.wait(forDuration: 1.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitEffectRemove, removeParticles])
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let dead = SKAction.playSoundFileNamed("enemyKilled.mp3", waitForCompletion: true)
            self.parent!.run(dead)
        }
        particles.run(seqEffect, completion: {
            return completion()
        })
    }
}
