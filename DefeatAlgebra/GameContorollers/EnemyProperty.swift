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
        (0, 0, [[1, 10], [4, 10], [7, 10]]), //0-3
        (0, 1, [[1, 10], [4, 10], [7, 10]]), //1-4 timeBomb
        (0, 2, [[1, 10], [3, 11], [5, 11], [7, 10]]), //2-5
        (1, 100, [[1, 10, 3], [3, 10, 3], [5, 10, 3], [7, 10, 3]]), //3-6
        (1, 100, [[1, 10, 4], [4, 10, 5], [7, 10, 4]]), //4-7
        (2, 6, [[1, 11], [3, 10], [5, 10], [7, 11]]), //5-8 eqRob
        (2, 6, [[1, 10], [3, 10], [5, 10], [7, 10]]), //6-9
        (2, 106, [[1, 9], [3, 9], [5, 9], [7, 9]]), //7-10
        (0, 7, [[1, 11], [4, 10], [7, 11]]), //8-11 second day
        (1, 100, [[1, 10, 8], [3, 11, 8], [5, 10, 8], [7, 11, 8]]), //9-12
        (2, 6, [[2, 11], [2, 9], [6, 9], [6, 11]]), //10-13
        (2, 106, [[2, 11], [2, 9], [6, 9], [6, 11]]), //11-14
        (1, 100, [[1, 9, 8], [4, 11, 8], [7, 9, 8]]), //12-16 cannon
        (1, 100, [[1, 10, 8], [3, 9, 9], [5, 9, 9], [7, 10, 8]]), //13-17
        (1, 100, [[1, 9, 8], [4, 10, 8], [7, 9, 8]]), //14-19 invisible
        (1, 100, [[0, 11, 8], [2, 10, 9], [6, 10, 8], [8, 11, 9]]) //15-20
        ]
    
    static let level0 = [0] //3
    static let level0VE = [String: [[Int]]]() // [3 enemies, from ve0, yRange]
    static let level1 = [0] //4 (timeBomb)
    static let level1VE = [String: [[Int]]]()
    static let level2 = [0] //5
    static let level2VE = [String: [[Int]]]()
    static let level3 = [0, 0, 0, 0, 0, 0, 0, 0, 1] //6 (moveExplain)
    static let level3VE = ["1": [[4, 3, 2]]]
    static let level4 = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2] //7 (unsimplified)
    static let level4VE = ["1": [[2, 5, 2], [1, 4, 2]], "2": [[2, 5, 2], [2, 4, 2]]]
    static let level5 = [0] //8 (eqRob)
    static let level5VE = [String: [[Int]]]()
    static let level6 = [0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11] //9
    static let level6VE = ["11": [[5, 6, 4]]]
    static let level7 = [0, 0, 0, 0, 0, 0, 101, 0, 0, 0, 0, 0, 0, 0, 101] //10
    static let level7VE = ["101": [[5, 6, 4]]]
    // Second day
    static let level8 = [0] //11
    static let level8VE = [String: [[Int]]]()
    static let level9 = [0, 0, 0, 0, 0, 0, 1] //12
    static let level9VE = ["1": [[4, 9, 2]]]
    static let level10 = [0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11] //13
    static let level10VE = ["11": [[5, 6, 2]]]
    static let level11 = [0, 0, 0, 0, 0, 0, 101, 0, 0, 0, 0, 0, 0, 0, 101] //14
    static let level11VE = ["101": [[5, 6, 2]]]
    static let level12 = [0, 0, 0, 0, 0, 0, 1] //16 (cannon)
    static let level12VE = ["1": [[3, 8, 4]]]
    static let level13 = [0, 0, 0, 0, 0, 0, 1] //17
    static let level13VE = ["1": [[3, 8, 4],[2, 9, 4]]]
    static let level14 = [0, 0, 0, 0, 0, 0, 1] //18 (inivisible)
    static let level14VE = ["1": [[4, 8, 4]]]
    static let level15 = [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1] //19
    static let level15VE = ["1": [[2, 8, 4], [2, 9, 4]]]
    
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
    
    static let addEnemyManager = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11, level12, level13, level14, level15]
    static let addEnemyVEManager = [level0VE, level1VE, level2VE, level3VE, level4VE, level5VE, level6VE, level7VE, level8VE, level9VE, level10VE, level11VE, level12VE, level13VE, level14VE, level15VE]
    
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
