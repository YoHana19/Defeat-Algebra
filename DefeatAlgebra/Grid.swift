//
//  Grid.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    
    /* Grid array dimensions */
    let rows = 10
    let columns = 10
    
    /* Individual cell dimension, auto-calculated */
    var cellWidth = 0
    var cellHeight = 0
    
    /* Enemy array */
    var enemyArray = [Enemy]()
    
    /* Flash speed */
    var flashSpeed: Double = 1.0
    
    /* Mine */
    var numOfMineLabel: SKLabelNode!
    var numOfMineOnGrid = 0
    var numOfMine = 0 {
        didSet {
            numOfMineLabel.text = String(numOfMine)
        }
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Display number of mine you have */
        numOfMineLabel = childNode(withName: "numOfMineLabel") as! SKLabelNode
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / (columns+2)
        cellHeight = Int(size.height) / (rows+2)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Make sure you can set mine only when gameState is gridFlash */
        let gameScene = self.parent as! GameScene
        guard gameScene.gameState == .GridFlashing || gameScene.gameState == .GameStart else { return }
        
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in the grid
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "mine" {
            nodeAtPoint.removeFromParent()
            /* Increase available mine */
            numOfMine += 1
            
            /* Count mine on grid */
            numOfMineOnGrid -= 1
        } else {
            /* Make sure you can add only mine you have */
            if numOfMine > 0 {
                /* Make sure touch is inside grid */
                if location.x < CGFloat(cellWidth) || location.x > 11*CGFloat(cellWidth) || location.y < CGFloat(cellHeight) || location.y > 11*CGFloat(cellHeight) {
                    return
                } else {
                    /* For tutorial */
                    if gameScene.t5SetMine == false {
                        gameScene.t5SetMine = true
                    }
                    
                    /* Caclulate grid array position */
                    let gridX = (Int(location.x)-cellWidth) / cellWidth
                    let gridY = (Int(location.y)-cellHeight) / cellHeight
                    
                    /* Add mine at grid */
                    addMineAtGrid(x: gridX, y: gridY)
                    
                    /* Reuduce available mine */
                    numOfMine -= 1
                    
                    /* Count mine on grid */
                    numOfMineOnGrid += 1
                }
            }
        }
    }

    
    func addEnemyAtGrid(_ numberOfEnemy: Int) {
        /* Add a new enemy at grid position*/
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = Enemy()
        
            /* Attach variable expression */
            enemy.makeTriangle()
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            
            
            /* Set direction of enemy randomly*/
            let directionIndex = Int(arc4random_uniform(4))+1
            enemy.direction = Direction(rawValue: directionIndex)!
            enemy.setMovingAnimation()
        
            /* Set position on screen */
            /* Enemy come into grid from out of it */
            let startPosition = Int(arc4random_uniform(10))+1
            
            /* Set enemy's move distance when showing up randomly */
            let rand = Int(arc4random_uniform(4))+2
            let startMoveDistanceHeight = CGFloat(rand*self.cellHeight+self.cellHeight/2)
            let startMoveDistanceWidth = CGFloat(rand*self.cellWidth+self.cellWidth/2)
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(Double(rand)*enemy.moveSpeed+enemy.moveSpeed/2)
            
            switch Int(directionIndex) {
            /* From top */
            case 1:
                let gridPosition = CGPoint(x: startPosition*cellWidth+cellWidth/2, y: Int(size.height))
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: 0, y: -startMoveDistanceHeight, duration: startDulation)
                enemy.run(move)
                break;
            /* From bottom */
            case 2:
                let gridPosition = CGPoint(x: startPosition*cellWidth+cellWidth/2, y: 0)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: 0, y: startMoveDistanceHeight, duration: startDulation)
                enemy.run(move)
                break;
            /* From right */
            case 3:
                let gridPosition = CGPoint(x: Int(size.width), y: startPosition*cellHeight+cellHeight/2)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: -startMoveDistanceWidth, y: 0, duration: startDulation)
                enemy.run(move)
                break;
            /* From left */
            case 4:
                let gridPosition = CGPoint(x: 0, y: startPosition*cellHeight+cellHeight/2)
                enemy.position = gridPosition
                
                /* Move enemy for startMoveDistance */
                let move = SKAction.moveBy(x: startMoveDistanceWidth, y: 0, duration: startDulation)
                enemy.run(move)
                break;
            default:
                break;
            }
        
            /* Add enemy to grid node */
            addChild(enemy)
        
            /* Add enemy to enemyArray */
            self.enemyArray.append(enemy)
        }
    }
    
    func propagateEnemy(enemyArray: [Enemy], numberOfEnemy: Int) {
        /* Propagate a new enemy form each enemy position*/
        
        for enemyOrigin in enemyArray {
            for _ in 1...numberOfEnemy {
                /* New enemy object */
                let enemy = Enemy()
                
                /* Attach variable expression */
                enemy.makeTriangle()
                enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
                
                
                /* Set direction of enemy randomly*/
                let directionIndex = Int(arc4random_uniform(4))+1
                enemy.direction = Direction(rawValue: directionIndex)!
                enemy.setMovingAnimation()
                
                /* Set position on screen */
                enemy.position = enemyOrigin.position
                
                /* Move one cell */
                switch directionIndex {
                /* Front */
                case 1:
                    /* Move enemy one cel */
                    let move = SKAction.moveBy(x: 0, y: -(CGFloat)(self.cellHeight), duration: 1.5)
                    enemy.run(move)
                    break;
                /* Back */
                case 2:
                    let move = SKAction.moveBy(x: 0, y: CGFloat(self.cellHeight), duration: 1.5)
                    enemy.run(move)
                    break;
                /* Left */
                case 3:
                    let move = SKAction.moveBy(x: -(CGFloat)(self.cellWidth), y: 0, duration: 1.5)
                    enemy.run(move)
                    break;
                /* Right */
                case 4:
                    let move = SKAction.moveBy(x: CGFloat(self.cellWidth), y: 0, duration: 1.5)
                    enemy.run(move)
                    break;
                default:
                    break;
                }
                
                /* Set physics */
                enemy.setEnemyCollisionToWall()
                
                /* Add enemy to grid node */
                addChild(enemy)
                
                /* Add enemy to enemyArray */
                self.enemyArray.append(enemy)
            }
        }
    }
    
    func flashGrid(labelNode: SKLabelNode) -> Int {
        /* Set the number of times of flash randomly */
        let numOfFlash = Int(arc4random_uniform(4))+1
        var numOfFlashForDisplay = 0
        
        /* Set flash animation */
        let fadeInColorlize = SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
        let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
        let fadeOutColorlize = SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
        let displayTimesOfFlash = SKAction.run({
            numOfFlashForDisplay += 1
            labelNode.text = String(numOfFlashForDisplay)
            labelNode.position = CGPoint(x: 111, y: labelNode.position.y)
        })
        let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, displayTimesOfFlash, wait])
        let flash = SKAction.repeat(seqFlash, count: numOfFlash)
        self.run(flash)
        
        return numOfFlash
    }
    
    func addGameConsole(_ total: Int) {
        
        for _ in 1...total {
            /* Create game console object */
            let gameConsole = GameConsole()
            
            /* Set position at grid randomly */
            let posX = Int(arc4random_uniform(10)+1)
            let posY = Int(arc4random_uniform(10)+1)
            let position = CGPoint(x: CGFloat(posX*self.cellWidth+self.cellWidth/2), y: CGFloat(posY*self.cellHeight+self.cellHeight/2))
            gameConsole.position = position
            
            /* Add gameConsole as child */
            self.addChild(gameConsole)
        }
    }
    
    /* add mine to get at grid */
    func addMineToGet(_ total: Int) {
        
        for _ in 1...total {
            /* Create game console object */
            let mine = MineToGet()
            
            /* Set position at grid randomly */
            let posX = Int(arc4random_uniform(10)+1)
            let posY = Int(arc4random_uniform(10)+1)
            let position = CGPoint(x: CGFloat(posX*self.cellWidth+self.cellWidth/2), y: CGFloat(posY*self.cellHeight+self.cellHeight/2))
            mine.position = position
            
            /* Add gameConsole as child */
            self.addChild(mine)
        }
    }
    
    /* Add a new mine at grid position*/
    func addMineAtGrid(x: Int, y: Int) {
        
        /* New creature object */
        let mine = Mine()
        
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: (x+1)*cellWidth+cellWidth/2, y: (y+1)*cellHeight+cellHeight/2)
        mine.position = gridPosition
    
        /* Add mine to grid node */
        addChild(mine)
        
    }
}

