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
    
    /* Tutorial */
    var isTutorial: Bool = false
    
    /* Grid array dimensions */
    let rows = 12
    let columns = 9
    
    /* Individual cell dimension, auto-calculated */
    var cellWidth: Double = 0.0
    var cellHeight: Double = 0.0
    
    /* Enemy move speed when adding */
    var addingMoveSpeed = 0.5
    
    /* Hero move */
    var beganPos = [Int]()
    var currentPos = [Int]()
    var directionJudgeDoneFlag = false
    
    /* Enemy Management */
    var enemyArray = [Enemy]()
    var enemySUPairDict = [Enemy: Enemy]()
    var positionEnemyAtGrid = [[Bool]]()
    var currentPositionOfEnemies = [[Int]]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var startPosArray = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var touchingEnemyFlag = false
    var touchedEnemy = Enemy(variableExpressionSource: [[0,1,0,0]], forEdu: false) /* temporally */
    var editedEnemy  = Enemy(variableExpressionSource: [[0,1,0,0]], forEdu: false) /* temporally */
    
    /* Move & Attack & item setting area for player */
    var squareRedArray = [[SKShapeNode]]() /* for attack */
    var squareBlueArray = [[SKShapeNode]]() /* for move */
    var squarePurpleArray = [[SKShapeNode]]() /* for item */
    
    /*== Items ==*/
    /* timeBomb */
    var timeBombSetPosArray = [[Int]]()
    var timeBombSetArray = [TimeBomb]()
    /* Wall */
    var wallSetArray = [Wall]()
    /* Magic sword */
    var vEindex = -1
    var castEnemyDone = false
    /* Battle ship */
    var battleShipSetArray = [BattleShip]()
    
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Calculate individual cell dimensions */
        cellWidth = Double(size.width)/Double(columns)
        cellHeight = Double(size.height)/Double(rows)
        
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
        
        /* Create enemy startPosArray */
        EnemyMoveController.resetEnemyPositon(grid: self)
        
        /* For display active area for player action */
        GridActiveAreaController.coverGrid(grid: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTutorial {
            return
        } else {
            /* Get gameScene */
            let gameScene = self.parent as! GameScene
            
            guard gameScene.pauseFlag == false else { return }
            guard gameScene.boardActiveFlag == false else { return }
            guard gameScene.gameState == .PlayerTurn else { return }
            
            /* Get touch point */
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            
            /* Touch point to move to */
            if gameScene.playerTurnState == .MoveState {
                
                /* Touch red square for active area */
                if nodeAtPoint.name == "activeArea" {
                    
                    /* Reset all */
                    beganPos = []
                    currentPos = []
                    
                    /* Caclulate grid array position */
                    let gridX = Int(Double(location.x) / cellWidth)
                    let gridY = Int(Double(location.y) / cellHeight)
                    
                    
                    /* Touch hero's position */
                    if gridX == gameScene.hero.positionX && gridY == gameScene.hero.positionY {
                        /* Display move path */
                        GridActiveAreaController.brightCellAsPath(gridX: gridX, gridY: gridY, grid: self)
                        /* Set touch began position */
                        beganPos = [gridX, gridY]
                        currentPos = beganPos
                    }
                }
            }
            
            /*
             /* Touch enemy to check variable expression */
             if touchingEnemyFlag == false {
             if nodeAtPoint.name == "enemy" {
             /* Make sure to be invalid when using magicSword */
             guard gameScene.magicSwordAttackDone == false else { return }
             
             touchingEnemyFlag = true
             touchedEnemy = nodeAtPoint as! Enemy
             touchedEnemy.position = location
             touchedEnemy.physicsBody = nil
             }
             }
             */
            
            /* Touch enemy to edit variable expression */
            if !gameScene.usingMagicSword {
                if nodeAtPoint.name == "enemy" {
                    /* Get enemy to edit */
                    editedEnemy = nodeAtPoint as! Enemy
                    
                    /* Set enemy's original variable expression */
                    gameScene.simplificationBoard.originLabel.text = editedEnemy.originVariableExpression
                    
                    /* Make simplification board visible */
                    gameScene.simplificationBoard.isActive = true
                    
                    gameScene.boardActiveFlag = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTutorial {
            return
        } else {
            /* Get gameScene */
            let gameScene = self.parent as! GameScene
            
            guard gameScene.pauseFlag == false else { return }
            guard gameScene.gameState == .PlayerTurn else { return }
            
            /* Get touch point */
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            
            /* Touch ends on active area */
            if nodeAtPoint.name == "activeArea" {
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                if beganPos.count > 0 {
                    if beganPos[0] == gameScene.hero.positionX && beganPos[1] == gameScene.hero.positionY {
                        
                        let nextPos = [gridX, gridY]
                        
                        /* Touching position moves to next cell */
                        if nextPos != currentPos {
                            
                            /* Make sure direction judge is excute at first move */
                            if directionJudgeDoneFlag == false {
                                directionJudgeDoneFlag = true
                                
                                /* Finger move horizontally */
                                if nextPos[0] != beganPos[0] {
                                    gameScene.hero.moveDirection = .Horizontal
                                    GridActiveAreaController.dispMovePath(start: beganPos, dest: nextPos, grid: self)
                                    currentPos = nextPos
                                    /* Finger move vertically */
                                } else if nextPos[1] != beganPos[1] {
                                    gameScene.hero.moveDirection = .Vertical
                                    GridActiveAreaController.dispMovePath(start: beganPos, dest: nextPos, grid: self)
                                    currentPos = nextPos
                                }
                            } else {
                                GridActiveAreaController.dispMovePath(start: beganPos, dest: nextPos, grid: self)
                                currentPos = nextPos
                            }
                            /* In case backing to began position */
                        } else if nextPos == beganPos {
                            currentPos = nextPos
                            GridActiveAreaController.brightCellAsPath(gridX: beganPos[0], gridY: beganPos[1], grid: self)
                            
                            directionJudgeDoneFlag = false
                        }
                    }
                }
                
                if touchingEnemyFlag {
                    EnemyMoveController.rePosEnemy(enemy: touchedEnemy, grid: self)
                    touchingEnemyFlag = false
                }
                
                /*
                 } else if nodeAtPoint.name == "enemy" {
                 if touchingEnemyFlag {
                 touchedEnemy.position = location
                 }
                 */
            } else {
                directionJudgeDoneFlag = false
                GridActiveAreaController.resetMovePath(grid: self)
                if touchingEnemyFlag {
                    EnemyMoveController.rePosEnemy(enemy: touchedEnemy, grid: self)
                    touchingEnemyFlag = false
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTutorial {
            return
        } else {
            /* Get gameScene */
            let gameScene = self.parent as! GameScene
            
            guard gameScene.pauseFlag == false else { return }
            guard gameScene.gameState == .PlayerTurn else { return }
            
            /*
             /* Reset enemy position after checking variable expression */
             if touchingEnemyFlag {
             rePosEnemy(enemy: touchedEnemy)
             touchingEnemyFlag = false
             }
             */
            
            /* Get touch point */
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            
            /* Touch point to move to */
            if gameScene.playerTurnState == .MoveState {
                
                /* Touch ends on active area */
                if nodeAtPoint.name == "activeArea" {
                    /* Reset move area */
                    GridActiveAreaController.resetSquareArray(color: "blue", grid: self)
                    
                    /* Stop showing move pass */
                    GridActiveAreaController.resetMovePath(grid: self)
                    
                    /* Caclulate grid array position */
                    let gridX = Int(Double(location.x) / cellWidth)
                    let gridY = Int(Double(location.y) / cellHeight)
                    
                    /* Reset hero move direction flag */
                    directionJudgeDoneFlag = false
                    
                    /* On hero moving flag */
                    gameScene.heroMovingFlag = true
                    
                    /* On moveDoneFlad */
                    gameScene.hero.moveDoneFlag = true
                    
                    /* Move hero to touch location */
                    gameScene.hero.heroMoveToDest(posX: gridX, posY: gridY)
                    
                    /* Keep track hero position */
                    gameScene.hero.positionX = gridX
                    gameScene.hero.positionY = gridY
                    
                    /* Move next state */
                    let wait = SKAction.wait(forDuration: gameScene.turnEndWait)
                    let nextHero = SKAction.run({
                        /* Reset hero animation to back */
                        gameScene.hero.resetHero()
                        
                        gameScene.heroMovingFlag = false
                        
                        gameScene.playerTurnState = .TurnEnd
                        
                    })
                    let seq = SKAction.sequence([wait, nextHero])
                    self.run(seq)
                }
                
                
                /* Touch point to attack to */
            } else if gameScene.playerTurnState == .AttackState {
                
                /* Touch ends on active area */
                if nodeAtPoint.name == "activeArea" {
                    
                    guard gameScene.heroMovingFlag == false else { return }
                    
                    /* Remove attack area square */
                    GridActiveAreaController.resetSquareArray(color: "red", grid: self)
                    
                    /* Caclulate grid array position */
                    let gridX = Int(Double(location.x) / cellWidth)
                    let gridY = Int(Double(location.y) / cellHeight)
                    
                    /* Set direction of hero */
                    gameScene.hero.setHeroDirection(posX: gridX, posY: gridY)
                    
                    gameScene.hero.setSwordAnimation()
                    /* Play Sound */
                    if MainMenu.soundOnFlag {
                        let attack = SKAction.playSoundFileNamed("swordSound.wav", waitForCompletion: true)
                        self.run(attack)
                    }
                    /* If hitting enemy! */
                    if self.positionEnemyAtGrid[gridX][gridY] {
                        let waitAni = SKAction.wait(forDuration: 0.5)
                        let destroyEnemy = SKAction.run({
                            /* Look for the enemy to destroy */
                            for enemy in self.enemyArray {
                                if enemy.positionX == gridX && enemy.positionY == gridY {
                                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameScene)
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, destroyEnemy])
                        self.run(seq)
                    }
                    
                    /* Back to MoveState */
                    gameScene.hero.attackDoneFlag = true
                    let wait = SKAction.wait(forDuration: gameScene.turnEndWait+1.0) /* 1.0 is wait time for animation */
                    let moveState = SKAction.run({
                        /* Reset hero animation to back */
                        gameScene.hero.resetHero()
                        gameScene.playerTurnState = .MoveState
                    })
                    let seq = SKAction.sequence([wait, moveState])
                    self.run(seq)
                    
                    /* If touch anywhere but activeArea, back to MoveState  */
                } else {
                    
                    /* Make sure to be invalid when using catpult */
                    guard gameScene.setCatapultDoneFlag == false else { return }
                    
                    gameScene.playerTurnState = .MoveState
                    /* Set item area cover */
                    gameScene.itemAreaCover.isHidden = false
                    
                    /* Reset item type */
                    gameScene.itemType = .None
                    gameScene.magicSwordAttackDone = false
                    
                    /* Reset color of enemy */
                    if gameScene.usingMagicSword {
                        for enemy in self.enemyArray {
                            if enemy.enemyLife > 0 {
                                enemy.colorizeEnemy(color: UIColor.green)
                            } else {
                                enemy.resetColorizeEnemy()
                            }
                        }
                    }
                    
                    /* Remove variable expression display */
                    gameScene.hero.removeMagicSwordVE()
                    
                    /* Remove active area */
                    GridActiveAreaController.resetSquareArray(color: "purple", grid: self)
                    GridActiveAreaController.resetSquareArray(color: "red", grid: self)
                    gameScene.resetActiveAreaForCatapult()
                }
                
                /* Touch position to use item at */
            } else if gameScene.playerTurnState == .UsingItem {
                
                /* Touch ends on active area */
                if nodeAtPoint.name == "activeArea" {
                    let touch = touches.first!              // Get the first touch
                    let location = touch.location(in: self) // Find the location of that touch in this view
                    
                    /* Caclulate grid array position */
                    let gridX = Int(Double(location.x) / cellWidth)
                    let gridY = Int(Double(location.y) / cellHeight)
                    
                    /* Use timeBomb */
                    if gameScene.itemType == .timeBomb {
                        
                        /* Store position of set timeBomb */
                        self.timeBombSetPosArray.append([gridX, gridY])
                        
                        /* Set timeBomb at the location you touch */
                        let timeBomb = TimeBomb()
                        timeBomb.texture = SKTexture(imageNamed: "timeBombToSet")
                        timeBomb.zPosition = 3
                        /* Make sure not to collide to hero */
                        timeBomb.physicsBody = nil
                        self.timeBombSetArray.append(timeBomb)
                        self.addObjectAtGrid(object: timeBomb, x: gridX, y: gridY)
                        
                        /* Remove item active areas */
                        GridActiveAreaController.resetSquareArray(color: "purple", grid: self)
                        /* Reset item type */
                        gameScene.itemType = .None
                        /* Set item area cover */
                        gameScene.itemAreaCover.isHidden = false
                        
                        /* Back to MoveState */
                        gameScene.playerTurnState = .MoveState
                        
                        /* Remove used itemIcon from item array and Scene */
                        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                        
                        /* Use wall */
                    } else if gameScene.itemType == .Wall {
                        /* Set wall */
                        let wall = Wall()
                        wall.texture = SKTexture(imageNamed: "wallToSet")
                        wall.size = CGSize(width:50, height: 75)
                        wall.posX = gridX
                        wall.posY = gridY
                        wall.zPosition = 3
                        wall.physicsBody?.categoryBitMask = 32
                        wall.physicsBody?.contactTestBitMask = 26
                        self.wallSetArray.append(wall)
                        self.addObjectAtGrid(object: wall, x: gridX, y: gridY)
                        
                        /* Remove item active areas */
                        GridActiveAreaController.resetSquareArray(color: "purple", grid: self)
                        /* Reset item type */
                        gameScene.itemType = .None
                        /* Set item area cover */
                        gameScene.itemAreaCover.isHidden = false
                        
                        /* Back to MoveState */
                        gameScene.playerTurnState = .MoveState
                        
                        /* Remove used itemIcon from item array and Scene */
                        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                        
                        /* Use magic sword */
                    } else if gameScene.itemType == .MagicSword {
                        /* On magicSwordAttackDone flag */
                        gameScene.magicSwordAttackDone = true
                        
                        /* Remove attack area square */
                        GridActiveAreaController.resetSquareArray(color: "red", grid: self)
                        
                        /* Set direction of hero */
                        gameScene.hero.setHeroDirection(posX: gridX, posY: gridY)
                        
                        /* Do attack animation */
                        gameScene.hero.setSwordAnimation()
                        
                        /* If hitting enemy! */
                        if self.positionEnemyAtGrid[gridX][gridY] {
                            let waitAni = SKAction.wait(forDuration: 0.5)
                            let removeEnemy = SKAction.run({
                                /* Look for the enemy to destroy */
                                for enemy in self.enemyArray {
                                    enemy.colorizeEnemy(color: UIColor.purple)
                                    if enemy.positionX == gridX && enemy.positionY == gridY {
                                        /* Make sure to call only once in case attacking more than two enemies */
                                        if self.castEnemyDone == false {
                                            self.castEnemyDone = true
                                            self.vEindex = enemy.vECategory
                                            /* Set hero texture */
                                            let setTexture = SKAction.run({
                                                /* Set texture */
                                                gameScene.hero.removeAllActions()
                                                gameScene.hero.texture = SKTexture(imageNamed: "heroMagicSword")
                                                gameScene.hero.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                                                gameScene.hero.size = CGSize(width: 54, height: 85)
                                                /* Display variale expression you attacked */
                                                gameScene.hero.setMagicSwordVE(vE: enemy.variableExpressionString)
                                                /* Set effect */
                                                gameScene.setMagicSowrdEffect()
                                            })
                                            let seqHero = SKAction.sequence([waitAni, setTexture])
                                            self.run(seqHero)
                                            
                                            /* If you killed origin enemy */
                                            if enemy.forEduOriginFlag {
                                                EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self)
                                                /* If you killed branch enemy */
                                            } else if enemy.forEduBranchFlag {
                                                EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self)
                                            }
                                            
                                        }
                                        
                                        /* Effect to enemy */
                                        gameScene.setMagicSowrdEffectToEnemy(enemy: enemy)
                                        
                                        /* Enemy */
                                        let waitEffectRemove = SKAction.wait(forDuration: 2.5)
                                        let removeEnemy = SKAction.run({
                                            enemy.removeFromParent()
                                            gameScene.removeMagicSowrdEffectToEnemy()
                                        })
                                        let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                                        self.run(seqEnemy)
                                        
                                        /* Count defeated enemy */
                                        gameScene.totalNumOfEnemy -= 1
                                        enemy.aliveFlag = false
                                    }
                                }
                            })
                            let seq = SKAction.sequence([waitAni, removeEnemy])
                            self.run(seq)
                            gameScene.hero.attackDoneFlag = true
                            /* If not hit, back to moveState */
                        } else {
                            /* Reset item type */
                            gameScene.itemType = .None
                            gameScene.usingMagicSword = false
                            
                            let waitAni = SKAction.wait(forDuration: 1.0)
                            let backState = SKAction.run({
                                /* Back to MoveState */
                                gameScene.playerTurnState = .MoveState
                                gameScene.hero.resetHero()
                            })
                            let seq = SKAction.sequence([waitAni, backState])
                            self.run(seq)
                        }
                        
                        /* Set item area cover */
                        gameScene.itemAreaCover.isHidden = false
                        
                        /* Remove used itemIcon from item array and Scene */
                        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                        
                        /* Use teleport */
                    } else if gameScene.itemType == .Teleport {
                        /* Remove item active areas */
                        GridActiveAreaController.resetSquareArray(color: "purple", grid: self)
                        /* Reset item type */
                        gameScene.itemType = .None
                        /* Set item area cover */
                        gameScene.itemAreaCover.isHidden = false
                        /* Remove used itemIcon from item array and Scene */
                        gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                        
                        gameScene.hero.positionX = gridX
                        gameScene.hero.positionY = gridY
                        gameScene.hero.position = CGPoint(x: self.position.x+CGFloat((Double(gridX)+0.5)*cellWidth), y: self.position.y+CGFloat((Double(gridY)+0.5)*cellHeight))
                        
                        /* Reset hero animation to back */
                        gameScene.hero.resetHero()
                        gameScene.playerTurnState = .TurnEnd
                    }
                    
                    /* Touch ends enemy for magic sword */
                } else if nodeAtPoint.name == "enemy" {
                    let enemy = nodeAtPoint as! Enemy
                    
                    guard gameScene.magicSwordAttackDone else { return }
                    guard gameScene.usingMagicSword else { return }
                    
                    if enemy.vECategory == vEindex {
                        /* Effect */
                        gameScene.setMagicSowrdEffectToEnemy(enemy: enemy)
                        
                        /* Enemy */
                        let waitEffectRemove = SKAction.wait(forDuration: 2.5)
                        let removeEnemy = SKAction.run({
                            enemy.removeFromParent()
                            gameScene.removeMagicSowrdEffectToEnemy()
                        })
                        let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                        self.run(seqEnemy)
                        
                        enemy.aliveFlag = false
                        /* Count defeated enemy */
                        gameScene.totalNumOfEnemy -= 1
                        
                        /* If you killed origin enemy */
                        if enemy.forEduOriginFlag {
                            EnemyDeadController.originEnemyDead(origin: enemy, gridNode: self)
                            /* If you killed branch enemy */
                        } else if enemy.forEduBranchFlag {
                            EnemyDeadController.branchEnemyDead(branch: enemy, gridNode: self)
                        }
                        
                        /* Touch wrong enemy */
                    } else {
                        /* Reset hero */
                        gameScene.hero.resetHero()
                        /* Remove effect */
                        gameScene.removeMagicSowrdEffect()
                        /* Back to MoveState */
                        gameScene.playerTurnState = .MoveState
                        /* Reset item type */
                        gameScene.itemType = .None
                        gameScene.magicSwordAttackDone = false
                        gameScene.usingMagicSword = false
                        /* Reset color of enemy */
                        for enemy in self.enemyArray {
                            if enemy.enemyLife > 0 {
                                enemy.colorizeEnemy(color: UIColor.green)
                            } else {
                                enemy.resetColorizeEnemy()
                            }
                        }
                        /* Remove variable expression display */
                        gameScene.hero.removeMagicSwordVE()
                        /* Reset flag */
                        castEnemyDone = false
                    }
                    
                    /* Touch ends on anywhere except active area or enemy */
                } else {
                    
                    /* Make sure to be invalid when using catpult */
                    guard gameScene.setCatapultDoneFlag == false else { return }
                    guard gameScene.selectCatapultDoneFlag == false else { return }
                    
                    /* Reset hero */
                    gameScene.hero.resetHero()
                    /* Remove effect */
                    gameScene.removeMagicSowrdEffect()
                    
                    gameScene.playerTurnState = .MoveState
                    /* Set item area cover */
                    gameScene.itemAreaCover.isHidden = false
                    
                    /* Reset item type */
                    gameScene.itemType = .None
                    gameScene.magicSwordAttackDone = false
                    
                    /* Reset color of enemy */
                    if gameScene.usingMagicSword {
                        gameScene.usingMagicSword = false
                        for enemy in self.enemyArray {
                            if enemy.enemyLife > 0 {
                                enemy.colorizeEnemy(color: UIColor.green)
                            } else {
                                enemy.resetColorizeEnemy()
                            }
                        }
                    }
                    
                    /* Remove variable expression display */
                    gameScene.hero.removeMagicSwordVE()
                    /* Reset flag */
                    castEnemyDone = false
                    
                    /* Remove active area */
                    GridActiveAreaController.resetSquareArray(color: "purple", grid: self)
                    GridActiveAreaController.resetSquareArray(color: "red", grid: self)
                    gameScene.resetActiveAreaForCatapult()
                    
                    /* Remove triangle except the one of selected catapult */
                    for catapult in gameScene.setCatapultArray {
                        if let node = catapult.childNode(withName: "pointingCatapult") {
                            node.removeFromParent()
                        }
                    }
                    
                    /* Remove input board for cane */
                    gameScene.inputBoardForCane.isHidden = true
                }
            } else if gameScene.playerTurnState == .ShowingCard {
                gameScene.cardArray[0].removeFromParent()
                gameScene.cardArray.removeFirst()
                gameScene.gameState = .GameOver
            }
        }
    }
    
    /*== Items ==*/
    
    /* Add a new object at grid position*/
    func addObjectAtGrid(object: SKSpriteNode, x: Int, y: Int) {
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: (Double(x)+0.5)*cellWidth, y: (Double(y)+0.5)*cellHeight)
        object.position = gridPosition
        object.zPosition = 3
        
        /* Add timeBomb to grid node */
        addChild(object)
    }
}

