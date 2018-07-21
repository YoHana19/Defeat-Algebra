//
//  EqRobForInstruction.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/19.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqRobForInstruction: SKSpriteNode {
    
    var veString: String = ""
    var veLabel: SKLabelNode!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "eqRob")
        let enemySize = CGSize(width: 79, height: 80)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = false
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.name = "eqRobForInstruction"
        
        setLabel()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setLabel() {
        veLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        veLabel.fontSize = 50
        veLabel.verticalAlignmentMode = .center
        veLabel.horizontalAlignmentMode = .left
        veLabel.position = CGPoint(x: 45, y: 0)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        self.addChild(veLabel)
    }
    
    func showCalculation(value: Int) {
        let numForm =  veString.replacingOccurrences(of: "x", with: String(value))
        VECategory.getCategory(ve: veString) { cate in
            let result = VECategory.calculateValue(veCategory: cate, value: value)
            self.veLabel.text = self.veString + "=" + numForm + "=" + String(result)
        }
    }
}
