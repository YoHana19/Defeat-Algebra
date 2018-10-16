//
//  CannonRecordBoard.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/08.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CannonRecordBoard: SKSpriteNode {
    
    let posLeft = CGPoint(x: 30, y: 1215)
    let posRight = CGPoint(x: 440, y: 1215)
    
    let leftMarginTop: CGFloat = 40
    let leftMarginTopLabel: CGFloat = 80
    let leftMarginDistTitle: CGFloat = 150
    let leftMarginRecordL: CGFloat = 20
    let leftMarginRecordE: CGFloat = 100
    let leftMarginRecordC: CGFloat = 160
    let leftMarginDist: CGFloat = 230
    let topMargin: CGFloat = 80
    let lineSpace: CGFloat = 55
    
    var numOfCannon = 1
    var numOfXValue = 0
    var currentVeLabel = SKLabelNode()
    var distLabel: [SKLabelNode] = [SKLabelNode]() {
        didSet {
            if distLabel.count == 3 {
                if distLabel[0].text! == distLabel[1].text! && distLabel[1].text! == distLabel[2].text! {
                    if distLabel[0].text! == "0" {
                        for label in distLabel {
                            label.fontColor = UIColor.blue
                        }
                        currentVeLabel.fontColor = UIColor.blue
                        CannonTryController.isCorrect = true
                        DataController.setDataForGetAnswer()
                    } else {
                        for label in distLabel {
                            label.fontColor = UIColor.red
                        }
                        currentVeLabel.fontColor = UIColor.red
                        CannonTryController.hintOn = true
                        DataController.setDataForGetHint()
                    }
                }
            }
        }
    }
    
    init(isLeft: Bool, enemyVe: String, cannonVe: String) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "cannonRecordBoard")
        let bodySize = CGSize(width: 285, height: 900)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        zPosition = 2
        if isLeft {
            position = posLeft
        } else {
            position = posRight
        }
        anchorPoint = CGPoint(x: 0.0, y: 1.0)
        
        setEnemy(ve: enemyVe)
        setCannon(ve: cannonVe)
        setDistLabel()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setEnemy(ve: String) {
        let texture = SKTexture(imageNamed: "front1")
        let bodySize = CGSize(width: 40, height: 40)
        let enemyNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        enemyNode.zPosition = 1
        enemyNode.position = CGPoint(x: leftMarginTop, y: -topMargin)
        self.addChild(enemyNode)
        let labelPos = CGPoint(x: leftMarginTopLabel, y: -topMargin)
        createLabel(text: ve, color: nil, pos: labelPos, name: nil, fontSize: nil)
    }
    
    func setCannon(ve: String) {
        let texture = SKTexture(imageNamed: "cannonFront")
        let bodySize = CGSize(width: 40, height: 40)
        let cannonNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        cannonNode.zPosition = 1
        cannonNode.position = CGPoint(x: leftMarginTop, y: -(topMargin+lineSpace))
        self.addChild(cannonNode)
        let labelPos = CGPoint(x: leftMarginTopLabel, y: -(topMargin+lineSpace))
        createLabel(text: ve, color: nil, pos: labelPos, name: nil, fontSize: nil, isCannon: true)
    }
    
    func setDistLabel() {
        let labelPos1 = CGPoint(x: leftMarginDistTitle, y: -(topMargin+lineSpace-10))
        let labelPos2 = CGPoint(x: leftMarginDistTitle, y: -(topMargin+lineSpace+10))
        createLabel(text: "砲撃した所と", color: nil, pos: labelPos1, name: nil, fontSize: 20, font: DAFont.fontNameForTutorial)
        createLabel(text: "敵との距離", color: nil, pos: labelPos2, name: nil, fontSize: 20, font: DAFont.fontNameForTutorial)
    }
    
    public func createRecord(xValue: Int, distanse: Int, enemyValue: Int, cannonValue: Int) {
        let lineIndex = 1 + numOfCannon + numOfXValue
        numOfXValue += 1
        enemyForRecord(lineIndex: lineIndex, value: enemyValue)
        cannonForRecord(lineIndex: lineIndex, value: cannonValue)
        let xlabelPos = CGPoint(x: leftMarginRecordL, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        let distlabelPos = CGPoint(x: leftMarginDist, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        createLabel(text: "x=\(xValue)", color: nil, pos: xlabelPos, name: nil, fontSize: nil)
        createLabel(text: String(distanse), color: nil, pos: distlabelPos, name: nil, fontSize: nil, isDistanse: true)
    }
    
    private func enemyForRecord(lineIndex: Int, value: Int) {
        let texture = SKTexture(imageNamed: "front1")
        let bodySize = CGSize(width: 25, height: 25)
        let enemyNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        enemyNode.zPosition = 1
        enemyNode.position = CGPoint(x: leftMarginRecordE, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        self.addChild(enemyNode)
        let labelPos = CGPoint(x: leftMarginRecordE+20, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        createLabel(text: String(value), color: nil, pos: labelPos, name: nil, fontSize: 25)
    }
    
    private func cannonForRecord(lineIndex: Int, value: Int) {
        let texture = SKTexture(imageNamed: "cannonFront")
        let bodySize = CGSize(width: 25, height: 25)
        let cannonNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        cannonNode.zPosition = 1
        cannonNode.position = CGPoint(x: leftMarginRecordC, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        self.addChild(cannonNode)
        let labelPos = CGPoint(x: leftMarginRecordC+20, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        createLabel(text: String(value), color: nil, pos: labelPos, name: nil, fontSize: 25)
    }
    
    
    public func createCannon(ve: String) {
        let lineIndex = 1 + numOfCannon + numOfXValue
        numOfCannon += 1
        distLabel.removeAll()
        let texture = SKTexture(imageNamed: "cannonFront")
        let bodySize = CGSize(width: 40, height: 40)
        let cannonNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        cannonNode.zPosition = 1
        cannonNode.position = CGPoint(x: leftMarginTop, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        self.addChild(cannonNode)
        let labelPos = CGPoint(x: leftMarginTopLabel, y: -(topMargin+lineSpace*CGFloat(lineIndex)))
        createLabel(text: ve, color: nil, pos: labelPos, name: nil, fontSize: nil, isCannon: true)
    }
    
    func createLabel(text: String, color: UIColor?, pos: CGPoint, name: String?, fontSize: CGFloat?, font: String? = DAFont.fontName, isDistanse: Bool = false, isCannon: Bool = false) {
        let veLabel = SKLabelNode(fontNamed: font)
        veLabel.text = text
        veLabel.horizontalAlignmentMode = .left
        veLabel.verticalAlignmentMode = .center
        veLabel.fontSize = fontSize ?? 30
        veLabel.position = pos
        veLabel.zPosition = 1
        veLabel.fontColor = color ?? UIColor.white
        veLabel.name = name ?? ""
        if isDistanse {
            distLabel.append(veLabel)
        } else if isCannon {
            currentVeLabel = veLabel
        }
        self.addChild(veLabel)
    }
}
