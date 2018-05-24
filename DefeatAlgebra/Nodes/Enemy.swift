//
//  Enemy.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum EnemyState {
    case Move, Punch
}

class Enemy: SKSpriteNode {
    
    /* Enemy state management */
    var enemyState: EnemyState = .Move
    var circle = SKShapeNode(circleOfRadius: 20.0)
    
    /* Enemy position */
    var positionX = 0
    var positionY = 0
    
    /* Enemy property */
    var moveSpeed = 0.1
    var punchSpeed: CGFloat = 0.0020
    var direction: Direction = .front
    var punchInterval: Int!
    var punchIntervalForCount: Int = 0
    var singleTurnDuration: TimeInterval = 0.2
    var vECategory = 0
    var enemyLife = 0
    
    /* Enemy variable for punch */
    var valueOfEnemy: Int = 0
    var firstPunchLength: CGFloat = 78
    var singlePunchLength: CGFloat = 78
    var punchLength: CGFloat! = 0
    var variableExpression: [Int]!
    var variableExpressionForLabel = ""
    var variableExpressionString = ""
    var originVariableExpression = ""
    
    /* For arms when punch hit wall */
    var armArrayForSubSet: [EnemyArm] = []
    
    /* Flags */
    var myTurnFlag = false
    var turnDoneFlag = false
    var reachCastleFlag = false
    var wallHitFlag = false
    var aliveFlag = true
    var editedVEFlag = false
    var forEduOriginFlag = false
    var forEduBranchFlag = false
    
    init(variableExpressionSource: [[Int]], forEdu: Bool) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front1")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Set name */
        setName()
        
        /* Set punch interval */
        if forEdu == false {
            setPunchInterval()
        }
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 7
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /* Set physics property */
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        /* Set variable expression */
        EnemyVEController.setVariableExpression(enemy: self, variableExpressionSource: variableExpressionSource) { success in
            if !success {
                print("setVariableExpression: \(success)")
            }
        }
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /*===============*/
    /*== Animation ==*/
    /*===============*/
    
