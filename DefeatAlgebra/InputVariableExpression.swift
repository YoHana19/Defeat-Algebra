//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class InputVariableExpression: SKSpriteNode {
    
    var isActive: Bool = false {
        didSet {
            /* Visibility */
            self.isHidden = !isActive
        }
    }
    
    var variableExpressionLabel: SKLabelNode!
    var variableExpression: String = "" {
        didSet {
            variableExpressionLabel.text = variableExpression
        }
    }
    
    /* Calculate outputValue */
    var outputValue: Int = 0
    var operant = 0 /* 0: +, 1: - */
    var coefficientFlag = false
    var tempSpot = 0
    
    /* Set buttons */
    var buttonX: SKSpriteNode!
    var button1: SKSpriteNode!
    var button2: SKSpriteNode!
    var button3: SKSpriteNode!
    var buttonPuls: SKSpriteNode!
    var buttonMinus: SKSpriteNode!
    var buttonFire: SKSpriteNode!
    var invalidNote: SKSpriteNode!
    var dismissButton: SKSpriteNode!
    var coverArray = [SKShapeNode]()
    
    
    /* Flags for validation */
    var numberFlag = false
    var xFlag = false
    var operationFlag = false
    var putXFlag = false
    var errorFlag = false
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "inputBoard")
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
        if nodeAtPoint.name == "buttonX" {
            print("x")
            /* Display variable expression */
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("x")
                /* Valid +-, fire */
                uncoverOperant()
                uncoverFire()
                
                /* Invalid x, 123 */
                coverX()
                coverNumber()
                
                /* Make sure to put at least one x */
                putXFlag = true
            }
            
            /* Calculate value */
            if operant == 0 {
                if coefficientFlag == false {
                    outputValue += gameScene.xValue
                    gameScene.activeCatapult.coefficientArray.append(1)
                } else {
                    outputValue += tempSpot*gameScene.xValue
                    gameScene.activeCatapult.coefficientArray.append(tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            } else {
                if coefficientFlag == false {
                    outputValue -= gameScene.xValue
                    gameScene.activeCatapult.coefficientArray.append(-1)
                } else {
                    outputValue -= tempSpot*gameScene.xValue
                    gameScene.activeCatapult.coefficientArray.append(-tempSpot)
                    coefficientFlag = false
                    tempSpot = 0
                }
            }
        }
        
        /* Touch button 1 */
        if nodeAtPoint.name == "button1" {
            //            print("1")
            /* Display variable expression */
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("1")
                
                /* Valid x, +- */
                uncoverOperant()
                
                /* Invalid 123 */
                coverNumber()
                
                /* Make sure to put at least one x */
                if putXFlag {
                    uncoverFire()
                } else {
                    coverFire()
                }
            }
            
            /* Calculate value */
            tempSpot = 1
            coefficientFlag = true
        }
        
        /* Touch button 2 */
        if nodeAtPoint.name == "button2" {
            //            print("2")
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("2")
                
                /* Valid x, +- */
                uncoverOperant()
                
                /* Invalid 123 */
                coverNumber()
                
                /* Make sure to put at least one x */
                if putXFlag {
                    uncoverFire()
                } else {
                    coverFire()
                }
            }
            /* Calculate value */
            tempSpot = 2
            coefficientFlag = true
            
        }
        
        /* Touch button 3 */
        if nodeAtPoint.name == "button3" {
            //            print("3")
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("3")
                
                /* Valid x, +- */
                uncoverOperant()
                
                /* Invalid 123 */
                coverNumber()
                
                /* Make sure to put at least one x */
                if putXFlag {
                    uncoverFire()
                } else {
                    coverFire()
                }
            }
            /* Calculate value */
            tempSpot = 3
            coefficientFlag = true
            
        }
        
        /* Touch button + */
        if nodeAtPoint.name == "button+" {
            //            print("+")
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("+")
                
                /* Valid x, 123 */
                uncoverNumber()
                uncoverX()
                
                /* Invalid +-, fire */
                coverOperant()
                coverFire()
            }
            
            /* Calculate value */
            if coefficientFlag {
                if operant == 0 {
                    outputValue += tempSpot
                    gameScene.activeCatapult.constantsArray.append(tempSpot)
                    operant = 0
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    outputValue -= tempSpot
                    gameScene.activeCatapult.constantsArray.append(-tempSpot)
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
            //            print("-")
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                variableExpression.append("-")
                
                /* Valid x, 123 */
                uncoverNumber()
                uncoverX()
                
                /* Invalid +-, fire */
                coverOperant()
                coverFire()
            }
            
            /* Calculate value */
            if coefficientFlag {
                if operant == 0 {
                    outputValue += tempSpot
                    gameScene.activeCatapult.constantsArray.append(tempSpot)
                    operant = 1
                    coefficientFlag = false
                    tempSpot = 0
                } else {
                    outputValue -= tempSpot
                    gameScene.activeCatapult.constantsArray.append(-tempSpot)
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
            //            print("clear")
            
            guard errorFlag == false else { return }
            
            /* Reset */
            operant = 0
            coefficientFlag = false
            tempSpot = 0
            outputValue = 0
            variableExpression = ""
            variableExpressionLabel.text = "0"
            putXFlag = false
            
            /* Valid x, 123 */
            uncoverNumber()
            uncoverX()
            
            /* Invalid +-, fire */
            coverOperant()
            coverFire()
            
            /* Reset elemnts of variable expression of catapult */
            gameScene.activeCatapult.resetVEElementArray()
            
            
        }
        
        /* Touch button Fire */
        if nodeAtPoint.name == "buttonFire" {
            //            print("fire")
            if variableExpression.characters.count > 6 {
                invalidNote.isHidden = false
                dismissButton.isHidden = false
                errorFlag = true
            } else {
                gameScene.activeCatapult.variableExpression = variableExpression
                if operant == 0 {
                    outputValue += tempSpot
                    variableExpression = String(outputValue)
                    gameScene.activeCatapult.constantsArray.append(tempSpot)
                } else {
                    outputValue -= tempSpot
                    variableExpression = String(outputValue)
                    gameScene.activeCatapult.constantsArray.append(-tempSpot)
                }
                
                let wait = SKAction.wait(forDuration: 1.0)
                let removeBoard = SKAction.run({ self.isActive = !self.isActive })
                let resetStuffs = SKAction.run({
                    /* Reset stuffs */
                    self.operant = 0
                    self.coefficientFlag = false
                    self.tempSpot = 0
                    self.variableExpression = ""
                    self.variableExpressionLabel.text = "0"
                    self.putXFlag = false
                    /* Valid x, 123 */
                    self.uncoverNumber()
                    self.uncoverX()
                    
                    /* Invalid +-, fire */
                    self.coverOperant()
                    self.coverFire()
                })
                let onFlag = SKAction.run({ gameScene.catapultFireReady = true })
                let seq = SKAction.sequence([wait, removeBoard, resetStuffs, onFlag])
                self.run(seq)
                
            }
        }
        
        /* Touch dismiss button */
        if nodeAtPoint.name == "dismissButton" {
            dismissButton.isHidden = true
            invalidNote.isHidden = true
            
            errorFlag = false
            
            outputValue = 0
            variableExpression = ""
            variableExpressionLabel.text = "0"
            
            putXFlag = false
            
            /* Valid x, 123 */
            uncoverNumber()
            uncoverX()
            
            /* Invalid +-, fire */
            coverOperant()
            coverFire()
            
            /* Reset elemnts of variable expression of catapult */
            gameScene.activeCatapult.resetVEElementArray()
        }
    }
    
    func setButtons() {
        /* Set button size */
        let buttonSize = CGSize(width: 120, height: 120)
        
        /* button x */
        let buttonX = SKSpriteNode(imageNamed: "inputx")
        buttonX.size = buttonSize
        buttonX.position = CGPoint(x: -200, y: 100)
        buttonX.name = "buttonX"
        buttonX.zPosition = 3
        addChild(buttonX)
        let coverX = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: -200, y: 100))
        coverX.isHidden = true
        
        /* button 1 */
        let button1 = SKSpriteNode(imageNamed: "input1")
        button1.size = buttonSize
        button1.position = CGPoint(x: -200, y: -80)
        button1.name = "button1"
        button1.zPosition = 3
        addChild(button1)
        let cover1 = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: -200, y: -80))
        cover1.isHidden = true
        
        /* button 2 */
        let button2 = SKSpriteNode(imageNamed: "input2")
        button2.size = buttonSize
        button2.position = CGPoint(x: -50, y: -80)
        button2.name = "button2"
        button2.zPosition = 3
        addChild(button2)
        let cover2 = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: -50, y: -80))
        cover2.isHidden = true
        
        /* button 3 */
        let button3 = SKSpriteNode(imageNamed: "input3")
        button3.size = buttonSize
        button3.position = CGPoint(x: 100, y: -80)
        button3.name = "button3"
        button3.zPosition = 3
        addChild(button3)
        let cover3 = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: 100, y: -80))
        cover3.isHidden = true
        
        /* button + */
        let buttonPlus = SKSpriteNode(imageNamed: "input+")
        buttonPlus.size = buttonSize
        buttonPlus.position = CGPoint(x: -200, y: -260)
        buttonPlus.name = "button+"
        buttonPlus.zPosition = 3
        addChild(buttonPlus)
        let coverPlus = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: -200, y: -260))
        coverPlus.isHidden = false
        
        /* button - */
        let buttonMinus = SKSpriteNode(imageNamed: "input-")
        buttonMinus.size = buttonSize
        buttonMinus.position = CGPoint(x: -50, y: -260)
        buttonMinus.name = "button-"
        buttonMinus.zPosition = 3
        addChild(buttonMinus)
        let coverMinus = setCoverButtons(buttonSize: buttonSize, buttonPosition: CGPoint(x: -50, y: -260))
        coverMinus.isHidden = false
        
        /* button clear */
        let buttonClear = SKSpriteNode(imageNamed: "inputClear")
        buttonClear.size = CGSize(width: 180, height: 60)
        buttonClear.position = CGPoint(x: 170, y: -300)
        buttonClear.name = "buttonClear"
        buttonClear.zPosition = 3
        addChild(buttonClear)
        
        /* button fire */
        let buttonFire = SKSpriteNode(imageNamed: "inputFire")
        buttonFire.size = CGSize(width:180, height: 60)
        buttonFire.position = CGPoint(x: 170, y: -200)
        buttonFire.name = "buttonFire"
        buttonFire.zPosition = 3
        addChild(buttonFire)
        let coverFire = setCoverButtons(buttonSize: CGSize(width:180, height: 60), buttonPosition: CGPoint(x: 170, y: -200))
        coverFire.isHidden = false
        
        /* Invalid note */
        invalidNote = SKSpriteNode(imageNamed: "warningNote")
        invalidNote.zPosition = 100
        invalidNote.isHidden = true
        addChild(invalidNote)
        
        /* button dismiss */
        dismissButton = SKSpriteNode(imageNamed: "dismissButton")
        dismissButton.size = CGSize(width:20, height: 20)
        dismissButton.position = CGPoint(x: invalidNote.size.width/2-20, y: invalidNote.size.height/2-20)
        dismissButton.name  = "dismissButton"
        dismissButton.zPosition = 101
        dismissButton.isHidden = true
        addChild(dismissButton)
        
        /* label of variable expresion */
        variableExpressionLabel = SKLabelNode(fontNamed: "GillSans-Bold")
        variableExpressionLabel.text = "0"
        variableExpressionLabel.fontSize = 96
        variableExpressionLabel.position = CGPoint(x: 0, y: 225)
        variableExpressionLabel.zPosition = 3
        addChild(variableExpressionLabel)
    }
    
    /* Create button cover so that you can't press buttons in pecific case */
    func setCoverButtons(buttonSize: CGSize, buttonPosition: CGPoint) -> SKShapeNode {
        let square = SKShapeNode(rectOf: buttonSize)
        square.fillColor = UIColor.black
        square.position = buttonPosition
        square.alpha = 0.4
        square.zPosition = 5
        addChild(square)
        coverArray.append(square)
        return square
        
    }
    
    /* Toggle +- buttons */
    func coverOperant() {
        coverArray[4].isHidden = false
        coverArray[5].isHidden = false
    }
    func uncoverOperant() {
        coverArray[4].isHidden = true
        coverArray[5].isHidden = true
    }
    
    
    /* Toggle x buttons */
    func coverX() {
        coverArray[0].isHidden = false
    }
    func uncoverX() {
        coverArray[0].isHidden = true
    }
    
    /* Toggle 1,2,3 buttons */
    func coverNumber() {
        coverArray[1].isHidden = false
        coverArray[2].isHidden = false
        coverArray[3].isHidden = false
    }
    func uncoverNumber() {
        coverArray[1].isHidden = true
        coverArray[2].isHidden = true
        coverArray[3].isHidden = true
    }
    
    /* Toggle fire buttons */
    func coverFire() {
        coverArray[6].isHidden = false
    }
    func uncoverFire() {
        coverArray[6].isHidden = true
    }
    
}
