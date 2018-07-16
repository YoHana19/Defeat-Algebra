//
//  Line.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

//物理世界に影響される線を引くクラスです。
class Line: SKShapeNode {
    
    var line: SKShapeNode
    var sPoint: CGPoint
    var ePoint: CGPoint
    var points: [CGPoint]
    
    init(startPoint: CGPoint, endPoint: CGPoint, color: UIColor = UIColor.yellow, width: CGFloat = 10) {
        let path: UIBezierPath = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        points = [startPoint,endPoint]
        line = SKShapeNode(points: &points, count: points.count)
        
        sPoint = startPoint
        ePoint = endPoint
        
        //ここで一回初期化してしまう
        super.init()
        
        //パスに追加することで線が引けた。
        self.path = path.cgPath
        self.lineWidth = width
        self.strokeColor = color
        
        self.zPosition = 100
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
