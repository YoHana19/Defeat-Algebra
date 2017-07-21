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
    var moveSpeed = 0.2
    var punchSpeed: CGFloat = 0.0025
    var direction: Direction = .front
    var punchInterval: Int!
    var punchIntervalForCount: Int = 0
    var singleTurnDuration: TimeInterval = 1.0
    
    /* Enemy variable for punch */
    var valueOfEnemy: Int = 0
    var firstPunchLength: CGFloat = 78
    var singlePunchLength: CGFloat = 78
    var punchLength: CGFloat!
    var variableExpression: [Int]!
    var variableExpressionForLabel: String!
    
    /* For arms when punch hit wall */
    var armArrayForSubSet: [EnemyArm] = []
    
    /* Flags */
    var myTurnFlag = false
    var turnDoneFlag = false
    var reachCastleFlag = false
    
    var waitDoneFlag = false
    var punchDoneFlag = true
    var aliveFlag = true
    
    init(variableExpressionSource: [[Int]]) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front155")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        setName()
        
        punchLength = firstPunchLength+CGFloat((valueOfEnemy-1))*singlePunchLength
        
        /* Set punch interval */
        setPunchInterval()
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 5
        
        /* Set variable expression */
        setVariavleExpression(variableExpressionSource: variableExpressionSource)
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    /* Set variable expression */
    func setVariavleExpression(variableExpressionSource: [[Int]]) {
        
        let rand = arc4random_uniform(UInt32(variableExpressionSource.count))
        variableExpression = variableExpressionSource[Int(rand)]
        if variableExpression[0] == 1 {
            if variableExpression[1] == 0 {
                variableExpressionForLabel = "x"
            } else {
                variableExpressionForLabel = "x+\(variableExpression[1])"
            }
        } else {
            if variableExpression[1] == 0 {
                variableExpressionForLabel = "\(variableExpression[0])x"
            } else {
                variableExpressionForLabel = "\(variableExpression[0])x+\(variableExpression[1])"
            }
        }
    }
    
    /* Set name */
    func setName() {
        self.name = "enemy"
    }
    
    
    /* Set standing texture of enemy according to direction */
    func setStandingtexture() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "front155")
        case .back:
            self.texture = SKTexture(imageNamed: "back155")
        case .left:
            self.texture = SKTexture(imageNamed: "left155")
        case .right:
            self.texture = SKTexture(imageNamed: "right155")
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
        label.position = CGPoint(x:0, y: 50)
        
        /* Add to Scene */
        self.addChild(label)
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
    
    func calculatePunchLength(value: Int) {
        /* Calculate value of variable expression of enemy */
        self.valueOfEnemy = value*self.variableExpression[0]+variableExpression[1]
        
        /* Calculate length of punch */
        self.punchLength = self.firstPunchLength + CGFloat(self.valueOfEnemy-1) * self.singlePunchLength
    }

    
    /* Set texture in punching */
    func setTextureInPunch() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "frontPunch55")
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
            let armPos1 = CGPoint(x: -13, y: 5)
            let armPos2 = CGPoint(x: 13, y: 5)
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
            let fistPos1 = CGPoint(x: -13, y: 5)
            let fistPos2 = CGPoint(x: 13, y: 5)
            fist[0].position = fistPos1
            fist[1].position = fistPos2
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
    
    /* Move enemy */
    func enemyMove() {
        
        /* Get grid node */
        let gridNode = self.parent as! Grid
        
        /* Make sure not to call if it's not my turn */
        guard myTurnFlag else { return }
        
        /* Make sure to call once */
        guard turnDoneFlag == false else { return }
        turnDoneFlag = true
        
        /* Determine direction to move */
        let directionRand = arc4random_uniform(100)
        
        /* Left edge */
        if self.positionX <= 0 {
            /* Go forward with 70% */
            if directionRand < 70 {
                self.direction = .front
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionY -= 1
                
            /* Go right with 30% */
            } else if directionRand < 100 {
                self.direction = .right
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionX += 1
            }
            
        /* Right edge */
        } else if self.positionX >= gridNode.columns-1 {
            /* Go forward with 70% */
            if directionRand < 70 {
                self.direction = .front
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionY -= 1
                
                /* Go left with 30% */
            } else if directionRand < 100 {
                self.direction = .left
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionX -= 1
            }
            
        /* Middle */
        } else {
            /* Go forward with 60% */
            if directionRand < 60 {
                self.direction = .front
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: 0, y: -CGFloat(gridNode.cellHeight), duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionY -= 1
                
                /* Go left with 20% */
            } else if directionRand < 80 {
                self.direction = .left
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: -CGFloat(gridNode.cellWidth), y: 0, duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionX -= 1
                
                /* Go right with 20% */
            } else if directionRand < 100 {
                self.direction = .right
                self.setMovingAnimation()
                let move = SKAction.moveBy(x: CGFloat(gridNode.cellWidth), y: 0, duration: moveSpeed)
                self.run(move)
                
                /* Keep track enemy position */
                self.positionX += 1
            }
        }
        
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
            let decreseLife = SKAction.run({ gameScene.life -= 1 })
            
            /* Calculate punchlength */
            let originPosY = self.positionY
            self.punchLength = CGFloat(originPosY*gridNode.cellHeight)+gameScene.bottomGap+30 /* 30 is a buffer */
            
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
//                    newArm.physicsBody?.categoryBitMask = 0
//                    newArm.physicsBody?.contactTestBitMask = 0
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
                let moveBody = SKAction.moveBy(x: 0, y: -CGFloat(originPosY*gridNode.cellHeight), duration: TimeInterval(self.punchLength*self.punchSpeed))
                self.run(moveBody)
                for arm in self.armArrayForSubSet {
                    let moveArm = SKAction.moveBy(x: 0, y: CGFloat(originPosY*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    arm.run(moveArm)
                }
                for fist in armAndFist.fist {
                    let moveFist = SKAction.moveBy(x: 0, y: CGFloat(originPosY*gridNode.cellHeight), duration:
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
                self.makeTriangle()
                self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
            })
            
            /* Move next enemy's turn */
            let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
            let moveNextEnemy = SKAction.run({
                self.myTurnFlag = false
                if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                    gridNode.turnIndex += 1
                    gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
                }
                
                /* Reset enemy animation */
                self.setMovingAnimation()
                
                /* To check all enemy turn done */
                gridNode.numOfTurnEndEnemy += 1
                
                /* Reset count down punchInterval */
                self.punchIntervalForCount = self.punchInterval
                
                /* Set enemy position to edge */
                self.positionY = 0
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, decreseLife, subSetArm, waitForSubSet, removeArm, moveForward, shrinkArm, drawWait, punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
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
                let moveBody = SKAction.moveBy(x: 0, y: -CGFloat(self.valueOfEnemy*gridNode.cellHeight), duration: TimeInterval(self.punchLength*self.punchSpeed))
                self.run(moveBody)
                for arm in self.armArrayForSubSet {
                    let moveArm = SKAction.moveBy(x: 0, y: CGFloat(self.valueOfEnemy*gridNode.cellHeight), duration:
                        TimeInterval(self.punchLength*self.punchSpeed))
                    arm.run(moveArm)
                }
                for fist in armAndFist.fist {
                    let moveFist = SKAction.moveBy(x: 0, y: CGFloat(self.valueOfEnemy*gridNode.cellHeight), duration:
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
                self.makeTriangle()
                self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
            })
            
            /* Move next enemy's turn */
            let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
            let moveNextEnemy = SKAction.run({
                self.myTurnFlag = false
                if gridNode.turnIndex < gridNode.enemyArray.count-1 {
                    gridNode.turnIndex += 1
                    gridNode.enemyArray[gridNode.turnIndex].myTurnFlag = true
                }
                
                /* Reset enemy animation */
                self.setMovingAnimation()
                
                /* To check all enemy turn done */
                gridNode.numOfTurnEndEnemy += 1
                
                /* Display left trun till punch */
                self.setPunchIntervalLabel()
            })
            
            /* excute drawPunch */
            let seq = SKAction.sequence([wait, subSetArm, waitForSubSet, removeArm, moveForward, shrinkArm, drawWait, punchDone, setVariableExpression, moveTurnWait, moveNextEnemy])
            self.run(seq)
        }
        
    }

    
    /* Do punch */
    func punch() -> (arm: [EnemyArm], fist: [EnemyFist]) {
        
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
        let decreseLife = SKAction.run({ gameScene.life -= 1 })
        
        /* Set punchLength */
        self.punchLength = 80
        
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
            self.makeTriangle()
            self.setVariableExpressionLabel(text: self.variableExpressionForLabel)
        })
        
        /* Move next enemy's turn */
        let moveTurnWait = SKAction.wait(forDuration: self.singleTurnDuration)
        let moveNextEnemy = SKAction.run({
            self.myTurnFlag = false
            
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
    
    /* Set invisible node to destroy enemy */
    func setHitPoint(length: CGFloat) {

        switch self.direction {
        case .front:
            /* Set body size */
            let bodySize = CGSize(width: 55, height: 40)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: 0, y: -actLength)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .back:
            /* Set body size */
            let bodySize = CGSize(width: 55, height: 40)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: 0, y: actLength)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .left:
            /* Set body size */
            let bodySize = CGSize(width: 50, height: 45)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: -actLength, y: 0)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        case .right:
            /* Set body size */
            let bodySize = CGSize(width: 50, height: 45)
            
            /* Set invisible hit point */
            circle = SKShapeNode(rectOf: bodySize)
            
            /* Set position */
            let actLength = length + 15 /* 10 is adjustment */
            circle.position = CGPoint(x: actLength, y: 0)
            
            /* Make hit point invisible */
            circle.fillColor = SKColor.red
            circle.alpha = CGFloat(0.1)
            circle.zPosition = 5
            
            /* Set physics property */
            circle.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            circle.physicsBody?.categoryBitMask = 64
            circle.physicsBody?.collisionBitMask = 0
            circle.physicsBody?.contactTestBitMask = 33
            self.addChild(circle)
            
        }
    }
}
