//
//  ItemDropController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/27.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

enum ItemType: Int {
    case None = 0, timeBomb, EqRob, Cannon, Boots, Heart, Cane, Wall
}

struct ItemDropController {
    
    static let initialItemPosArray: [[(Int, Int, Int)]] = [
        [], //1
        [], //2
        [], //3
        [], //4 //(itemType, xPos, yPos)
        [], //5
        [], //6
        [], //7
        [], //8
        [] //9
    ]
    
    public static var gameScene: GameScene!
    private static var itemSpot = [[1,1],[1,2],[1,3],[1,4],[1,5],[2,1],[2,2],[2,3],[2,4],[2,5],[3,1],[3,2],[3,3],[3,4],[3,5],[4,1],[4,2],[4,3],[4,4],[4,5],[5,1],[5,2],[5,3],[5,4],[5,5],[6,1],[6,2],[6,3],[6,4],[6,5]]
    
    static let level0 = [Int]()
    static let level0Item = [String: [Int]]()
    static let level1 = [Int]()
    static let level1Item = [String: [Int]]()
    static let level2 = [Int]()
    static let level2Item = [String: [Int]]()
    static let level3 = [0, 0, 0, 0, 1]
    static let level3Item = ["1": [1, 1, 1]] // [itemType]
    static let level4 = [0, 0, 0, 0, 1]
    static let level4Item = ["1": [1, 1, 1, 1]]
    static let level5 = [Int]()
    static let level5Item = [String: [Int]]()
    // eqRob
    static let level6 = [Int]()
    static let level6Item = [String: [Int]]()
    static let level7 = [Int]()
    static let level7Item = [String: [Int]]()
    // Second day
    static let level8 = [Int]()
    static let level8Item = [String: [Int]]()
    static let level9 = [Int]()
    static let level9Item = [String: [Int]]()
    // cannon
    static let level10 = [Int]()
    static let level10Item = [String: [Int]]()
    static let level11 = [Int]()
    static let level11Item = [String: [Int]]()
    static let level12 = [Int]()
    static let level12Item = [String: [Int]]()
    static let level13 = [Int]()
    static let level13Item = [String: [Int]]()
    static let level14 = [Int]()
    static let level14Item = [String: [Int]]()
    
    static let manager = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11, level12, level13, level14]
    static let itemManager = [level0Item, level1Item, level2Item, level3Item, level4Item, level5Item, level6Item, level7Item, level8Item, level9Item, level10Item, level11Item, level12Item, level13Item, level14Item]
    
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
