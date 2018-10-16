//
//  ResetController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

struct ResetController {
    
    static func reset() {
        AddEnemyTurnController.done = false
        SignalSendingTurnController.done = false
        AddItemTurnController.done = false
        PlayerTurnController.done = false
        EnemyTurnController.done = false
        CannonTryController.hintOn = false
        CannonTryController.isCorrect = false
        CannonTryController.numOfCheck = 0
        CannonController.willFireCannon.removeAll()
        VEEquivalentController.numOfCheck = 0
    }
}
