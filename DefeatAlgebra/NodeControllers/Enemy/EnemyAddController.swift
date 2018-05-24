//
//  EnemyAddController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

class EnemyAddController {
    static func setSUEnemyPair(origin: Enemy, branch: Enemy, gridNode: Grid) {
        origin.forEduOriginFlag = true
        branch.forEduBranchFlag = true
        gridNode.enemySUPairDict[origin] = branch
    }
}
