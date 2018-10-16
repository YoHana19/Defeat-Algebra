//
//  DataController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

enum Data: String {
    case GameOverByHit, GameOverByCastle, EnemyKilledByDA, AttackedEnemyKilledByDA, UsedBomb, EnemyKilledByBomb, AttackedEnemyKilledByBomb, UsedEqRob, MissedEqRob, DestroyedEqRob, EnemyKilledByEqRob, FiredCannon, EnemyKilledByCannon, AttackedEnemyKilledByCannon, UsedTryCannon, ChangeCannonDistanceInTrying, GetHintInTryingCannon, GetAnswerInTryingCannon
}

class DataController {
    
    public static let data: [Data] = [.GameOverByHit, .GameOverByCastle, .EnemyKilledByDA, .AttackedEnemyKilledByDA, .UsedBomb, .EnemyKilledByBomb, .AttackedEnemyKilledByBomb, .UsedEqRob, .MissedEqRob, .DestroyedEqRob, .EnemyKilledByEqRob, .FiredCannon, .EnemyKilledByCannon, .AttackedEnemyKilledByCannon, .UsedTryCannon, .ChangeCannonDistanceInTrying,.GetHintInTryingCannon, .GetAnswerInTryingCannon]
    
    public static var isGameScene = true
    private static let ud = UserDefaults.standard
    
    private static var gameOverByHit = 0
    private static var gameOverByCastle = 0
    private static var enemyKilledByDA = 0
    private static var attackedEnemyKilledByDA = 0
    private static var usedBomb = 0
    private static var enemyKilledByBomb = 0
    private static var attackedEnemyKilledByBomb = 0
    private static var usedEqRob = 0
    private static var missedEqRob = 0
    private static var destroyedEqRob = 0
    private static var enemyKilledByEqRob = 0
    private static var firedCannon = 0
    private static var enemyKilledByCannon = 0
    private static var attackedEnemyKilledByCannon = 0
    private static var usedTryCannon = 0
    private static var changeCannonDistanceInTrying = 0
    private static var getHintInTryingCannon = 0
    private static var getAnswerInTryingCannon = 0
    
    public static func withDrawData(type: Data, level: Int) -> String {
        let key: String =  type.rawValue + String(level)
        let value = ud.integer(forKey: key)
        return String(value)
    }
    
    public static func setDataForGameOver(isHit: Bool) {
        guard isGameScene else { return }
        if isHit {
            gameOverByHit += 1
            setData(type: .GameOverByHit)
        } else {
            gameOverByCastle += 1
            setData(type: .GameOverByCastle)
        }
    }
    
    public static func setDataForUsedBomb() {
        guard isGameScene else { return }
        usedBomb += 1
        setData(type: .UsedBomb)
        
    }
    
    public static func setDataForEqRob(isPerfect: Bool, isMiss: Bool) {
        guard isGameScene else { return }
        usedEqRob += 1
        if (!isPerfect) {
            if (isMiss) {
                missedEqRob += 1
                setData(type: .MissedEqRob)
            } else {
                destroyedEqRob += 1
                setData(type: .DestroyedEqRob)
            }
        }
        setData(type: .UsedEqRob)
    }
    
    public static func setDataForFiredCannon(num: Int) {
        guard isGameScene else { return }
        firedCannon += num
        setData(type: .FiredCannon)
    }
    
    public static func setDataForUsedTryCannon() {
        guard isGameScene else { return }
        usedTryCannon += 1
        setData(type: .UsedTryCannon)
    }
    
    public static func setDataForChangeCannonDistanceInTrying() {
        guard isGameScene else { return }
        changeCannonDistanceInTrying += 1
        setData(type: .ChangeCannonDistanceInTrying)
    }
    
    public static func setDataForGetHint() {
        guard isGameScene else { return }
        getHintInTryingCannon += 1
        setData(type: .GetHintInTryingCannon)
    }
    
    public static func setDataForGetAnswer() {
        guard isGameScene else { return }
        getAnswerInTryingCannon += 1
        setData(type: .GetAnswerInTryingCannon)
    }
    
    public static func setDataForEnemyKilled() {
        guard isGameScene else { return }
        setData(type: .EnemyKilledByDA)
        setData(type: .AttackedEnemyKilledByDA)
        setData(type: .EnemyKilledByBomb)
        setData(type: .AttackedEnemyKilledByBomb)
        setData(type: .EnemyKilledByEqRob)
        setData(type: .EnemyKilledByCannon)
        setData(type: .AttackedEnemyKilledByCannon)
    }
    
