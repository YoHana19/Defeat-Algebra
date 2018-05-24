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
    
    public static func DrawData(gameScene: GameScene) {
        /* stageLevel */
        GameScene.stageLevel = ud.integer(forKey: "stageLevel")
        /* Hero */
        gameScene.moveLevel = ud.integer(forKey: "moveLevel")
        /* Items */
        gameScene.handedItemNameArray = ud.array(forKey: "itemNameArray") as? [String] ?? []
        /* Life */
        gameScene.maxLife = ud.integer(forKey: "life")
        /* Item flag */
        GameScene.firstGetItemFlagArray = ud.array(forKey: "firstGetItemFlagArray") as? [Bool] ?? [false, false, false, false, false, false, false, false, false, false, false, false, false]
    }
    
    public static func SetData(gameScene: GameScene) {
    }
}
