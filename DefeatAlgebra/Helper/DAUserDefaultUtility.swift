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
        /* Stage Level */
        GameScene.stageLevel = gameScene.selectedLevel.map { $0 } ?? ud.integer(forKey: "stageLevel")
        /* Hero */
        gameScene.moveLevel = ud.integer(forKey: "moveLevel") == 0 ? 1 : ud.integer(forKey: "moveLevel")
        /* Items */
        gameScene.handedItemNameArray = ud.array(forKey: "itemNameArray") as? [String] ?? []
        /* Life */
        gameScene.maxLife = ud.integer(forKey: "life") == 0 ? 3 : ud.integer(forKey: "life")
        /* Item flag */
        GameScene.firstGetItemFlagArray = ud.array(forKey: "firstGetItemFlagArray") as? [Bool] ?? [false, false, false, false, false, false, false, false, false, false, false, false, false]
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
        ud.set(gameScene.maxLife, forKey: "life")
    }
}
