//
//  Balloon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Balloon: SKSpriteNode {
    
    var fontSize: CGFloat = 37
    let texture0 = SKTexture(imageNamed: "BalloonMulti2")
    let texture1 = SKTexture(imageNamed: "Balloon2")
    let texture2 = SKTexture(imageNamed: "Balloon3")
    
    init() {
        /* Initialize with enemy asset */
        let bodySize = CGSize(width: 504, height: 311.5)
        super.init(texture: texture0, color: UIColor.clear, size: bodySize)
        
        /* Set Z-Position, ensure ontop of screen */
        zPosition = 20
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLines(with text: String, pos: Int) {
        if let label = self.childNode(withName: "line") {
            label.removeFromParent()
        }
        
        let singleLineMessage = SKLabelNode(fontNamed: "GillSans-Bold")
        singleLineMessage.fontSize = fontSize
        singleLineMessage.verticalAlignmentMode = .center // Keep the origin in the center
        singleLineMessage.horizontalAlignmentMode = .left
        singleLineMessage.text = text
        
        let textLabel = singleLineMessage.multilined()
        switch pos {
        case 0:
            doctorTextPos(with: textLabel, numOfLines: textLabel.children.count)
            break;
        case 1:
            madDoctorTextPos(with: textLabel, numOfLines: textLabel.children.count)
            break;
        case 2:
            mainHeroTextPos(with: textLabel, numOfLines: textLabel.children.count)
            break;
        default:
            break;
        }
        textLabel.name = "line"
        textLabel.zPosition = 3  // On top of all other nodes
        textLabel.fontColor = UIColor.white
        addChild(textLabel)
    }
    
    func doctorTextPos(with label: SKLabelNode, numOfLines: Int) {
        switch numOfLines {
        case 2:
            label.position = CGPoint(x: -170, y: -20)
            break;
        case 4:
            label.position = CGPoint(x: -170, y: -25)
            break;
        default:
            label.position = CGPoint(x: -170, y: 0)
            break;
        }
    }
    
    func madDoctorTextPos(with label: SKLabelNode, numOfLines: Int) {
        switch numOfLines {
        case 4:
            label.position = CGPoint(x: -170, y: -20)
            break;
        default:
            label.position = CGPoint(x: -170, y: 0)
            break;
        }
    }
    
    func mainHeroTextPos(with label: SKLabelNode, numOfLines: Int) {
        switch numOfLines {
        case 2:
            label.position = CGPoint(x: -190, y: -20)
            break;
        case 4:
            label.position = CGPoint(x: -190, y: -30)
            break;
        default:
            label.position = CGPoint(x: -190, y: 0)
            break;
        }
    }
}
