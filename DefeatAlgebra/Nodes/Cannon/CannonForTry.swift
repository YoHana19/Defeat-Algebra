//
//  CannonForTry.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/06.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension Cannon {
    func throwBombForTry(enemy: Enemy, value: Int, completion: @escaping (Int) -> Void) {
        bombFlying(xValue: value) { bomb in
            self.bombExplode(bomb: bomb) {
                self.hitEnemyForTry(enemy: enemy, xValue: value) { result in
                    return completion(result)
                }
            }
        }
    }
    
    func hitEnemyForTry(enemy: Enemy, xValue: Int, completion: @escaping (Int) -> Void) {
        let value = calculateValue(value: xValue)
        let yPos = spotPos[1]
        
        if yPos-value < 0 {
            return completion(0)
        } else {
            let hitPosY = yPos-value
            if enemy.cannonPosY == hitPosY {
                enemy.hit {
                    return completion(1)
                }
            } else {
                return completion(2)
            }
        }
    }
}
