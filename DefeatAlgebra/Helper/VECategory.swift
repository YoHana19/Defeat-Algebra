//
//  VECategory.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

struct VECategory {
    static func getCategory(ve: String, completion: @escaping (Int) -> Void) {
        switch ve {
        case "x", "1x", "2x-x", "0+x", "x+0", "0+1x", "1x+0", "1×x", "x×1":
            return completion(0)
        case "2x", "3x-x", "x+x", "1x+x", "x+1x", "2x+0", "0+2x", "2×x", "x×2":
            return completion(1)
        case "3x", "4x-x", "2x+x", "x+2x", "3x+0", "0+3x", "3×x", "x×3":
            return completion(2)
        case "x+1", "1x+1", "1+x", "1+1x", "1+1×x", "1+x×1", "1×x+1", "x×1+1":
            return completion(3)
        case "x+2", "1x+2", "2+x", "2+1x", "2+1×x", "2+x×1", "1×x+2", "x×1+2":
            return completion(4)
        case "x+3", "1x+3", "3+x", "3+1x", "3+1×x", "3+x×1", "1×x+3", "x×1+3":
            return completion(5)
        case "2x+1", "1+2x", "1+2×x", "1+x×2", "2×x+1", "x×2+1":
            return completion(6)
        case "2x+2", "2+2x", "2+2×x", "2+x×2", "2×x+2", "x×2+2":
            return completion(7)
        case "2x+3", "3+2x", "3+2×x", "3+x×2", "2×x+3", "x×2+3":
            return completion(8)
        case "3x+1", "1+3x", "1+3×x", "1+x×3", "3×x+1", "x×3+1":
            return completion(9)
        case "3x+2", "2+3x", "2+3×x", "2+x×3", "3×x+2", "x×3+2":
            return completion(10)
        case "3x+3", "3+3x", "3+3×x", "3+x×3", "3×x+3", "x×3+3":
            return completion(11)
        case "2x-1", "2×x-1", "x×2-1":
            return completion(12)
        case "3x-1", "3×x-1", "x×3-1":
            return completion(13)
        case "3x-2", "3×x-2", "x×3-2":
            return completion(14)
        case "4x-1", "4×x-1", "x×4-1":
            return completion(15)
        case "4x-2", "4×x-2", "x×4-2":
            return completion(16)
        case "4x-3", "4×x-3", "x×4-3":
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
}
