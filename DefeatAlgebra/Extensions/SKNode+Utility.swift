//
//  SKSpiteNodes+Utility.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    // this only works for node which has one or no parent
    func absolutePos() -> CGPoint {
        if let parent = self.parent {
            let parentPos = parent.position
            let childPos = self.position
            return CGPoint(x: parentPos.x+childPos.x, y: parentPos.y+childPos.y)
        } else {
            return self.position
        }
    }
    
    func distance(to target: SKNode) -> CGFloat {
        let dx = self.absolutePos().x - target.absolutePos().x
        let dy = self.absolutePos().y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance
    }
    
    func distance(toPos position: CGPoint) -> CGFloat {
        let dx = self.absolutePos().x - position.x
        let dy = self.absolutePos().y - position.y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance
    }
    
    func angleDegree(with target: SKNode) -> CGFloat {
        let b = self.absolutePos()
        let a = target.absolutePos()
        var r = atan2(-b.y - -a.y, b.x - a.x)
        if r < 0 {
            r = r + 2 * .pi
        }
        let degree = floor(r * 360 / (2 * .pi))
        if degree > 180 {
            return -1 * (360-degree)
        } else {
            return degree
        }
    }
    
    func angleRadian(with target: SKNode) -> CGFloat {
        let b = self.absolutePos()
        let a = target.absolutePos()
        var r = atan2(-b.y - -a.y, b.x - a.x)
        return r
    }
    
    func angleRadian(withPos position: CGPoint) -> CGFloat {
        let b = self.absolutePos()
        let a = position
        var r = atan2(-b.y - -a.y, b.x - a.x)
        return r
    }
}
