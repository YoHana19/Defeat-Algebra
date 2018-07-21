//
//  DACharacter.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class DACharacter: SKSpriteNode {
    
    static let moveSpan: TimeInterval = 0.5
    var balloon = Balloon()
    
    init(charaTexture: SKTexture, charaSize: CGSize) {
        /* Initialize with enemy asset */
        super.init(texture: charaTexture, color: UIColor.clear, size: charaSize)
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 20
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(balloon)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPos(pos: CGPoint) {
        self.position = pos
    }
    
    func moveWithScaling(to: CGPoint, value: CGFloat, duration: TimeInterval = DACharacter.moveSpan, completion: @escaping () -> Void) {
        scale(value: value, duration: duration)
        move(from: nil, to: to, duration: duration)
        let wait = SKAction.wait(forDuration: duration)
        self.run(wait, completion: {
            return completion()
        })
    }
    
    func move(from oldPos: CGPoint?, to newPos: CGPoint, duration: TimeInterval = DACharacter.moveSpan) {
        self.position = oldPos ?? self.position
        let move = SKAction.move(to: newPos, duration: duration)
        self.run(move)
    }
    
    func scale(value: CGFloat, duration: TimeInterval = DACharacter.moveSpan) {
        let scale = SKAction.scale(to: value, duration: duration)
        self.run(scale)
    }
    
    func shake() {
        if let shake: SKAction = SKAction.init(named: "Shake") {
            self.run(shake)
        }
    }
}
