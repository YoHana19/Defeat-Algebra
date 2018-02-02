//
//  DAUtility.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/02/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

class DAUtility {
    static func getTwoRandomNumber(total: Int, completion: @escaping ([Int]) -> Void) {
        let num1 = Int(arc4random_uniform(UInt32(total)))
        var array:[Int] = ([Int])(0...total-1).filter{ $0 != num1 }
        let ran = arc4random_uniform(UInt32(total-1))
        let num2 = array[Int(ran)]
        return completion([num1, num2])
    }
}
