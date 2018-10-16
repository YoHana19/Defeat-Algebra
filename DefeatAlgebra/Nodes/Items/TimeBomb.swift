//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class TimeBomb: Item {
    
    let tx = SKTexture(imageNamed: "timeBomb")
    let bodySize = CGSize(width: 60, height: 60)
    var setPos: (Int, Int)!
    
    init(pos: (Int, Int)) {
        setPos = pos
        /* Initialize with 'mine' asset */
        super.init(texture: tx, size: bodySize)
        
        /* For detect what object to tougch */
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "timeBomb"
    }
    
    public func explode(completion: @escaping () -> Void) {
        guard let grid = self.parent as? Grid else { return }
        guard let gameScene = grid.parent as? GameScene else { return }
        for enemy in grid.enemyArray {
            /* Hit enemy! */
            if enemy.positionX == setPos.0 && enemy.positionY == setPos.1 {
                DataController.countForEnemyKilledByTimeBomb(enemy: enemy)
                EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene) {}
            }
        }
        timeBombEffect(gameScene: gameScene) {
            return completion()
        }
    }
    
    func timeBombEffect(gameScene: GameScene, completion: @escaping () -> Void) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "TimeBombExplode")!
        let particles2 = SKEmitterNode(fileNamed: "TimeBombSmoke")!
        particles.position = CGPoint(x: 0, y: 0)
        particles2.position = self.absolutePos()
        /* Add particles to scene */
        self.addChild(particles)
        gameScene.addChild(particles2)
        let waitRemoveExplode = SKAction.wait(forDuration: 0.5)
        let waitRemoveSmoke = SKAction.wait(forDuration: 3.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitRemoveExplode, removeParticles])
        let seqEffect2 = SKAction.sequence([waitRemoveSmoke, removeParticles])
        particles.run(seqEffect, completion: {
            self.removeFromParent()
        })
        particles2.run(seqEffect2, completion: {     
            return completion()
        })
    }
}
