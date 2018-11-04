//
//  Log.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/24.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class Log: SKSpriteNode {
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func hit(completion: @escaping () -> Void) {
        move(by: -20, duration: 1.5, easeFunction: nil, easeType: nil) {
            self.move(by: 40, duration: 1.0, easeFunction: .curveTypeElastic, easeType: nil) {
                SoundController.sound(scene: self.parent as? SKScene, sound: .LogDefence)
                self.position = CGPoint(x: self.position.x, y: self.position.y-20)
                return completion()
            }
        }
    }
    
    func move(by length: CGFloat, duration: TimeInterval, easeFunction: CurveType?, easeType: EaseType?, completion: @escaping () -> Void) {
        let easeFunction = easeFunction ?? .curveTypeLinear
        let easeType = easeType ?? .easeTypeOut
        let targetPoint = CGPoint(x: self.position.x, y: self.position.y + length)
        let move = SKEase.move(easeFunction: easeFunction,
                               easeType: easeType,
                               time: duration,
                               from: self.position,
                               to: targetPoint)
        self.run(move, completion: {
            return completion()
        })
    } 
}
