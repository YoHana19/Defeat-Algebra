//
//  VECategory.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

struct VECategory {
    // level 3
    static let ve0 = ["2+x", "x×1"]
    // level 4
    static let ve1 = ["2x", "2×x", "2x+1"]
    // level 5 (timeBomb)
    static let ve2 = ["3x-2", "2x+2", "3x"]
    static let ve3 = ["2x+1", "3x-1", "2x-1"]
    // level 6 (unsimplified)
    static let ve4 = ["x×2+1", "x+x+2", "3+x×1"]
    static let ve5 = ["x+1+x", "3x-x", "x+x+x", "2x+x"]
    // level 7 (eqRobOld)
    static let ve6 = ["2+x", "2x", "2x-x+2", "3-1+x", "0", "3+x", "3x", "3x-2x+3", "4-1+x", "0"]
    static let ve7 = ["1+2x", "3x", "2x+x", "4x-x", "0", "3x-1", "2x", "x+x", "3x-x", "0"]
    // level 8 9 (eqRobNew) 10
    static let ve8 = ["2+2x", "4x", "x+2+x", "x+x+2x", "2x+3-1", "0", "2x+2", "4x", "2+4x-2", "x+2x+x", "3x-x+2", "0"]
    static let ve9 = ["2+3x", "5x", "2x+2+x", "2x+x+2x", "3x+4-2", "0", "3x+2", "5x", "2+5x-2", "3x+x+x", "4x-x+2", "0"]
    // level 12 (cannon), 13, 15 (invisible), 16
    static let ve10 = ["x+1", "x+3", "2+x", "2x+1", "2+2x", "2x", "3x", "2x-1", "3x-1", "3x-2"]
    static let ve11 = ["x+1", "x+3", "2+x", "2x+1", "2+2x", "2x", "3x", "2x-1", "3x-1", "3x-2"]
    
    static let ves: [[String]] = [ve0, ve1, ve2, ve3, ve4, ve5, ve6, ve7, ve8, ve9, ve10, ve11]
    static let unSFrom = [11]
    
    static func getCategory(ve: String, completion: @escaping (Int) -> Void) {
        switch ve {
        case "x", "1×x", "x×1", "2x-x", "3x-2x", "2x+1-x-1", "3x-2-2x+2", "3+2x-3-x", "2-x-2+2x":
            return completion(0)
        case "2x", "2×x", "x×2", "3x-x", "4x-2x", "x+x", "3x+1-x-1", "4x-2-2x+2", "3+3x-3-x", "2-x-2+3x":
            return completion(1)
        case "3x", "3×x", "x×3", "x+x+x", "2x+x", "4x-x", "2×x+x", "4x+1-x-1", "5x-2-2x+2", "3+4x-3-x", "2-x-2+4x":
            return completion(2)
        case "x+1", "1+1×x", "x×1+1", "x+2-1", "3+x-2", "2x-x+1", "1+3x-2x":
            return completion(3)
        case "x+2", "2+x", "x×1+2", "x+4-2", "x+3-1", "2x-x+2", "3x-2x+2", "2+x×1", "4+x-2", "2x+2-x", "2+3x-2x", "2x+3-x-1", "3x-2-2x+4", "5+2x-3-x", "4-x-2+2x", "3-1+x", "x-1+3":
            return completion(4)
        case "x+3", "3+x", "3+x×1", "1×x+3", "x+4-1", "x+5-2", "2x-x+3", "3x-2x+3", "x-2+5", "2x+3-x", "3+3x-2x", "2x+4-x-1", "3x-2-2x+5", "6+2x-3-x", "5-x-2+2x", "4-1+x", "4+x-1":
            return completion(5)
        case "2x+1", "1+2x", "x×2+1", "x+1+x", "2x+3-2", "3x-x+1", "4x-2x+1", "x+x+1", "3+2x-2", "1+4x-2x", "3x+2-x-1", "4x-2-2x+3", "4+3x-3-x", "3-x-2+3x", "2x+2-1":
            return completion(6)
        case "2x+2", "2+2x", "x+x+2", "2+2×x", "x+2+x", "x×2+2", "2x+3-1", "4+2x-2", "3x-x+2", "2+4x-2x", "3x-x+3-1", "2x+3-1":
            return completion(7)
        case "2x-1", "x×2-1", "2x-2+1", "3x-x-1", "4x-2x-1", "x+x-1", "2x+1-2", "4x-1-2x", "x-1+x", "3x+1-x-2", "4x-3-2x+2", "3+3x-4-x", "2-x-3+3x":
            return completion(8)
        case "3x-1", "x×3-1", "3x-3+2", "4x-x-1", "5x-2x-1", "x+x+x-1", "3x+2-3", "5x-1-2x", "2x-1+x", "4x+1-x-2", "5x-3-2x+2", "3+4x-4-x", "2-x-3+4x", "2×x+x-1":
            return completion(9)
        case "3x-2", "x×3-2", "3x-3+1", "4x-x-2", "5x-2x-2", "x+x+x-2", "1+3x-3", "5x-2-2x", "2x-2+x", "4x+1-x-3", "5x-4-2x+2", "3+4x-5-x", "2-x-4+4x":
            return completion(10)
        case "3x+2", "2+3x", "5+3x-3", "5x-2x+2", "2+4x-x", "x+2+x+x", "4x-x+2", "2x+2+x", "4x-x+4-2", "3x+4-2":
            return completion(11)
        case "4x", "2x+2x", "3x+x", "x+x+2x", "4x-2+2", "2+2x+2x-2", "x+2x+x", "2+4x-2":
            return completion(12)
        case "5x", "2x+3x", "4x+x", "x+x+3x", "5x-2+2", "2x+x+2x", "2+2x+3x-2", "3x+x+x", "2+5x-2":
            return completion(13)
        default:
            return completion(1000)
        }
    }
    
