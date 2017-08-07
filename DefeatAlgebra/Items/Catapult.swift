//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Catapult: SKSpriteNode {
    
    var numOfTurn = 3
    var constantsArray = [Int]()
    var coefficientArray = [Int]()
    var activeFlag = true
    var xPos: Int = 0
    var variableExpression: String = ""
    var spotPos = [Int]()
    
    init() {
        /* Initialize with 'mine' asset */
        let texture = SKTexture(imageNamed: "catapult")
        let bodySize = CGSize(width: 60, height: 60)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 2
        
        /* Set anchor point to center */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.categoryBitMask = 64
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        /* For detect what object to tougch */
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "catapult"
    }
    
    /* Calculate the distance to throw bomb */
    func calculateCatapultValue() -> Int {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        var outPut = 0
        for constant in constantsArray {
            outPut += constant
        }
        for coeffcient in coefficientArray {
            outPut += coeffcient*gameScene.xValue
        }
        return outPut
    }
    
    func resetVEElementArray() {
        constantsArray.removeAll()
        coefficientArray.removeAll()
    }
    
    func setCatapultVELabel(vE: String) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        /* Set text */
        label.text = vE
        /* Set font size */
        label.fontSize = 30
        /* Set font color */
        label.fontColor = UIColor.white
        /* Set zPosition */
        label.zPosition = 10
        /* Set position */
        label.position = CGPoint(x: 0, y: -38)
        /* Add to Scene */
        addChild(label)

    }
    
    func setCatapultBase() {
        let catapultBase = SKSpriteNode(imageNamed: "catapultBase")
        catapultBase.name = "catapultBase"
        catapultBase.zPosition = -1
        catapultBase.position = CGPoint(x: 0, y: -22)
        addChild(catapultBase)
    }
    
    func makeTriangle() {
        /* length of one side */
        let length: CGFloat = 15
        
        /* Set 4 points from start point to end point */
        var points = [CGPoint(x: 0.0, y: -length),
                      CGPoint(x: -length, y: length / 2.0),
                      CGPoint(x: length, y: length / 2.0),
                      CGPoint(x: 0.0, y: -length)]
        
        /* Make triangle */
        let triangle = SKShapeNode(points: &points, count: points.count)
        
        /* Set triangle position */
        triangle.position = CGPoint(x: 0, y: 45)
        triangle.zPosition = 3
        
        
        /* Colorlize triangle to red */
        triangle.fillColor = UIColor.red
        triangle.strokeColor = UIColor.red
        
        triangle.name = "pointingCatapult"
        self.addChild(triangle)
    }
}
