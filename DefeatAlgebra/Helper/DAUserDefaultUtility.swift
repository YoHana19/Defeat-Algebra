//
//  DAUserDefaultUtility.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/23.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

enum GameProperty {
    case StageLevel, MoveLevel, ItemNameArray, Life, firstGetItemFlagArray
}

class DAUserDefaultUtility {
    static let ud = UserDefaults.standard
    static var initialScenario = false
    static var uncoverSignal = false
    static var changeMoveSpan = false
    static var timeBombExplain = false
    static var moveExplain = false
    static var showUnsimplified = false
    static var changeVeSizeExplainByEdge = false
    static var changeVeSizeExplainByNeignbor = false
    static var eqRobExplain = false
    static var cannonExplain = false
    static var invisibleSignal = false
    static var lastScenario = false
    static var logDefenceFirst = false
    
    public static func DrawData(gameScene: GameScene) {
        /* Stage Level */
        GameScene.stageLevel = gameScene.selectedLevel.map { $0 } ?? ud.integer(forKey: "stageLevel")
        
        initialScenario = ud.bool(forKey: "initialScenario")
        uncoverSignal = ud.bool(forKey: "uncoverSignal")
        changeMoveSpan = ud.bool(forKey: "changeMoveSpan")
        timeBombExplain = ud.bool(forKey: "timeBombExplain")
        moveExplain = ud.bool(forKey: "moveExplain")
        showUnsimplified = ud.bool(forKey: "showUnsimplified")
        changeVeSizeExplainByEdge = ud.bool(forKey: "changeVeSizeExplainByEdge")
        changeVeSizeExplainByNeignbor = ud.bool(forKey: "changeVeSizeExplainByNeignbor")
        eqRobExplain = ud.bool(forKey: "eqRobExplain")
        cannonExplain = ud.bool(forKey: "cannonExplain")
        invisibleSignal = ud.bool(forKey: "invisibleSignal")
        lastScenario = ud.bool(forKey: "lastScenario")
        
        logDefenceFirst = ud.bool(forKey: "logDefenceFirst")
    }
    
    public static func SetData() {
        /* Stage level */
        ud.set(GameScene.stageLevel, forKey: "stageLevel")
    }
    
    public static func resetData() {
        
        guard let appDomain = Bundle.main.bundleIdentifier else { return }
        ud.removePersistentDomain(forName: appDomain)
      
        initialScenario = false
        uncoverSignal = false
        changeMoveSpan = false
        timeBombExplain = false
        moveExplain = false
        showUnsimplified = false
        changeVeSizeExplainByEdge = false
        changeVeSizeExplainByNeignbor = false
        eqRobExplain = false
        cannonExplain = false
        invisibleSignal = false
        lastScenario = false
        logDefenceFirst = false
        
    }
    
    public static func doneFirstly(name: String) {
        ud.set(true, forKey: name)
        switch name {
        case "initialScenario":
            initialScenario = true
            break;
        case "uncoverSignal":
            uncoverSignal = true
            break;
        case "changeMoveSpan":
            changeMoveSpan = true
            break;
        case "timeBombExplain":
            timeBombExplain = true
            break;
        case "moveExplain":
            moveExplain = true
            break;
        case "showUnsimplified":
            showUnsimplified = true
            break;
        case "changeVeSizeExplainByNeignbor":
            changeVeSizeExplainByNeignbor = true
            break;
        case "changeVeSizeExplainByEdge":
            changeVeSizeExplainByEdge = true
            break;
        case "eqRobExplain":
            eqRobExplain = true
            break;
        case "cannonExplain":
            cannonExplain = true
            break;
        case "invisibleSignal":
            invisibleSignal = true
            break;
        case "lastScenario":
            lastScenario = true
            break;
        case "logDefenceFirst":
            logDefenceFirst = true
            break;
        default:
            break;
        }
    }
}
