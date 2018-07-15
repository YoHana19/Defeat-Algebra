//
//  Balloon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Balloon: SKSpriteNode {
    
    var textLabel = SKLabelNode(fontNamed: "GillSans-Bold")
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "BalloonMulti2")
        let bodySize = CGSize(width: 504, height: 311.5)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 101
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setTextLabel()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setTextLabel() {
        textLabel.fontSize = 20
        textLabel.position = CGPoint(x: 0, y: 0)
        textLabel.zPosition = 3
        textLabel.fontColor = UIColor.red
        textLabel.text = "あああああああああああ"
        self.addChild(textLabel)
    }
    
}
