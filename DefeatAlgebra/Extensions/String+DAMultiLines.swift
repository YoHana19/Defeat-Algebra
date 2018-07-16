//
//  String+DAMultiLines.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

extension String {
    func DAMultilined(completion: @escaping (String) -> Void) {
        let length = 10 // num of max characters in single line
        var multiLine = ""
        let substrings: [String] = self.components(separatedBy: "\n")
        let dispachGroup = DispatchGroup()
        for (i, line) in substrings.enumerated() {
            dispachGroup.enter()
            line.insertNewLine(length) { newLine in
                if i < substrings.count-1 {
                    multiLine = multiLine + newLine + "\n"
                } else {
                    multiLine += newLine
                }
                dispachGroup.leave()
            }
        }
        dispachGroup.notify(queue: .main, execute: {
            return completion(multiLine)
        })
    }
    
    func insertNewLine(_ length: Int, completion: @escaping (String) -> Void) {
        var str = self
        let dispachGroup = DispatchGroup()
        for i in 0 ..< (str.count - 1) / max(length, 1) {
            dispachGroup.enter()
            str.insert("*", at: str.index(str.startIndex, offsetBy: (i + 1) * max(length, 1) + i))
            dispachGroup.leave()
        }
        dispachGroup.notify(queue: .main, execute: {
            return completion(str.replacingOccurrences(of: "*", with: "\n"))
        })
    }
}
