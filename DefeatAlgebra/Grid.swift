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
    let rows = 12
    let columns = 9
    
    /* Individual cell dimension, auto-calculated */
    var cellWidth = 0
    var cellHeight = 0
    
    /* Enemy array */
    var enemyArray = [Enemy]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var moveEnemyTurnTime: TimeInterval = 1.0
    
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
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / (columns)
        cellHeight = Int(size.height) / (rows)

    }
    
    func addEnemyAtGrid(_ numberOfEnemy: Int) {
        /* Add a new enemy at grid position*/
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = Enemy()
        
            /* Attach variable expression */
            enemy.makeTriangle()
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            
            
            /* Set direction of enemy */
            enemy.direction = .front
            enemy.setMovingAnimation()
        
            /* Set position on screen */
            /* Enemy come to grid from out of it */
            let startPosition = Int(arc4random_uniform(9))
            let gameScene = self.parent as! GameScene2
            
            /* Keep track enemy position */
            enemy.positionX = startPosition
            
            /* Calculate gap between top of grid and gameScene */
            let gridPosition = CGPoint(x: (startPosition)*cellWidth+cellWidth/2, y: Int(gameScene.topGap+self.size.height))
            enemy.position = gridPosition
            
            /* Set enemy's move distance when showing up */
            let startMoveDistance = CGFloat(Int(gameScene.topGap)+self.cellHeight/2)
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(1.5*enemy.moveSpeed)
                
            /* Move enemy for startMoveDistance */
            let move = SKAction.moveBy(x: 0, y: -startMoveDistance, duration: startDulation)
            enemy.run(move)
        
            /* Add enemy to grid node */
            addChild(enemy)
        
            /* Add enemy to enemyArray */
            self.enemyArray.append(enemy)
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

