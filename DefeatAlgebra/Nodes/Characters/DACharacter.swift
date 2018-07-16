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
    
    var moveSpan: TimeInterval = 0.5
    var balloon = Balloon()
    
    init(charaTexture: SKTexture, charaSize: CGSize) {
        /* Initialize with enemy asset */
        super.init(texture: charaTexture, color: UIColor.clear, size: charaSize)
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 101
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
    
    func move(from oldPos: CGPoint?, to newPos: CGPoint) {
        self.position = oldPos ?? self.position
        let move = SKAction.move(to: newPos, duration: moveSpan)
        self.run(move)
    }
    
    func shake() {
        if let shake: SKAction = SKAction.init(named: "Shake") {
            self.run(shake)
        }
    }
}