    /* Set standing texture of enemy according to direction */
    func setStandingtexture() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "front1")
        case .back:
            self.texture = SKTexture(imageNamed: "back1")
        case .left:
            self.texture = SKTexture(imageNamed: "left1")
        case .right:
            self.texture = SKTexture(imageNamed: "right1")
        }
    }
    
    /* Set Animation to enemy according to direction */
    func setMovingAnimation() {
        switch direction {
        case .front:
            let enemyMoveAnimation = SKAction(named: "enemyMoveForward")!
            self.run(enemyMoveAnimation)
        case .back:
            let enemyMoveAnimation = SKAction(named: "enemyMoveBackward")!
            self.run(enemyMoveAnimation)
        case .left:
            let enemyMoveAnimation = SKAction(named: "enemyMoveLeft")!
            self.run(enemyMoveAnimation)
        case .right:
            let enemyMoveAnimation = SKAction(named: "enemyMoveRight")!
            self.run(enemyMoveAnimation)
        }
    }
    
    /*==================*/
    /*== Set property ==*/
    /*==================*/
    
    /* Set name */
    func setName() {
        self.name = "enemy"
    }
    
    func setVariableExpressionLabel(text: String) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set text */
        label.text = text
        
        /* Set name */
        label.name = "variableExpressionLabel"
        
        /* Enphasize it if enemy will punch next turn */
        if self.punchIntervalForCount == 0 {
            label.fontColor = UIColor.red
        }
        
        /* Set font size */
        label.fontSize = 35
        
        /* Set zPosition */
        label.zPosition = 5
        
        /* Set position */
        label.position = CGPoint(x:0, y: 35)
        
        /* Add to Scene */
        self.addChild(label)
        
        /*
         /* Edit button if needed */
         if variableExpression.count >= 5 {
         let editButton = SKSpriteNode(imageNamed: "editButton")
         editButton.size = CGSize(width: 25, height: 25)
         editButton.position = CGPoint(x: 30, y: 15)
         editButton.name  = "editButton"
         editButton.zPosition = 5
         addChild(editButton)
         }
         */
    }
    
    func makeTriangle() {
        /* length of one side */
        let length: CGFloat = 7
        
        /* Set 4 points from start point to end point */
        var points = [CGPoint(x: 0.0, y: -length),
                      CGPoint(x: -length, y: length / 2.0),
                      CGPoint(x: length, y: length / 2.0),
                      CGPoint(x: 0.0, y: -length)]
        
        /* Make triangle */
        let triangle = SKShapeNode(points: &points, count: points.count)
        
        /* Set triangle position */
        triangle.position = CGPoint(x: 0, y: 35)
        triangle.zPosition = 4
        
        
        /* Colorlize triangle to red */
        triangle.fillColor = UIColor.red
        
        self.addChild(triangle)
    }
    
    /* Set punch interval randomly */
    func setPunchInterval() {
        let rand = Int(arc4random_uniform(100))
        
        /* punchInterval is 1 with 40% */
        if rand < 45 {
            punchInterval = 1
            punchIntervalForCount = punchInterval
            setPunchIntervalLabel()
            
            /* punchInterval is 2 with 40% */
        } else if rand < 90 {
            punchInterval = 2
            punchIntervalForCount = punchInterval
            setPunchIntervalLabel()
            
            /* punchInterval is 0 with 20% */
        } else {
            punchInterval = 0
            punchIntervalForCount = punchInterval
            setPunchIntervalLabel()
            
        }
        
    }
    
    func setPunchIntervalLabel() {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set name */
        label.name = "punchInterval"
        
        /* Set text */
        label.text = String(self.punchIntervalForCount)
        
        /* Enphasize it if enemy will punch next turn */
        if self.punchIntervalForCount == 0 {
            label.fontColor = UIColor.red
            if let label = self.childNode(withName: "variableExpressionLabel") as? SKLabelNode {
                label.fontColor = UIColor.red
            }
        }
        
        /* Set font size */
        label.fontSize = 30
        
        /* Set zPosition */
        label.zPosition = 5
        
        /* Set position */
        label.position = CGPoint(x:0, y: -40)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    /*==================*/
    /*== Enemy Action ==*/
    /*==================*/
    
    /*== Move ==*/
    /* Move enemy */
    func enemyMove() {
        
        /* Get grid node */
        let gridNode = self.parent as! Grid
        
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        
        EnemyMoveController.move(enemy: self, gridNode: gridNode)
        
        /* Move next enemy's turn */
        let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
        let moveNextEnemy = SKAction.run({
            self.myTurnFlag = false
            if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                gridNode.turnIndex += 1
                gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
            }
            
            /* Remove punchInterval label */
            if let theNode = self.childNode(withName: "punchInterval") {
                theNode.removeFromParent()
            }
            
            /* To check all enemy turn done */
            gridNode.numOfTurnEndEnemy += 1
            
            /* Count down till do punch */
            self.punchIntervalForCount -= 1
            
            /* Display left turn till punch */
            self.setPunchIntervalLabel()
        })
        
        /* excute drawPunch */
        let seq = SKAction.sequence([moveTurnWait, moveNextEnemy])
        self.run(seq)
    }
    
    /*== Attack ==*/
    /* Calculate punch length */
    func calculatePunchLength(value: Int) {
        /* Calculate value of variable expression of enemy */
        if variableExpression[0] == 4 {
            self.valueOfEnemy = value*self.variableExpression[1]-variableExpression[2]
        } else if variableExpression[0] == 5 || variableExpression[0] == 7 {
            self.valueOfEnemy = variableExpression[2]-value*self.variableExpression[1]
        } else {
            self.valueOfEnemy = value*self.variableExpression[1]+variableExpression[2]
        }
        
        /* Calculate length of punch */
        self.punchLength = self.firstPunchLength + CGFloat(self.valueOfEnemy-1) * self.singlePunchLength
    }
    
    /* Set texture in punching */
    func setTextureInPunch() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "frontPunch")
        case .back:
            self.texture = SKTexture(imageNamed: "backPunch55")
        case .left:
            self.texture = SKTexture(imageNamed: "leftPunch55")
            break;
        case .right:
            self.texture = SKTexture(imageNamed: "rightPunch55")
            break;
        }
        
    }
    
    /* Set position of arm */
    func setArm(arm: [EnemyArm], direction: Direction) {
        
        /* Set position of arms */
        switch direction {
        case .front:
            let armPos1 = CGPoint(x: -18, y: 5)
            let armPos2 = CGPoint(x: 18, y: 5)
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .back:
            let armPos1 = CGPoint(x: -13, y: 10)
            let armPos2 = CGPoint(x: 13, y: 10)
            arm[0].zPosition = -1
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .left:
            let armPos1 = CGPoint(x: 0, y: 3)
            let armPos2 = CGPoint(x: 0, y: -10)
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        case .right:
            let armPos1 = CGPoint(x: 0, y: 3)
            let armPos2 = CGPoint(x: 0, y: -10)
            arm[1].zPosition = -1
            arm[0].position = armPos1
            arm[1].position = armPos2
        }
        
        /* Add arm as enemy child */
        addChild(arm[0])
        addChild(arm[1])
    }
    
    /* Set position of fist */
    func setFist(fist: [EnemyFist], direction: Direction) {
        
        /* Set position of fists */
        switch direction {
        case .front:
            let fistPos1 = CGPoint(x: -20, y: 5)
            let fistPos2 = CGPoint(x: 19, y: 5)
            fist[0].position = fistPos1
            fist[1].position = fistPos2
            fist[1].texture = SKTexture(imageNamed: "frontFistLeft")
        case .back:
            let fistPos1 = CGPoint(x: -13, y: 10)
            let fistPos2 = CGPoint(x: 13, y: 10)
            fist[0].zPosition = -1
            fist[1].zPosition = -1
            fist[0].position = fistPos1
            fist[1].position = fistPos2
        case .left:
            let fistPos1 = CGPoint(x: 0, y: 3)
            let fistPos2 = CGPoint(x: 0, y: -10)
            fist[1].zPosition = -1
            fist[0].position = fistPos1
            fist[1].position = fistPos2
        case .right:
            let fistPos1 = CGPoint(x: 0, y: 3)
            let fistPos2 = CGPoint(x: 0, y: -10)
            fist[1].zPosition = -1
            fist[0].position = fistPos1
            fist[1].position = fistPos2
        }
        
        /* Add arm as enemy child */
        addChild(fist[0])
        addChild(fist[1])
    }
    
    /* Do punch */
    func punch() -> (arm: [EnemyArm], fist: [EnemyFist]) {
        let gridNode = self.parent as! Grid
        
        if self.positionY < self.valueOfEnemy {
            /* Adjust punch length */
            self.punchLength  = CGFloat(Double(self.positionY)*gridNode.cellHeight+100.0)
            
            /* Make sure enemy punch front direction */
            self.direction = .front
            
            /* Stop animation of enemy */
            self.removeAllActions()
            
            /* Set texture according to direction of enemy */
            self.setTextureInPunch()
            
            /* Set arm */
            let arm1 = EnemyArm(direction: self.direction)
            let arm2 = EnemyArm(direction: self.direction)
            setArm(arm: [arm1, arm2], direction: self.direction)
            
            /* Set fist */
            let fist1 = EnemyFist(direction: self.direction)
            let fist2 = EnemyFist(direction: self.direction)
            setFist(fist: [fist1, fist2], direction: self.direction)
            
            /* Move Fist */
            fist1.moveFistForward(length: punchLength, speed: self.punchSpeed)
            fist2.moveFistForward(length: punchLength, speed: self.punchSpeed)
            
            /* Extend arm */
            arm1.extendArm(length: punchLength, speed: self.punchSpeed)
            arm2.extendArm(length: punchLength, speed: self.punchSpeed)
            
            /* Store reference for func drawPunch */
            return ([arm1, arm2], [fist1, fist2])
        } else {
            /* Make sure enemy punch front direction */
            self.direction = .front
            
            /* Stop animation of enemy */
            self.removeAllActions()
            
            /* Set texture according to direction of enemy */
            self.setTextureInPunch()
            
            /* Set arm */
            let arm1 = EnemyArm(direction: self.direction)
            let arm2 = EnemyArm(direction: self.direction)
            setArm(arm: [arm1, arm2], direction: self.direction)
            
            /* Set fist */
            let fist1 = EnemyFist(direction: self.direction)
            let fist2 = EnemyFist(direction: self.direction)
            setFist(fist: [fist1, fist2], direction: self.direction)
            
            /* Move Fist */
            fist1.moveFistForward(length: punchLength, speed: self.punchSpeed)
            fist2.moveFistForward(length: punchLength, speed: self.punchSpeed)
            
            /* Extend arm */
            arm1.extendArm(length: punchLength, speed: self.punchSpeed)
            arm2.extendArm(length: punchLength, speed: self.punchSpeed)
            
            /* Store reference for func drawPunch */
            return ([arm1, arm2], [fist1, fist2])
        }
    }
    
    func moveBodyForward(length: CGFloat, speed: CGFloat) {
        /* Move fist */
        switch direction {
        case .front:
            let moveFist = SKAction.moveBy(x: 0, y: -length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .back:
            let moveFist = SKAction.moveBy(x: 0, y: -length, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .left:
            let moveFist = SKAction.moveBy(x: length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        case .right:
            let moveFist = SKAction.moveBy(x: -length, y: 0, duration: TimeInterval(length*speed))
            self.run(moveFist)
        }
    }
    
    func drawPunch(arms: [EnemyArm], fists: [EnemyFist], length: CGFloat) {
        for arm in arms {
            arm.ShrinkArm(length: length, speed: self.punchSpeed)
        }
        
        if arms.count > 0 {
            for fist in fists {
                fist.moveFistBackward(length: arms[0].size.height, speed: self.punchSpeed)
            }
        }
    }
    
    /* Enemy punch and move to the position of fist */
    func punchAndMove() {
        
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        
        /* Get grid node */
        let gridNode = self.parent as! Grid
        /* Get GameScene */
        let gameScene = gridNode.parent as! GameScene
        
        /* Do punch */
        let armAndFist = self.punch()
        
        /* Enemy punch beyond edge of grid */
        if self.positionY < self.valueOfEnemy {
            
            /* Decrese life */
            let decreseLife = SKAction.run({
                if self.wallHitFlag == false {
                    gameScene.life -= 1
                    gameScene.setLife(numOflife: gameScene.life)
                } else {
                    gameScene.life += 0
                }
            })
            
            /* Calculate punchlength */
            let originPosY = self.positionY
            self.punchLength = CGFloat(Double(originPosY)*gridNode.cellHeight)+95 /* 95 is an adjustment */
            
            /* Wait till punch streach out fully */
            let wait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed))
            
            /* Subsutitute arm with opposite direction arm for shrink it the other way around */
            let subSetArm = SKAction.run({
                for arm in armAndFist.arm {
                    let size = arm.size
                    let posX = arm.position.x
                    let posY = arm.position.y-size.height
                    let newArm = EnemyArm(direction: self.direction)
                    newArm.yScale = (size.height)/newArm.size.height
                    newArm.position = CGPoint(x: posX, y: posY)
                    newArm.anchorPoint = CGPoint(x: 0.5, y: 1)
                    newArm.physicsBody = nil
                    self.addChild(newArm)
                    self.armArrayForSubSet.append(newArm)
                }
            })
            
            /* Make sure to remove old arm after setting new arm done */
            let waitForSubSet = SKAction.wait(forDuration: 0.25)
            
            /* Remove old arms */
            let removeArm = SKAction.run({
                for arm in armAndFist.arm {
                    arm.removeFromParent()
                }
            })
            
            /* Move enemy's body to punch position */
            let moveForward = SKAction.run({
                let moveBody = SKAction.moveBy(x: 0, y: -CGFloat(Double(originPosY)*gridNode.cellHeight), duration: TimeInterval(self.punchLength*self.punchSpeed))
                self.run(moveBody)
                for arm in self.armArrayForSubSet {
                    let moveArm = SKAction.moveBy(x: 0, y: CGFloat(Double(originPosY)*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    arm.run(moveArm)
                }
                for fist in armAndFist.fist {
                    let moveFist = SKAction.moveBy(x: 0, y: CGFloat(Double(originPosY)*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    fist.run(moveFist)
                }
            })
            
            
            /* Shrink arms */
            let shrinkArm = SKAction.run({
                for arm in self.armArrayForSubSet {
                    let shrinkArm = SKAction.scaleY(to: 3.0, duration: TimeInterval(self.punchLength*self.punchSpeed))
                    arm.run(shrinkArm)
                }
            })
            
            /* Make sure delete arms & fists after finishing punch drawing */
            let drawWait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed-0.1)) /* 0.1 is buffer */
            
            /* Get rid of all arms and fists */
            let punchDone = SKAction.run({
                self.removeAllChildren()
            })
            
            /* Set variable expression */
            let setVariableExpression = SKAction.run({
                //                self.makeTriangle()
                /* Reset count down punchInterval */
                self.punchIntervalForCount = self.punchInterval
                self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
                /* Reset enemy animation */
                self.setMovingAnimation()
                self.setPunchIntervalLabel()
            })
            
            /* Move next enemy's turn */
            let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
            let moveNextEnemy = SKAction.run({
                self.myTurnFlag = false
                /* For sound */
                gameScene.hitCastleWallSoundDone = false
                if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                    gridNode.turnIndex += 1
                    gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
                }
                
                /* To check all enemy turn done */
                gridNode.numOfTurnEndEnemy += 1
                
                /* Reset flag */
                self.wallHitFlag = false
                
                /* Set enemy position to edge */
                self.positionY = 0
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, subSetArm, waitForSubSet, removeArm, moveForward, shrinkArm, drawWait, decreseLife, punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
            self.run(seq)
            
        } else {
            
            /* Keep track enemy position */
            self.positionY -= self.valueOfEnemy
            
            /* Wait untill enemy punch streach out */
            let wait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed))
            
            /* Subsutitute arm with opposite direction arm for shrink it the other way around */
            let subSetArm = SKAction.run({
                for arm in armAndFist.arm {
                    let size = arm.size
                    let posX = arm.position.x
                    let posY = arm.position.y-size.height
                    let newArm = EnemyArm(direction: self.direction)
                    newArm.yScale = (size.height)/newArm.size.height
                    newArm.position = CGPoint(x: posX, y: posY)
                    newArm.anchorPoint = CGPoint(x: 0.5, y: 1)
                    newArm.physicsBody = nil
                    self.addChild(newArm)
                    self.armArrayForSubSet.append(newArm)
                }
            })
            
            /* Make sure to remove old arm after setting new arm done */
            let waitForSubSet = SKAction.wait(forDuration: 0.25)
            
            /* Remove old arms */
            let removeArm = SKAction.run({
                for arm in armAndFist.arm {
                    arm.removeFromParent()
                }
            })
            
            /* Move self's body to punch position */
            let moveForward = SKAction.run({
                let moveBody = SKAction.moveBy(x: 0, y: -CGFloat(Double(self.valueOfEnemy)*gridNode.cellHeight), duration: TimeInterval(self.punchLength*self.punchSpeed))
                self.run(moveBody)
                for arm in self.armArrayForSubSet {
                    let moveArm = SKAction.moveBy(x: 0, y: CGFloat(Double(self.valueOfEnemy)*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    arm.run(moveArm)
                }
                for fist in armAndFist.fist {
                    let moveFist = SKAction.moveBy(x: 0, y: CGFloat(Double(self.valueOfEnemy)*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    fist.run(moveFist)
                }
            })
            
            
            /* Shrink arms */
            let shrinkArm = SKAction.run({
                for arm in self.armArrayForSubSet {
                    arm.ShrinkArm(length: self.punchLength, speed: self.punchSpeed)
                }
            })
            
            /* Make sure delete arms & fists after finishing punch drawing */
            let drawWait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed-0.1)) /* 0.1 is buffer */
            
            /* Get rid of all arms and fists */
            let punchDone = SKAction.run({
                self.removeAllChildren()
            })
            
            /* Set variable expression */
            let setVariableExpression = SKAction.run({
                /* Reset count down punchInterval */
                self.punchIntervalForCount = self.punchInterval
                /* Create variable expression */
                //                self.makeTriangle()
                self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
                /* Reset enemy animation */
                self.setMovingAnimation()
                /* Display left trun till punch */
                self.setPunchIntervalLabel()
            })
            
            /* Move next enemy's turn */
            let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
            let moveNextEnemy = SKAction.run({
                self.myTurnFlag = false
                if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                    gridNode.turnIndex += 1
                    gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
                }
                
                /* To check all enemy turn done */
                gridNode.numOfTurnEndEnemy += 1
                
                
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, subSetArm, waitForSubSet, removeArm, moveForward, shrinkArm, drawWait, punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
            self.run(seq)
        }
        
    }
    
    /* Punch when enemy reach to castle */
    func punchToCastle() {
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        
        /* Get grid node */
        let gridNode = self.parent as! Grid
        /* Get GameScene */
        let gameScene = gridNode.parent as! GameScene
        
        /* Decrese life */
        let decreseLife = SKAction.run({
            gameScene.life -= 1
            gameScene.setLife(numOflife: gameScene.life)
        })
        
        /* Set punchLength */
        self.punchLength = self.position.y+gameScene.gridNode.position.y-gameScene.castleNode.position.y-40+5
        
        /* Do punch */
        let armAndFist = self.punch()
        
        /* Wait for punch streach out fully */
        let wait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed))
        
        /* Draw punch */
        let draw = SKAction.run({
            self.drawPunch(arms: armAndFist.arm, fists: armAndFist.fist, length: self.punchLength)
        })
        
        /* Make sure delete arms & fists after finishing punch drawing */
        let drawWait = SKAction.wait(forDuration: TimeInterval(self.punchLength*self.punchSpeed-0.1)) /* 0.1 is buffer */
        
        /* Get rid of all arms and fists */
        let punchDone = SKAction.run({
            self.removeAllChildren()
        })
        
        /* Set variable expression */
        let setVariableExpression = SKAction.run({
            self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
            self.setPunchIntervalLabel()
        })
        
        /* Move next enemy's turn */
        let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
        let moveNextEnemy = SKAction.run({
            self.myTurnFlag = false
            gameScene.hitCastleWallSoundDone = false
            /* Reset enemy animation */
            self.setMovingAnimation()
            
            if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                gridNode.turnIndex += 1
                gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
            }
            
            /* To check all enemy turn done */
            gridNode.numOfTurnEndEnemy += 1
        })
        
        /* excute drawPunch */
        let seq = SKAction.sequence([wait, decreseLife, draw, drawWait, punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
        self.run(seq)
    }
    
    
    /*== For Magic Sword ==*/
    /* Put color to enemy */
    func colorizeEnemy(color: UIColor) {
        self.run(SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.50))
    }
    
    func resetColorizeEnemy() {
        self.run(SKAction.colorize(with: UIColor.purple, colorBlendFactor: 0, duration: 0.50))
    }
}
