//
//  EnemyEqDemo.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/07.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

extension Enemy {
    
    func setDemoCalcLabel() {
        demoCalcLabel.fontSize = 30
        demoCalcLabel.verticalAlignmentMode = .center
        demoCalcLabel.horizontalAlignmentMode = .center
        demoCalcLabel.position = CGPoint(x: 0, y: 0)
        demoCalcLabel.zPosition = 5
        demoCalcLabel.fontColor = UIColor.white
        self.addChild(demoCalcLabel)
        demoCalcLabel.isHidden = true
    }
    
    public func showCalculation(pos: CGPoint, value: Int) {
        demoCalcLabel.isHidden = false
        demoCalcLabel.position = pos
        demoCalculation(value: value)
    }
    
    private func demoCalculation(value: Int) {
        var xPos = [Int]()
        var xPosOrigin = [Int]()
        var charaIndex = -1
        var characters = variableExpressionString.map { String($0) }
        let dispatchGroup = DispatchGroup()
        for (i, c) in characters.enumerated() {
            charaIndex += 1
            dispatchGroup.enter()
            if c == "x" {
                xPosOrigin.append(i)
                if i > 0 {
                    if characters[i-1] == "+" || characters[i-1] == "-" || characters[i-1] == "×" {
                        xPos.append(charaIndex)
                        characters[i] = String(value)
                        dispatchGroup.leave()
                    } else {
                        charaIndex += 1
                        xPos.append(charaIndex)
                        characters[i] = "×" + String(value)
                        dispatchGroup.leave()
                    }
                } else {
                    xPos.append(charaIndex)
                    characters[i] = String(value)
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            var numForm = ""
            characters.forEach { numForm += $0 }
            let result = VECategory.calculateValue(veCategory: self.vECategory, value: value)
            self.demoCalcLabel.text = self.variableExpressionString + "=" + numForm + "=" + String(result)
            let attrText = NSMutableAttributedString(string: self.demoCalcLabel.text!)
            let font = UIFont(name: DAFont.fontName, size: 30) ?? UIFont.systemFont(ofSize: 30)
            attrText.addAttributes([.foregroundColor: UIColor.white, .font: font], range: NSMakeRange(0, self.demoCalcLabel.text!.count))
            for pos in xPos {
                attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(self.variableExpressionString.count+1+pos, 1))
            }
            for pos in xPosOrigin {
                attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(pos, 1))
            }
            if result > 9 {
                attrText.addAttribute(.foregroundColor, value: UIColor.green, range: NSMakeRange(self.demoCalcLabel.text!.count-2, 2))
            } else {
                attrText.addAttribute(.foregroundColor, value: UIColor.green, range: NSMakeRange(self.demoCalcLabel.text!.count-1, 1))
            }
            if #available(iOS 11.0, *) {
                self.demoCalcLabel.attributedText = attrText
            }
        })
    }
    
    
    
}
