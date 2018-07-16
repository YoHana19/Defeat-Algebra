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
    
    var moveSpeed: CGFloat = 0.002
    var rotateSpeed: CGFloat = 0.1
    var rotateForeverSpeed: TimeInterval = 3
    
    var veCategory: Int = 0
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.name = "eqRob"
        self.zPosition = 101
    }
    
    func go(to target: SKNode, completion: @escaping () -> Void) {
        self.look(at: target) {
            self.move(to: target, easeFunction: nil, easeType: nil) {
                return completion()
            }
        }
    }
    
    func go(toPos position: CGPoint, completion: @escaping () -> Void) {
        self.look(atPos: position) {
            self.move(to: position, easeFunction: nil, easeType: nil) {
                return completion()
            }
        }
    }
    
    func look(at target: SKNode, completion: @escaping () -> Void) {
        let angle = self.angleRadian(with: target)
        let rotate = SKAction.rotate(toAngle: -angle, duration: TimeInterval(rotateSpeed*abs(angle)))
        self.run(rotate, completion: {
            return completion()
        })
    }
    
    func look(atPos position: CGPoint, completion: @escaping () -> Void) {
        let angle = self.angleRadian(withPos: position)
        let rotate = SKAction.rotate(toAngle: -angle, duration: TimeInterval(rotateSpeed*abs(angle)))
        self.run(rotate, completion: {
            return completion()
        })
    }
    
    func rotateForever() {
        let oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotateForeverSpeed)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        self.run(repeatRotation)
    }
    
    func stopAction() {
        self.removeAllActions()
    }

    
    func move(to target: SKNode, easeFunction: CurveType?, easeType: EaseType?, completion: @escaping () -> Void) {
        let easeFunction = easeFunction ?? .curveTypeLinear
        let easeType = easeType ?? .easeTypeOut
        let distance = self.distance(to: target)
        let move = SKEase.move(easeFunction: easeFunction,
                    easeType: easeType,
                    time: TimeInterval(moveSpeed*distance),
                    from: self.absolutePos(),
                    to: target.absolutePos())
        //let move = SKAction.move(to: target.absolutePos(), duration: )
        self.run(move, completion: {
            return completion()
        })
    }
    
    func move(to position: CGPoint, easeFunction: CurveType?, easeType: EaseType?, completion: @escaping () -> Void) {
        let easeFunction = easeFunction ?? .curveTypeLinear
        let easeType = easeType ?? .easeTypeOut
        let distance = self.distance(toPos: position)
        print(distance)
        let move = SKEase.move(easeFunction: easeFunction,
                               easeType: easeType,
                               time: TimeInterval(moveSpeed*distance),
                               from: self.absolutePos(),
                               to: position)
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
