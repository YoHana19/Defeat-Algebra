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
        PlayerTurnController.done = false
        PlayerTurnController.isNewEqRobTurn = true
        PlayerTurnController.countTurn = 0
        CharacterController.doctor.changeBalloonTexture(index: 0)
        CharacterController.doctor.balloon.isHidden = true
        CharacterController.mainHero.balloon.isHidden = true
        CharacterController.doctor.setScale(1.0)
        CharacterController.mainHero.setScale(1.0)
    }
}
