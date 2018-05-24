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
    static func setVariableExpression(enemy: Enemy, variableExpressionSource: [[Int]], success: @escaping (Bool) -> Void) {
        let rand = arc4random_uniform(UInt32(variableExpressionSource.count))
        enemy.variableExpression = variableExpressionSource[Int(rand)]
        /* Set equivalence ve */
        enemy.vECategory = enemy.variableExpression.last!
        getVELabel(vE: enemy.variableExpression) { label in
            enemy.variableExpressionString = label
            EnemyVEController.setVariableExpressionLabel(enemy: enemy, vEString: label) { label in
                enemy.setVariableExpressionLabel(text: label)
                success(true)
            }
        }
    }
    
    private static func getVELabel(vE: [Int], completion: @escaping (String) -> Void) {
        if let index = EnemyProperty.simplifiedVariableExpressionSource[GameScene.stageLevel].index(where: {$0 == vE}) {
            let label = EnemyProperty.simplifiedVariableExpressionLabelSource[GameScene.stageLevel][index]
            return completion(label)
        } else if let index = EnemyProperty.unSimplifiedVariableExpressionSource[GameScene.stageLevel].index(where: {$0 == vE}) {
            let label = EnemyProperty.unSimplifiedVariableExpressionLabelSource[GameScene.stageLevel][index]
            return completion(label)
        } else {
            print("somthing wrong in EnemyVEController.getVELabel")
        }
    }
    
    static func setVariableExpressionLabel(enemy: Enemy, vEString: String, completion: @escaping (String) -> Void) {
        if vEString.count > 4 {
            getShortVELabel(vEString: vEString) { label in
                enemy.variableExpressionForLabel = label
                completion(label)
            }
        } else {
            enemy.variableExpressionForLabel = vEString
            completion(vEString)
        }
    }
    
    private static func getShortVELabel(vEString: String, completion: @escaping (String) -> Void) {
        guard vEString.count > 4 else { return completion("") }
        var label = ""
        var i = 0
        let dispatchGroup = DispatchGroup()
        for s in vEString {
            dispatchGroup.enter()
            if i < 4 {
                label += String(s)
                i += 1
                dispatchGroup.leave()
            } else {
                label += ".."
                dispatchGroup.leave()
                break
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(label)
        })
    }
}
