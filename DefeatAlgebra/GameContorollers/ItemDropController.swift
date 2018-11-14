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
    
    public static var gameScene: GameScene!
    private static var itemSpot = [[1,1],[1,2],[1,3],[1,4],[1,5],[2,1],[2,2],[2,3],[2,4],[2,5],[3,1],[3,2],[3,3],[3,4],[3,5],[4,1],[4,2],[4,3],[4,4],[4,5],[5,1],[5,2],[5,3],[5,4],[5,5],[6,1],[6,2],[6,3],[6,4],[6,5]]
    
//    public static func getManager() -> [Int] {
//        switch GameScene.stageLevel {
//        case MainMenu.showUnsimplifiedStartTurn:
//            return [0, 0, 0, 1]
//        case MainMenu.secondDayStartTurn+1:
//            return [0, 0, 0, 1]
//        default:
//            return [Int]()
//        }
//    }
    
//    public static func getItemManager() -> [String: [Int]] {
//        switch GameScene.stageLevel {
//        case MainMenu.showUnsimplifiedStartTurn:
//            return ["1": [1, 1, 1, 1]]
//        case MainMenu.secondDayStartTurn+1:
//            return ["1": [1, 1, 1]]
//        default:
//            return [String: [Int]]()
//        }
//    }
    
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
