//
//  EnemyVEController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

class EnemyVEController {
    static func setVariableExpression(enemy: EnemyEasy, variableExpressionSource: [[Int]]) {
        let rand = arc4random_uniform(UInt32(variableExpressionSource.count))
        enemy.variableExpression = variableExpressionSource[Int(rand)]
        /* Set equivalence ve */
        enemy.vECategory = enemy.variableExpression.last!
        getVELabel(vE: enemy.variableExpression) { label in
            enemy.variableExpressionForLabel = label
        }
    }
    
    private static func getVELabel(vE: [Int], completion: @escaping (String) -> Void) {
        if let index = EnemyProperty.simplifiedVariableExpressionSource[GameSceneEasy.stageLevel].index(where: {$0 == vE}) {
            let label = EnemyProperty.simplifiedVariableExpressionLabelSource[GameSceneEasy.stageLevel][index]
            return completion(label)
        } else if let index = EnemyProperty.unSimplifiedVariableExpressionSource[GameSceneEasy.stageLevel].index(where: {$0 == vE}) {
            let label = EnemyProperty.unSimplifiedVariableExpressionLabelSource[GameSceneEasy.stageLevel][index]
            return completion(label)
        } else {
            print("somthing wrong in EnemyVEController.getVELabel")
        }
    }
}
