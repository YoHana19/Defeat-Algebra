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
    static var scenario2First = false
    static var timeBombExplainFirst = false
    static var scenario3First = false
    static var eqRobExplainFirst = false
    static var cannonExplainFirst = false
    static var invisibleSignalFirst = false
    static var logDefenceFirst = false
    static var heartGotFirst = false
    
    public static func DrawData(gameScene: GameScene) {
        /* Stage Level */
        GameScene.stageLevel = gameScene.selectedLevel.map { $0 } ?? ud.integer(forKey: "stageLevel")
        /* Hero */
        gameScene.moveLevel = ud.integer(forKey: "moveLevel") == 0 ? 1 : ud.integer(forKey: "moveLevel")
        /* Items */
        gameScene.handedItemNameArray = ud.array(forKey: "itemNameArray") as? [String] ?? []
        /* Life */
        gameScene.life = ud.integer(forKey: "life") < 6 ? 5 : ud.integer(forKey: "life")
        
        initialScenarioFirst = ud.bool(forKey: "initialScenarioFirst")
        scenario2First = ud.bool(forKey: "scenario2First")
        timeBombExplainFirst = ud.bool(forKey: "timeBombExplainFirst")
        scenario3First = ud.bool(forKey: "scenario3First")
        eqRobExplainFirst = ud.bool(forKey: "eqRobExplainFirst")
        cannonExplainFirst = ud.bool(forKey: "cannonExplainFirst")
        invisibleSignalFirst = ud.bool(forKey: "invisibleSignalFirst")
        logDefenceFirst = ud.bool(forKey: "logDefenceFirst")
        heartGotFirst = ud.bool(forKey: "heartGotFirst")
    }
    
    public static func SetData(gameScene: GameScene?) {
        guard let gameScene = gameScene else { return }
        /* Stage level */
        ud.set(GameScene.stageLevel, forKey: "stageLevel")
        /* Hero */
        //ud.set(gameScene.hero!.moveLevel, forKey: "moveLevel")
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
        //ud.set([1], forKey: "moveLevel")
        /* item */
        let itemNameArray = [String]()
        ud.set(itemNameArray, forKey: "itemNameArray")
        /* life */
        ud.set(5, forKey: "life")
        
        ud.set(false, forKey: "initialScenarioFirst")
        ud.set(false, forKey: "scenario2First")
        ud.set(false, forKey: "timeBombExplainFirst")
        ud.set(false, forKey: "scenario3First")
        ud.set(false, forKey: "eqRobExplainFirst")
        ud.set(false, forKey: "cannonExplainFirst")
        ud.set(false, forKey: "invisibleSignalFirst")
        ud.set(false, forKey: "logDefenceFirst")
        ud.set(false, forKey: "heartGotFirst")
        
        initialScenarioFirst = false
        scenario2First = false
        timeBombExplainFirst = false
        scenario3First = false
        eqRobExplainFirst = false
        cannonExplainFirst = false
        invisibleSignalFirst = false
        logDefenceFirst = false
        heartGotFirst = false
    }
    
    public static func doneFirstly(name: String) {
        ud.set(true, forKey: name)
        switch name {
        case "initialScenarioFirst":
            initialScenarioFirst = true
            break;
        case "scenario2First":
            scenario2First = true
            break;
        case "timeBombExplainFirst":
            timeBombExplainFirst = true
            break;
        case "scenario3First":
            scenario3First = true
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
        case "heartGotFirst":
            heartGotFirst = true
            break;
        default:
            break;
        }
    }
}
