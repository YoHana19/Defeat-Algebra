//
//  EqRob.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqRob: SKSpriteNode {
    
    var moveSpeed: CGFloat = 0.006
    var rotateSpeed: CGFloat = 0.1
    
    var veCategory: Int = 0
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.name = "eqRob"
    }
    
    func go(to target: Enemy) {
        self.look(at: target) {
            self.move(to: target) {}
        }
    }
    
    func look(at target: Enemy, completion: @escaping () -> Void) {
        let angle = self.angleRadian(with: target)
        let rotate = SKAction.rotate(toAngle: -angle, duration: TimeInterval(rotateSpeed*abs(angle)))
        self.run(rotate, completion: {
            return completion()
        })
    }

    
    func move(to target: Enemy, completion: @escaping () -> Void) {
        let distance = self.distance(to: target)
        let move = SKEase.move(easeFunction: .curveTypeBounce,
                    easeType: .easeTypeOut,
                    time: TimeInterval(moveSpeed*distance),
                    from: self.absolutePos(),
                    to: target.absolutePos())
        //let move = SKAction.move(to: target.absolutePos(), duration: )
        self.run(move, completion: {
            return completion()
        })
    }
    
    func kill(_ target: Enemy, completion: @escaping () -> Void) {
        self.detect(target) { completion in
            if completion {
                target.removeFromParent()
            } else {
                self.isHidden = true
            }
        }
    }
    
    func detect(_ target: Enemy, completion: @escaping (Bool) -> Void) {
        if self.veCategory == target.vECategory {
            return completion(true)
        } else {
            return completion(false)
        }
    }
}
