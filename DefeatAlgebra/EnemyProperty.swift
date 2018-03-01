//
//  EnemyProperty.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/01.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

/* [0: number of adding enemy, 1: inteval of adding enemy, 2: number of times of adding enemy, 3: range of start yPos]
var addEnemyManagement = [
    [0, 0, 0, 1],
    [0, 0, 0, 1],
    [4, 4, 1, 1],
    [4, 2, 3, 1],
    [4, 6, 2, 1],
    [3, 1, 5, 2],
    [4, 2, 4, 3],
    [6, 3, 3, 3],
    [5, 2, 3, 3],
    [4, 1, 3, 3],
    [5, 1, 5, 3],
    [5, 1, 5, 3]
]
*/

class EnemyProperty {
    /* 1st element decides which is coefficiet or constant term, last elment indicates equivarence of variable expression */
    /* 1st element 0:x+1, 1:1+x, 2:1×x, 3:x×1, 4:2x-1, 5:3-x, 6:X+1+2;2x-3+1, 7:2+1-x, 8:x+x+1;2x-x;x+x-1, 9:x+x+2+1 */
    /* 8th: 01origin, 9th: 45origin, 10th: 01to6, 11th: 45to67, 12th: 01to8, 13th: 45to8, 14th: 01to9, 15th: 45to9 */
    /* not using
    static let variableExpressionSource = [
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 1, 1, 1], [0, 2, 1, 7], [0, 2, 2, 9], [0, 3, 1, 8], [2, 1, 0, 0], [2, 2, 0, 4], [3, 1, 0, 0], [3, 2, 0, 4], [1, 1, 1, 1], [1, 2, 1, 7], [1, 2, 2, 9], [1, 3, 1, 8]],
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5], [0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10]],
        [[4, 2, 1, 11], [4, 3, 1, 12], [4, 3, 2, 13], [5, 1, 4, 14], [5, 2, 7, 15], [5, 2, 8, 16]],
        [[6, 1, 0, 0], [6, 2, 0, 4], [6, 3, 0, 5], [6, 1, 1, 1], [6, 2, 1, 7], [6, 3, 1, 8], [6, 1, 2, 2], [6, 2, 2, 9], [6, 3, 2, 10]],
        [[6, 2, -1, 11], [6, 3, -1, 12], [6, 3, -2, 13], [7, 1, 4, 14], [7, 2, 7, 15], [7, 2, 8, 16]],
        [[8, 1, 0, 0], [8, 2, 0, 4], [8, 3, 0, 5], [8, 1, 1, 1], [8, 2, 1, 7], [8, 3, 1, 8], [8, 1, 2, 2], [8, 2, 2, 9], [8, 3, 2, 10]],
        [[8, 2, -1, 11], [8, 3, -1, 12], [8, 3, -2, 13], [8, -1, 4, 14], [8, -2, 7, 15], [8, -2, 8, 16]],
        [[9, 1, 0, 0], [9, 2, 0, 4], [9, 3, 0, 5], [9, 1, 1, 1], [9, 2, 1, 7], [9, 3, 1, 8], [9, 1, 2, 2], [9, 2, 2, 9], [9, 3, 2, 10]],
        [[9, 2, -1, 11], [9, 3, -1, 12], [9, 3, -2, 13], [9, -1, 4, 14], [9, -2, 7, 15], [9, -2, 8, 16]]
    ]
    */
    
