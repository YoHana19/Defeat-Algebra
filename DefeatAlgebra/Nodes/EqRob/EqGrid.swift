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
    
    public var demoCalcLabel = SKLabelNode(fontNamed: DAFont.fontName)
    private var conclusionLabel = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        setEqRobDemoCalcLabel()
        setConclusionLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let gameScene = self.parent as? GameScene else { return }
        if gameScene.isCharactersTurn {
            switch gameScene.tutorialState {
            case .None:
                break;
            case .Converstaion:
                ScenarioController.nextLine()
                return
                break;
            case .Action:
                if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = self.parent as? ScenarioScene {
                    guard ScenarioTouchController.eqRobSimulatorTutorialTouch() else { return }
                } else if GameScene.stageLevel == MainMenu.invisibleStartTurn {
                    guard CannonTutorialController.userTouch(on: "") else { return }
                }
                break;
            }
        }
        
        if gameScene.playerTurnState == .UsingItem && gameScene.itemType == .EqRob {
            if VEEquivalentController.simOneSessionDone {
                VEEquivalentController.nextSessoin()
                return
            } else if VEEquivalentController.simTwoVeDone {
                VEEquivalentController.compare()
                return
            } else if VEEquivalentController.simOneVeDone {
                VEEquivalentController.nextSim()
                return
            } else if VEEquivalentController.allDone {
                VEEquivalentController.doneSimulation()
                return
            }
        }
        
        if CannonTouchController.state == .Trying {
            guard let gameScene = self.parent as? GameScene else { return }
            if gameScene.inputPanelForCannon.isActive == true {
                CannonController.hideInputPanelInTrying()
            }
        }
    }
    
    
    private func setConclusionLabel() {
        /* Set label with font */
        conclusionLabel = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        conclusionLabel.fontSize = 100
        conclusionLabel.fontColor = UIColor.white
        conclusionLabel.horizontalAlignmentMode = .center
        conclusionLabel.verticalAlignmentMode = .center
        conclusionLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2-60)
        conclusionLabel.zPosition = 140
        conclusionLabel.isHidden = true
        conclusionLabel.text = "同じ文字式"
        addChild(conclusionLabel)
        let veBG = SKShapeNode(rectOf: CGSize(width:  537, height: 156))
        veBG.fillColor = UIColor.red
        veBG.strokeColor = UIColor.clear
        veBG.zPosition = -1
        veBG.position = CGPoint(x: 0, y: 0)
        conclusionLabel.addChild(veBG)
    }
    
    public func showConclusionLabel() -> Bool {
        guard conclusionLabel.isHidden else { return true }
        conclusionLabel.isHidden = false
        SoundController.sound(scene: VEEquivalentController.gameScene, sound: .ButtonMove)
        if EqRobTouchController.state == .AliveInstruction
        {
            conclusionLabel.text = "同じ文字式"
        } else if EqRobTouchController.state == .DeadInstruction {
            conclusionLabel.text = "違う文字式"
        } else if EqRobJudgeController.isEquivalent {
            conclusionLabel.text = "同じ文字式"
        } else if !EqRobJudgeController.isEquivalent {
            conclusionLabel.text = "違う文字式"
        } else if let _ = VEEquivalentController.gameScene as? ScenarioScene {
            conclusionLabel.text = "同じ文字式"
        }
        return false
    }
    
    public func hideConclusionLabel() {
        conclusionLabel.isHidden = true
        conclusionLabel.text = ""
    }
    
    public func createLabel(text: String, posX: Int, posY: Int, redLetterPos: [Int], greenLetterPos: [Int]) {
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
        for pos in greenLetterPos {
            attrText.addAttribute(.foregroundColor, value: UIColor.green, range: NSMakeRange(pos, 1))
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
    
    func setEqRobDemoCalcLabel() {
        demoCalcLabel.fontSize = 30
        demoCalcLabel.verticalAlignmentMode = .center
        demoCalcLabel.horizontalAlignmentMode = .center
        demoCalcLabel.position = CGPoint(x: 0, y: 0)
        demoCalcLabel.zPosition = 3
        demoCalcLabel.fontColor = UIColor.white
        self.addChild(demoCalcLabel)
        demoCalcLabel.isHidden = true
    }
    
    public func showEqRobDemoCalcLabel(pos: CGPoint, value: Int, eqRob: EqRob) {
        demoCalcLabel.isHidden = false
        demoCalcLabel.position = pos
        demoCalculation(value: value, eqRob: eqRob)
    }
    
    private func demoCalculation(value: Int, eqRob: EqRob) {
        var xPos = [Int]()
        var xPosOrigin = [Int]()
        var charaIndex = -1
        var characters = eqRob.variableExpressionString.map { String($0) }
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
            let result = eqRob.calculateValue(value: value)
            self.demoCalcLabel.text = eqRob.variableExpressionString + "=" + numForm + "=" + String(result)
            let attrText = NSMutableAttributedString(string: self.demoCalcLabel.text!)
            let font = UIFont(name: DAFont.fontName, size: 30) ?? UIFont.systemFont(ofSize: 30)
            attrText.addAttributes([.foregroundColor: UIColor.white, .font: font], range: NSMakeRange(0, self.demoCalcLabel.text!.count))
            for pos in xPos {
                attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(eqRob.variableExpressionString.count+1+pos, 1))
            }
            for pos in xPosOrigin {
                attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(pos, 1))
            }
            if result < -9 {
                attrText.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSMakeRange(self.demoCalcLabel.text!.count-3, 3))
            } else if result < 0 {
                attrText.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSMakeRange(self.demoCalcLabel.text!.count-2, 2))
            } else if result > 9 {
                attrText.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSMakeRange(self.demoCalcLabel.text!.count-2, 2))
            } else {
                attrText.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSMakeRange(self.demoCalcLabel.text!.count-1, 1))
            }
            if #available(iOS 11.0, *) {
                self.demoCalcLabel.attributedText = attrText
            }
        })
    }
}
