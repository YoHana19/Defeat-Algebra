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
    static var initialScenarioFirst = false
    static var punchInteravalExplainFirst = false
    static var moveExplainFirst = false
    static var eqRobExplainFirst = false
    static var cannonExplainFirst = false
    static var invisibleSignalFirst = false
    static var logDefenceFirst = false
    static var bootsGotFirst = false
    static var timeBombGotFirst = false
    static var heartGotFirst = false
    static var caneGotFirst = false
    static var wallGotFirst = false
    
    public static func DrawData(gameScene: GameScene) {
        /* Stage Level */
        GameScene.stageLevel = gameScene.selectedLevel.map { $0 } ?? ud.integer(forKey: "stageLevel")
        /* Hero */
        gameScene.moveLevel = ud.integer(forKey: "moveLevel") == 0 ? 1 : ud.integer(forKey: "moveLevel")
        /* Items */
        gameScene.handedItemNameArray = ud.array(forKey: "itemNameArray") as? [String] ?? []
        /* Life */
        gameScene.life = ud.integer(forKey: "life") < 4 ? 3 : ud.integer(forKey: "life")
        
        initialScenarioFirst = ud.bool(forKey: "initialScenarioFirst")
        punchInteravalExplainFirst = ud.bool(forKey: "punchInteravalExplainFirst")
        moveExplainFirst = ud.bool(forKey: "moveExplainFirst")
        eqRobExplainFirst = ud.bool(forKey: "eqRobExplainFirst")
        cannonExplainFirst = ud.bool(forKey: "cannonExplainFirst")
        invisibleSignalFirst = ud.bool(forKey: "invisibleSignalFirst")
        logDefenceFirst = ud.bool(forKey: "logDefenceFirst")
        bootsGotFirst = ud.bool(forKey: "bootsGotFirst")
        timeBombGotFirst = ud.bool(forKey: "timeBombGotFirst")
        heartGotFirst = ud.bool(forKey: "heartGotFirst")
        caneGotFirst = ud.bool(forKey: "caneGotFirst")
        wallGotFirst = ud.bool(forKey: "wallGotFirst")
    }
    
    public static func SetData(gameScene: GameScene?) {
        guard let gameScene = gameScene else { return }
        /* Stage level */
        ud.set(GameScene.stageLevel, forKey: "stageLevel")
        /* Hero */
        ud.set(gameScene.hero!.moveLevel, forKey: "moveLevel")
        /* Items */
        var itemNameArray = [String]()
        for (i, item) in (gameScene.itemArray.enumerated()) {
            itemNameArray.append(item.name!)
            if i == (gameScene.itemArray.count)-1 {
                ud.set(itemNameArray, forKey: "itemNameArray")
            }
        }
        /* Life */
        ud.set(gameScene.life, forKey: "life")
    }
    
    public static func resetData() {
        let ud = UserDefaults.standard
        /* Stage level */
        ud.set(0, forKey: "stageLevel")
        /* Hero */
        ud.set([1], forKey: "moveLevel")
        /* item */
        let itemNameArray = [String]()
        ud.set(itemNameArray, forKey: "itemNameArray")
        /* life */
        ud.set(3, forKey: "life")
        
        ud.set(false, forKey: "initialScenarioFirst")
        ud.set(false, forKey: "punchInteravalExplainFirst")
        ud.set(false, forKey: "moveExplainFirst")
        ud.set(false, forKey: "eqRobExplainFirst")
        ud.set(false, forKey: "cannonExplainFirst")
        ud.set(false, forKey: "invisibleSignalFirst")
        ud.set(false, forKey: "logDefenceFirst")
        ud.set(false, forKey: "bootsGotFirst")
        ud.set(false, forKey: "timeBombGotFirst")
        ud.set(false, forKey: "heartGotFirst")
        ud.set(false, forKey: "caneGotFirst")
        ud.set(false, forKey: "wallGotFirst")
        
        initialScenarioFirst = false
        punchInteravalExplainFirst = false
        moveExplainFirst = false
        eqRobExplainFirst = false
        cannonExplainFirst = false
        invisibleSignalFirst = false
        logDefenceFirst = false
        bootsGotFirst = false
        timeBombGotFirst = false
        heartGotFirst = false
        caneGotFirst = false
        wallGotFirst = false
    }
    
    public static func doneFirstly(name: String) {
        ud.set(true, forKey: name)
        switch name {
        case "initialScenarioFirst":
            initialScenarioFirst = true
            break;
        case "punchInteravalExplainFirst":
            punchInteravalExplainFirst = true
            break;
        case "moveExplainFirst":
            moveExplainFirst = true
            break;
        case "eqRobExplainFirst":
            eqRobExplainFirst = true
            break;
        case "cannonExplainFirst":
            cannonExplainFirst = true
            break;
        case "invisibleSignalFirst":
            invisibleSignalFirst = true
            break;
        case "logDefenceFirst":
            logDefenceFirst = true
            break;
        case "bootsGotFirst":
            bootsGotFirst = true
            break;
        case "timeBombGotFirst":
            timeBombGotFirst = true
            break;
        case "heartGotFirst":
            heartGotFirst = true
            break;
        case "caneGotFirst":
            caneGotFirst = true
            break;
        case "wallGotFirst":
            wallGotFirst = true
            break;
        default:
            break;
        }
    }
}
