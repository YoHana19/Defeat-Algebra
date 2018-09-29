//
//  VeLength.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class VeLength: SKSpriteNode {
    
    init(grid: Grid, xPos: Int, yPos: Int, ve: String, height: CGFloat? = nil) {
        /* Initialize with 'mine' asset */
        let texture = SKTexture(imageNamed: "veLength")
        if let h = height {
            let bodySize = CGSize(width: texture.size().width, height: h)
            super.init(texture: texture, color: UIColor.clear, size: bodySize)
        } else {
            super.init(texture: texture, color: UIColor.clear, size: texture.size())
        }
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 12
        
        /* Set anchor point to center */
        anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let x = (Double(xPos) + 1/2) * grid.cellWidth
        let y = Double(yPos+1) * grid.cellHeight
        self.position = CGPoint(x: x, y: y)
        
        self.name = "veLength"
        setShowLength(grid: grid, ve: ve, arrowHeight: self.size.height/2-40)
        
        grid.addChild(self)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setShowLength(grid: Grid, ve: String, arrowHeight: CGFloat?) {
        let showLength = ShowLength(pos: CGPoint(x: CGFloat(grid.cellWidth), y: -self.size.height/2), text: ve, arrowHeight: arrowHeight)
        addChild(showLength)
    }
}
