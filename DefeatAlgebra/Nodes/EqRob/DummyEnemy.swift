//
//  SelectedEnemy.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class DummyEnemy: Enemy {
    
    var outPutXValue = 0
    var outPutNumValue = 0
    var xPos = 0
    var lastXPos = 0
    var distance = 0
    var eqGrid: EqGrid?
    
    init(position: CGPoint, xValue: Int, numValue: Int, ve: String, bg: EqBackground, grid: EqGrid, fromXPosOnGrid: Int, toXPosOnGrid: Int, lastPos: Int) {
        /* Initialize with enemy asset */
        super.init(ve: ve)
        let enemySize = CGSize(width: 60, height: 60)
        self.size = enemySize
        
        outPutXValue = xValue
        outPutNumValue = numValue
        xPos = toXPosOnGrid
        lastXPos = lastPos
        distance = toXPosOnGrid - fromXPosOnGrid
        self.position = position
        eqGrid = grid
        bg.addChild(self)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.name = "dummyEnemy"
        self.isHidden = true
        adjustLabelSize()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setLabel() {
        let veLabel = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel.fontSize = 30
        veLabel.verticalAlignmentMode = .center
        veLabel.horizontalAlignmentMode = .center
        veLabel.position = CGPoint(x: 0, y: 50)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        self.addChild(veLabel)
    }
    
    func move(completion: @escaping () -> Void) {
        guard let eqGrid = self.eqGrid else { return }
        VEEquivalentController.resetEcessArea(posX: VEEquivalentController.curActivePos.0)
        self.isHidden = false
        let move = SKAction.moveBy(x: CGFloat(Double(self.distance)*eqGrid.cellWidth), y: 0, duration: 1.0)
        self.run(move, completion: {
            if self.outPutXValue > 11 {
                VEEquivalentController.showEcessArea(yValue: self.outPutXValue, posX: self.xPos)
                for i in 1...11 {
                    GridActiveAreaController.showActiveArea(at: [(self.xPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
                }
            } else {
                for i in 1...self.outPutXValue {
                    GridActiveAreaController.showActiveArea(at: [(self.xPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
                }
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
            self.punchLength = CGFloat(self.outPutXValue+self.outPutNumValue) * CGFloat(self.gameScene.gridNode.cellHeight)
            /* Do punch */
            self.punch() { armAndFist in
                self.subSetArm(arms: armAndFist.arm) { (newArms) in
                    for arm in armAndFist.arm {
                        arm.removeFromParent()
                    }
                    return completion()
                }
            }
        })
    }
    
    func lastMove(completion: @escaping () -> Void) {
        guard let eqGrid = self.eqGrid else { return }
        VEEquivalentController.resetEcessArea(posX: xPos)
        self.isHidden = false
        let move = SKAction.moveBy(x: CGFloat(Double(lastXPos-xPos)*eqGrid.cellWidth), y: 0, duration: 1.0)
        self.run(move, completion: {
            if self.outPutXValue > 11 {
                VEEquivalentController.showEcessArea(yValue: self.outPutXValue, posX: self.lastXPos)
                for i in 1...11 {
                    GridActiveAreaController.showActiveArea(at: [(self.lastXPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
                }
            } else {
                for i in 1...self.outPutXValue {
                    GridActiveAreaController.showActiveArea(at: [(self.lastXPos, 11-i)], color: "red", grid: eqGrid, zPosition: 12)
                }
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
    
    override func adjustLabelSize() {
        guard let grid = self.eqGrid else { return }
        let cellWidth = CGFloat(grid.cellWidth)
        if variableExpressionLabel.frame.width > cellWidth {
            let scaleFactor = cellWidth / variableExpressionLabel.frame.width
            variableExpressionLabel.fontSize *= scaleFactor
        }
    }
}
