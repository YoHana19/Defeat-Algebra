//
//  DummyEqRob.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/05.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class DummyEqRob: SKSpriteNode {
    
    var veString: String = ""
    var veLabel = SKLabelNode()
    var outPutXValue = 0
    var outPutNumValue = 0
    var xPos = 0
    var lastXPos = 0
    var distance = 0
    var eqGrid: EqGrid?
    
    init(position: CGPoint, xValue: Int, numValue: Int, ve: String, bg: EqBackground, grid: EqGrid, fromXPosOnGrid: Int, toXPosOnGrid: Int, lastPos: Int) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "eqRob")
        let size = CGSize(width: 60, height: 56)
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        outPutXValue = xValue
        outPutNumValue = numValue
        veString = ve
        xPos = toXPosOnGrid
        lastXPos = lastPos
        distance = toXPosOnGrid - fromXPosOnGrid
        self.position = position
        eqGrid = grid
        bg.addChild(self)
        
        self.zRotation = .pi * 1/2
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.name = "dummyEqRob"
        self.isHidden = true
        setLabel()
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setLabel() {
        veLabel = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel.fontSize = 30
        veLabel.text = veString
        veLabel.verticalAlignmentMode = .center
        veLabel.horizontalAlignmentMode = .center
        veLabel.position = CGPoint(x: 0, y: 0)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        veLabel.zRotation = .pi * -1/2
        veLabel.color = UIColor.red
        self.addChild(veLabel)
        addBGForVeLabel()
    }
    
    func addBGForVeLabel() {
        let veBG = SKShapeNode(rectOf: CGSize(width: veLabel.frame.height+5, height: veLabel.frame.width+5))
        veBG.fillColor = UIColor.red
        veBG.zPosition = -1
        veBG.position = CGPoint(x: 0, y: 0)
        veLabel.addChild(veBG)
    }
    
    func move(completion: @escaping () -> Void) {
        guard let eqGrid = self.eqGrid else { return }
        self.isHidden = false
        let move = SKAction.moveBy(x: CGFloat(Double(self.distance)*eqGrid.cellWidth), y: 0, duration: 1.0)
        self.run(move, completion: {
            for i in 1...self.outPutXValue {
                GridActiveAreaController.showActiveArea(at: [(self.xPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
            }
            if self.outPutNumValue > 0 {
                for i in 1...self.outPutNumValue {
                    GridActiveAreaController.showActiveArea(at: [(self.xPos, 11-self.outPutXValue-i)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            } else if self.outPutNumValue < 0 {
                for i in 1...abs(self.outPutNumValue) {
                    GridActiveAreaController.showActiveArea(at: [(self.xPos, 11-self.outPutXValue+i-1)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            }
            return completion()
        })
    }
    
    func lastMove(completion: @escaping () -> Void) {
        guard let eqGrid = self.eqGrid else { return }
        self.isHidden = false
        let move = SKAction.moveBy(x: CGFloat(Double(lastXPos-xPos)*eqGrid.cellWidth), y: 0, duration: 1.0)
        self.run(move, completion: {
            for i in 1...self.outPutXValue {
                GridActiveAreaController.showActiveArea(at: [(self.lastXPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
            }
            if self.outPutNumValue > 0 {
                for i in 1...self.outPutNumValue {
                    GridActiveAreaController.showActiveArea(at: [(self.lastXPos, 11-self.outPutXValue-i)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            } else if self.outPutNumValue < 0 {
                for i in 1...abs(self.outPutNumValue) {
                    GridActiveAreaController.showActiveArea(at: [(self.lastXPos, 11-self.outPutXValue+i-1)], color: "yellow", grid: eqGrid, zPosition: 12)
                }
            }
            return completion()
        })
    }
}