    public static func countForEnemyKilledByDA(enemy: Enemy) {
        guard isGameScene else { return }
        enemyKilledByDA += 1
        if enemy.posRecord.last?.2 == 0 {
            attackedEnemyKilledByDA += 1
        }
    }
    
    public static func countForEnemyKilledByTimeBomb(enemy: Enemy) {
        guard isGameScene else { return }
        enemyKilledByBomb += 1
        if enemy.posRecord.last?.2 == 0 {
            attackedEnemyKilledByBomb += 1
        }
    }
    
    public static func countForEnemyKilledByEqRob(num: Int) {
        guard isGameScene else { return }
        enemyKilledByEqRob += num
    }
    
    public static func countForEnemyKilledByCannon(enemy: Enemy) {
        guard isGameScene else { return }
        enemyKilledByCannon += 1
        if enemy.posRecord.last?.2 == 0 {
            attackedEnemyKilledByCannon += 1
        }
    }
    
    private static func setData(type: Data) {
        let key: String =  type.rawValue + String(GameScene.stageLevel)
        let num = ud.integer(forKey: key) + getNum(type: type)
        ud.set(num, forKey: key)
        resetNum(type: type)
    }
    
    private static func getNum(type: Data) -> Int {
        switch type {
        case .GameOverByHit:
            return gameOverByHit
        case .GameOverByCastle:
            return gameOverByCastle
        case .EnemyKilledByDA:
            return enemyKilledByDA
        case .AttackedEnemyKilledByDA:
            return attackedEnemyKilledByDA
        case .UsedBomb:
            return usedBomb
        case .EnemyKilledByBomb:
            return enemyKilledByBomb
        case .AttackedEnemyKilledByBomb:
            return attackedEnemyKilledByBomb
        case .UsedEqRob:
            return usedEqRob
        case .MissedEqRob:
            return missedEqRob
        case .DestroyedEqRob:
            return destroyedEqRob
        case .EnemyKilledByEqRob:
            return enemyKilledByEqRob
        case .FiredCannon:
            return firedCannon
        case .EnemyKilledByCannon:
            return enemyKilledByCannon
        case .AttackedEnemyKilledByCannon:
            return attackedEnemyKilledByCannon
        case .UsedTryCannon:
            return usedTryCannon
        case .ChangeCannonDistanceInTrying:
            return changeCannonDistanceInTrying
        case .GetHintInTryingCannon:
            return getHintInTryingCannon
        case .GetAnswerInTryingCannon:
            return getAnswerInTryingCannon
        }
    }
    
    private static func resetNum(type: Data) {
        switch type {
        case .GameOverByHit:
            gameOverByHit = 0
            break;
        case .GameOverByCastle:
            gameOverByCastle = 0
            break;
        case .EnemyKilledByDA:
            enemyKilledByDA = 0
            break;
        case .AttackedEnemyKilledByDA:
            attackedEnemyKilledByDA = 0
            break;
        case .UsedBomb:
            usedBomb = 0
            break;
        case .EnemyKilledByBomb:
            enemyKilledByBomb = 0
            break;
        case .AttackedEnemyKilledByBomb:
            attackedEnemyKilledByBomb = 0
            break;
        case .UsedEqRob:
            usedEqRob = 0
            break;
        case .MissedEqRob:
            missedEqRob = 0
            break;
        case .DestroyedEqRob:
            destroyedEqRob = 0
            break;
        case .EnemyKilledByEqRob:
            enemyKilledByEqRob = 0
            break;
        case .FiredCannon:
            firedCannon = 0
            break;
        case .EnemyKilledByCannon:
            enemyKilledByCannon = 0
            break;
        case .AttackedEnemyKilledByCannon:
            attackedEnemyKilledByCannon = 0
            break;
        case .UsedTryCannon:
            usedTryCannon = 0
            break;
        case .ChangeCannonDistanceInTrying:
            changeCannonDistanceInTrying = 0
            break;
        case .GetHintInTryingCannon:
            getHintInTryingCannon = 0
            break;
        case .GetAnswerInTryingCannon:
            getAnswerInTryingCannon = 0
            break;
        }
    }
}
