//
//  EnemyDeadController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

class EnemyDeadController {
    static func originEnemyDead(origin: EnemyEasy, gridNode: GridEasy) {
        if let branch = gridNode.enemySUPairDict[origin] {
            branch.forEduBranchFlag = false
            gridNode.enemySUPairDict[origin] = nil
        } else {
            print("something wrong in EnemyDeadController.originEnemyDead")
        }
    }
    
    static func branchEnemyDead(branch: EnemyEasy, gridNode: GridEasy) {
        let temp = gridNode.enemySUPairDict.flatMap({ $0.1 == branch ? $0.0 : nil })
        if let origin = temp.first {
            origin.forEduOriginFlag = false
            gridNode.enemySUPairDict[origin] = nil
        } else {
            print("something wrong in EnemyDeadController.branchEnemyDead")
        }
    }
}
