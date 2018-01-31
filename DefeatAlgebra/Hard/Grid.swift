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
    var positionEnemyAtGrid = [[Bool]]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var startPosArray = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var touchingEnemyFlag = false
    var touchedEnemy = Enemy(variableExpressionSource: [[0,1,0,0]]) /* temporally */
    var editedEnemy  = Enemy(variableExpressionSource: [[0,1,0,0]]) /* temporally */
    
    /* Flash */
    var flashSpeed: Double = 0.5
    var numOfFlashUp = 3
    
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
        self.resetEnemyPositon()
        
        /* For display active area for player action */
        coverGrid()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        guard gameScene.pauseFlag == false else { return }
        
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
                if gridX == gameScene.activeHero.positionX && gridY == gameScene.activeHero.positionY {
                    /* Display move path */
                    brightCellAsPath(gridX: gridX, gridY: gridY)
                    /* Set touch began position */
                    beganPos = [gridX, gridY]
                    currentPos = beganPos
                }
            }
        }
        
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
        
        /* Touch edit button to edit variable expression */
        if nodeAtPoint.name == "editButton" {
            /* Get enemy to edit */
            editedEnemy = nodeAtPoint.parent as! Enemy
            
            /* Set enemy's original variable expression */
            gameScene.simplificationBoard.setOriginalVE(vE: editedEnemy.originVariableExpression)
            
            /* Make simplification board visible */
            gameScene.simplificationBoard.isActive = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
                if beganPos[0] == gameScene.activeHero.positionX && beganPos[1] == gameScene.activeHero.positionY {
                    
                    let nextPos = [gridX, gridY]
                    
                    /* Touching position moves to next cell */
                    if nextPos != currentPos {
                        
                        /* Make sure direction judge is excute at first move */
                        if directionJudgeDoneFlag == false {
                            directionJudgeDoneFlag = true
                            
                            /* Finger move horizontally */
                            if nextPos[0] != beganPos[0] {
                                gameScene.activeHero.moveDirection = .Horizontal
                                dispMovePath(start: beganPos, dest: nextPos)
                                currentPos = nextPos
                                /* Finger move vertically */
                            } else if nextPos[1] != beganPos[1] {
                                gameScene.activeHero.moveDirection = .Vertical
                                dispMovePath(start: beganPos, dest: nextPos)
                                currentPos = nextPos
                            }
                        } else {
                            dispMovePath(start: beganPos, dest: nextPos)
                            currentPos = nextPos
                        }
                        /* In case backing to began position */
                    } else if nextPos == beganPos {
                        currentPos = nextPos
                        brightCellAsPath(gridX: beganPos[0], gridY: beganPos[1])
                        
                        directionJudgeDoneFlag = false
                    }
                }
            }
            
            if touchingEnemyFlag {
                rePosEnemy(enemy: touchedEnemy)
                touchingEnemyFlag = false
            }
            
        } else if nodeAtPoint.name == "enemy" {
            if touchingEnemyFlag {
                touchedEnemy.position = location
            }
        } else {
            directionJudgeDoneFlag = false
            resetMovePath()
            if touchingEnemyFlag {
                rePosEnemy(enemy: touchedEnemy)
                touchingEnemyFlag = false
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        guard gameScene.pauseFlag == false else { return }
        guard gameScene.gameState == .PlayerTurn else { return }
        
        /* Reset enemy position after checking variable expression */
        if touchingEnemyFlag {
            rePosEnemy(enemy: touchedEnemy)
            touchingEnemyFlag = false
        }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch point to move to */
        if gameScene.playerTurnState == .MoveState {
            
            /* Touch ends on active area */
            if nodeAtPoint.name == "activeArea" {
                /* Reset move area */
                self.resetSquareArray(color: "blue")
                
                /* Stop showing move pass */
                resetMovePath()
                
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                /* Reset hero move direction flag */
                directionJudgeDoneFlag = false
                
                /* On hero moving flag */
                gameScene.heroMovingFlag = true
                
                /* On moveDoneFlad */
                gameScene.activeHero.moveDoneFlag = true
                
                /* Move hero to touch location */
                gameScene.activeHero.heroMoveToDest(posX: gridX, posY: gridY)
                
                /* Keep track hero position */
                gameScene.activeHero.positionX = gridX
                gameScene.activeHero.positionY = gridY
                
                /* Move next state */
                let wait = SKAction.wait(forDuration: gameScene.turnEndWait)
                let nextHero = SKAction.run({
                    /* Reset hero animation to back */
                    gameScene.activeHero.resetHero()
                    
                    gameScene.heroMovingFlag = false
                    
                    /* All hero turn end */
                    if gameScene.numOfTurnDoneHero >= gameScene.heroArray.count-1 {
                        gameScene.playerTurnState = .TurnEnd
                    } else {
                        gameScene.numOfTurnDoneHero += 1
                        gameScene.activeHero = gameScene.heroArray[gameScene.numOfTurnDoneHero]
                    }
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
                self.resetSquareArray(color: "red")
                
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                /* Set direction of hero */
                gameScene.activeHero.setHeroDirection(posX: gridX, posY: gridY)
                
                /* Sword attack */
                if gameScene.activeHero.attackType == 0 {
                    gameScene.activeHero.setSwordAnimation()
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
                                    /* Effect */
                                    self.enemyDestroyEffect(enemy: enemy)

                                    /* Enemy */
                                    let waitEffectRemove = SKAction.wait(forDuration: 1.0)
                                    let removeEnemy = SKAction.run({ enemy.removeFromParent() })
                                    let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                                    self.run(seqEnemy)
                                    enemy.aliveFlag = false
                                    /* Count defeated enemy */
                                    gameScene.totalNumOfEnemy -= 1
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, destroyEnemy])
                        self.run(seq)
                    }
                    
                    /* Spear attack */
                } else if gameScene.activeHero.attackType == 1 {
                    gameScene.activeHero.setSpearAnimation()
                    
                    let hitSpots = self.hitSpotsForSpear()
                    /* If hitting enemy! */
                    if self.positionEnemyAtGrid[hitSpots.0[0]][hitSpots.0[1]] || self.positionEnemyAtGrid[hitSpots.1[0]][hitSpots.1[1]] {
                        let waitAni = SKAction.wait(forDuration: 0.5)
                        let removeEnemy = SKAction.run({
                            /* Look for the enemy to destroy */
                            for enemy in self.enemyArray {
                                if enemy.positionX == hitSpots.0[0] && enemy.positionY == hitSpots.0[1] || enemy.positionX == hitSpots.1[0] && enemy.positionY == hitSpots.1[1] {
                                    /* Effect */
                                    self.enemyDestroyEffect(enemy: enemy)
                                    
                                    /* Enemy */
                                    let waitEffectRemove = SKAction.wait(forDuration: 1.0)
                                    let removeEnemy = SKAction.run({ enemy.removeFromParent() })
                                    let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                                    self.run(seqEnemy)
                                    enemy.aliveFlag = false
                                    /* Count defeated enemy */
                                    gameScene.totalNumOfEnemy -= 1
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, removeEnemy])
                        self.run(seq)
                    }
                }
                
                /* Back to MoveState */
                gameScene.activeHero.attackDoneFlag = true
                let wait = SKAction.wait(forDuration: gameScene.turnEndWait+1.0) /* 1.0 is wait time for animation */
                let moveState = SKAction.run({
                    /* Reset hero animation to back */
                    gameScene.activeHero.resetHero()
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
                for enemy in self.enemyArray {
                    enemy.resetColorizeEnemy()
                }
                
                /* Remove variable expression display */
                gameScene.activeHero.removeMagicSwordVE()
                
                /* Remove active area */
                gameScene.gridNode.resetSquareArray(color: "purple")
                gameScene.gridNode.resetSquareArray(color: "red")
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
                    self.resetSquareArray(color: "purple")
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
                    self.resetSquareArray(color: "purple")
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
                    self.resetSquareArray(color: "red")
                    
                    /* Set direction of hero */
                    gameScene.activeHero.setHeroDirection(posX: gridX, posY: gridY)
                    
                    /* Do attack animation */
                    gameScene.activeHero.setSwordAnimation()
                    
                    /* If hitting enemy! */
                    if self.positionEnemyAtGrid[gridX][gridY] {
                        let waitAni = SKAction.wait(forDuration: 0.5)
                        let removeEnemy = SKAction.run({
                            /* Look for the enemy to destroy */
                            for enemy in self.enemyArray {
                                enemy.colorizeEnemy()
                                if enemy.positionX == gridX && enemy.positionY == gridY {
                                    /* Make sure to call only once in case attacking more than two enemies */
                                    if self.castEnemyDone == false {
                                        self.castEnemyDone = true
                                        self.vEindex = enemy.vECategory
                                        /* Set hero texture */
                                        let setTexture = SKAction.run({
                                            /* Set texture */
                                            gameScene.activeHero.removeAllActions()
                                            gameScene.activeHero.texture = SKTexture(imageNamed: "heroMagicSword")
                                            gameScene.activeHero.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                                            gameScene.activeHero.size = CGSize(width: 54, height: 85)
                                            /* Display variale expression you attacked */
                                            gameScene.activeHero.setMagicSwordVE(vE: enemy.variableExpressionForLabel)
                                            /* Set effect */
                                            gameScene.setMagicSowrdEffect()
                                        })
                                        let seqHero = SKAction.sequence([waitAni, setTexture])
                                        self.run(seqHero)
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
                        gameScene.activeHero.attackDoneFlag = true
                    /* If not hit, back to moveState */
                    } else {
                        /* Reset item type */
                        gameScene.itemType = .None
                        
                        let waitAni = SKAction.wait(forDuration: 1.0)
                        let backState = SKAction.run({
                            /* Back to MoveState */
                            gameScene.playerTurnState = .MoveState
                            gameScene.activeHero.resetHero()
                        })
                        let seq = SKAction.sequence([waitAni, backState])
                        self.run(seq)
                    }
                    
                    /* Set item area cover */
                    gameScene.itemAreaCover.isHidden = false
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                    
                /* Use battle ship */
                } else if gameScene.itemType == .BattleShip {
                    
                    /* Set timeBomb at the location you touch */
                    let battleShip = BattleShip()
                    battleShip.texture = SKTexture(imageNamed: "battleShipToSet")
                    /* Make sure not to collide to hero */
                    battleShip.physicsBody = nil
                    self.battleShipSetArray.append(battleShip)
                    battleShip.position = CGPoint(x: 0.0, y: (Double(gridY)+0.5)*self.cellHeight)
                    addChild(battleShip)
                    
                    /* Remove item active areas */
                    self.resetSquareArray(color: "purple")
                    /* Reset item type */
                    gameScene.itemType = .None
                    /* Set item area cover */
                    gameScene.itemAreaCover.isHidden = false
                    
                    /* Back to MoveState */
                    gameScene.playerTurnState = .MoveState
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                    
                /* Use teleport */
                } else if gameScene.itemType == .Teleport {
                    /* Remove item active areas */
                    self.resetSquareArray(color: "purple")
                    /* Reset item type */
                    gameScene.itemType = .None
                    /* Set item area cover */
                    gameScene.itemAreaCover.isHidden = false
                    /* Remove used itemIcon from item array and Scene */
                    gameScene.resetDisplayItem(index: gameScene.usingItemIndex)
                    
                    gameScene.activeHero.positionX = gridX
                    gameScene.activeHero.positionY = gridY
                    gameScene.activeHero.position = CGPoint(x: self.position.x+CGFloat((Double(gridX)+0.5)*cellWidth), y: self.position.y+CGFloat((Double(gridY)+0.5)*cellHeight))
                    
                    /* Reset hero animation to back */
                    gameScene.activeHero.resetHero()
                    
                    /* All hero turn end */
                    if gameScene.numOfTurnDoneHero >= gameScene.heroArray.count-1 {
                        gameScene.playerTurnState = .TurnEnd
                    } else {
                        gameScene.numOfTurnDoneHero += 1
                        gameScene.activeHero = gameScene.heroArray[gameScene.numOfTurnDoneHero]
                    }
                    
                }
                
            /* Touch ends enemy for magic sword */
            } else if nodeAtPoint.name == "enemy" {
                let enemy = nodeAtPoint as! Enemy
                
                guard gameScene.magicSwordAttackDone else { return }
                
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
                    /* Touch wrong enemy */
                } else {
                    
                    guard gameScene.magicSwordAttackDone else { return }
                    
                    /* Reset hero */
                    gameScene.activeHero.resetHero()
                    /* Remove effect */
                    gameScene.removeMagicSowrdEffect()
                    /* Back to MoveState */
                    gameScene.playerTurnState = .MoveState
                    /* Reset item type */
                    gameScene.itemType = .None
                    gameScene.magicSwordAttackDone = false
                    /* Reset color of enemy */
                    for enemy in self.enemyArray {
                        enemy.resetColorizeEnemy()
                    }
                    /* Remove variable expression display */
                    gameScene.activeHero.removeMagicSwordVE()
                    /* Reset flag */
                    castEnemyDone = false
                }
                
            /* Touch ends on anywhere but active area or enemy */
            } else {
                
                /* Make sure to be invalid when using catpult */
                guard gameScene.setCatapultDoneFlag == false else { return }
                guard gameScene.selectCatapultDoneFlag == false else { return }
                
                /* Reset hero */
                gameScene.activeHero.resetHero()
                /* Remove effect */
                gameScene.removeMagicSowrdEffect()
                
                gameScene.playerTurnState = .MoveState
                /* Set item area cover */
                gameScene.itemAreaCover.isHidden = false
                
                /* Reset item type */
                gameScene.itemType = .None
                gameScene.magicSwordAttackDone = false
                
                /* Reset color of enemy */
                for enemy in self.enemyArray {
                    enemy.resetColorizeEnemy()
                }
                
                /* Remove variable expression display */
                gameScene.activeHero.removeMagicSwordVE()
                /* Reset flag */
                castEnemyDone = false
                
                /* Remove active area */
                gameScene.gridNode.resetSquareArray(color: "purple")
                gameScene.gridNode.resetSquareArray(color: "red")
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
            gameScene.heroArray = gameScene.heroArray.filter({ $0.aliveFlag == true })
            if gameScene.heroArray.count > 0{
                gameScene.playerTurnState = .TurnEnd
            } else {
                gameScene.gameState = .GameOver
            }
        }
    }
    
    /*== Enemy Position Management ==*/
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
    
    /* Reposition enemy for checking variable exoression */
    func rePosEnemy(enemy: Enemy) {
        enemy.position = CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*self.cellWidth), y: CGFloat((Double(enemy.positionY)+0.5)*self.cellHeight))
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = 1
    }
    
    /*== Set effect when enemy destroyed ==*/
    func enemyDestroyEffect(enemy: Enemy) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "DestroyEnemy")!
        particles.position = CGPoint(x: enemy.position.x, y: enemy.position.y-20)
        /* Add particles to scene */
        self.addChild(particles)
        let waitEffectRemove = SKAction.wait(forDuration: 1.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitEffectRemove, removeParticles])
        particles.run(seqEffect)
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let dead = SKAction.playSoundFileNamed("enemyKilled.mp3", waitForCompletion: true)
            self.run(dead)
        }

    }
    
    /*== Adding Enemy ==*/
    
    /* Add initial enemy */
    func addInitialEnemyAtGrid(enemyPosArray: [[Int]], variableExpressionSource: [[Int]]) {
        /* Add a new enemy at grid position*/
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        for posArray in enemyPosArray {
            /* New enemy object */
            let enemy = Enemy(variableExpressionSource: variableExpressionSource)
            
            /* Set enemy speed according to stage level */
            if gameScene.stageLevel < 1 {
                enemy.moveSpeed = 0.2
                enemy.punchSpeed = 0.0025
                enemy.singleTurnDuration = 1.0
            }
            
            /* Attach variable expression */
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            
            /* Store variable expression as origin */
            enemy.originVariableExpression = enemy.variableExpressionForLabel
            
            /* Set direction of enemy */
            enemy.direction = .front
            enemy.setMovingAnimation()
            
            /* Set position on screen */
            /* Enemy come to grid from out of it */
            let startPosition = posArray[0]
            
            /* Keep track enemy position */
            enemy.positionX = startPosition
            enemy.positionY = posArray[1]
            
            /* Calculate gap between top of grid and gameScene */
            let gridPosition = CGPoint(x: (Double(startPosition)+0.5)*cellWidth, y: Double(gameScene.topGap+self.size.height))
            enemy.position = gridPosition
            
            /* Set enemy's move distance when showing up */
            let startMoveDistance = Double(gameScene.topGap)+self.cellHeight*(Double(11-posArray[1])+0.5)
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(startMoveDistance/Double(self.cellHeight)*self.addingMoveSpeed)
            
            /* Move enemy for startMoveDistance */
            let move = SKAction.moveTo(y: CGFloat((Double(enemy.positionY)+0.5)*self.cellHeight), duration: startDulation)
            enemy.run(move)
            
            /* Add enemy to grid node */
            addChild(enemy)
            
            /* Add enemy to enemyArray */
            self.enemyArray.append(enemy)
        }
    }
    
    /* Add enemy in the middle of game */
    func addEnemyAtGrid(_ numberOfEnemy: Int, variableExpressionSource: [[Int]], yRange: Int) {
        /* Add a new enemy at grid position*/
        
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = Enemy(variableExpressionSource: variableExpressionSource)
            
            /* Attach variable expression */
            enemy.setVariableExpressionLabel(text: enemy.variableExpressionForLabel)
            
            /* Store variable expression as origin */
            enemy.originVariableExpression = enemy.variableExpressionForLabel
            
            /* Set direction of enemy */
            enemy.direction = .front
            enemy.setMovingAnimation()
            
            /* Set position on screen */
            /* Enemy come to grid from out of it */
            /* x position */
            let randX = Int(arc4random_uniform(UInt32(startPosArray.count)))
            let startPositionX = startPosArray[randX]
            /* Make sure not to overlap enemies */
            startPosArray.remove(at: randX)
            
            /* y position */
            let randY = Int(arc4random_uniform(UInt32(yRange)))
            /* Keep track enemy position */
            enemy.positionX = startPositionX
            enemy.positionY = 11-randY
            
            /* Calculate gap between top of grid and gameScene */
            let gridPosition = CGPoint(x: (Double(startPositionX)+0.5)*cellWidth, y: Double(gameScene.topGap+self.size.height))
            enemy.position = gridPosition
            
            /* Calculate relative duration with distance */
            let startDulation = TimeInterval(1.5*self.addingMoveSpeed)
            
            /* Move enemy for startMoveDistance */
            let move = SKAction.moveTo(y: CGFloat((Double(enemy.positionY)+0.5)*self.cellHeight), duration: startDulation)
            enemy.run(move)
            
            /* Add enemy to grid node */
            addChild(enemy)
            
            /* Add enemy to enemyArray */
            self.enemyArray.append(enemy)
        }
    }
    
    /*== Flash grid ==*/
    
    func flashGrid(labelNode: SKLabelNode) -> Int {
        /* Set the number of times of flash randomly */
        let numOfFlash = Int(arc4random_uniform(UInt32(numOfFlashUp)))+1
        
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let sound = SKAction.playSoundFileNamed("flash.wav", waitForCompletion: true)
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let group = SKAction.group([sound, seqFlash])
            let flash = SKAction.repeat(group, count: numOfFlash)
            self.run(flash)
            
        } else {
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let flash = SKAction.repeat(seqFlash, count: numOfFlash)
            self.run(flash)
            
        }
        
        /* Display the number of flash */
        let wholeWait = SKAction.wait(forDuration: TimeInterval((self.flashSpeed+0.2)*Double(numOfFlash)))
        let display = SKAction.run({ labelNode.text = String(numOfFlash) })
        let seq = SKAction.sequence([wholeWait, display])
        self.run(seq)
        
        return numOfFlash
    }
    
    func flashGridForCane(labelNode: SKLabelNode, numOfFlash: Int) {
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let sound = SKAction.playSoundFileNamed("flash.wav", waitForCompletion: true)
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let group = SKAction.group([sound, seqFlash])
            let flash = SKAction.repeat(group, count: numOfFlash)
            self.run(flash)
            
        } else {
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let flash = SKAction.repeat(seqFlash, count: numOfFlash)
            self.run(flash)
        }
        
        /* Display the number of flash */
        let wholeWait = SKAction.wait(forDuration: TimeInterval((self.flashSpeed+0.2)*Double(numOfFlash)))
        let display = SKAction.run({ labelNode.text = String(numOfFlash) })
        let seq = SKAction.sequence([wholeWait, display])
        self.run(seq)
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
    
    /*=================*/
    /*== Active Area ==*/
    /*=================*/
    
    /*== Setting area ==*/
    /* Add area at cell */
    func addSquareAtGrid(x: Int, y: Int, color: UIColor) {
        /* Add a new creature at grid position*/
        
        /* Create square */
        let square = SKShapeNode(rectOf: CGSize(width: self.cellWidth, height: cellHeight))
        square.fillColor = color
        square.alpha = 0.4
        square.zPosition = 100
        square.name = "activeArea"
        
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: (Double(x)+0.5)*cellWidth, y: (Double(y)+0.5)*cellHeight)
        square.position = gridPosition
        
        /* Set default isAlive */
        square.isHidden = true
        
        /* Add creature to grid node */
        addChild(square)
        
        /* Add creature to grid array */
        switch color {
        case UIColor.red:
            squareRedArray[x].append(square)
        case UIColor.blue:
            squareBlueArray[x].append(square)
        case UIColor.purple:
            squarePurpleArray[x].append(square)
        default:
            break;
        }
    }
    
    /* Set area on grid */
    func coverGrid() {
        /* Populate the grid with creatures */
        
        /* Red square */
        /* Loop through columns */
        for gridX in 0..<columns {
            /* Initialize empty column */
            squareRedArray.append([])
            /* Loop through rows */
            for gridY in 0..<rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.red)
            }
        }
        
        /* Blue square */
        /* Loop through columns */
        for gridX in 0..<columns {
            /* Initialize empty column */
            squareBlueArray.append([])
            /* Loop through rows */
            for gridY in 0..<rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.blue)
            }
        }
        
        /* purple square */
        /* Loop through columns */
        for gridX in 0..<columns {
            /* Initialize empty column */
            squarePurpleArray.append([])
            /* Loop through rows */
            for gridY in 0..<rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.purple)
            }
        }
    }
    
    /* Reset squareArray */
    func resetSquareArray(color: String) {
        switch color {
        case "red":
            for x in 0..<columns {
                /* Loop through rows */
                for y in 0..<rows {
                    squareRedArray[x][y].isHidden = true
                }
            }
        case "blue":
            for x in 0..<columns {
                /* Loop through rows */
                for y in 0..<rows {
                    squareBlueArray[x][y].isHidden = true
                }
            }
        case "purple":
            for x in 0..<columns {
                /* Loop through rows */
                for y in 0..<rows {
                    squarePurpleArray[x][y].isHidden = true
                }
            }
        default:
            break;
        }
        
    }
    
    /*== Move ==*/
    /* Show area where player can move */
    func showMoveArea(posX: Int, posY: Int, moveLevel: Int) {
        /* Show up red square according to move level */
        switch moveLevel {
        case 1:
            for gridX in posX-1...posX+1 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-1...posY+1 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    squareBlueArray[posX][gridY].isHidden = false
                }
            }
        case 2:
            for gridX in posX-2...posX+2 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-2...posY+2 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    squareBlueArray[posX][gridY].isHidden = false
                }
            }
            for gridX in posX-1...posX+1 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    for gridY in posY-1...posY+1 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= self.rows-1 {
                            squareBlueArray[gridX][gridY].isHidden = false
                        }
                    }
                }
            }
        case 3:
            for gridX in posX-3...posX+3 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-3...posY+3 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    squareBlueArray[posX][gridY].isHidden = false
                }
            }
            for gridX in posX-2...posX+2 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    for gridY in posY-2...posY+2 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= self.rows-1 {
                            /* Remove corner */
                            if gridX == posX-2 && gridY == posY-2 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX-2 && gridY == posY+2 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+2 && gridY == posY-2 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+2 && gridY == posY+2 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else {
                                squareBlueArray[gridX][gridY].isHidden = false
                            }
                            
                        }
                    }
                }
            }
        case 4:
            for gridX in posX-4...posX+4 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-4...posY+4 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    squareBlueArray[posX][gridY].isHidden = false
                }
            }
            for gridX in posX-3...posX+3 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    for gridY in posY-3...posY+3 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= self.rows-1 {
                            /* Remove corner */
                            if gridX == posX-3 && gridY == posY-3 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX-3 && gridY == posY+3 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+3 && gridY == posY-3 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+3 && gridY == posY+3 {
                                squareBlueArray[gridX][gridY].isHidden = true
                            } else {
                                squareBlueArray[gridX][gridY].isHidden = false
                            }
                            
                        }
                    }
                }
            }
        default:
            break;
        }
    }
    
    /* Swiping Move */
    /* Display move path */
    func dispMovePath(start: [Int], dest: [Int]) {
        /* Get gameScene */
        let gameScene = self.parent as! GameScene
        
        /* Reset display path */
        resetMovePath()
        
        /* Calculate difference between beganPos and destination */
        let diffX = dest[0] - start[0]
        let diffY = dest[1] - start[1]
        
        switch gameScene.activeHero.moveDirection {
            /* Set move path horizontal → vertical */
        case .Horizontal:
            if diffY == 0 {
                
                /* To right */
                if diffX > 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: dest)
                }
                /* To left */
                if diffX < 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: start)
                }
            } else if diffX == 0 {
                
                /* To up direction */
                if diffY > 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: start, destPos: dest)
                }
                /* To down direction */
                if diffY < 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: dest, destPos: start)
                }
            } else if diffY > 0 {
                
                /* To right up direction */
                if diffX > 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: viaPos)
                    brightColumnAsPath(startPos: viaPos, destPos: dest)
                }
                /* To left up direction */
                if diffX < 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: start)
                    brightColumnAsPath(startPos: viaPos, destPos: dest)
                }
            } else if diffY < 0 {
                
                /* To right down direction */
                if diffX > 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: viaPos)
                    brightColumnAsPath(startPos: dest, destPos: viaPos)
                }
                /* To left down direction */
                if diffX < 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: start)
                    brightColumnAsPath(startPos: dest, destPos: viaPos)
                }
            }
            break;
            /* Set move path horizontal → vertical */
        case .Vertical:
            if diffX == 0 {
                /* To up */
                if diffY > 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: start, destPos: dest)
                }
                /* To down */
                if diffY < 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: dest, destPos: start)
                }
            } else if diffY == 0 {
                /* To right direction */
                if diffX > 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: dest)
                }
                /* To left direction */
                if diffX < 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: start)
                }
            } else if diffY > 0 {
                /* To right up direction */
                if diffX > 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: dest)
                    brightColumnAsPath(startPos: start, destPos: viaPos)
                }
                /* To left up direction */
                if diffX < 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: viaPos)
                    brightColumnAsPath(startPos: start, destPos: viaPos)
                }
            } else if diffY < 0 {
                /* To right down direction */
                if diffX > 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: dest)
                    brightColumnAsPath(startPos: viaPos, destPos: start)
                }
                /* To left down direction */
                if diffX < 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: viaPos)
                    brightColumnAsPath(startPos: viaPos, destPos: start)
                }
            }
            break;
        }
    }
    
    func brightRowAsPath(startPos: [Int], destPos: [Int]) {
        for i in startPos[0]...destPos[0] {
            brightCellAsPath(gridX: i, gridY: startPos[1])
        }
    }
    
    func brightColumnAsPath(startPos: [Int], destPos: [Int]) {
        for i in startPos[1]...destPos[1] {
            brightCellAsPath(gridX: startPos[0], gridY: i)
        }
    }
    
    func brightCellAsPath(gridX: Int, gridY: Int) {
        squareBlueArray[gridX][gridY].alpha = 0.6
    }
    
    /* Reset move path */
    func resetMovePath() {
        for gridX in 0..<self.columns {
            for gridY in 0..<self.rows-1 {
                self.squareBlueArray[gridX][gridY].alpha = 0.4
            }
        }
    }
    
    
    /*== Attack ==*/
    /* Show attack area */
    func showAttackArea(posX: Int, posY: Int, attackType: Int) {
        /* Show up red square according to move level */
        switch attackType {
        case 0:
            for gridX in posX-1...posX+1 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    /* Remove hero position */
                    if gridX != posX {
                        squareRedArray[gridX][posY].isHidden = false
                    }
                }
            }
            for gridY in posY-1...posY+1 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    /* Remove hero position */
                    if gridY != posY {
                        squareRedArray[posX][gridY].isHidden = false
                    }
                }
            }
        case 1:
            for gridX in posX-2...posX+2 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= self.columns-1 {
                    /* Remove hero position */
                    if gridX != posX {
                        squareRedArray[gridX][posY].isHidden = false
                    }
                }
            }
            for gridY in posY-2...posY+2 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= self.rows-1 {
                    /* Remove hero position */
                    if gridY != posY {
                        squareRedArray[posX][gridY].isHidden = false
                    }
                }
            }
        default:
            break;
        }
        
    }
    
    /* Find hit spots for spear attack */
    func hitSpotsForSpear() -> ([Int], [Int]) {
        let gameScene = self.parent as! GameScene
        switch gameScene.activeHero.direction {
        case .front:
            if gameScene.activeHero.positionY < 2 {
                return ([gameScene.activeHero.positionX, 0], [gameScene.activeHero.positionX, 0])
            } else {
                return ([gameScene.activeHero.positionX, gameScene.activeHero.positionY-1], [gameScene.activeHero.positionX, gameScene.activeHero.positionY-2])
            }
        case .back:
            if gameScene.activeHero.positionY > 9 {
                return ([gameScene.activeHero.positionX, 11], [gameScene.activeHero.positionX, 11])
            } else {
                return ([gameScene.activeHero.positionX, gameScene.activeHero.positionY+1], [gameScene.activeHero.positionX, gameScene.activeHero.positionY+2])
            }
        case .left:
            if gameScene.activeHero.positionX < 2 {
                return ([0, gameScene.activeHero.positionY], [0, gameScene.activeHero.positionY])
            } else {
                return ([gameScene.activeHero.positionX-1, gameScene.activeHero.positionY], [gameScene.activeHero.positionX-2, gameScene.activeHero.positionY])
            }
        case .right:
            if gameScene.activeHero.positionX > 6 {
                return ([8, gameScene.activeHero.positionY], [8, gameScene.activeHero.positionY])
            } else {
                return ([gameScene.activeHero.positionX+1, gameScene.activeHero.positionY], [gameScene.activeHero.positionX+2, gameScene.activeHero.positionY])
            }
        }
    }
    
    /*== Items ==*/
    /* timeBomb */
    /* Show timeBomb setting area */
    func showtimeBombSettingArea() {
        for gridX in 0..<self.columns {
            for gridY in 1..<self.rows-1 {
                self.squarePurpleArray[gridX][gridY].isHidden = false
            }
        }
    }
    
    /* Show wall setting area */
    func showWallSettingArea() {
        for gridX in 0..<self.columns {
            for gridY in 0..<self.rows-1 {
                self.squarePurpleArray[gridX][gridY].isHidden = false
                if gridX == self.columns-1 && gridY == self.rows-2 {
                    for enemy in self.enemyArray {
                        if enemy.aliveFlag {
                            self.squarePurpleArray[enemy.positionX][enemy.positionY].isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    /* Battle Ship */
    /* Show active area for battle ship */
    func showBttleShipSettingArea() {
        for i in 1..<self.rows-1 {
            squarePurpleArray[0][i].isHidden = false
        }
    }   
    
    /* Teleport */
    /* Show active area for teleport */
    func showTeleportSettingArea() {
        for gridX in 0..<self.columns {
            for gridY in 0..<self.rows {
                self.squarePurpleArray[gridX][gridY].isHidden = false
            }
        }
    }
    
}

