//
//  EqVESimulator.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/04.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqVESimulator: SKLabelNode {
    
    var veUnit = [EqVeUnit]()
    var tempIsPositive: Bool = true
    var isKeisu: Bool = false
    var tempString: String = ""
    var gap: CGFloat = 10
    var currentForcus = 0
    let result = SKLabelNode(fontNamed: DAFont.fontName)
    let resultX = SKLabelNode(fontNamed: DAFont.fontName)
    let xLabel = SKLabelNode(fontNamed: DAFont.fontName)
    let resultNum = SKLabelNode(fontNamed: DAFont.fontName)
    var lastKeisu = 0
    
    init(text: String) {
        super.init()
        setVe(text: text) {
            self.positioning()
        }
        self.fontName = DAFont.fontName
        zPosition = 3
        setResult()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func activate() {
        guard veUnit.count > 0 else { return }
        if currentForcus < veUnit.count {
            if currentForcus == 0 {
                veUnit[currentForcus].isActive = true
            } else {
                veUnit[currentForcus-1].isActive = false
                veUnit[currentForcus].isActive = true
                positioning()
                showResult()
            }
        } else if currentForcus == veUnit.count {
            veUnit[currentForcus-1].isActive = false
            positioning()
            showResult()
            VEEquivalentController.doneSim()
        }
        currentForcus += 1
    }
    
    func setVe(text: String, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        splitByOperant(text: text) { units in
            for (i, unit) in units.enumerated() {
                dispatchGroup.enter()
                if (i == 0) {
                    self.setLabel(unit: unit, isFirst: true) {
                        dispatchGroup.leave()
                    }
                } else {
                    self.setLabel(unit: unit) {
                        dispatchGroup.leave()
                    }
                }
                
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion()
            })
        }
    }
    
    func splitByOperant(text: String, completion: @escaping ([(Bool, String)]) -> Void) {
        var tempUnit = [(Bool, String)]()
        let dispatchGroup = DispatchGroup()
        for (i, c) in text.enumerated() {
            dispatchGroup.enter()
            let s = String(c)
            if i == text.count - 1 {
                tempString += s
                tempUnit.append((tempIsPositive, tempString))
            } else {
                if s == "+" {
                    tempUnit.append((tempIsPositive, tempString))
                    tempIsPositive = true
                    tempString = ""
                } else if s == "-" {
                    tempUnit.append((tempIsPositive, tempString))
                    tempIsPositive = false
                    tempString = ""
                } else {
                    tempString += s
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(tempUnit)
        })
    }
    
    func setLabel(unit: (Bool, String), isFirst: Bool = false, completion: @escaping () -> Void) {
        let isPositive = unit.0
        let ve = unit.1
        if ve.count == 1 {
            if ve == "x" {
                setX(isPositive: isPositive, isFirst: isFirst) {
                    return completion()
                }
            } else {
                setNum(num: Int(ve)!, isPositive: isPositive, isFirst: isFirst) {
                    return completion()
                }
            }
        } else if ve.count == 2 {
            let array = ve.map { "\($0)" }
            setNumX(num: Int(array[0])!, isPositive: isPositive, isFirst: isFirst) {
                return completion()
            }
        } else if ve.count == 3 {
            let array = ve.map { "\($0)" }
            if array[0] == "x" {
                setXMlpNum(num: Int(array[2])!, isPositive: isPositive, isFirst: isFirst) {
                    return completion()
                }
            } else {
                setNumMlpX(num: Int(array[0])!, isPositive: isPositive, isFirst: isFirst) {
                    return completion()
                }
            }
        }
    }
    
    func setX(isPositive: Bool, isFirst: Bool, completion: @escaping () -> Void) {
        var eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: isPositive, value: 0, isMultiplied: false, isFirst: isFirst)
        if isFirst {
            eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: true, value: 1, isMultiplied: false, isFirst: isFirst)
        } else {
            if isPositive {
                eqUnit = EqVeUnit(text: "+", withX: true, isFront: true, isPositive: true, value: 1, isMultiplied: false, isFirst: isFirst)
            } else {
                eqUnit = EqVeUnit(text: "-", withX: true, isFront: true, isPositive: false, value: 1, isMultiplied: false, isFirst: isFirst)
            }
        }
        eqUnit.isHidden = true
        addChild(eqUnit)
        veUnit.append(eqUnit)
        return completion()
    }
    
    func setNum(num: Int, isPositive: Bool, isFirst: Bool, completion: @escaping () -> Void) {
        var eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: isPositive, value: 0, isMultiplied: false, isFirst: isFirst)
        if isFirst {
            eqUnit = EqVeUnit(text: String(num), withX: false, isFront: false, isPositive: true, value: num, isMultiplied: false, isFirst: isFirst)
        } else {
            if isPositive {
                eqUnit = EqVeUnit(text: "+\(num)", withX: false, isFront: true, isPositive: true, value: num, isMultiplied: false, isFirst: isFirst)
            } else {
                eqUnit = EqVeUnit(text: "-\(num)", withX: false, isFront: true, isPositive: false, value: num, isMultiplied: false, isFirst: isFirst)
            }
        }
        addChild(eqUnit)
        eqUnit.isHidden = true
        veUnit.append(eqUnit)
        return completion()
    }
    
    func setNumX(num: Int, isPositive: Bool, isFirst: Bool, completion: @escaping () -> Void) {
        var eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: isPositive, value: 0, isMultiplied: false, isFirst: isFirst)
        if isFirst {
            eqUnit = EqVeUnit(text: String(num), withX: true, isFront: true, isPositive: true, value: num, isMultiplied: false, isFirst: isFirst)
        } else {
            if isPositive {
                eqUnit = EqVeUnit(text: "+\(num)", withX: true, isFront: true, isPositive: true, value: num, isMultiplied: false, isFirst: isFirst)
            } else {
                eqUnit = EqVeUnit(text: "-\(num)", withX: true, isFront: true, isPositive: false, value: num, isMultiplied: false, isFirst: isFirst)
            }
        }
        addChild(eqUnit)
        eqUnit.isHidden = true
        veUnit.append(eqUnit)
        return completion()
    }
    
    func setNumMlpX(num: Int, isPositive: Bool, isFirst: Bool, completion: @escaping () -> Void) {
        var eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: isPositive, value: 0, isMultiplied: false, isFirst: isFirst)
        if isFirst {
            eqUnit = EqVeUnit(text: "\(num)×", withX: true, isFront: true, isPositive: true, value: num, isMultiplied: true, isFirst: isFirst)
        } else {
            if isPositive {
                eqUnit = EqVeUnit(text: "+\(num)×", withX: true, isFront: true, isPositive: true, value: num, isMultiplied: true, isFirst: isFirst)
            } else {
                eqUnit = EqVeUnit(text: "-\(num)×", withX: true, isFront: true, isPositive: false, value: num, isMultiplied: true, isFirst: isFirst)
            }
        }
        addChild(eqUnit)
        eqUnit.isHidden = true
        veUnit.append(eqUnit)
        return completion()
    }
    
    func setXMlpNum(num: Int, isPositive: Bool, isFirst: Bool, completion: @escaping () -> Void) {
        var eqUnit = EqVeUnit(text: "", withX: true, isFront: true, isPositive: isPositive, value: 0, isMultiplied: false, isFirst: isFirst)
        if isFirst {
            eqUnit = EqVeUnit(text: "×\(num)", withX: true, isFront: false, isPositive: true, value: num, isMultiplied: true, isFirst: true)
        } else {
            if isPositive {
                eqUnit = EqVeUnit(text: "×\(num)", withX: true, isFront: false, isPositive: true, value: num, isMultiplied: true, isFirst: false)
            } else {
                eqUnit = EqVeUnit(text: "×\(num)", withX: true, isFront: false, isPositive: false, value: num, isMultiplied: true, isFirst: false)
            }
        }
        addChild(eqUnit)
        eqUnit.isHidden = true
        veUnit.append(eqUnit)
        return completion()
    }
    
    func setResult() {
        result.fontSize = 70
        result.verticalAlignmentMode = .center
        result.horizontalAlignmentMode = .left
        result.isHidden = true
        result.text = "="
        resultX.fontSize = 70
        resultX.verticalAlignmentMode = .center
        resultX.horizontalAlignmentMode = .left
        resultX.isHidden = true
        resultX.fontColor = UIColor.red
        resultNum.fontSize = 70
        resultNum.verticalAlignmentMode = .center
        resultNum.horizontalAlignmentMode = .left
        resultNum.isHidden = true
        resultNum.fontColor = UIColor.yellow
        result.addChild(resultX)
        result.addChild(resultNum)
        addChild(result)
        xLabel.fontSize = 40
        xLabel.fontColor = UIColor.red
        xLabel.verticalAlignmentMode = .center
        xLabel.horizontalAlignmentMode = .center
        xLabel.isHidden = true
        resultX.addChild(xLabel)
    }
    
    func showResult() {
        var totalWidth: CGFloat = veUnit.last!.frame.width/2
        veUnit.forEach({ totalWidth += $0.totalWidth })
        result.position = CGPoint(x: totalWidth+gap, y: self.position.y)
        result.isHidden = false
        
        if VEEquivalentController.outPutXValue != 0 {
            resultX.text = String(VEEquivalentController.outPutXValue)
            resultX.position = CGPoint(x: result.frame.width+gap, y: 0)
            resultX.isHidden = false
            showXLabel()
        } else {
            resultX.text = ""
        }
        
        if VEEquivalentController.outPutNumValue != 0 {
            resultNum.text = String(VEEquivalentController.outPutNumValue)
            if VEEquivalentController.outPutNumValue > 0 {
                resultNum.text = "+\(VEEquivalentController.outPutNumValue)"
            }
            resultNum.position = CGPoint(x: result.frame.width+resultX.frame.width+gap*2, y: 0)
            resultNum.isHidden = false
        } else {
            resultNum.text = ""
        }
        VEEquivalentController.showArea()
    }
    
    func showXLabel() {
        let keisu = VEEquivalentController.outPutXValue / VEEquivalentController.xValue
        if lastKeisu != keisu {
            lastKeisu = keisu
            var txt = "x"
            if keisu == -1 {
                txt = "-x"
            } else if keisu != 1 {
                txt = "\(keisu)x"
            }
            xLabel.position = CGPoint(x: resultX.frame.width/2, y: 0)
            xLabel.text = txt
            xLabel.isHidden = false
            let move = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
            xLabel.run(move)
        }
    }
    
    func positioning() {
        for (i, unit) in veUnit.enumerated() {
            getPosition(i: i) { pos in
                unit.position = pos
                unit.isHidden = false
            }
        }
    }
    
    func getPosition(i: Int, completion: @escaping (CGPoint) -> Void) {
        if i == 0 {
            var xPos: CGFloat = 0
            if let xSim = veUnit[0].xSim, !veUnit[0].isFront {
                xPos = xSim.frame.width + veUnit[0].gap
            }
            return completion(CGPoint(x: xPos, y: self.position.y))
        } else {
            var width: CGFloat = CGFloat(i)*gap
            let dispatchGroup = DispatchGroup()
            for index in 0...i-1 {
                dispatchGroup.enter()
                width += veUnit[index].totalWidth
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main, execute: {
                return completion(CGPoint(x: width, y: self.position.y))
            })
        }
    }
    
    func reset() {
        veUnit.forEach({ $0.reset() })
        positioning()
        result.isHidden = true
        resultX.isHidden = true
        resultNum.isHidden = true
        xLabel.isHidden = true
        lastKeisu = 0
        currentForcus = 0
    }
}
