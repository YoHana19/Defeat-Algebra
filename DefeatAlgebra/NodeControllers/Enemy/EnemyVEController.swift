//
//  EnemyVEController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyVEController {
    static func setVariableExpression(enemy: Enemy, vESource: [String]) {
        let rand = arc4random_uniform(UInt32(vESource.count))
        enemy.variableExpressionString = vESource[Int(rand)]
    }
    
    static func rewriteVariableExpression(enemy: Enemy, vEString: String, completion: @escaping (String) -> Void) {
        enemy.variableExpressionString = vEString
        completion(vEString)
    }
}
