//
//  InputPanleForCannon.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/22.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class InputPanelForCannon: SKSpriteNode {
    
    /* Set button size */
    let buttonSize = CGSize(width: 60, height: 60)
    let radius: CGFloat = 30
    let centerX: CGFloat = -40
    let centerY: CGFloat = -20
    let merginX: CGFloat = 30
    let merginY: CGFloat = 15
    let clearButtonPos = CGPoint(x: 150, y: -150)
    let okButtonPos = CGPoint(x: 250, y: -150)
    let tryButtonPos = CGPoint(x: 200, y: -40)
    let bigButtonSize = CGSize(width: 82, height: 82)
    let tryButtonSize = CGSize(width: 180, height: 90)
    let labelPos = CGPoint(x: -140, y: 57)
    let labelMergin: CGFloat = 93
    
    var isActive: Bool = false {
        didSet {
            self.isHidden = !isActive
            if (isActive) {
                CannonController.selectedCannon.resetVEElementArray()
                if GameScene.stageLevel < MainMenu.invisivleStartTurn {
                    buttonTry.isHidden = true
                    coverTryBtn.isHidden = true
                } else {
                    if CannonTouchController.state == .Trying {
                        buttonTry.isHidden = true
                        coverTryBtn.isHidden = true
                    } else {
                        buttonTry.isHidden = false
                        coverTryBtn.isHidden = false
                    }
                }    
            }
        }
    }
    
    var veLabel1: SKLabelNode!
    var veLabel2: SKLabelNode!
    var veLabel3: SKLabelNode!
    var veLabel4: SKLabelNode!
    var labelArray = [SKLabelNode]()
    
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
    
    var buttonX = SKSpriteNode()
    var buttonPlus = SKSpriteNode()
    var buttonMinus = SKSpriteNode()
    
    var cover0Btn = SKShapeNode()
    var coverXBtn = SKShapeNode()
    var coverOKBtn = SKShapeNode()
    var coverTryBtn = SKShapeNode()
    var buttonTry = SKSpriteNode()
    var coverNumArray = [SKShapeNode]()
    var coverOpeArray = [SKShapeNode]()
    var eqRobPoint = SKShapeNode(circleOfRadius: 10)
    
    /* Flags for validation */
    var numberFlag = false
    var xFlag = false
    var operationFlag = false
    var putXFlag = false
    var errorFlag = false
    
    var isNewVesion = false
    
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
        
        if GameScene.stageLevel < MainMenu.invisivleStartTurn {
            isNewVesion = false
            oldVersion()
        } else {
            isNewVesion = true
        }
        
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
        
        if GameScene.stageLevel == MainMenu.cannonStartTurn || GameScene.stageLevel == MainMenu.invisivleStartTurn, let _ = gameScene as? ScenarioScene {
            guard CannonTutorialController.userTouch(on: nodeAtPoint.name) else { return }
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
                    CannonController.selectedCannon.coefficientArray.append(1)
                } else {
                    CannonController.selectedCannon.coefficientArray.append(tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            } else {
                if coefficientFlag == false {
                    CannonController.selectedCannon.coefficientArray.append(-1)
                } else {
                    CannonController.selectedCannon.coefficientArray.append(-tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            }
            
        }
        
        /* Touch button 0 */
        if nodeAtPoint.name == "button0" {
            tappedNumber(num: 0)
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "button1" {
            tappedNumber(num: 1)
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
            tappedNumber(num: 2)
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
           tappedNumber(num: 3)
        }
        
        /* Touch button 4 */
        if nodeAtPoint.name == "button4" {
            tappedNumber(num: 4)
        }
        
        /* Touch button 5 */
        if nodeAtPoint.name == "button5" {
            tappedNumber(num: 5)
        }
        
        /* Touch button 6 */
        if nodeAtPoint.name == "button6" {
            tappedNumber(num: 6)
        }
        
        /* Touch button 7 */
        if nodeAtPoint.name == "button7" {
            tappedNumber(num: 7)
        }
        
        /* Touch button 8 */
        if nodeAtPoint.name == "button8" {
            tappedNumber(num: 8)
        }
        /* Touch button 9 */
        if nodeAtPoint.name == "button9" {
            tappedNumber(num: 9)
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
                    CannonController.selectedCannon.constantsArray.append(tempSpot)
                    operant = 0
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    CannonController.selectedCannon.constantsArray.append(-tempSpot)
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
                    CannonController.selectedCannon.constantsArray.append(tempSpot)
                    operant = 1
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    CannonController.selectedCannon.constantsArray.append(-tempSpot)
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
            CannonController.selectedCannon.resetVEElementArray()
            
        }
        
        /* Touch button ok */
        if nodeAtPoint.name == "buttonOK" {
            if operant == 0 {
                CannonController.selectedCannon.constantsArray.append(tempSpot)
            } else {
                CannonController.selectedCannon.constantsArray.append(-tempSpot)
            }
            
            CannonController.selectedCannon.setInputVE(value: variableExpression)
            let tempVe = self.variableExpression
            
            /* Reset stuffs */
            self.variableExpression = ""
            self.putXFlag = false
            self.operant = 0
            self.coefficientFlag = false
            self.tempSpot = 0
            /* Valid x, num */
            self.uncoverNumber()
            self.uncoverX()
            /* Invalid +-, ok, 0*/
            self.coverOperant()
            self.coverOK()
            self.cover0()
            
            self.isHidden = true
            
            if let _ = gameScene as? ScenarioScene {
                if GameScene.stageLevel == MainMenu.cannonStartTurn {
                    return
                } else if GameScene.stageLevel == MainMenu.invisivleStartTurn {
                    if ScenarioController.currentActionIndex < 17 {
                        return
                    }
                }
            }
    
            if CannonTouchController.state == .Trying {
                DataController.setDataForChangeCannonDistanceInTrying()
                CannonController.execute(3, cannon: nil)
                CannonTryController.getBG() { bg in
                    guard let canSim = bg else { return }
                    canSim.recordBoard.createCannon(ve: tempVe)
                }
            } else {
                CannonController.execute(1, cannon: nil)
            }
        }
        
        /* Touch button try */
        if nodeAtPoint.name == "buttonTry" {
            if operant == 0 {
                CannonController.selectedCannon.constantsArray.append(tempSpot)
            } else {
                CannonController.selectedCannon.constantsArray.append(-tempSpot)
            }
            
            CannonController.selectedCannon.setInputVE(value: variableExpression)
            
            /* Reset stuffs */
            self.variableExpression = ""
            self.putXFlag = false
            self.operant = 0
            self.coefficientFlag = false
            self.tempSpot = 0
            /* Valid x, num */
            self.uncoverNumber()
            self.uncoverX()
            /* Invalid +-, ok */
            self.coverOperant()
            self.coverOK()
            
            DataController.setDataForUsedTryCannon()
            
            self.isHidden = true
            CannonController.execute(2, cannon: nil)
        }
        
    }
    
    func tappedNumber(num: Int) {
        /* Valid x, +-, 0 */
        uncoverOperant()
        uncover0()
        
        /* Make sure to put at least one x */
        if isNewVesion {
            if putXFlag {
                uncoverOK()
            } else {
                coverOK()
            }
        } else {
            uncoverOK()
        }
        
        variableExpression.append(String(num))
        
        /* Calculate value */
        if tempSpot != 0 {
            tempSpot = tempSpot*10+num
        } else {
            tempSpot = num
        }
        coefficientFlag = true
    }
    
    func makeButtons(completion: @escaping ([SKSpriteNode]) -> Void) {
        
        let button1 = SKSpriteNode(imageNamed: "input1")
        let button2 = SKSpriteNode(imageNamed: "input2")
        let button3 = SKSpriteNode(imageNamed: "input3")
        let button4 = SKSpriteNode(imageNamed: "input4")
        let button5 = SKSpriteNode(imageNamed: "input5")
        let button6 = SKSpriteNode(imageNamed: "input6")
        let button7 = SKSpriteNode(imageNamed: "input7")
        let button8 = SKSpriteNode(imageNamed: "input8")
        let button9 = SKSpriteNode(imageNamed: "input9")
        buttonMinus = SKSpriteNode(imageNamed: "input-")
        buttonPlus = SKSpriteNode(imageNamed: "input+")
        buttonX = SKSpriteNode(imageNamed: "inputX")
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
        if GameScene.stageLevel < MainMenu.invisivleStartTurn {
            let button0 = SKSpriteNode(imageNamed: "input0")
            button0.name = "button0"
            return completion([button0, button1, button2, button3, button4, button5, button6, button7, button8, button9, buttonMinus, buttonPlus, buttonX])
        } else {
            return completion([button1, button2, button3, button4, button5, button6, button7, button8, button9, buttonMinus, buttonPlus, buttonX])
        }
        
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
                if i < 4 {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i), y: self.centerY)
                    button.position = pos
                    if button.name == "button0" {
                        self.cover0Btn = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        self.cover0Btn.isHidden = false
                        self.coverNumArray.append(self.cover0Btn)
                    } else {
                        let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        cover.isHidden = true
                        self.coverNumArray.append(cover)
                    }
                } else if i < 8 {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-4), y: secondLayerPosY)
                    button.position = pos
                    let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                    cover.isHidden = true
                    self.coverNumArray.append(cover)
                } else {
                    let pos = CGPoint(x: leadingPosX+(rMerginX)*CGFloat(i-8), y: thirdLayerPosY)
                    button.position = pos
                    if button.name == "button8" || button.name == "button9" {
                        let cover = self.setCoverButtons(buttonSize: self.radius, buttonPosition: pos)
                        cover.isHidden = true
                        self.coverNumArray.append(cover)
                    } else if button.name == "buttonX" {
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
        
        /* button try */
        buttonTry = SKSpriteNode(imageNamed: "tryButton")
        buttonTry.size = tryButtonSize
        buttonTry.position = tryButtonPos
        buttonTry.name = "buttonTry"
        buttonTry.zPosition = 3
        addChild(buttonTry)
        coverTryBtn = SKShapeNode(rect: CGRect(x: tryButtonPos.x-tryButtonSize.width/2, y: tryButtonPos.y-tryButtonSize.height/2, width: tryButtonSize.width, height: tryButtonSize.height))
        
        coverTryBtn.fillColor = UIColor.black
        coverTryBtn.alpha = 0.4
        coverTryBtn.zPosition = 5
        addChild(coverTryBtn)
        coverTryBtn.isHidden = false
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
    
    /* Toggle +- buttons */
    func coverOperant() {
        guard isNewVesion else { return }
        for c in coverOpeArray {
            c.isHidden = false
        }
    }
    func uncoverOperant() {
        guard isNewVesion else { return }
        for c in coverOpeArray {
            c.isHidden = true
        }
    }
    
    /* Toggle x buttons */
    func coverX() {
        guard isNewVesion else { return }
        coverXBtn.isHidden = false
    }
    func uncoverX() {
        guard isNewVesion else { return }
        coverXBtn.isHidden = true
    }
    
    /* Toggle number buttons */
    func coverNumber() {
        guard isNewVesion else { return }
        for c in coverNumArray {
            c.isHidden = false
        }
    }
    func uncoverNumber() {
        guard isNewVesion else { return }
        for c in coverNumArray {
            c.isHidden = true
        }
    }
    
    /* Toggle 0 buttons */
    func cover0() {
        guard !isNewVesion else { return }
        cover0Btn.isHidden = false
    }
    
    func uncover0() {
        guard !isNewVesion else { return }
        cover0Btn.isHidden = true
    }
    
    /* Toggle ok buttons */
    func coverOK() {
        coverOKBtn.isHidden = false
        guard GameScene.stageLevel >= MainMenu.invisivleStartTurn else { return }
        guard CannonTouchController.state != .Trying else { return }
        coverTryBtn.isHidden = false
    }
    
    func uncoverOK() {
        coverOKBtn.isHidden = true
        guard GameScene.stageLevel >= MainMenu.invisivleStartTurn else { return }
        guard CannonTouchController.state != .Trying else { return }
        coverTryBtn.isHidden = true
    }
    
    func oldVersion() {
        buttonX.isHidden = true
        buttonPlus.isHidden = true
        buttonMinus.isHidden = true
        coverXBtn.isHidden = true
        for c in coverOpeArray {
            c.isHidden = true
        }
    }
    
}
