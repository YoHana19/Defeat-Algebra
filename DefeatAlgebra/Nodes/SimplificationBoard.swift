//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class SimplificationBoard: SKSpriteNode {
    
    var isActive: Bool = false {
        didSet {
            /* Visibility */
            self.isHidden = !isActive
        }
    }
    
    var originLabel: SKLabelNode!
    var createdLabel: SKLabelNode!
    var variableExpression: String = "" {
        didSet {
            createdLabel.text = variableExpression
        }
    }
    
    /* Set buttons */
    var buttonX: SKSpriteNode!
    var button0: SKSpriteNode!
    var button1: SKSpriteNode!
    var button2: SKSpriteNode!
    var button3: SKSpriteNode!
    var button4: SKSpriteNode!
    var button5: SKSpriteNode!
    var button6: SKSpriteNode!
    var button7: SKSpriteNode!
    var button8: SKSpriteNode!
    var button9: SKSpriteNode!
    var buttonPuls: SKSpriteNode!
    var buttonMinus: SKSpriteNode!
    var buttonFire: SKSpriteNode!
    var invalidNote: SKSpriteNode!
    var dismissButton: SKSpriteNode!
    var backButton: SKSpriteNode!
    
    
    /* Flags for validation */
    var errorFlag = false
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "inputBoardForSimplifing")
        let bodySize = CGSize(width: 700, height: 790)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 100
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 700)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        setOriginalVE()
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch button x */
        if nodeAtPoint.name == "inputX" {
            /* Display variable expression */
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("x")
            }
        }
        
        /* Touch button 0 */
        if nodeAtPoint.name == "input0" {
            /* Display variable expression */
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("0")
            }
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "input1" {
            /* Display variable expression */
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("1")
            }
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "input2" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("2")
            }
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "input3" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("3")
            }
        }
        
        /* Touch button 4 */
        if nodeAtPoint.name == "input4" {
            /* Display variable expression */
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("4")
            }
        }
        
        /* Touch button 5 */
        if nodeAtPoint.name == "input5" {
            /* Display variable expression */
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("5")
            }
        }
        
        /* Touch button 6 */
        if nodeAtPoint.name == "input6" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("6")
            }
        }
        
        /* Touch button 7 */
        if nodeAtPoint.name == "input7" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("7")
            }
        }
        
        /* Touch button 8 */
        if nodeAtPoint.name == "input8" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("8")
            }
        }
        
        /* Touch button 9 */
        if nodeAtPoint.name == "input9" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("9")
            }
        }
        
        /* Touch button + */
        if nodeAtPoint.name == "input+" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("+")
            }
        }
        
        /* Touch button - */
        if nodeAtPoint.name == "input-" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("-")
            }
        }
        
        /* Touch button clear */
        if nodeAtPoint.name == "inputClear" {
            guard errorFlag == false else { return }
            
            /* Reset */
            variableExpression = ""
        }
        
        /* Touch button OK */
        if nodeAtPoint.name == "inputOk" {
            if variableExpression.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                /* Get selcting enemy */
                let selectingEnemy = gameScene.gridNode.editedEnemy
                
                /* Edit selecting enemy's variable expression */
                selectingEnemy.variableExpressionString = self.variableExpression
                
                /* Rewrite enemy's variable expression */
                selectingEnemy.removeAllChildren()
                EnemyVEController.setVariableExpressionLabel(enemy: selectingEnemy, vEString: self.variableExpression) { label in
                    selectingEnemy.setVariableExpressionLabel(text: label)
                }
                
                /* Reset color if input variable expression is correct */
                if EnemyProperty.judgeCorrectVe(origin: selectingEnemy.originVariableExpression, input: self.variableExpression) {
                    selectingEnemy.resetColorizeEnemy()
                    selectingEnemy.enemyLife = 0
                }
                
                /* Hide simplification board */
                self.isActive = false
                gameScene.boardActiveFlag = false
                
                /* Reset input variable expresion */
                self.variableExpression = ""
                
            }
        }
        
        /* Touch dismiss button */
        if nodeAtPoint.name == "dismissButton" {
            dismissButton.isHidden = true
            invalidNote.isHidden = true
            errorFlag = false
            variableExpression = ""
        }
        
        /* Touch back button */
        if nodeAtPoint.name == "backButton" {
            variableExpression = ""
            originLabel.text = ""
            self.isActive = false
            gameScene.boardActiveFlag = false
        }
    }
    
    func setButtons() {
        
        /* button x */
        let posX = CGPoint(x: -200, y: -25)
        createButton(position: posX, imageName: "inputX")
        
        /* button + */
        let posPlus = CGPoint(x: -100, y: -25)
        createButton(position: posPlus, imageName: "input+")
        
        /* button - */
        let posMinus = CGPoint(x: 0, y: -25)
        createButton(position: posMinus, imageName: "input-")
        
        /* button 0 */
        let pos0 = CGPoint(x: -200, y: -120)
        createButton(position: pos0, imageName: "input0")
        
        /* button 1 */
        let pos1 = CGPoint(x: -100, y: -120)
        createButton(position: pos1, imageName: "input1")
        
        /* button 2 */
        let pos2 = CGPoint(x: 0, y: -120)
        createButton(position: pos2, imageName: "input2")
        
        /* button 3 */
        let pos3 = CGPoint(x: 100, y: -120)
        createButton(position: pos3, imageName: "input3")
        
        /* button 4 */
        let pos4 = CGPoint(x: 200, y: -120)
        createButton(position: pos4, imageName: "input4")
        
        /* button 5 */
        let pos5 = CGPoint(x: -200, y: -215)
        createButton(position: pos5, imageName: "input5")
        
        /* button 6 */
        let pos6 = CGPoint(x: -100, y: -215)
        createButton(position: pos6, imageName: "input6")
        
        /* button 7 */
        let pos7 = CGPoint(x: 0, y: -215)
        createButton(position: pos7, imageName: "input7")
        
        /* button 8 */
        let pos8 = CGPoint(x: 100, y: -215)
        createButton(position: pos8, imageName: "input8")
        
        /* button 9 */
        let pos9 = CGPoint(x: 200, y: -215)
        createButton(position: pos9, imageName: "input9")
        
        /* button clear */
        let posClear = CGPoint(x: -100, y: -310)
        createButton(position: posClear, imageName: "inputClear")
        
        /* button ok */
        let posOk = CGPoint(x: -200, y: -310)
        createButton(position: posOk, imageName: "inputOk")
        
        /* Invalid note */
        invalidNote = SKSpriteNode(imageNamed: "invalidNote")
        invalidNote.zPosition = 100
        invalidNote.isHidden = true
        addChild(invalidNote)
        
        /* button dismiss */
        dismissButton = SKSpriteNode(imageNamed: "dismissButton")
        dismissButton.size = CGSize(width:40, height: 40)
        dismissButton.position = CGPoint(x: invalidNote.size.width/2-30, y: invalidNote.size.height/2-30)
        dismissButton.name  = "dismissButton"
        dismissButton.zPosition = 101
        dismissButton.isHidden = true
        addChild(dismissButton)
        
        /* button back */
        backButton = SKSpriteNode(imageNamed: "dismissButton")
        backButton.size = CGSize(width:40, height: 40)
        backButton.position = CGPoint(x: self.size.width/2-30, y: self.size.height/2-30)
        backButton.name  = "backButton"
        backButton.zPosition = 101
        addChild(backButton)
        
        /* label of variable expresion */
        createdLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        createdLabel.text = ""
        createdLabel.fontSize = 96
        createdLabel.position = CGPoint(x: 0, y: 55)
        createdLabel.zPosition = 3
        addChild(createdLabel)
    }
    
    func createButton(position: CGPoint, imageName: String) {
        let buttonFire = SKSpriteNode(imageNamed: imageName)
        buttonFire.size = CGSize(width: 80, height: 80)
        buttonFire.position = position
        buttonFire.name = imageName
        buttonFire.zPosition = 3
        addChild(buttonFire)
    }
    
    func setOriginalVE() {
        /* Set original variable expression label */
        originLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        originLabel.text = ""
        originLabel.fontSize = 96
        originLabel.position = CGPoint(x: 0, y: 180)
        originLabel.zPosition = 3
        addChild(originLabel)
    }
    
}
