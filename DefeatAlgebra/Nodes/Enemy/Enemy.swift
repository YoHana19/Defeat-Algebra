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
    case Move, Attack
}

class Enemy: SKSpriteNode {
    
    /* Enemy state management */
    var state: EnemyState = .Move
    var circle = SKShapeNode(circleOfRadius: 20.0)
    
    /* Enemy position */
    var positionX = 0
    var positionY = 0
    
    /* Enemy property */
    var moveSpeed = 0.1
    var punchSpeed: CGFloat = 0.002
    var direction: Direction = .front
    var punchInterval: Int!
    var punchIntervalLabel = SKLabelNode(fontNamed: "GillSans-Bold")
    var punchIntervalForCount: Int = 0 {
        didSet {
            if punchIntervalForCount == 0 {
                state = .Attack
            } else {
                state = .Move
            }
            punchIntervalLabel.fontColor = UIColor.white
            variableExpressionLabel.fontColor = UIColor.white
            punchIntervalLabel.text = String(punchIntervalForCount)
        }
    }
    var singleTurnDuration: TimeInterval = 0.2
    var vECategory = 0
    
    /* Enemy variable for punch */
    var valueOfEnemy: Int = 0
    var firstPunchLength: CGFloat = 78
    var singlePunchLength: CGFloat = 78
    var punchLength: CGFloat! = 0
    var variableExpressionLabel = SKLabelNode(fontNamed: "GillSans-Bold")
    var variableExpressionString = "" {
        didSet {
            variableExpressionLabel.text = variableExpressionString
            //adjustLabelSize()
        }
    }
    var originVariableExpression = "" {
        didSet {
            VECategory.getCategory(ve: variableExpressionString) { cate in
                self.vECategory = cate
            }
        }
    }
    
    /* Flags */
    var myTurnFlag = false
    var turnDoneFlag = false
    var reachCastleFlag = false
    var wallHitFlag = false
    var aliveFlag = true
    var editedVEFlag = false
    var forEduOriginFlag = false
    var forEduBranchFlag = false
    var isSelectedForEqRob = false
    
    var gridNode: Grid {
        return self.parent as! Grid
    }
    
    var gameScene: GameScene {
        return gridNode.parent as! GameScene
    }
    
    init(variableExpressionSource: [String], forEdu: Bool) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front1")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Set name */
        setName()
        
        /* Initialize Labels */
        initializePunchIntervalLabel()
        initailizeVariableExpressionLabel()
        
        if GameScene.stageLevel < 2 {
            punchIntervalLabel.isHidden = true
        }
        
        /* Set punch interval */
        if forEdu == false {
            setPunchInterval()
        }
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 4
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /* Set physics property */
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        /* Set variable expression */
        EnemyVEController.setVariableExpression(enemy: self, vESource: variableExpressionSource)
        
        /* Set enemy speed according to stage level */
        if GameScene.stageLevel < 1 {
            self.moveSpeed = 0.2
            self.punchSpeed = 0.0025
            self.singleTurnDuration = 1.0
        }
        
        if GameScene.stageLevel > 1 {
            variableExpressionLabel.fontSize = 24.5
        }
    }
    
    init(ve: String) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "front1")
        let enemySize = CGSize(width: 61, height: 61)
        super.init(texture: texture, color: UIColor.clear, size: enemySize)
        
        /* Set name */
        setName()
        
        /* Set variable expression */
        self.variableExpressionString = ve
        
        /* Initialize Labels */
        initializePunchIntervalLabel()
        initailizeVariableExpressionLabel()
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 4
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /* Set physics property */
        physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        
        self.variableExpressionLabel.isHidden = true
        self.punchIntervalLabel.isHidden = true
        
        /* Set enemy speed according to stage level */
        if GameScene.stageLevel < 1 {
            self.moveSpeed = 0.2
            self.punchSpeed = 0.0025
            self.singleTurnDuration = 1.0
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
            //self.texture = SKTexture(imageNamed: "back1")
            break;
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
    
    /* Set pointing icon */
    func pointing() {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.name = "pointing"
        icon.size = CGSize(width: 50, height: 50)
        icon.position = CGPoint(x: 60, y: 60)
        icon.zPosition = 4
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        addChild(icon)
    }
    
    func removePointing() {
        if let icon = childNode(withName: "pointing") {
            icon.removeFromParent()
        }
    }
    
    /*==================*/
    /*== Set property ==*/
    /*==================*/
    
    /* Set name */
    func setName() {
        self.name = "enemy"
    }
    
    func initializePunchIntervalLabel() {
        /* name */
        punchIntervalLabel.name = "punchInterval"
        /* text */
        punchIntervalLabel.text = String(self.punchIntervalForCount)
        /* font size */
        punchIntervalLabel.fontSize = 30
        /* zPosition */
        punchIntervalLabel.zPosition = 5
        /* position */
        punchIntervalLabel.position = CGPoint(x:0, y: -40)
        /* Add to Scene */
        self.addChild(punchIntervalLabel)
    }
    
    func initailizeVariableExpressionLabel() {
        /* text */
        variableExpressionLabel.text = variableExpressionString
        /* name */
        variableExpressionLabel.name = "variableExpressionLabel"
        /* font size */
        variableExpressionLabel.fontSize = 35
        /* zPosition */
        variableExpressionLabel.zPosition = 5
        /* position */
        variableExpressionLabel.position = CGPoint(x:0, y: 35)
        /* Add to Scene */
        self.addChild(variableExpressionLabel)
        
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
    
    func adjustLabelSize() {
        guard let grid = self.parent as? Grid else { return }
        let cellWidth = CGFloat(grid.cellWidth)
        if variableExpressionLabel.frame.width > cellWidth {
            let scaleFactor = cellWidth / variableExpressionLabel.frame.width
            variableExpressionLabel.fontSize *= scaleFactor
            print(variableExpressionLabel.fontSize)
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
    
    /* Set punch interval randomly */
    func setPunchInterval() {
        let rand = Int(arc4random_uniform(100))
        
        /* punchInterval is 1 with 40% */
        if rand < 45 {
            punchInterval = 1
            punchIntervalForCount = punchInterval
            
            /* punchInterval is 2 with 40% */
        } else if rand < 90 {
            punchInterval = 2
            punchIntervalForCount = punchInterval
            
            /* punchInterval is 0 with 20% */
        } else {
            punchInterval = 0
            punchIntervalForCount = punchInterval
            
        }
    }
    
    public func forcusForAttack(color: UIColor) {
        punchIntervalLabel.fontColor = color
        variableExpressionLabel.fontColor = color
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
            
            /* To check all enemy turn done */
            gridNode.numOfTurnEndEnemy += 1
            
            /* Count down till do punch */
            self.punchIntervalForCount -= 1
            
        })
        
        /* excute drawPunch */
        let seq = SKAction.sequence([moveTurnWait, moveNextEnemy])
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
