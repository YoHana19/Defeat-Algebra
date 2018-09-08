//
//  ItemDropController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

enum ItemType: Int {
    case None = 0, timeBomb, Boots, Heart, Cane, Wall, EqRob, Cannon
}

struct ItemDropController {
    
    static let initialItemPosArray = [
        [(2, 3, 3), (1, 5, 3)], //1 //(itemType, xPos, yPos)
        [(2, 4, 5), (1, 2, 3), (1, 6, 3), (3, 4, 1)], //2
        [(2, 1, 6), (2, 7, 6), (1, 1, 3), (4, 7, 3), (4, 2, 0), (1, 6, 0)], //3
        [(1, 2, 0), (1, 6, 0), (1, 7, 3), (4, 4, 6), (5, 4, 0), (5, 1, 3)], //4
        [(1, 4, 0), (1, 4, 6), (1, 1, 3), (1, 7, 3), (5, 3, 4), (5, 5, 2), (5, 2, 1), (5, 6, 5)], //5
        [(1, 4, 6), (1, 4, 0), (4, 2, 4), (4, 6, 2)], //6
    ]
    
    public static var gameScene: GameScene!
    private static var itemSpot = [[1,1],[1,2],[1,3],[1,4],[1,5],[2,1],[2,2],[2,3],[2,4],[2,5],[3,1],[3,2],[3,3],[3,4],[3,5],[4,1],[4,2],[4,3],[4,4],[4,5],[5,1],[5,2],[5,3],[5,4],[5,5],[6,1],[6,2],[6,3],[6,4],[6,5]]
    
    static let level1 = [0, 0, 0, 0, 0, 1]
    static let level1Item = ["1": [1, 1]] // [itemType]
    static let level2 = [0, 0, 0, 0, 1, 0, 0, 0, 0, 2]
    static let level2Item = ["1": [1, 1], "2": [1, 1]]
    static let level3 = [0, 0, 0, 0, 0, 1]
    static let level3Item = ["1": [1, 1, 3, 3, 4]]
    static let level4 = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]
    static let level4Item = ["1": [1, 5]]
    static let level5 = [0, 0, 1, 0, 0, 2, 0, 0, 1, 0, 0, 2]
    static let level5Item = ["1": [1, 5], "2": [1, 4, 5]]
    static let level6 = [0, 0, 0, 1, 0, 0, 1]
    static let level6Item = ["1": [1, 1, 4, 4]]
    
    static let manager = [level1, level2, level3, level4, level5, level6]
    static let itemManager = [level1Item, level2Item, level3Item, level4Item, level5Item, level6Item]
    
    static func getItemSpot(num: Int, completion: @escaping ([[Int]]) -> Void) {
        var fieldItemSpots = gameScene.gridNode.itemsOnField.map { $0.spotPos }
        fieldItemSpots.append([gameScene.hero.positionX, gameScene.hero.positionY])
        var tempSpot = itemSpot.filter { !fieldItemSpots.contains($0) }
        DAUtility.getRandomNumbers(total: tempSpot.count, times: num) { indexArray in
            var spots = [[Int]]()
            let dispatchGroup = DispatchGroup()
            for i in indexArray {
                dispatchGroup.enter()
                spots.append(tempSpot[i])
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion(spots)
            })
        }
    }
    
    static func makeItemPosArray(items: [Int], completion: @escaping ([(Int, Int, Int)]) -> Void) {
        getItemSpot(num: items.count) { spots in
            var itemPosArray = [(Int, Int, Int)]()
            let dispatchGroup = DispatchGroup()
            for (i, spot) in spots.enumerated() {
                dispatchGroup.enter()
                itemPosArray.append((items[i], spot[0], spot[1]))
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion(itemPosArray)
            })
        }
    }
}
