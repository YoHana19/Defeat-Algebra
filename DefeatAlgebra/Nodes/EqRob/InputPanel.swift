//
//  InputPanel.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class InputPanel: SKSpriteNode {
    
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
            if variableExpression.count == 4 {
                coverX()
                coverNumber()
                coverOperant()
            }
        }
    }
    
    /* Calculate outputValue */
    var outputValue: Int = 0
    var operant = 0 /* 0: +, 1: - */
    var coefficientFlag = false
    var tempSpot = 0
    
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
    
    var coverXBtn = SKShapeNode()
    var coverOKBtn = SKShapeNode()
    var cover0Btn = SKShapeNode()
    var coverNumArray = [SKShapeNode]()
    var coverOpeArray = [SKShapeNode]()
    var eqRobPoint = SKShapeNode(circleOfRadius: 10)
    
    /* Flags for validation */
    var putXFlag = false
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "inputPanel")
        let bodySize = CGSize(width: 654, height: 445)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 10
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 668)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        setLabels()
        
        setEqRobPoint()
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
        
        if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = gameScene as? ScenarioScene {
            guard EqRobTutorialController.userTouch(on: nodeAtPoint.name) else { return }
        }
        
        /* Touch button x */
        if nodeAtPoint.name == "buttonX" {
            
            /* Valid +-, ok */
            uncoverOperant()
            uncoverOK()
            
            /* Invalid x, number */
            coverX()
            coverNumber()
            
            /* Make sure to put at least one x */
            putXFlag = true
            
            variableExpression.append("x")
            
            /* Calculate value */
            if operant == 0 {
                if coefficientFlag == false {
                    gameScene.eqRob.coefficientArray.append(1)
                } else {
                    gameScene.eqRob.coefficientArray.append(tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            } else {
                if coefficientFlag == false {
                    gameScene.eqRob.coefficientArray.append(-1)
                } else {
                    gameScene.eqRob.coefficientArray.append(-tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            }
            
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "button1" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("1")
            
            /* Calculate value */
            tempSpot = 1
            coefficientFlag = true
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("2")
            
            /* Calculate value */
            tempSpot = 2
            coefficientFlag = true
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            variableExpression.append("3")
            
            /* Calculate value */
            tempSpot = 3
            coefficientFlag = true
        }
        
        /* Touch button 4 */
        if nodeAtPoint.name == "button4" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            variableExpression.append("4")
            
            /* Calculate value */
            tempSpot = 4
            coefficientFlag = true
            
        }
        
        /* Touch button 5 */
        if nodeAtPoint.name == "button5" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("5")
        
            /* Calculate value */
            tempSpot = 5
            coefficientFlag = true
        }
        
        /* Touch button 6 */
        if nodeAtPoint.name == "button6" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("6")
            
            /* Calculate value */
            tempSpot = 6
            coefficientFlag = true
        }
        
        /* Touch button 7 */
        if nodeAtPoint.name == "button7" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("7")
            
            /* Calculate value */
            tempSpot = 7
            coefficientFlag = true
        }
        
        /* Touch button 8 */
        if nodeAtPoint.name == "button8" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("8")
            
            /* Calculate value */
            tempSpot = 8
            coefficientFlag = true
        }
        /* Touch button 9 */
        if nodeAtPoint.name == "button9" {
            
            /* Valid x, +- */
            uncoverOperant()
            uncover0()
            
            /* Make sure to put at least one x */
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
            
            variableExpression.append("9")
            
            /* Calculate value */
            tempSpot = 9
            coefficientFlag = true
            
        }
        
        /* Touch button + */
        if nodeAtPoint.name == "button+" {
            
            /* Valid x, num */
            uncoverNumber()
            uncoverX()
            
            /* Invalid +-, ok */
            coverOperant()
            coverOK()
            variableExpression.append("+")
            
            /* Calculate value */
            if coefficientFlag {
                if operant == 0 {
                    gameScene.eqRob.constantsArray.append(tempSpot)
                    operant = 0
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    gameScene.eqRob.constantsArray.append(-tempSpot)
                    operant = 0
                    coefficientFlag = false
                    tempSpot = 0
                }
            } else {
                operant = 0
            }
        }
        
        /* Touch button - */
        if nodeAtPoint.name == "button-" {
            
            /* Valid x, num */
            uncoverNumber()
            uncoverX()
            
            /* Invalid +-, fire */
            coverOperant()
            coverOK()
            variableExpression.append("-")
            
            /* Calculate value */
            if coefficientFlag {
                if operant == 0 {
                    gameScene.eqRob.constantsArray.append(tempSpot)
                    operant = 1
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    gameScene.eqRob.constantsArray.append(-tempSpot)
                    operant = 1
                    coefficientFlag = false
                    tempSpot = 0
                }
            } else {
                operant = 1
            }
        }
        
        /* Touch button clear */
        if nodeAtPoint.name == "buttonClear" {
            
            /* Reset */
            variableExpression = ""
            putXFlag = false
            operant = 0
            coefficientFlag = false
            tempSpot = 0
            
            /* Valid x, num */
            uncoverNumber()
            uncoverX()
            
            /* Invalid +-, ok, 0 */
            coverOperant()
            coverOK()
            cover0()
            
            /* Reset elemnts of variable expression of cannon */
            gameScene.eqRob.resetVEElementArray()
        }
        
        /* Touch button ok */
        if nodeAtPoint.name == "buttonOK" {
            if operant == 0 {
                gameScene.eqRob.constantsArray.append(tempSpot)
            } else {
                gameScene.eqRob.constantsArray.append(-tempSpot)
            }
            
            VECategory.getCategory(ve: variableExpression) { cate in
                gameScene.eqRob.veCategory = cate
                self.confirmedVE = self.variableExpression
                gameScene.eqRob.variableExpressionString = self.variableExpression
                
                /* Reset stuffs */
                self.variableExpression = ""
                self.putXFlag = false
                self.operant = 0
                self.coefficientFlag = false
                self.tempSpot = 0
                /* Valid x, num */
                self.uncoverNumber()
                self.uncoverX()
                /* Invalid +-, 0, ok */
                self.cover0()
                self.coverOperant()
                self.coverOK()
                
                if GameScene.stageLevel == MainMenu.eqRobStartTurn, let _ = gameScene as? ScenarioScene {
                    self.isHidden = true
                } else {
                    EqRobController.execute(1, enemy: nil)
                    self.isHidden = true
                }
                
            }
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
                    if i == 0 {
                        self.cover0Btn = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        self.cover0Btn.isHidden = false
                        self.coverNumArray.append(self.cover0Btn)
                    } else {
                        let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        cover.isHidden = true
                        self.coverNumArray.append(cover)
                    }
                } else if i < 10 {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-5), y: secondLayerPosY)
                    button.position = pos
                    let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                    cover.isHidden = true
                    self.coverNumArray.append(cover)
                } else {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-10), y: thirdLayerPosY)
                    button.position = pos
                    if button.name == "buttonX" {
                        self.coverXBtn = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        self.coverXBtn.isHidden = true
                    } else {
                        let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        cover.isHidden = false
                        self.coverOpeArray.append(cover)
                    }
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
        coverOKBtn = setCoverButtons(buttonSize: bigButtonSize.width/2, buttonPosition: okButtonPos)
        coverOKBtn.isHidden = false
        
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
    
    /* Create button cover so that you can't press buttons in pecific case */
    func setCoverButtons(buttonSize: CGFloat, buttonPosition: CGPoint) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: buttonSize)
        circle.fillColor = UIColor.black
        circle.position = buttonPosition
        circle.alpha = 0.4
        circle.zPosition = 5
        addChild(circle)
        return circle
        
    }
    
    func setEqRobPoint() {
        eqRobPoint.strokeColor = UIColor.clear
        eqRobPoint.fillColor = UIColor.clear
        eqRobPoint.position = CGPoint(x: -frame.width/2+70, y: frame.height/2-70)
        eqRobPoint.zPosition = 5
        addChild(eqRobPoint)
    }
    
    /* Toggle +- buttons */
    func coverOperant() {
        for c in coverOpeArray {
            c.isHidden = false
        }
    }
    func uncoverOperant() {
        for c in coverOpeArray {
            c.isHidden = true
        }
    }
    
    /* Toggle 0 buttons */
    func cover0() {
        cover0Btn.isHidden = false
    }
    func uncover0() {
        cover0Btn.isHidden = true
    }
    
    /* Toggle x buttons */
    func coverX() {
        coverXBtn.isHidden = false
    }
    func uncoverX() {
        coverXBtn.isHidden = true
    }
    
    /* Toggle number buttons */
    func coverNumber() {
        for c in coverNumArray {
            c.isHidden = false
        }
    }
    func uncoverNumber() {
        for c in coverNumArray {
            c.isHidden = true
        }
    }
    
    /* Toggle ok buttons */
    func coverOK() {
        coverOKBtn.isHidden = false
    }
    func uncoverOK() {
        coverOKBtn.isHidden = true
    }
    
}
