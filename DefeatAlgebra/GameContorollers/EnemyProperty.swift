//
//  EnemyProperty.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/01.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

/* property
 0: fix → veCate, [xPos, yPos]
 1: random → nothing, [xPos, yPos, ve]
 2: eqRob → 0s:easy/100s:hard veCate, [xPos, yPos]
*/

class EnemyProperty {
    
    static let initialEnemyPosArray = [
        (0, 0, [[2, 10], [6, 10]]), //0-3
        (0, 1, [[1, 10], [4, 10], [7, 10]]), //1-4
        (0, 2, [[1, 10], [4, 11], [7, 10]]), //2-5 timeBomb
        (0, 4, [[1, 10], [4, 9], [7, 10]]), //3-6 unsimplified
        (2, 6, [[1, 9], [3, 9], [5, 9], [7, 9], [4, 11]]), //5-7 eqRob
        (2, 6, [[1, 10], [4, 10], [7, 10], [3, 8], [5, 8]]), //6-8
        (2, 6, [[1, 10], [4, 10], [7, 10], [3, 8], [5, 8]]), //7-9 second day
        (1, 100, [[1, 9, 7], [4, 11, 7], [7, 9, 7]]), //8-11 cannon
        (1, 100, [[1, 10, 7], [3, 9, 8], [5, 9, 8], [7, 10, 7]]), //9-12
        (1, 100, [[1, 9, 7], [4, 10, 7], [7, 9, 7]]), //10-14 invisible
        (1, 100, [[0, 11, 7], [2, 10, 8], [6, 10, 7], [8, 11, 8]]) //11-15
        ]
    
    static let level0 = [0] //3
    static let level0VE = [String: [[Int]]]() // [3 enemies, from ve0, yRange]
    static let level1 = [0] //4
    static let level1VE = [String: [[Int]]]()
    static let level2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] //5 (timeBomb)
    static let level2VE = ["1": [[3, 3, 2]]]
    static let level3 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] //6 (unsimplified)
    static let level3VE = ["1": [[4, 5, 2]]]
    static let level4 = [0, 0, 0, 0, 0, 0, 0, 0, 11] //7 (eqRob)
    static let level4VE = ["11": [[5, 6, 4]]]
    static let level5 = [0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11] //8
    static let level5VE = ["11": [[5, 6, 4]]]
    // Second day
    static let level6 = [0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11] //9
    static let level6VE = ["11": [[5, 6, 4]]]
    static let level7 = [0, 0, 0, 0, 0, 0, 1] //11 (cannon)
    static let level7VE = ["1": [[3, 7, 4]]]
    static let level8 = [0, 0, 0, 0, 0, 0, 1] //12
    static let level8VE = ["1": [[3, 7, 4],[2, 8, 4]]]
    static let level9 = [0, 0, 0, 0, 0, 0, 1] //14 (inivisible)
    static let level9VE = ["1": [[4, 7, 4]]]
    static let level10 = [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1] //15
    static let level10VE = ["1": [[2, 7, 4], [2, 8, 4]]]
    
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
    
    static let addEnemyManager = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9, level10]
    static let addEnemyVEManager = [level0VE, level1VE, level2VE, level3VE, level4VE, level5VE, level6VE, level7VE, level8VE, level9VE, level10VE]
    
    static func getNumOfAllEnemy(stageLevel: Int, completion: @escaping (Int) -> Void) {
        let iniProperty = EnemyProperty.initialEnemyPosArray[stageLevel]
        var start = 0
        if (iniProperty.0 == 0 || iniProperty.0 == 1 || iniProperty.0 == 2) {
            start += iniProperty.2.count
        }
        
        let dispatchGroup = DispatchGroup()
        var totalNum = start
        for i in EnemyProperty.addEnemyManager[stageLevel] {
            dispatchGroup.enter()
            if i != 0 {
                let array = EnemyProperty.addEnemyVEManager[stageLevel][String(i)]
                array?.forEach{ totalNum += $0[0] }
                dispatchGroup.leave()
            } else {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(totalNum)
        })
    }
    
}
