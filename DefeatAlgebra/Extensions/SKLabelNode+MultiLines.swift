//
//  SKLabelNode+MultiLines.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension SKLabelNode {
    func multilined() -> SKLabelNode {
        let substrings: [String] = self.text!.components(separatedBy: "\n")
        return substrings.enumerated().reduce(SKLabelNode()) {
            let label = SKLabelNode(fontNamed: self.fontName)
            label.text = $1.element
            label.fontColor = self.fontColor
            label.fontSize = self.fontSize
            label.position = self.position
            label.zPosition = self.zPosition
            label.horizontalAlignmentMode = self.horizontalAlignmentMode
            label.verticalAlignmentMode = self.verticalAlignmentMode
            let y = CGFloat($1.offset - substrings.count / 2) * (self.fontSize + 15)
            label.position = CGPoint(x: 0, y: -y)
            $0.addChild(label)
            return $0
        }
    }
    
    func multilinedForVE(completion: @escaping (SKLabelNode) -> Void) {
        let substrings: [String] = self.text!.components(separatedBy: "\n")
        let labelTop = SKLabelNode(fontNamed: self.fontName)
        labelTop.text = substrings[0]
        labelTop.fontColor = self.fontColor
        labelTop.fontSize = self.fontSize
        labelTop.position = self.position
        labelTop.zPosition = self.zPosition
        labelTop.horizontalAlignmentMode = .center
        labelTop.verticalAlignmentMode = .top
        let dispatchGroup = DispatchGroup()
        for (i, text) in substrings.enumerated() {
            if i == 0 { continue }
            dispatchGroup.enter()
            let label = SKLabelNode(fontNamed: self.fontName)
            label.text = text
            label.fontColor = self.fontColor
            label.fontSize = self.fontSize
            label.zPosition = self.zPosition
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .top
            let y = (self.fontSize) * CGFloat(i)
            label.position = CGPoint(x: 0, y: -y)
            labelTop.addChild(label)
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(labelTop)
        })
    }
}
