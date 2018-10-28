//
//  PasswordScreen.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/28.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class PasswordScreen: SKSpriteNode {
    
    /* Set button size */
    let buttonSize = CGSize(width: 60, height: 60)
    let radius: CGFloat = 30
    let centerX: CGFloat = -40
    let centerY: CGFloat = -20
    let merginX: CGFloat = 30
    let merginY: CGFloat = 15
    let clearButtonPos = CGPoint(x: 250, y: -50)
    let okButtonPos = CGPoint(x: 250, y: -150)
    let bigButtonSize = CGSize(width: 82, height: 82)
    let labelPos = CGPoint(x: -140, y: 57)
    let labelMergin: CGFloat = 93
    
    var isActive: Bool = false {
        didSet {
            /* Visibility */
            self.isHidden = !isActive
        }
    }
    
    var veLabel1: SKLabelNode!
    var veLabel2: SKLabelNode!
    var veLabel3: SKLabelNode!
    var veLabel4: SKLabelNode!
    var labelArray = [SKLabelNode]()
    
    var confirmedVE: String = ""
    var variableExpression: String = "" {
        didSet {
            if variableExpression.count == 0 {
                veLabel1.text = ""
                veLabel2.text = ""
                veLabel3.text = ""
                veLabel4.text = ""
            } else {
                for (i, char) in variableExpression.enumerated() {
                    labelArray[i].text = String(char)
                }
            }
        }
    }
    
    /* Set buttons */
    public var buttonX: SKSpriteNode!
    public var button0: SKSpriteNode!
    public var button1: SKSpriteNode!
    public var button2: SKSpriteNode!
    public var button3: SKSpriteNode!
    public var button4: SKSpriteNode!
    public var button5: SKSpriteNode!
    public var button6: SKSpriteNode!
    public var button7: SKSpriteNode!
    public var button8: SKSpriteNode!
    public var button9: SKSpriteNode!
    public var buttonPlus: SKSpriteNode!
    public var buttonMinus: SKSpriteNode!
    
    public var buttonClear: SKSpriteNode!
    public var buttonOK: SKSpriteNode!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "inputPanel")
        let bodySize = CGSize(width: 654, height: 445)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 200
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 668)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        setLabels()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch button clear */
        if nodeAtPoint.name == "buttonClear" {
            variableExpression = ""
        }
        
        /* Touch button ok */
        if nodeAtPoint.name == "buttonOK" {
            guard let mainMenu = self.parent as? MainMenu else { return }
            if variableExpression == "0318" {
                self.isActive = false
                mainMenu.settingScreen.isActive = true
            }
        }
        
        guard variableExpression.count < 4 else { return }
        
        /* Touch button x */
        if nodeAtPoint.name == "buttonX" {
            variableExpression.append("x")
        }
        
        /* Touch button 0 */
        if nodeAtPoint.name == "button0" {
            variableExpression.append("0")
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "button1" {
           variableExpression.append("1")
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
           variableExpression.append("2")
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
          variableExpression.append("3")
        }
        
        /* Touch button 4 */
        if nodeAtPoint.name == "button4" {
            variableExpression.append("4")
        }
        
        /* Touch button 5 */
        if nodeAtPoint.name == "button5" {
            variableExpression.append("5")
        }
        
        /* Touch button 6 */
        if nodeAtPoint.name == "button6" {
            variableExpression.append("6")
        }
        
        /* Touch button 7 */
        if nodeAtPoint.name == "button7" {
            variableExpression.append("7")
        }
        
        /* Touch button 8 */
        if nodeAtPoint.name == "button8" {
           variableExpression.append("8")
        }
        /* Touch button 9 */
        if nodeAtPoint.name == "button9" {
            variableExpression.append("9")
        }
        
        /* Touch button + */
        if nodeAtPoint.name == "button+" {
            variableExpression.append("+")
        }
        
        /* Touch button - */
        if nodeAtPoint.name == "button-" {
            variableExpression.append("-")
        }
    }
    
    func makeButtons(completion: @escaping ([SKSpriteNode]) -> Void) {
        let button0 = SKSpriteNode(imageNamed: "input0")
        let button1 = SKSpriteNode(imageNamed: "input1")
        let button2 = SKSpriteNode(imageNamed: "input2")
        let button3 = SKSpriteNode(imageNamed: "input3")
        let button4 = SKSpriteNode(imageNamed: "input4")
        let button5 = SKSpriteNode(imageNamed: "input5")
        let button6 = SKSpriteNode(imageNamed: "input6")
        let button7 = SKSpriteNode(imageNamed: "input7")
        let button8 = SKSpriteNode(imageNamed: "input8")
        let button9 = SKSpriteNode(imageNamed: "input9")
        let buttonMinus = SKSpriteNode(imageNamed: "input-")
        let buttonPlus = SKSpriteNode(imageNamed: "input+")
        let buttonX = SKSpriteNode(imageNamed: "inputX")
        button0.name = "button0"
        button1.name = "button1"
        button2.name = "button2"
        button3.name = "button3"
        button4.name = "button4"
        button5.name = "button5"
        button6.name = "button6"
        button7.name = "button7"
        button8.name = "button8"
        button9.name = "button9"
        buttonMinus.name = "button-"
        buttonPlus.name = "button+"
        buttonX.name = "buttonX"
        return completion([button0, button1, button2, button3, button4, button5, button6, button7, button8, button9, buttonMinus, buttonPlus, buttonX])
    }
    
    func setButtons() {
        
        let rMerginX = buttonSize.width + merginX
        let rMerginY = buttonSize.height + merginY
        let leadingPosX = centerX - (rMerginX) * 2
        let secondLayerPosY = centerY - (rMerginY)
        let thirdLayerPosY = centerY - (rMerginY) * 2
        
        makeButtons() { buttons in
            for (i, button) in buttons.enumerated() {
                button.size = self.buttonSize
                button.zPosition = 3
                button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if i < 5 {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i), y: self.centerY)
                    button.position = pos
                } else if i < 10 {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-5), y: secondLayerPosY)
                    button.position = pos
                } else {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-10), y: thirdLayerPosY)
                    button.position = pos
                }
                self.addChild(button)
            }
        }
        
        /* button clear */
        let buttonClear = SKSpriteNode(imageNamed: "inputClear")
        buttonClear.size = bigButtonSize
        buttonClear.position = clearButtonPos
        buttonClear.name = "buttonClear"
        buttonClear.zPosition = 3
        addChild(buttonClear)
        
        /* button fire */
        let buttonOK = SKSpriteNode(imageNamed: "inputOk")
        buttonOK.size = bigButtonSize
        buttonOK.position = okButtonPos
        buttonOK.name = "buttonOK"
        buttonOK.zPosition = 3
        addChild(buttonOK)
        
    }
    
    func makeLabels(completion: @escaping ([SKLabelNode]) -> Void) {
        veLabel1 = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel2 = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel3 = SKLabelNode(fontNamed: DAFont.fontName)
        veLabel4 = SKLabelNode(fontNamed: DAFont.fontName)
        return completion([veLabel1, veLabel2, veLabel3, veLabel4])
    }
    
    func setLabels() {
        makeLabels() { labels in
            self.labelArray = labels
            for (i, label) in labels.enumerated() {
                label.fontSize = 96
                label.position = CGPoint(x: self.labelPos.x+self.labelMergin*CGFloat(i), y: self.labelPos.y)
                label.zPosition = 3
                label.fontColor = UIColor.red
                self.addChild(label)
            }
        }
    }
}
