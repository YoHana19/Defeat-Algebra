//
//  SelectedEnemy.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/16.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class SelectedEnemy: SKSpriteNode {
    
    var veString: String = ""
    var veLabel: SKLabelNode!
    var crossNode: SKSpriteNode!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front1")
        let enemySize = CGSize(width: 80, height: 80)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = false
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.name = "selectedEnemy"
        
        setLabel()
        setCrossNode()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setLabel() {
        veLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        veLabel.fontSize = 50
        veLabel.verticalAlignmentMode = .center
        veLabel.horizontalAlignmentMode = .left
        veLabel.position = CGPoint(x: 45, y: 0)
        veLabel.zPosition = 3
        veLabel.fontColor = UIColor.white
        self.addChild(veLabel)
    }
    
    func setStandingtexture(direction: Direction) {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "front1")
        case .back:
            //self.texture = SKTexture(imageNamed: "back1")
            break;
        case .left:
            self.texture = SKTexture(imageNamed: "left1")
        case .right:
            self.texture = SKTexture(imageNamed: "right1")
        }
    }
    
    func setCrossNode() {
        let texture = SKTexture(imageNamed: "cross")
        let size = CGSize(width: 60, height: 60)
        crossNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: size)
        crossNode.position = CGPoint(x: 0, y: 0)
        crossNode.isHidden = true
        crossNode.zPosition = 4
        addChild(crossNode)
    }
    
    func showCrossNode() {
        crossNode.isHidden = false
    }
    
    func showCalculation(value: Int) {
        var xPos = [Int]()
        var charaIndex = -1
        var characters = veString.map { String($0) }
        let dispatchGroup = DispatchGroup()
        for (i, c) in characters.enumerated() {
            charaIndex += 1
            dispatchGroup.enter()
            if c == "x" {
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
            VECategory.getCategory(ve: self.veString) { cate in
                let result = VECategory.calculateValue(veCategory: cate, value: value)
                self.veLabel.text = self.veString + "=" + numForm + "=" + String(result)
                let attrText = NSMutableAttributedString(string: self.veLabel.text!)
                let font = UIFont(name: "GillSans-Bold", size: 50) ?? UIFont.systemFont(ofSize: 50)
                attrText.addAttributes([.foregroundColor: UIColor.white, .font: font], range: NSMakeRange(0, self.veLabel.text!.count))
                for pos in xPos {
                    attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(self.veString.count+1+pos, 1))
                }
                if #available(iOS 11.0, *) {
                    self.veLabel.attributedText = attrText
                }
            }
        })
    }
    
}
