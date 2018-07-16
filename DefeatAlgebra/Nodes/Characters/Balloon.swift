//
//  Balloon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Balloon: SKSpriteNode {
    
    var fontSize: CGFloat = 37
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "BalloonMulti2")
        let bodySize = CGSize(width: 504, height: 311.5)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 101
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLines(with text: String) {
        if let label = self.childNode(withName: "line") {
            label.removeFromParent()
        }
        
        let singleLineMessage = SKLabelNode(fontNamed: "GillSans-Bold")
        singleLineMessage.fontSize = fontSize
        singleLineMessage.verticalAlignmentMode = .center // Keep the origin in the center
        singleLineMessage.horizontalAlignmentMode = .left
        singleLineMessage.text = text
        
        let textLabel = singleLineMessage.multilined()
        textLabel.position = CGPoint(x: -170, y: 0)
        textLabel.name = "line"
        textLabel.zPosition = 3  // On top of all other nodes
        textLabel.fontColor = UIColor.white
        addChild(textLabel)
    }
    
}
