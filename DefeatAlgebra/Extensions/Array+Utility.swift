//
//  Array+Utility.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func shuffle() {
        for i in 0..<self.count {
            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
    
    var shuffled: Array {
        var copied = Array<Element>(self)
        copied.shuffle()
        return copied
    }
}
