//
//  EqGrid.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqGrid: Grid {
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let gameScene = self.parent as? GameScene else { return }
        if gameScene.isCharactersTurn {
            switch gameScene.tutorialState {
            case .None:
                break;
            case .Converstaion:
                ScenarioController.nextLine()
                break;
            case .Action:
                if GameScene.stageLevel == 5, let _ = self.parent as? ScenarioScene {
                    if VEEquivalentController.numOfCheck > 3 {
                        VEEquivalentController.getBG() { bg in
                            bg?.isEnable = false
                        }
                        ScenarioController.controllActions()
                        return
                    } else {
                        CharacterController.doctor.balloon.isHidden = true
                    }
                }
                break;
            }
        } else {
            guard gameScene.pauseFlag == false else { return }
            guard gameScene.gameState == .PlayerTurn else { return }
            guard gameScene.playerTurnState == .UsingItem else { return }
            guard gameScene.itemType == .EqRob else { return }
            
            ItemTouchController.othersTouched()
        }
    }
    
    public func createCalucalationLabel(text: String, posX: Int, posY: Int, redLetterPos: [Int]) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        /* Set text */
        label.text = text
        /* Set name */
        label.name = "label"
        /* Set font size */
        label.fontSize = 35
        /* Set zPosition */
        label.zPosition = 5
        /* Set position */
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        let pos = CGPoint(x: CGFloat((Double(posX)+1/2)*cellWidth), y: CGFloat((Double(posY)+1/2)*cellHeight))
        label.position = pos
        
        let attrText = NSMutableAttributedString(string: label.text!)
        let font = UIFont(name: DAFont.fontName, size: label.fontSize) ?? UIFont.systemFont(ofSize: label.fontSize)
        attrText.addAttributes([.foregroundColor: UIColor.white, .font: font], range: NSMakeRange(0, label.text!.count))
        for pos in redLetterPos {
            attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(pos, 1))
        }
        if #available(iOS 11.0, *) {
            label.attributedText = attrText
        }
        
        /* Add to Scene */
        addChild(label)
    }
    
    public func createLabel(text: String, posX: Int, posY: Int, redLetterPos: [Int]) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        /* Set text */
        label.text = text
        /* Set name */
        label.name = "label"
        /* Set font size */
        label.fontSize = 60
        /* Set zPosition */
        label.zPosition = 5
        /* Set position */
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        let pos = CGPoint(x: CGFloat(posX)*CGFloat(cellWidth), y: CGFloat(posY)*CGFloat(cellHeight))
        label.position = pos
        
        let attrText = NSMutableAttributedString(string: label.text!)
        let font = UIFont(name: DAFont.fontName, size: label.fontSize) ?? UIFont.systemFont(ofSize: label.fontSize)
        attrText.addAttributes([.foregroundColor: UIColor.white, .font: font], range: NSMakeRange(0, label.text!.count))
        for pos in redLetterPos {
            attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(pos, 1))
        }
        if #available(iOS 11.0, *) {
            label.attributedText = attrText
        }
        
        /* Add to Scene */
        addChild(label)
    }
    
    public func removeLabel() {
        for child in self.children {
            if child.name == "label" {
                child.removeFromParent()
            }
        }
    }
}
