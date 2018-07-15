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
        case "x", "1x", "2x-x", "0+x", "x+0", "0+1x", "1x+0":
            return completion(0)
        case "2x", "3x-x", "x+x", "1x+x", "x+1x", "2x+0", "0+2x":
            return completion(1)
        case "3x", "4x-x", "2x+x", "x+2x", "3x+0", "0+3x":
            return completion(2)
        case "x+1", "1x+1", "1+x", "1+1x":
            return completion(3)
        case "x+2", "1x+2", "2+x", "2+1x":
            return completion(4)
        case "x+3", "1x+3", "3+x", "3+1x":
            return completion(5)
        case "2x+1", "1+2x":
            return completion(6)
        case "2x+2", "2+2x":
            return completion(7)
        case "2x+3", "3+2x":
            return completion(8)
        case "3x+1", "1+3x":
            return completion(9)
        case "3x+2", "2+3x":
            return completion(10)
        case "3x+3", "3+3x":
            return completion(11)
        case "2x-1":
            return completion(12)
        case "3x-1":
            return completion(13)
        case "3x-2":
            return completion(14)
        case "4x-1":
            return completion(15)
        case "4x-2":
            return completion(16)
        case "4x-3":
            return completion(17)
        case "4-x", "4-1x":
            return completion(18)
        case "7-2x":
            return completion(19)
        case "8-2x":
            return completion(20)
        default:
            return completion(1000)
        }
    }
}
