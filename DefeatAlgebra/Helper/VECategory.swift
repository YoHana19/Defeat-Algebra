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
    // level 8 (eqRob), 9, 10, 13, 14
    static let ve6 = ["x+2", "x+3", "2+x", "3+x", "2x+1", "1+2x", "2x-1", "3x-1", "3x-2"]
    // level 11 (second day)
    static let ve7 = ["x+1", "3+x", "2x"]
    // level 12, 16(cannon), 17, 18(invisible), 19
    static let ve8 = ["x+1", "x+3", "2+x", "2x+1", "2+2x", "x", "2x", "3x", "2x-1", "3x-1", "3x-2"]
    static let ve9 = ["x+1", "x+3", "2+x", "2x+1", "2+2x", "x", "2x", "3x", "2x-1", "3x-1", "3x-2"]
    
    static let ves: [[String]] = [ve0, ve1, ve2, ve3, ve4, ve5, ve6, ve7, ve8, ve9]
    static let unSFrom = [9]
    
    static func getCategory(ve: String, completion: @escaping (Int) -> Void) {
        switch ve {
        case "x", "1x", "2x-x", "0+x", "x+0", "0+1x", "1x+0", "1×x", "x×1", "x+1-1", "x+2-2", "x+3-3", "x-1+1", "x-2+2", "x-3+3", "1+x-1", "2+x-2", "3+x-3", "1-1+x", "2-2+x", "3-3+x", "3x-2x", "3x-x-x", "2x+1-x-1", "3x-2-2x+2", "3+2x-3-x", "2-x-2+2x":
            return completion(0)
        case "2x", "3x-x", "x+x", "1x+x", "x+1x", "2x+0", "0+2x", "2×x", "x×2", "2x+1-1", "2x+2-2", "2x+3-3", "2x-1+1", "2x-2+2", "2x-3+3", "1+2x-1", "2+2x-2", "3+2x-3", "1-1+2x", "3x+1-x-1", "4x-2-2x+2", "3+3x-3-x", "2-x-2+3x", "2-2+2x", "3-3+2x", "4x-2x":
            return completion(1)
        case "3x", "4x-x", "2x+x", "x+2x", "3x+0", "0+3x", "3×x", "x×3", "3x+1-1", "3x+2-2", "3x+3-3", "3x-1+1", "3x-2+2", "3x-3+3", "1+3x-1", "2+3x-2", "3+3x-3", "1-1+3x", "2-2+3x", "3-3+3x", "x+x+x", "2×x+x", "4x+1-x-1", "5x-2-2x+2", "3+4x-3-x", "2-x-2+4x":
            return completion(2)
        case "x+1", "1x+1", "1+x", "1+1x", "1+1×x", "1+x×1", "1×x+1", "x×1+1", "x+2-1", "x+3-2", "x+4-3", "x-1+2", "x-2+3", "x-3+4", "2+x-1", "3+x-2", "4+x-3", "2-1+x", "3-2+x", "4-3+x", "2x-x+1", "1+3x-2x", "2x+1-x":
            return completion(3)
        case "x+2", "1x+2", "2+x", "2+1x", "2+1×x", "2+x×1", "1×x+2", "x×1+2", "x+3-1", "x+4-2", "x+5-3", "x-1+3", "x-2+4", "x-3+5", "3+x-1", "4+x-2", "5+x-3", "3-1+x", "4-2+x", "5-3+x", "2x-x+2", "2+3x-2x", "2x+2-x", "2x+3-x-1", "3x-2-2x+4", "5+2x-3-x", "4-x-2+2x":
            return completion(4)
        case "x+3", "1x+3", "3+x", "3+1x", "3+1×x", "3+x×1", "1×x+3", "x×1+3", "x+4-1", "x+5-2", "x+6-3", "x-1+4", "x-2+5", "x-3+6", "4+x-1", "5+x-2", "6+x-3", "4-1+x", "5-2+x", "6-3+x", "2x-x+3", "3+3x-2x", "2x+4-x-1", "3x-2-2x+5", "6+2x-3-x", "5-x-2+2x", "2x+3-x":
            return completion(5)
        case "2x+1", "1+2x", "1+2×x", "1+x×2", "2×x+1", "x×2+1", "2x+2-1", "2x+3-2", "2x+4-3", "2x-1+2", "2x-2+3", "2x-3+4", "2+2x-1", "3+2x-2", "4+2x-3", "2-1+2x", "3-2+2x", "4-3+2x", "3x-x+1", "1+3x-x", "1+4x-2x", "x+x+1", "1+x+x", "x+1+x", "3x+2-x-1", "4x-2-2x+3", "4+3x-3-x", "3-x-2+3x":
            return completion(6)
        case "2x+2", "2+2x", "2+2×x", "2+x×2", "2×x+2", "x×2+2", "2x+3-1", "2x+4-2", "2x+5-3", "2x-1+3", "2x-2+4", "2x-3+5", "3+2x-1", "4+2x-2", "5+2x-3", "3-1+2x", "4-2+2x", "5-3+2x", "3x-x+2", "2+4x-2x", "x+x+2", "2+x+x", "x+2+x", "3x+2-x":
            return completion(7)
        case "2x+3", "3+2x", "3+2×x", "3+x×2", "2×x+3", "x×2+3", "2x+4-1", "2x+5-2", "2x+6-3", "2x-1+4", "2x-2+5", "2x-3+6", "4+2x-1", "5+2x-2", "6+2x-3", "4-1+2x", "5-2+2x", "6-3+2x", "3x-x+3", "3+4x-2x", "x+x+3":
            return completion(8)
        case "3x+1", "1+3x", "1+3×x", "1+x×3", "3×x+1", "x×3+1", "3x+2-1", "3x+3-2", "3x+4-3", "3x-1+2", "3x-2+3", "3x-3+4", "2+3x-1", "3+3x-2", "4+3x-3", "2-1+3x", "3-2+3x", "4-3+3x", "4x-x+1", "1+5x-2x", "x+x+x+1", "2x+x+1":
            return completion(9)
        case "3x+2", "2+3x", "2+3×x", "2+x×3", "3×x+2", "x×3+2", "3x+3-1", "3x+4-2", "3x+5-3", "3x-1+3", "3x-2+4", "3x-3+5", "3+3x-1", "4+3x-2", "5+3x-3", "3-1+3x", "4-2+3x", "5-3+3x", "4x-x+2", "2+5x-2x", "x+x+x+2", "2x+x+2":
            return completion(10)
        case "3x+3", "3+3x", "3+3×x", "3+x×3", "3×x+3", "x×3+3", "3x+4-1", "3x+5-2", "3x+6-3", "3x-1+4", "3x-2+5", "3x-3+6", "4+3x-1", "5+3x-2", "6+3x-3", "4-1+3x", "5-2+3x", "6-3+3x", "4x-x+3", "3+5x-2x", "x+x+x+3", "2x+x+3":
            return completion(11)
        case "2x-1", "2×x-1", "x×2-1", "2x+1-2", "2x+2-3", "2x+3-4", "2x-2+1", "2x-3+2", "2x-4+3", "1+2x-2", "2+2x-3", "3+2x-4", "1-2+2x", "2-3+2x", "3-4+2x", "3x-x-1", "4x-1-2x", "x+x-1", "3x+1-x-2", "4x-3-2x+2", "3+3x-4-x", "2-x-3+3x":
            return completion(12)
        case "3x-1", "3×x-1", "x×3-1", "3x+1-2", "3x+2-3", "3x+3-4", "3x-2+1", "3x-3+2", "3x-4+3", "1+3x-2", "2+3x-3", "3+3x-4", "1-2+3x", "2-3+3x", "3-4+3x", "4x-x-1", "5x-1-2x", "x+x+x-1", "2×x+x-1", "4x+1-x-2", "5x-3-2x+2", "3+4x-4-x", "2-x-3+4x", "2x-1+x":
            return completion(13)
        case "3x-2", "3×x-2", "x×3-2", "3x+1-3", "3x+2-4", "3x+3-5", "3x-3+1", "3x-4+2", "3x-5+3", "1+3x-3", "2+3x-4", "3+3x-5", "1-3+3x", "2-4+3x", "3-5+3x", "4x-x-2", "5x-2-2x", "x+x+x-2", "2×x+x-2", "4x+1-x-3", "5x-4-2x+2", "3+4x-5-x", "2-x-4+4x", "2x-2+x":
            return completion(14)
        case "4x-1", "4×x-1", "x×4-1", "4x+1-2", "4x+2-3", "4x+3-4", "4x-2+1", "4x-3+2", "4x-4+3", "1+4x-2", "2+4x-3", "3+4x-4", "1-2+4x", "2-3+4x", "3-4+4x":
            return completion(15)
        case "4x-2", "4×x-2", "x×4-2", "4x+1-3", "4x+2-4", "4x+3-5", "4x-3+1", "4x-4+2", "4x-5+3", "1+4x-3", "2+4x-4", "3+4x-5", "1-3+4x", "2-4+4x", "3-5+4x":
            return completion(16)
        case "4x-3", "4×x-3", "x×4-3", "4x+1-4", "4x+2-5", "4x+3-6", "4x-4+1", "4x-5+2", "4x-6+3", "1+4x-4", "2+4x-5", "3+4x-6", "1-4+4x", "2-5+4x", "3-6+4x":
            return completion(17)
        case "4-x", "4-1x", "4-1×x", "4-x×1":
            return completion(18)
        case "7-2x", "7-2×x", "7-x×2":
            return completion(19)
        case "8-2x", "8-2×x", "8-x×2":
            return completion(20)
        default:
            return completion(1000)
        }
    }
    
    // "x+2", "x+3", "2+x", "3+x", "2x+1", "1+2x", "2x-1", "3x-1", "3x-2"
    public static func unSimplifiedVEs(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["1×x", "x×1", "2x-x", "3x-2x"]
            return ves
        case 1: // 2x
            let ves = ["2×x", "x×2", "3x-x", "4x-2x", "x+x"]
            return ves
        case 2: // 3x
            let ves = ["3×x", "x×3", "2x+x", "4x-x", "x+x+x", "2×x+x"]
            return ves
        case 3: // x+1
            let ves = ["1+1×x", "x×1+1", "x+2-1", "3+x-2", "2x-x+1", "1+3x-2x"]
            return ves
        case 4: // x+2
            let ves = ["2+x×1", "4+x-2", "2x+2-x", "2x-x+2", "2+3x-2x"]
            return ves
        case 5: // x+3
            let ves = ["1×x+3", "x-2+5", "2x+3-x", "2x-x+3", "3+3x-2x"]
            return ves
        case 6: // 2x+1
            let ves = ["x×2+1", "3+2x-2", "3x-x+1", "1+4x-2x", "x+1+x"]
            return ves
        case 7: // 2x+2
            let ves = ["2+2×x", "x×2+2", "2x+3-1", "4+2x-2", "3x-x+2", "2+4x-2x", "x+x+2"]
            return ves
        case 8: // 2x+3
            let ves = ["3+2×x", "x×2+3", "2x+4-1", "5+2x-2", "3x-x+3", "3+4x-2x", "x+x+3"]
            return ves
        case 9: // 3x+1
            let ves = ["1+3×x", "x×3+1", "3x+2-1", "3+3x-2", "4x-x+1", "1+5x-2x", "x+x+x+1", "2x+x+1"]
            return ves
        case 10: // 3x+2
            let ves = ["2+3×x", "x×3+2", "3x+3-1", "4+3x-2", "4x-x+2", "2+5x-2x", "x+x+x+2", "2x+x+2"]
            return ves
        case 11: // 3x+3
            let ves = ["3+3×x", "x×3+3", "3x+4-1", "5+3x-2", "4x-x+3", "3+5x-2x", "x+x+x+3", "2x+x+3"]
            return ves
        case 12: // 2x-1
            let ves = ["x×2-1", "2x+1-2", "3x-x-1", "4x-1-2x", "x+x-1"]
            return ves
        case 13: // 3x-1
            let ves = ["x×3-1", "3x+2-3", "4x-x-1", "5x-1-2x", "x+x+x-1", "2x-1+x"]
            return ves
        case 14: // 3x-2
            let ves = ["x×3-2", "1+3x-3", "4x-x-2", "5x-2-2x", "x+x+x-2", "2x-2+x"]
            return ves
        case 15: // 4x-1
            let ves = ["4×x-1", "x×4-1", "4x+1-2", "4x+2-3", "4x+3-4", "4x-2+1", "4x-3+2", "4x-4+3", "1+4x-2", "2+4x-3", "3+4x-4", "1-2+4x", "2-3+4x", "3-4+4x"]
            return ves
        case 16: // 4x-2
            let ves = ["4×x-2", "x×4-2", "4x+1-3", "4x+2-4", "4x+3-5", "4x-3+1", "4x-4+2", "4x-5+3", "1+4x-3", "2+4x-4", "3+4x-5", "1-3+4x", "2-4+4x", "3-5+4x"]
            return ves
        case 17: // 4x-3
            let ves = ["4×x-3", "x×4-3", "4x+1-4", "4x+2-5", "4x+3-6", "4x-4+1", "4x-5+2", "4x-6+3", "1+4x-4", "2+4x-5", "3+4x-6", "1-4+4x", "2-5+4x", "3-6+4x"]
            return ves
        default:
            return []
        }
    }
    
    public static func vEsForEqRob(veCate: Int) -> [String] {
        switch veCate {
        case 0: // x
            let ves = ["x", "1×x", "x×1", "2x-x", "3x-2x"]
            return ves
        case 1: // 2x
            let ves = ["2x", "2×x", "x×2", "3x-x", "4x-2x", "x+x"]
            return ves
        case 2: // 3x
            let ves = ["3x", "3×x", "x×3", "2x+x", "4x-x", "x+x+x", "2×x+x"]
            return ves
        case 3: // x+1
            let ves = ["x+1", "1+x", "1+1×x", "x×1+1", "x+2-1", "3+x-2", "2x-x+1", "1+3x-2x"]
            return ves
        case 4: // x+2
            let ves = ["x+2", "2+x", "2+x×1", "1×x+2", "x-1+3", "4+x-2", "2x-x+2", "2+3x-2x"]
            return ves
        case 5: // x+3
            let ves = ["x+3", "3+x", "3+x×1", "1×x+3", "x-2+5", "4+x-1", "2x-x+3", "3+3x-2x"]
            return ves
        case 6: // 2x+1
            let ves = ["2x+1", "1+2x", "1+2×x", "x×2+1", "2x+2-1", "3+2x-2", "3x-x+1", "1+4x-2x", "x+x+1", "x+1+x"]
            return ves
        case 7: // 2x+2
            let ves = ["2x+2", "2+2x", "2+2×x", "x×2+2", "2x+3-1", "4+2x-2", "3x-x+2", "2+4x-2x", "x+x+2"]
            return ves
        case 8: // 2x+3
            let ves = ["2x+3", "3+2x", "3+2×x", "x×2+3", "2x+4-1", "5+2x-2", "3x-x+3", "3+4x-2x", "x+x+3"]
            return ves
        case 9: // 3x+1
            let ves = ["3x+1", "1+3x", "1+3×x", "x×3+1", "3x+2-1", "3+3x-2", "4x-x+1", "1+5x-2x", "x+x+x+1", "2x+x+1"]
            return ves
        case 10: // 3x+2
            let ves = ["3x+2", "2+3x", "2+3×x", "x×3+2", "3x+3-1", "4+3x-2", "4x-x+2", "2+5x-2x", "x+x+x+2", "2x+x+2"]
            return ves
        case 11: // 3x+3
            let ves = ["3x+3", "3+3x", "3+3×x", "x×3+3", "3x+4-1", "5+3x-2", "4x-x+3", "3+5x-2x", "x+x+x+3", "2x+x+3"]
            return ves
        case 12: // 2x-1
            let ves = ["2x-1", "2×x-1", "x×2-1", "2x+1-2", "3x-x-1", "4x-1-2x", "x+x-1"]
            return ves
        case 13: // 3x-1
            let ves = ["3x-1", "3×x-1", "x×3-1", "3x+2-3", "4x-x-1", "5x-1-2x", "x+x+x-1", "2×x+x-1"]
            return ves
        case 14: // 3x-2
            let ves = ["3x-2", "3×x-2", "x×3-2", "1+3x-3", "4x-x-2", "5x-2-2x", "x+x+x-2", "2×x+x-2"]
            return ves
        case 15: // 4x-1
            let ves = ["4x-1", "4×x-1", "x×4-1", "4x+1-2", "4x+2-3", "4x+3-4", "4x-2+1", "4x-3+2", "4x-4+3", "1+4x-2", "2+4x-3", "3+4x-4", "1-2+4x", "2-3+4x", "3-4+4x"]
            return ves
        case 16: // 4x-2
            let ves = ["4x-2", "4×x-2", "x×4-2", "4x+1-3", "4x+2-4", "4x+3-5", "4x-3+1", "4x-4+2", "4x-5+3", "1+4x-3", "2+4x-4", "3+4x-5", "1-3+4x", "2-4+4x", "3-5+4x"]
            return ves
        case 17: // 4x-3
            let ves = ["4x-3", "4×x-3", "x×4-3", "4x+1-4", "4x+2-5", "4x+3-6", "4x-4+1", "4x-5+2", "4x-6+3", "1+4x-4", "2+4x-5", "3+4x-6", "1-4+4x", "2-5+4x", "3-6+4x"]
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
        case 12: // 2x-1
            let ves = ["3x+1-x-2", "4x-3-2x+2", "3+3x-4-x", "2-x-3+3x"]
            return ves
        case 13: // 3x-1
            let ves = ["4x+1-x-2", "5x-3-2x+2", "3+4x-4-x", "2-x-3+4x"]
            return ves
        case 14: // 3x-2
            let ves = ["4x+1-x-3", "5x-4-2x+2", "3+4x-5-x", "2-x-4+4x"]
            return ves
        default:
            return ["x+1+x+2"]
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
            return 2*value+3
        case 9:
            return 3*value+1
        case 10:
            return 3*value+2
        case 11:
            return 3*value+3
        case 12:
            return 2*value-1
        case 13:
            return 3*value-1
        case 14:
            return 3*value-2
        case 15:
            return 4*value-1
        case 16:
            return 4*value-2
        case 17:
            return 4*value-3
        case 18:
            return 4-value
        case 19:
            return 7-2*value
        case 20:
            return 8-2*value
        default:
            return 1000
        }
    }
    
    public static func wrongableVEs(ve: String) -> [String] {
        switch ve {
        case "x+2":
            return ["2x"]
        case "2+x":
            return ["2x"]
        case "x+3":
            return ["3x"]
        case "3+x":
            return ["3x"]
        case "2x+1":
            return ["3x"]
        case "1+2x":
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
        default:
            return ["x+1"]
        }
    }
    static func getUnsimplified(source: [String], completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var ves =  source
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
