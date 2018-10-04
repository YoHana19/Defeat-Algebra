//
//  ShowLength.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/09/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ShowLength: SKLabelNode {
    
    init(pos: CGPoint, text: String, arrowHeight: CGFloat?) {
        super.init(fontNamed: DAFont.fontName)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 12
        
        /* Set text */
        self.text = text
        /* Set font size */
        self.fontSize = 40
        self.position = pos
        self.verticalAlignmentMode = .center
        
        setArrow(height: arrowHeight)
        
        self.name = "showLength"
    }
    
    init(grid: Grid, gridAt: (Int, Double), text: String, arrowHeight: CGFloat?) {
        super.init(fontNamed: DAFont.fontName)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 12
        self.verticalAlignmentMode = .center
        
        /* Set text */
        self.text = text
        /* Set font size */
        self.fontSize = 40
        let xPos = (Double(gridAt.0)+1/2) * grid.cellWidth
        let yPos = gridAt.1 * grid.cellHeight
        self.position = CGPoint(x: xPos, y: yPos)
        grid.addChild(self)
        
        setArrow(height: arrowHeight)
        
        self.name = "showLength"
    }
    
    override init() {
        super.init()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setArrow(height: CGFloat?) {
        let down = LengthArrow(height: height)
        let up = LengthArrow(height: height)
        up.zRotation = .pi
        down.position = CGPoint(x: 0, y: -35)
        up.position = CGPoint(x: 0, y: 35)
        addChild(down)
        addChild(up)
    }
}
