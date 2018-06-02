//
//  CharacterAniController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CharacterAniController {
    public static func move(character: SKSpriteNode, dest: CGPoint, duration: TimeInterval) {
        let move = SKAction.move(to: dest, duration: duration)
        character.run(move)
    }
    
    public static func SlideInToL(character: SKSpriteNode, distance: CGFloat, duration: TimeInterval) {
        let move = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        character.run(move)
    }
    
    public static func SlideInToD(character: SKSpriteNode, distance: CGFloat, duration: TimeInterval) {
        let move = SKAction.moveBy(x: 0, y: -distance, duration: duration)
        character.run(move)
    }
}
