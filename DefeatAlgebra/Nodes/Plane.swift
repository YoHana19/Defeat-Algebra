//
//  Plane.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class Plane: SKSpriteNode {
    
    let initialPos = CGPoint(x: -200, y: 800)
    let endPos = CGPoint(x: 1000, y: 800)
    let flyingTime = 3.0
    
    init(gameScene: GameScene) {
        /* Initialize with 'mine' asset */
        let texture = SKTexture(imageNamed: "planeG")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 12
        
        /* Set anchor point to center */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //self.setScale(3.0)
        self.position = initialPos
        self.isHidden = true
        gameScene.addChild(self)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func fly(items: [(Int, Int, Int)], completion: @escaping () -> Void) {
        self.isHidden = false
        let move = SKEase.move(easeFunction: .curveTypeLinear,
                               easeType: .easeTypeOut,
                               time: flyingTime,
                               from: self.position,
                               to: endPos)
        self.run(move, completion: {
            self.isHidden = true
            self.position = self.initialPos
            return completion()
        })
        
        let wait = SKAction.wait(forDuration: flyingTime/2)
        self.run(wait, completion: {
            self.dropItems(items: items)
        })
    }
    
    func dropItems(items: [(Int, Int, Int)]) {
        items.forEach { self.dropItem(item: ItemType(rawValue: $0.0)!, pos: ($0.1, $0.2)) }
    }
    
    func dropItem(item: ItemType, pos: (Int, Int)) {
        if let gameScene = self.parent as? GameScene {
            switch item {
            case .timeBomb:
                let object = TimeBomb()
                gameScene.gridNode.addObjectAtGrid(object: object, x: pos.0, y: pos.1)
                break;
            case .Boots:
                let object = Boots()
                gameScene.gridNode.addObjectAtGrid(object: object, x: pos.0, y: pos.1)
                break;
            case .Heart:
                let object = Heart()
                gameScene.gridNode.addObjectAtGrid(object: object, x: pos.0, y: pos.1)
                break;
            case .Wall:
                let object = Wall()
                gameScene.gridNode.addObjectAtGrid(object: object, x: pos.0, y: pos.1)
                break;
            case .Cane:
                let object = Cane()
                gameScene.gridNode.addObjectAtGrid(object: object, x: pos.0, y: pos.1)
                break;
            default:
                break;
            }
        }
    }
    
}
