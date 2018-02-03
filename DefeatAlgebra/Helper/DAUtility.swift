//
//  DAUtility.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

class DAUtility {
    static func getRandomNumbers(total: Int, times: Int, completion: @escaping ([Int]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var nums = [Int]()
        var array: [Int] = ([Int])(0...total)
        for i in 0..<times {
            dispatchGroup.enter()
            let random = Int(arc4random_uniform(UInt32(total-i)))
            let num = array[random]
            nums.append(num)
            array = array.filter{ $0 != num }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(nums)
        })
    }
}