    static let simplifiedVariableExpressionSource: [[[Int]]] = [
        [[0, 1, 0, 0]], //1
        [[0, 1, 0, 0]], //2
        [[0 ,1, 0, 0], [0, 1, 1, 1], [0, 1, 2, 2]], //3
        [[0, 1, 0, 0], [0, 1, 1, 1], [0, 1, 2, 2], [0, 1, 3, 3], [1, 1, 1, 1], [1, 1, 2, 2], [1, 1, 3, 3]], //4
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5]], //5
        [[0, 1, 0, 0], [0, 2, 0, 4], [0, 3, 0, 5], [0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10], [1, 1, 1, 1], [1, 2, 1, 7], [1, 3, 1, 8], [1, 1, 2, 2], [1, 2, 2, 9], [1, 3, 2, 10]], //6
        [[0, 1, 1, 1], [0, 2, 1, 7], [0, 3, 1, 8], [0, 1, 2, 2], [0, 2, 2, 9], [0, 3, 2, 10], [4, 2, 1, 11], [4, 3, 1, 12], [4, 3, 2, 13], [5, 1, 4, 14], [5, 2, 7, 15], [5, 2, 8, 16]], //7
        [[0 ,1, 0, 0], [0, 1, 1, 1], [0, 2, 0, 4], [0, 2, 1, 7]] //8
    ]
    
    static let simplifiedVariableExpressionLabelSource: [[String]] = [
        ["x"], //1
        ["x"], //2
        ["x", "x+1", "x+2"], //3
        ["x", "x+1", "x+2", "x+3", "1+x", "2+x", "3+x"], //4
        ["x", "2x", "3x", "1×x", "2×x", "3×x", "x×1", "x×2", "x×3"], //5
        ["x", "2x", "3x", "x+1", "2x+1", "3x+1", "x+2", "2x+2", "3x+2", "1+x", "1+2x", "1+3x", "2+x", "2+2x", "2+3x"], //6
        ["x+1", "2x+1", "3x+1", "x+2", "2x+2", "3x+2", "2x-1", "3x-1", "3x-2", "4-x", "7-2x", "8-2x"], //7
        ["x", "x+1", "2x", "2x+1"]
    ]
    
    static let unSimplifiedVariableExpressionSource: [[[Int]]] = [
        [], //1
        [], //2
        [], //3
        [], //4
        [[2, 1, 0, 0], [2, 2, 0, 4], [2, 3, 0, 5], [3, 1, 0, 0], [3, 2, 0, 4], [3, 3, 0, 5]], //5
        [], //6
        [], //7
        [[0 ,1, 0, 0, 0], [0 ,1, 0, 1, 0], [0, 1, 1, 0, 1], [0, 1, 1, 1, 1], [0, 2, 0, 0, 4], [0, 2, 0, 1, 4], [0, 2, 1, 0, 7], [0, 2, 1, 1, 7]] //8
    ]
    
    static let unSimplifiedVariableExpressionLabelSource: [[String]] = [
        [], //1
        [], //2
        [], //3
        [], //4
        ["1×x", "2×x", "3×x", "x×1", "x×2", "x×3"], //5
        [], //6
        [], //7
        ["x+1-1", "2+x-2", "x+2-1", "2+x-1", "2x-2+2", "1+2x-1", "2x-1+2", "3-2+2x"] //8
    ]
    
    static func judgeCorrectVe(origin: String, input: String) -> Bool {
        if let cand = vELabelPairDict[origin] {
            let result = cand.contains(input)
            return result
        } else {
            return false
        }
    }
    
    private static let vELabelPairDict: [String: [String]] = [
        "x+1-1": ["x"], "2+x-2": ["x"], "x+2-1": ["x+1", "1+x"], "2+x-1": ["x+1", "1+x"], "2x-2+2": ["2x"], "1+2x-1": ["2x"], "2x-1+2": ["2x+1", "1+2x"], "3-2+2x": ["2x+1", "1+2x"]
    ]
    
    static let addEnemyManager = [
        [[0]], //1
        [[0]], //2
        [[0], [0], [0], [0], [1, 0, 4, 1]], //3
        [[0], [0], [1, 0, 4, 1], [0], [0], [1, 0, 4, 1], [0], [0], [1, 0, 4, 1]], //4
        [[0], [0], [0], [0], [1, 1, 2], [0], [0], [1, 1, 2], [0], [0], [1, 0, 3, 1]], //5
        [[0], [0], [1, 0, 3, 2], [0], [1, 0, 3, 2], [0], [1, 0, 3, 2], [0], [1, 0, 3, 2], [0], [1, 0, 3, 2], [0]], //6
        [[0], [0], [0], [1, 0, 4, 3], [0], [0], [1, 0, 4, 3]], //7
        [[0], [0], [0], [0], [1, 1, 2], [0], [0], [1, 1, 2], [0], [0], [1, 0, 3, 1]], //8
    ]
    
    static func getNumOfAllEnemy(stageLevel: Int, completion: @escaping (Int) -> Void) {
        let start = EnemyProperty.initialEnemyPosArray[stageLevel].count
        let startForUnS = EnemyProperty.initialEnemyPosArrayForUnS[stageLevel].count
        let dispatchGroup = DispatchGroup()
        var totalNum = start + startForUnS
        for array in EnemyProperty.addEnemyManager[stageLevel] {
            dispatchGroup.enter()
            if array[0] == 1 {
                if array[1] == 0 {
                    totalNum += array[2]
                    dispatchGroup.leave()
                } else {
                    totalNum += array[2]*2
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(totalNum)
        })
    }
    
    static let initialEnemyPosArray = [
        [[1, 9], [4, 9], [7, 9]], //1
        [[1, 10], [4, 10], [7, 10], [2, 8], [6, 8]], //2
        [[1, 11], [3, 11], [5, 11], [7, 11], [2, 9], [4, 9], [6, 9]], //3
        [[0, 10], [2, 10], [4, 10], [6, 10], [8, 10], [3, 8], [5, 8]], //4
        [[1, 11], [5, 11], [1, 9], [5, 9]], //5
        [[2, 10], [6, 10], [2, 8], [6, 8], [4, 9]], //6
        [[1, 11], [2, 10], [3, 9], [7, 11], [6, 10], [5, 9]], //7
        [[0, 9], [1, 11], [2, 9], [3, 11]], //8
        [[1, 11], [2, 9], [1, 7], [4, 9], [6, 9], [7, 11], [7, 7]], //9
        [[0, 11], [0, 7], [2, 10], [2, 8], [6, 10], [6, 8], [8, 7], [8, 11]], //10
        [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]], //11
        [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]] //12
    ]
    
    static let initialEnemyPosArrayForUnS = [
        [], //1
        [], //2
        [], //3
        [], //4
        [[3, 11], [7, 11], [3, 9], [7, 9]], //5
        [], //6
        [], //7
        [[4, 9], [5, 11], [6, 9], [7, 11], [8, 9]], //8
        [[1, 11], [2, 9], [1, 7], [4, 9], [6, 9], [7, 11], [7, 7]], //9
        [[0, 11], [0, 7], [2, 10], [2, 8], [6, 10], [6, 8], [8, 7], [8, 11]], //10
        [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]], //11
        [[1, 10], [3, 8], [4, 10], [5, 8], [7, 10]] //12
    ]
    
}
