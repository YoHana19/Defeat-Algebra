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
    
    /* For swiping */
    var beganPos:CGPoint!
    
    /* Enemy array */
    var enemyArray = [Enemy]()
    var positionEnemyAtGrid = [[Bool]]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var moveEnemyTurnTime: TimeInterval = 1.0
    var startPosArray = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    
    /* Flash speed */
    var flashSpeed: Double = 1.0
    
    /* Move & Attack & item setting area for player */
    var squareArray = [[SKShapeNode]]()
    
    /* Attack area position */
    var attackAreaPos = [[Int]]()
    
    /* Mine */
    var mineArray = [[Int]]()
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / (columns)
        cellHeight = Int(size.height) / (rows)
        
        /* Set enemy position origin array */
        /* Loop through columns */
        for gridX in 0..<columns {
            
            /* Initialize empty column */
            positionEnemyAtGrid.append([])
            
            /* Loop through rows */
            for _ in 0..<rows {
                
                /* Set false at row / column position */
                positionEnemyAtGrid[gridX].append(false)
            }
        }
        
        /* For display player move area */
        coverGrid()

    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        /* Select direction to move or attack */
        if gameScene.playerTurnState == .SelectDirection {
        
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
        
            /* Hero move */
            if gameScene.hero.heroState == .Move {
                if nodeAtPoint.name == "activeArea" {
                
                    /* Caclulate grid array position */
                    let gridX = Int(location.x) / cellWidth
                    let gridY = Int(location.y) / cellHeight
                
                    /* Hero move */
                    if gameScene.hero.heroState == .Move {
                    
                        /* Move hero to touch location */
                        gameScene.hero.heroMoveToDest(posX: gridX, posY: gridY)
                    
                        /* Reset move area */
                        self.resetSquareArray()
                    
                        /* Keep track hero position */
                        gameScene.hero.positionX = gridX
                        gameScene.hero.positionY = gridY
                    
                    /* Hero attack */
                    } else if gameScene.hero.heroState == .Attack {
                    
                    }
                
                    /* Move next state */
                    gameScene.selectDirectionDone = true
                    let wait = SKAction.wait(forDuration: 2.5)
                    let moveState = SKAction.run({ gameScene.playerTurnState = .TurnEnd })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                
                }
            /* Hero attack */
            } else if gameScene.hero.heroState == .Attack {
                beganPos = touch.location(in: self)
            }
        /* Use item */
        } else if gameScene.playerTurnState == .UsingItem {
            /* Use mine */
            if gameScene.itemType == .Mine {
                let touch = touches.first!              // Get the first touch
                let location = touch.location(in: self) // Find the location of that touch in this view
                let nodeAtPoint = atPoint(location)     // Find the node at that location
                if nodeAtPoint.name == "activeArea" {
                    /* Caclulate grid array position */
                    let gridX = Int(location.x) / cellWidth
                    let gridY = Int(location.y) / cellHeight
                    
                    /* Remove active areas */
                    self.resetSquareArray()
                    
                    /* Store position of set mine */
                    self.mineArray.append([gridX, gridY])
//                    print(self.mineArray)
 
                    /* Set mine at the location you touch */
                    let mine = Mine()
                    self.addObjectAtGrid(object: mine, x: gridX, y: gridY)
                    
                    /* Move state */
                    gameScene.playerTurnState = .SelectAction
                    
                    /* Remove itemIcon from item array and Scene */
                    gameScene.itemArray[0].removeFromParent()
                    gameScene.itemArray.remove(at: 0)
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        /* Swipe is available only at the time of selectDirection */
        guard gameScene.playerTurnState == .SelectDirection else { return }
        
        /* Swipe is available only when heroState is Attack */
        guard gameScene.hero.heroState == .Attack else { return }
        
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        
        /* Show attack area */
        showAttackAreaBySwipe(diffPos)
    }
    
    func resetStartPosArray() {
        for i in 0..<columns {
            self.startPosArray.append(i)
        }
    }
    
    func addEnemyAtGrid(_ numberOfEnemy: Int, variableExpressionSource: [[Int]]) {
        /* Add a new enemy at grid position*/
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = Enemy(variableExpressionSource: variableExpressionSource)
        
            /* Attach variable expression */
            enemy.makeTriangle()
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            
            /* Set direction of enemy */
            enemy.direction = .front
            enemy.setMovingAnimation()
        
            /* Set position on screen */
            /* Enemy come to grid from out of it */
            let rand = Int(arc4random_uniform(UInt32(startPosArray.count)))
            let startPosition = startPosArray[rand]
            /* Make sure not to overlap enemies */
            startPosArray.remove(at: rand)
            
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
        let numOfFlash = Int(arc4random_uniform(3))+1
        
        /* Set flash animation */
        let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
        let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
        let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
        let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
        let flash = SKAction.repeat(seqFlash, count: numOfFlash)
        self.run(flash)
        
        /* Display the number of flash */
        let wholeWait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed*Double(numOfFlash)))
        let display = SKAction.run({ labelNode.text = String(numOfFlash) })
        let seq = SKAction.sequence([wholeWait, display])
        self.run(seq)
        
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
    
    /* Add a new object at grid position*/
    func addObjectAtGrid(object: SKSpriteNode, x: Int, y: Int) {
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: x*cellWidth+cellWidth/2, y: y*cellHeight+cellHeight/2)
        object.position = gridPosition
    
        /* Add mine to grid node */
        addChild(object)
    }
    
    /* Reset enemy position array */
    func resetEnemyPositon() {
        for x in 0..<columns {
            /* Loop through rows */
            for y in 0..<rows {
                positionEnemyAtGrid[x][y] = false
            }
        }
    }
        
    /* Update enemy position at grid */
    func updateEnemyPositon() {
        for enemy in self.enemyArray {
            self.positionEnemyAtGrid[enemy.positionX][enemy.positionY] = true
        }
    }
    
    /* Show area where player can move */
    func showMoveArea(posX: Int, posY: Int, moveLevel: Int) {
        /* Show up red square according to move level */
        switch moveLevel {
        case 1:
            for gridX in posX-1...posX+1 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    /* Remove hero position */
                    if gridX != posX {
                        squareArray[gridX][posY].isHidden = false
                    }
                }
            }
            for gridY in posY-1...posY+1 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.columns-1 {
                    /* Remove hero position */
                    if gridY != posY {
                        squareArray[posX][gridY].isHidden = false
                    }
                }
            }
        case 2:
            for gridX in posX-2...posX+2 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    /* Remove hero position */
                    if gridX != posX {
                        squareArray[gridX][posY].isHidden = false
                    }
                }
            }
            for gridY in posY-2...posY+2 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.columns-1 {
                    /* Remove hero position */
                    if gridY != posY {
                        squareArray[posX][gridY].isHidden = false
                    }
                }
            }
            for gridX in posX-1...posX+1 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    for gridY in posY-1...posY+1 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= self.rows-1 {
                            /* Remove hero position */
                            if gridX != posX && gridY != posY {
                                squareArray[gridX][gridY].isHidden = false
                            }
                        }
                    }
                }
            }
        default:
            break;
        }
    }
    
    /* Show attack area */
    func showAttackArea() {
        /* Reset squareArray */
        self.resetSquareArray()
        
        /* Reset attackAreaPos */
        self.attackAreaPos.removeAll()
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        switch gameScene.hero.direction {
        case .front:
            if gameScene.hero.positionY-1 >= 0 {
                self.squareArray[gameScene.hero.positionX][gameScene.hero.positionY-1].isHidden = false
                self.attackAreaPos.append([gameScene.hero.positionX, gameScene.hero.positionY-1])
            }
            
        case .back:
            if gameScene.hero.positionY+1 <= self.rows-1 {
                self.squareArray[gameScene.hero.positionX][gameScene.hero.positionY+1].isHidden = false
                self.attackAreaPos.append([gameScene.hero.positionX, gameScene.hero.positionY+1])
            }
        case .left:
            if gameScene.hero.positionX-1 >= 0 {
                self.squareArray[gameScene.hero.positionX-1][gameScene.hero.positionY].isHidden = false
                self.attackAreaPos.append([gameScene.hero.positionX-1, gameScene.hero.positionY])
            }
        case .right:
            if gameScene.hero.positionX+1 <= self.columns-1 {
                self.squareArray[gameScene.hero.positionX+1][gameScene.hero.positionY].isHidden = false
                self.attackAreaPos.append([gameScene.hero.positionX+1, gameScene.hero.positionY])
            }
        }
    }
    
    /* Show mine setting area */
    func showMineSettingArea() {
        for gridX in 0..<self.columns {
            for gridY in 1..<self.rows-1 {
                self.squareArray[gridX][gridY].isHidden = false
            }
        }
    }
    
    func showAttackAreaBySwipe(_ diffPos: CGPoint) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        var degree:Int
        
        if diffPos.x != 0 {
            /* horizontal move */
            let radian = atan(diffPos.y/fabs(diffPos.x)) // calculate radian by arctan
            degree = Int(radian * CGFloat(180 * M_1_PI)) // convert radian to degree
        } else {
            /* just touch */
            if diffPos.y == 0 {
                degree = 1000
            } else {
                /* vertical move */
                degree = diffPos.y < 0 ? -90:90;
            }
        }
        
        switch degree {
        case -90 ..< -45:
            gameScene.hero.direction = .front
            gameScene.hero.setTexture()
            showAttackArea()
        case -45 ..< 45:
            if diffPos.x >= 0 {
                gameScene.hero.direction = .right
                gameScene.hero.setTexture()
                showAttackArea()
            } else {
                gameScene.hero.direction = .left
                gameScene.hero.setTexture()
                showAttackArea()
            }
        case 45 ... 90:
            gameScene.hero.direction = .back
            gameScene.hero.setTexture()
            showAttackArea()
        default:
            break;
        }
        
    }
    
    /* Reset squareArray */
    func resetSquareArray() {
        for x in 0..<columns {
            /* Loop through rows */
            for y in 0..<rows {
                squareArray[x][y].isHidden = true
            }
        }
    }
    
    func coverGrid() {
        /* Populate the grid with creatures */
        
        /* Loop through columns */
        for gridX in 0..<columns {
            
            /* Initialize empty column */
            squareArray.append([])
            
            /* Loop through rows */
            for gridY in 0..<rows {
                
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY)
            }
        }
    }
    
    func addSquareAtGrid(x: Int, y: Int) {
        /* Add a new creature at grid position*/
        
        /* Create square */
        let square = SKShapeNode(rectOf: CGSize(width: self.cellWidth, height: cellHeight))
        square.fillColor = UIColor.red
        square.alpha = 0.5
        square.zPosition = 100
        square.name = "activeArea"
        
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: x*cellWidth+cellWidth/2, y: y*cellHeight+cellHeight/2)
        square.position = gridPosition
        
        /* Set default isAlive */
        square.isHidden = true
        
        /* Add creature to grid node */
        addChild(square)
        
        /* Add creature to grid array */
        squareArray[x].append(square)
    }

    
}