    static let overs = [12, 13]
    
    static func checkOvers(ve: String, completion: @escaping (Bool) -> Void) {
        getCategory(ve: ve) { cate in
            if overs.contains(cate) {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }
    
    static func calculateValue(veCategory: Int, value: Int) -> Int {
        switch veCategory {
        case 0:
            return value
        case 1:
            return value*2
        case 2:
            return value*3
        case 3:
            return value+1
        case 4:
            return value+2
        case 5:
            return value+3
        case 6:
            return 2*value+1
        case 7:
            return 2*value+2
        case 8:
            return 2*value-1
        case 9:
            return 3*value-1
        case 10:
            return 3*value-2
        case 11:
            return 3*value+2
        case 12:
            return 4*value
        case 13:
            return 5*value
        default:
            return 1000
        }
    }
    
    // "x+1", "x+3", "2+x", "2x+1", "2+2x", "2x", "3x", "2x-1", "3x-1", "3x-2"
    public static func unSimplifiedVEs(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["1×x", "x×1", "2x-x", "3x-2x"]
            return ves
        case 1: // 2x using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["3x-x", "4x-2x", "x+x"]
            } else {
                ves = ["2×x", "x×2", "3x-x", "4x-2x", "x+x"]
            }
            return ves
        case 2: // 3x using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["2x+x", "4x-x", "x+x+x"]
            } else {
                ves = ["3×x", "x×3", "2x+x", "4x-x", "x+x+x", "2×x+x"]
            }
            return ves
        case 3: // x+1 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["3+x-2", "2x-x+1", "1+3x-2x"]
            } else {
                ves = ["1+1×x", "x×1+1", "x+2-1", "3+x-2", "2x-x+1", "1+3x-2x"]
            }
            return ves
        case 4: // x+2 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["4+x-2", "2x-x+2", "2+3x-2x"]
            } else {
                ves = ["2+x×1", "4+x-2", "2x+2-x", "2x-x+2", "2+3x-2x"]
            }
            return ves
        case 5: // x+3 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["x-2+5", "2x-x+3", "3+3x-2x"]
            } else {
                ves = ["1×x+3", "x-2+5", "2x+3-x", "2x-x+3", "3+3x-2x"]
            }

            return ves
        case 6: // 2x+1 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["3+2x-2", "3x-x+1", "1+4x-2x", "x+1+x"]
            } else {
                ves = ["x×2+1", "3+2x-2", "3x-x+1", "1+4x-2x", "x+1+x"]
            }
            return ves
        case 7: // 2x+2 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["4+2x-2", "3x-x+2", "2+4x-2x", "x+x+2"]
            } else {
                ves = ["2+2×x", "x×2+2", "2x+3-1", "4+2x-2", "3x-x+2", "2+4x-2x", "x+x+2"]
            }
            return ves
        case 8: // 2x-1 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["2x+1-2", "3x-x-1", "4x-1-2x", "x-1+x"]
            } else {
                ves = ["x×2-1", "2x+1-2", "3x-x-1", "4x-1-2x", "x-1+x"]
            }
            return ves
        case 9: // 3x-1 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["3x+2-3", "4x-x-1", "x+x+x-1", "2x-1+x"]
            } else {
                ves = ["x×3-1", "3x+2-3", "4x-x-1", "5x-1-2x", "x+x+x-1", "2x-1+x"]
            }
            return ves
        case 10: // 3x-2 using
            var ves = [String]()
            if GameScene.stageLevel == MainMenu.lastTurn {
                ves = ["1+3x-3", "5x-2-2x", "x+x+x-2", "2x-2+x"]
            } else {
                ves = ["x×3-2", "1+3x-3", "4x-x-2", "5x-2-2x", "x+x+x-2", "2x-2+x"]
            }
            return ves
        case 11: // 3x+2
            let ves = ["5+3x-3", "5x-2x+2", "2+4x-x", "x+2+x+x"]
            return ves
        case 12: // 4x
            let ves = ["2x+2x", "3x+x", "x+x+2x", "4x-2+2"]
            return ves
        case 13: // 5x
            let ves = ["2x+3x", "4x+x", "x+x+3x", "5x-2+2"]
            return ves
        default:
            return []
        }
    }
    
    public static func originVEsForEqRob(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["x"]
            return ves
        case 1: // 2x
            let ves = ["2x"]
            return ves
        case 2: // 3x
            let ves = ["3x"]
            return ves
        case 3: // x+1
            let ves = ["x+1", "1+x"]
            return ves
        case 4: // x+2
            if let _ = VEEquivalentController.gameScene as? ScenarioScene {
                let ves = ["x+2"]
                return ves
            } else {
                let ves = ["x+2", "2+x"]
                return ves
            }
        case 5: // x+3
            let ves = ["x+3", "3+x"]
            return ves
        case 6: // 2x+1
            let ves = ["2x+1", "1+2x"]
            return ves
        case 7: // 2x+2
            let ves = ["2x+2", "2+2x"]
            return ves
        case 8: // 2x-1
            let ves = ["2x-1"]
            return ves
        case 9: // 3x-1
            let ves = ["3x-1"]
            return ves
        case 10: // 3x-2
            let ves = ["3x-2"]
            return ves
        case 11: // 3x+2
            let ves = ["3x+2"]
            return ves
        case 12: // 4x
            let ves = ["4x"]
            return ves
        case 13: // 5x
            let ves = ["5x"]
            return ves
        default:
            return []
        }
    }
    
    public static func unSVEsForEqRob(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["2x-x", "3x-2x"]
            return ves
        case 1: // 2x
            let ves = ["3x-x", "4x-2x", "x+x"]
            return ves
        case 2: // 3x
            let ves = ["2x+x", "4x-x", "x+x+x", "2×x+x"]
            return ves
        case 3: // x+1
            let ves = ["x+2-1", "3+x-2", "2x-x+1", "1+3x-2x"]
            return ves
        case 4: // x+2
            let ves = ["x-1+3", "4+x-2", "2x-x+2", "2+3x-2x"]
            return ves
        case 5: // x+3
            let ves = ["x-2+5", "4+x-1", "2x-x+3", "3+3x-2x"]
            return ves
        case 6: // 2x+1
            let ves = ["2x+2-1", "3+2x-2", "3x-x+1", "1+4x-2x", "x+x+1", "x+1+x"]
            return ves
        case 7: // 2x+2
            let ves = ["2x+3-1", "4+2x-2", "3x-x+2", "2+4x-2x", "x+x+2"]
            return ves
        case 8: // 2x-1
            let ves = ["2x+1-2", "3x-x-1", "4x-1-2x", "x+x-1"]
            return ves
        case 9: // 3x-1
            let ves = ["3x+2-3", "4x-x-1", "5x-1-2x", "x+x+x-1", "2×x+x-1"]
            return ves
        case 10: // 3x-2
            let ves = ["1+3x-3", "4x-x-2", "5x-2-2x", "x+x+x-2", "2×x+x-2"]
            return ves
        case 11: // 3x+2
            let ves = ["5+3x-3", "5x-2x+2", "2+4x-x", "x+2+x+x"]
            return ves
        case 12: // 4x
            let ves = ["2x+2x", "3x+x", "x+x+2x", "4x-2+2"]
            return ves
        case 13: // 5x
            let ves = ["2x+3x", "4x+x", "x+x+3x", "5x-2+2"]
            return ves
        default:
            return []
        }
    }
    
    public static func unSimplifiedHardVEs(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["2x+1-x-1", "3x-2-2x+2", "3+2x-3-x", "2-x-2+2x"]
            return ves
        case 1: // 2x
            let ves = ["3x+1-x-1", "4x-2-2x+2", "3+3x-3-x", "2-x-2+3x"]
            return ves
        case 2: // 3x
            let ves = ["4x+1-x-1", "5x-2-2x+2", "3+4x-3-x", "2-x-2+4x"]
            return ves
        case 4: // x+2
            let ves = ["2x+3-x-1", "3x-2-2x+4", "5+2x-3-x", "4-x-2+2x"]
            return ves
        case 5: // x+3
            let ves = ["2x+4-x-1", "3x-2-2x+5", "6+2x-3-x", "5-x-2+2x"]
            return ves
        case 6: // 2x+1
            let ves = ["3x+2-x-1", "4x-2-2x+3", "4+3x-3-x", "3-x-2+3x"]
            return ves
        case 8: // 2x-1
            let ves = ["3x+1-x-2", "4x-3-2x+2", "3+3x-4-x", "2-x-3+3x"]
            return ves
        case 9: // 3x-1
            let ves = ["4x+1-x-2", "5x-3-2x+2", "3+4x-4-x", "2-x-3+4x"]
            return ves
        case 10: // 3x-2
            let ves = ["4x+1-x-3", "5x-4-2x+2", "3+4x-5-x", "2-x-4+4x"]
            return ves
        default:
            return ["2x"]
        }
    }
    
    
    public static func wrongableVEs(ve: String) -> [String] {
        switch ve {
        case "x+2", "2+x":
            return ["2x"]
        case "x+3", "3+x":
            return ["3x"]
        case "2x+1", "1+2x":
            return ["3x"]
        case "2x-1":
            return ["x"]
        case "3x-1":
            return ["2x"]
        case "3x-2":
            return ["x"]
        case "2x":
            return ["x+2", "2+x", "3x-1"]
        case "3x":
            return ["x+3", "3+x"]
        case "2x+2", "2+2x":
            return ["4x"]
        case "3x+2", "2+3x":
            return ["5x"]
        case "4x":
            return ["2x+2", "2+2x"]
        case "5x":
            return ["2x+3", "3+2x"]
        default:
            return ["x+1"]
        }
    }
    static func getUnsimplified(source: [String], completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var ves = [String]()
        for ve in source {
            dispatchGroup.enter()
            getCategory(ve: ve) { cate in
                ves.append(contentsOf: unSimplifiedVEs(veCate: cate))
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(ves)
        })
    }
    
    static func getUnsimplifiedSingle(source: String, completion: @escaping ([String]) -> Void) {
        getCategory(ve: source) { cate in
            return completion(unSimplifiedVEs(veCate: cate))
        }
    
    }
}
