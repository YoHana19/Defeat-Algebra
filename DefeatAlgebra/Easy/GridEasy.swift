//
//  Grid.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class GridEasy: SKSpriteNode {
    
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
    var enemyArray = [EnemyEasy]()
    var enemySUPairDict = [EnemyEasy: EnemyEasy]()
    var positionEnemyAtGrid = [[Bool]]()
    var currentPositionOfEnemies = [[Int]]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var startPosArray = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var touchingEnemyFlag = false
    var touchedEnemy = EnemyEasy(variableExpressionSource: [[0,1,0,0]], forEdu: false) /* temporally */
    var editedEnemy  = EnemyEasy(variableExpressionSource: [[0,1,0,0]], forEdu: false) /* temporally */
    
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
        
        /* Get gameSceneEasy */
        let gameSceneEasy = self.parent as! GameSceneEasy
        
        guard gameSceneEasy.pauseFlag == false else { return }
        guard gameSceneEasy.boardActiveFlag == false else { return }
        guard gameSceneEasy.gameState == .PlayerTurn else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Touch point to move to */
        if gameSceneEasy.playerTurnState == .MoveState {
            
            /* Touch red square for active area */
            if nodeAtPoint.name == "activeArea" {
                
                /* Reset all */
                beganPos = []
                currentPos = []
                
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                
                /* Touch hero's position */
                if gridX == gameSceneEasy.activeHero.positionX && gridY == gameSceneEasy.activeHero.positionY {
                    /* Display move path */
                    brightCellAsPath(gridX: gridX, gridY: gridY)
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
                guard gameSceneEasy.magicSwordAttackDone == false else { return }
                
                touchingEnemyFlag = true
                touchedEnemy = nodeAtPoint as! EnemyEasy
                touchedEnemy.position = location
                touchedEnemy.physicsBody = nil
            }
        }
        */
        
        /* Touch enemy to edit variable expression */
        if !gameSceneEasy.usingMagicSword {
            if nodeAtPoint.name == "enemy" {
                /* Get enemy to edit */
                editedEnemy = nodeAtPoint as! EnemyEasy
                
                /* Set enemy's original variable expression */
                gameSceneEasy.simplificationBoard.originLabel.text = editedEnemy.originVariableExpression
                
                /* Make simplification board visible */
                gameSceneEasy.simplificationBoard.isActive = true
                
                gameSceneEasy.boardActiveFlag = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Get gameSceneEasy */
        let gameSceneEasy = self.parent as! GameSceneEasy
        
        guard gameSceneEasy.pauseFlag == false else { return }
        guard gameSceneEasy.gameState == .PlayerTurn else { return }
        
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
                if beganPos[0] == gameSceneEasy.activeHero.positionX && beganPos[1] == gameSceneEasy.activeHero.positionY {
                    
                    let nextPos = [gridX, gridY]
                    
                    /* Touching position moves to next cell */
                    if nextPos != currentPos {
                        
                        /* Make sure direction judge is excute at first move */
                        if directionJudgeDoneFlag == false {
                            directionJudgeDoneFlag = true
                            
                            /* Finger move horizontally */
                            if nextPos[0] != beganPos[0] {
                                gameSceneEasy.activeHero.moveDirection = .Horizontal
                                dispMovePath(start: beganPos, dest: nextPos)
                                currentPos = nextPos
                                /* Finger move vertically */
                            } else if nextPos[1] != beganPos[1] {
                                gameSceneEasy.activeHero.moveDirection = .Vertical
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
         
        /*
        } else if nodeAtPoint.name == "enemy" {
            if touchingEnemyFlag {
                touchedEnemy.position = location
            }
        */
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
        
        /* Get gameSceneEasy */
        let gameSceneEasy = self.parent as! GameSceneEasy
        
        guard gameSceneEasy.pauseFlag == false else { return }
        guard gameSceneEasy.gameState == .PlayerTurn else { return }
        
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
        if gameSceneEasy.playerTurnState == .MoveState {
            
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
                gameSceneEasy.heroMovingFlag = true
                
                /* On moveDoneFlad */
                gameSceneEasy.activeHero.moveDoneFlag = true
                
                /* Move hero to touch location */
                gameSceneEasy.activeHero.heroMoveToDest(posX: gridX, posY: gridY)
                
                /* Keep track hero position */
                gameSceneEasy.activeHero.positionX = gridX
                gameSceneEasy.activeHero.positionY = gridY
                
                /* Move next state */
                let wait = SKAction.wait(forDuration: gameSceneEasy.turnEndWait)
                let nextHero = SKAction.run({
                    /* Reset hero animation to back */
                    gameSceneEasy.activeHero.resetHero()
                    
                    gameSceneEasy.heroMovingFlag = false
                    
                    /* All hero turn end */
                    if gameSceneEasy.numOfTurnDoneHero >= gameSceneEasy.heroArray.count-1 {
                        gameSceneEasy.playerTurnState = .TurnEnd
                    } else {
                        gameSceneEasy.numOfTurnDoneHero += 1
                        gameSceneEasy.activeHero = gameSceneEasy.heroArray[gameSceneEasy.numOfTurnDoneHero]
                    }
                })
                let seq = SKAction.sequence([wait, nextHero])
                self.run(seq)
            }
            
            
        /* Touch point to attack to */
        } else if gameSceneEasy.playerTurnState == .AttackState {
            
            /* Touch ends on active area */
            if nodeAtPoint.name == "activeArea" {
                
                guard gameSceneEasy.heroMovingFlag == false else { return }
                
                /* Remove attack area square */
                self.resetSquareArray(color: "red")
                
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                /* Set direction of hero */
                gameSceneEasy.activeHero.setHeroDirection(posX: gridX, posY: gridY)
                
                /* Sword attack */
                if gameSceneEasy.activeHero.attackType == 0 {
                    gameSceneEasy.activeHero.setSwordAnimation()
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
                                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameSceneEasy)
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, destroyEnemy])
                        self.run(seq)
                    }
                    
                /* Spear attack */
                } else if gameSceneEasy.activeHero.attackType == 1 {
                    gameSceneEasy.activeHero.setSpearAnimation()
                    
                    let hitSpots = self.hitSpotsForSpear()
                    /* If hitting enemy! */
                    if self.positionEnemyAtGrid[hitSpots.0[0]][hitSpots.0[1]] || self.positionEnemyAtGrid[hitSpots.1[0]][hitSpots.1[1]] {
                        let waitAni = SKAction.wait(forDuration: 0.5)
                        let removeEnemy = SKAction.run({
                            /* Look for the enemy to destroy */
                            for enemy in self.enemyArray {
                                if enemy.positionX == hitSpots.0[0] && enemy.positionY == hitSpots.0[1] || enemy.positionX == hitSpots.1[0] && enemy.positionY == hitSpots.1[1] {
                                    EnemyDeadController.hitEnemy(enemy: enemy, gameScene: gameSceneEasy)
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, removeEnemy])
                        self.run(seq)
                    }
                }
                
                /* Back to MoveState */
                gameSceneEasy.activeHero.attackDoneFlag = true
                let wait = SKAction.wait(forDuration: gameSceneEasy.turnEndWait+1.0) /* 1.0 is wait time for animation */
                let moveState = SKAction.run({
                    /* Reset hero animation to back */
                    gameSceneEasy.activeHero.resetHero()
                    gameSceneEasy.playerTurnState = .MoveState
                })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
                
            /* If touch anywhere but activeArea, back to MoveState  */
            } else {
                
                /* Make sure to be invalid when using catpult */
                guard gameSceneEasy.setCatapultDoneFlag == false else { return }
                
                gameSceneEasy.playerTurnState = .MoveState
                /* Set item area cover */
                gameSceneEasy.itemAreaCover.isHidden = false
                
                /* Reset item type */
                gameSceneEasy.itemType = .None
                gameSceneEasy.magicSwordAttackDone = false
                
                /* Reset color of enemy */
                if gameSceneEasy.usingMagicSword {
                    for enemy in self.enemyArray {
                        if enemy.enemyLife > 0 {
                            enemy.colorizeEnemy(color: UIColor.green)
                        } else {
                            enemy.resetColorizeEnemy()
                        }
                    }
                }
                
                /* Remove variable expression display */
                gameSceneEasy.activeHero.removeMagicSwordVE()
                
                /* Remove active area */
                gameSceneEasy.gridNode.resetSquareArray(color: "purple")
                gameSceneEasy.gridNode.resetSquareArray(color: "red")
                gameSceneEasy.resetActiveAreaForCatapult()
            }
            
        /* Touch position to use item at */
        } else if gameSceneEasy.playerTurnState == .UsingItem {
            
            /* Touch ends on active area */
            if nodeAtPoint.name == "activeArea" {
                let touch = touches.first!              // Get the first touch
                let location = touch.location(in: self) // Find the location of that touch in this view
                
                /* Caclulate grid array position */
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                
                /* Use timeBomb */
                if gameSceneEasy.itemType == .timeBomb {
                    
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
                    gameSceneEasy.itemType = .None
                    /* Set item area cover */
                    gameSceneEasy.itemAreaCover.isHidden = false
                    
                    /* Back to MoveState */
                    gameSceneEasy.playerTurnState = .MoveState
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameSceneEasy.resetDisplayItem(index: gameSceneEasy.usingItemIndex)
                    
                    /* Use wall */
                } else if gameSceneEasy.itemType == .Wall {
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
                    gameSceneEasy.itemType = .None
                    /* Set item area cover */
                    gameSceneEasy.itemAreaCover.isHidden = false
                    
                    /* Back to MoveState */
                    gameSceneEasy.playerTurnState = .MoveState
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameSceneEasy.resetDisplayItem(index: gameSceneEasy.usingItemIndex)
                    
                    /* Use magic sword */
                } else if gameSceneEasy.itemType == .MagicSword {
                    /* On magicSwordAttackDone flag */
                    gameSceneEasy.magicSwordAttackDone = true
                    
                    /* Remove attack area square */
                    self.resetSquareArray(color: "red")
                    
                    /* Set direction of hero */
                    gameSceneEasy.activeHero.setHeroDirection(posX: gridX, posY: gridY)
                    
                    /* Do attack animation */
                    gameSceneEasy.activeHero.setSwordAnimation()
                    
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
                                            gameSceneEasy.activeHero.removeAllActions()
                                            gameSceneEasy.activeHero.texture = SKTexture(imageNamed: "heroMagicSword")
                                            gameSceneEasy.activeHero.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                                            gameSceneEasy.activeHero.size = CGSize(width: 54, height: 85)
                                            /* Display variale expression you attacked */
                                            gameSceneEasy.activeHero.setMagicSwordVE(vE: enemy.variableExpressionForLabel)
                                            /* Set effect */
                                            gameSceneEasy.setMagicSowrdEffect()
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
                                    gameSceneEasy.setMagicSowrdEffectToEnemy(enemy: enemy)
                                    
                                    /* Enemy */
                                    let waitEffectRemove = SKAction.wait(forDuration: 2.5)
                                    let removeEnemy = SKAction.run({
                                        enemy.removeFromParent()
                                        gameSceneEasy.removeMagicSowrdEffectToEnemy()
                                    })
                                    let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                                    self.run(seqEnemy)
                                    
                                    /* Count defeated enemy */
                                    gameSceneEasy.totalNumOfEnemy -= 1
                                    enemy.aliveFlag = false
                                }
                            }
                        })
                        let seq = SKAction.sequence([waitAni, removeEnemy])
                        self.run(seq)
                        gameSceneEasy.activeHero.attackDoneFlag = true
                        /* If not hit, back to moveState */
                    } else {
                        /* Reset item type */
                        gameSceneEasy.itemType = .None
                        gameSceneEasy.usingMagicSword = false
                        
                        let waitAni = SKAction.wait(forDuration: 1.0)
                        let backState = SKAction.run({
                            /* Back to MoveState */
                            gameSceneEasy.playerTurnState = .MoveState
                            gameSceneEasy.activeHero.resetHero()
                        })
                        let seq = SKAction.sequence([waitAni, backState])
                        self.run(seq)
                    }
                    
                    /* Set item area cover */
                    gameSceneEasy.itemAreaCover.isHidden = false
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameSceneEasy.resetDisplayItem(index: gameSceneEasy.usingItemIndex)
                    
                    /* Use battle ship */
                } else if gameSceneEasy.itemType == .BattleShip {
                    
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
                    gameSceneEasy.itemType = .None
                    /* Set item area cover */
                    gameSceneEasy.itemAreaCover.isHidden = false
                    
                    /* Back to MoveState */
                    gameSceneEasy.playerTurnState = .MoveState
                    
                    /* Remove used itemIcon from item array and Scene */
                    gameSceneEasy.resetDisplayItem(index: gameSceneEasy.usingItemIndex)
                    
                    /* Use teleport */
                } else if gameSceneEasy.itemType == .Teleport {
                    /* Remove item active areas */
                    self.resetSquareArray(color: "purple")
                    /* Reset item type */
                    gameSceneEasy.itemType = .None
                    /* Set item area cover */
                    gameSceneEasy.itemAreaCover.isHidden = false
                    /* Remove used itemIcon from item array and Scene */
                    gameSceneEasy.resetDisplayItem(index: gameSceneEasy.usingItemIndex)
                    
                    gameSceneEasy.activeHero.positionX = gridX
                    gameSceneEasy.activeHero.positionY = gridY
                    gameSceneEasy.activeHero.position = CGPoint(x: self.position.x+CGFloat((Double(gridX)+0.5)*cellWidth), y: self.position.y+CGFloat((Double(gridY)+0.5)*cellHeight))
                    
                    /* Reset hero animation to back */
                    gameSceneEasy.activeHero.resetHero()
                    
                    /* All hero turn end */
                    if gameSceneEasy.numOfTurnDoneHero >= gameSceneEasy.heroArray.count-1 {
                        gameSceneEasy.playerTurnState = .TurnEnd
                    } else {
                        gameSceneEasy.numOfTurnDoneHero += 1
                        gameSceneEasy.activeHero = gameSceneEasy.heroArray[gameSceneEasy.numOfTurnDoneHero]
                    }
                    
                }
                
                /* Touch ends enemy for magic sword */
            } else if nodeAtPoint.name == "enemy" {
                let enemy = nodeAtPoint as! EnemyEasy
                
                guard gameSceneEasy.magicSwordAttackDone else { return }
                guard gameSceneEasy.usingMagicSword else { return }
                
                if enemy.vECategory == vEindex {
                    /* Effect */
                    gameSceneEasy.setMagicSowrdEffectToEnemy(enemy: enemy)
                    
                    /* Enemy */
                    let waitEffectRemove = SKAction.wait(forDuration: 2.5)
                    let removeEnemy = SKAction.run({
                        enemy.removeFromParent()
                        gameSceneEasy.removeMagicSowrdEffectToEnemy()
                    })
                    let seqEnemy = SKAction.sequence([waitEffectRemove, removeEnemy])
                    self.run(seqEnemy)
                    
                    enemy.aliveFlag = false
                    /* Count defeated enemy */
                    gameSceneEasy.totalNumOfEnemy -= 1
                    
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
                    gameSceneEasy.activeHero.resetHero()
                    /* Remove effect */
                    gameSceneEasy.removeMagicSowrdEffect()
                    /* Back to MoveState */
                    gameSceneEasy.playerTurnState = .MoveState
                    /* Reset item type */
                    gameSceneEasy.itemType = .None
                    gameSceneEasy.magicSwordAttackDone = false
                    gameSceneEasy.usingMagicSword = false
                    /* Reset color of enemy */
                    for enemy in self.enemyArray {
                        if enemy.enemyLife > 0 {
                            enemy.colorizeEnemy(color: UIColor.green)
                        } else {
                            enemy.resetColorizeEnemy()
                        }
                    }
                    /* Remove variable expression display */
                    gameSceneEasy.activeHero.removeMagicSwordVE()
                    /* Reset flag */
                    castEnemyDone = false
                }
                
            /* Touch ends on anywhere except active area or enemy */
            } else {
                
                /* Make sure to be invalid when using catpult */
                guard gameSceneEasy.setCatapultDoneFlag == false else { return }
                guard gameSceneEasy.selectCatapultDoneFlag == false else { return }
                
                /* Reset hero */
                gameSceneEasy.activeHero.resetHero()
                /* Remove effect */
                gameSceneEasy.removeMagicSowrdEffect()
                
                gameSceneEasy.playerTurnState = .MoveState
                /* Set item area cover */
                gameSceneEasy.itemAreaCover.isHidden = false
                
                /* Reset item type */
                gameSceneEasy.itemType = .None
                gameSceneEasy.magicSwordAttackDone = false
                
                /* Reset color of enemy */
                if gameSceneEasy.usingMagicSword {
                    gameSceneEasy.usingMagicSword = false
                    for enemy in self.enemyArray {
                        if enemy.enemyLife > 0 {
                            enemy.colorizeEnemy(color: UIColor.green)
                        } else {
                            enemy.resetColorizeEnemy()
                        }
                    }
                }
                
                /* Remove variable expression display */
                gameSceneEasy.activeHero.removeMagicSwordVE()
                /* Reset flag */
                castEnemyDone = false
                
                /* Remove active area */
                gameSceneEasy.gridNode.resetSquareArray(color: "purple")
                gameSceneEasy.gridNode.resetSquareArray(color: "red")
                gameSceneEasy.resetActiveAreaForCatapult()
                
                /* Remove triangle except the one of selected catapult */
                for catapult in gameSceneEasy.setCatapultArray {
                    if let node = catapult.childNode(withName: "pointingCatapult") {
                        node.removeFromParent()
                    }
                }
                
                /* Remove input board for cane */
                gameSceneEasy.inputBoardForCane.isHidden = true
            }
        } else if gameSceneEasy.playerTurnState == .ShowingCard {
            gameSceneEasy.cardArray[0].removeFromParent()
            gameSceneEasy.cardArray.removeFirst()
            gameSceneEasy.heroArray = gameSceneEasy.heroArray.filter({ $0.aliveFlag == true })
            if gameSceneEasy.heroArray.count > 0{
                gameSceneEasy.playerTurnState = .TurnEnd
            } else {
                gameSceneEasy.gameState = .GameOver
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
    func rePosEnemy(enemy: EnemyEasy) {
        enemy.position = CGPoint(x: CGFloat((Double(enemy.positionX)+0.5)*self.cellWidth), y: CGFloat((Double(enemy.positionY)+0.5)*self.cellHeight))
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = 1
    }
    
    /*== Set effect when enemy destroyed ==*/
    func enemyDestroyEffect(enemy: EnemyEasy) {
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
    func addInitialEnemyAtGrid(enemyPosArray: [[Int]], enemyPosArrayForUnS: [[Int]], sVariableExpressionSource: [[Int]], uVariableExpressionSource: [[Int]]) {
        /* Add a new enemy at grid position*/
        
        for posArray in enemyPosArray {
            /* New enemy object */
            let enemy = EnemyEasy(variableExpressionSource: sVariableExpressionSource, forEdu: false)
                
            /* Set enemy speed according to stage level */
            if GameSceneEasy.stageLevel < 1 {
                enemy.moveSpeed = 0.2
                enemy.punchSpeed = 0.0025
                enemy.singleTurnDuration = 1.0
            }
                
            /* set adding enemy movement */
            setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1])
        }
            
        for posArray in enemyPosArrayForUnS {
            /* New enemy object */
            let enemy = EnemyEasy(variableExpressionSource: uVariableExpressionSource, forEdu: false)
                
            /* Set enemy speed according to stage level */
            if GameSceneEasy.stageLevel < 1 {
                enemy.moveSpeed = 0.2
                enemy.punchSpeed = 0.0025
                enemy.singleTurnDuration = 1.0
            }
            
            if GameSceneEasy.stageLevel > 6 {
                enemy.enemyLife = 1
                enemy.colorizeEnemy(color: UIColor.green)
            }
                
            /* set adding enemy movement */
            setAddEnemyMovement(enemy: enemy, posX: posArray[0], posY: posArray[1])
        }
    }
    
    /* Add enemy in the middle of game */
    func addEnemyAtGrid(_ numberOfEnemy: Int, variableExpressionSource: [[Int]], yRange: Int) {
        /* Add a new enemy at grid position*/
        
        for _ in 1...numberOfEnemy {
            /* New enemy object */
            let enemy = EnemyEasy(variableExpressionSource: variableExpressionSource, forEdu: false)
            
            /* x position */
            let randX = Int(arc4random_uniform(UInt32(startPosArray.count)))
            let startPositionX = startPosArray[randX]
            /* Make sure not to overlap enemies */
            startPosArray.remove(at: randX)
            
            /* y position */
            let randY = Int(arc4random_uniform(UInt32(yRange)))
            
            /* set adding enemy movement */
            setAddEnemyMovement(enemy: enemy, posX: startPositionX, posY: 11-randY)
        }
    }
    
    /* Add enemy for education */
    func addEnemyForEdu(sVariableExpressionSource: [[Int]], uVariableExpressionSource: [[Int]], numOfOrigin: Int) {
        
        DAUtility.getRandomNumbers(total: sVariableExpressionSource.count, times: numOfOrigin) { (nums) in
            for i in nums {
                /* Select origin Enemy */
                let variableExpression = sVariableExpressionSource[i]
                /* Select branch Enemy */
                let branchGroup = uVariableExpressionSource.filter({ $0.last! == variableExpression.last! })
                
                /* New enemy object */
                let enemyOrigin = EnemyEasy(variableExpressionSource: [variableExpression], forEdu: true)
                let enemyBranch = EnemyEasy(variableExpressionSource: branchGroup, forEdu: true)
                
                EnemyAddController.setSUEnemyPair(origin: enemyOrigin, branch: enemyBranch, gridNode: self)
                
                /* Set punch inteval */
                let randPI = Int(arc4random_uniform(100))
                
                /* punchInterval is 1 with 40% */
                if randPI < 45 {
                    enemyOrigin.punchInterval = 1
                    enemyOrigin.punchIntervalForCount = 1
                    enemyOrigin.setPunchIntervalLabel()
                    enemyBranch.punchInterval = 1
                    enemyBranch.punchIntervalForCount = 1
                    enemyBranch.setPunchIntervalLabel()
                    
                    /* punchInterval is 2 with 40% */
                } else if randPI < 90 {
                    enemyOrigin.punchInterval = 2
                    enemyOrigin.punchIntervalForCount = 2
                    enemyOrigin.setPunchIntervalLabel()
                    enemyBranch.punchInterval = 2
                    enemyBranch.punchIntervalForCount = 2
                    enemyBranch.setPunchIntervalLabel()
                    
                    /* punchInterval is 0 with 20% */
                } else {
                    enemyOrigin.punchInterval = 0
                    enemyOrigin.punchIntervalForCount = 0
                    enemyOrigin.setPunchIntervalLabel()
                    enemyBranch.punchInterval = 0
                    enemyBranch.punchIntervalForCount = 0
                    enemyBranch.setPunchIntervalLabel()
                }
                
                /* x position */
                /* First enemy set will be placed left half part */
                if i == 0 {
                    let randX = Int(arc4random_uniform(3))
                    let startPositionX = self.startPosArray[randX]
                    /* set adding enemy movement */
                    self.setAddEnemyMovement(enemy: enemyOrigin, posX: startPositionX, posY: 11)
                    self.setAddEnemyMovement(enemy: enemyBranch, posX: startPositionX+1, posY: 11)
                    /* First enemy set will be placed right half part */
                } else {
                    let randX = Int(arc4random_uniform(3))
                    let startPositionX = self.startPosArray[randX+4]
                    /* set adding enemy movement */
                    self.setAddEnemyMovement(enemy: enemyOrigin, posX: startPositionX, posY: 11)
                    self.setAddEnemyMovement(enemy: enemyBranch, posX: startPositionX+1, posY: 11)
                }
            }
        }
    }
    
    /* Make common stuff for adding enemy */
    func setAddEnemyMovement(enemy: EnemyEasy, posX: Int, posY: Int) {
        /* Get gameSceneEasy */
        let gameSceneEasy = self.parent as! GameSceneEasy
        
        /* Store variable expression as origin */
        enemy.originVariableExpression = enemy.variableExpressionString
        
        /* Set direction of enemy */
        enemy.direction = .front
        enemy.setMovingAnimation()
        
        /* Set position on screen */
        
        /* Keep track enemy position */
        enemy.positionX = posX
        enemy.positionY = posY
        
        /* Calculate gap between top of grid and gameSceneEasy */
        let gridPosition = CGPoint(x: (Double(posX)+0.5)*cellWidth, y: Double(gameSceneEasy.topGap+self.size.height))
        enemy.position = gridPosition
        
        /* Set enemy's move distance when showing up */
        let startMoveDistance = Double(gameSceneEasy.topGap)+self.cellHeight*(Double(11-posY)+0.5)
        
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
        /* Get gameSceneEasy */
        let gameSceneEasy = self.parent as! GameSceneEasy
        
        /* Reset display path */
        resetMovePath()
        
        /* Calculate difference between beganPos and destination */
        let diffX = dest[0] - start[0]
        let diffY = dest[1] - start[1]
        
        switch gameSceneEasy.activeHero.moveDirection {
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
        let gameSceneEasy = self.parent as! GameSceneEasy
        switch gameSceneEasy.activeHero.direction {
        case .front:
            if gameSceneEasy.activeHero.positionY < 2 {
                return ([gameSceneEasy.activeHero.positionX, 0], [gameSceneEasy.activeHero.positionX, 0])
            } else {
                return ([gameSceneEasy.activeHero.positionX, gameSceneEasy.activeHero.positionY-1], [gameSceneEasy.activeHero.positionX, gameSceneEasy.activeHero.positionY-2])
            }
        case .back:
            if gameSceneEasy.activeHero.positionY > 9 {
                return ([gameSceneEasy.activeHero.positionX, 11], [gameSceneEasy.activeHero.positionX, 11])
            } else {
                return ([gameSceneEasy.activeHero.positionX, gameSceneEasy.activeHero.positionY+1], [gameSceneEasy.activeHero.positionX, gameSceneEasy.activeHero.positionY+2])
            }
        case .left:
            if gameSceneEasy.activeHero.positionX < 2 {
                return ([0, gameSceneEasy.activeHero.positionY], [0, gameSceneEasy.activeHero.positionY])
            } else {
                return ([gameSceneEasy.activeHero.positionX-1, gameSceneEasy.activeHero.positionY], [gameSceneEasy.activeHero.positionX-2, gameSceneEasy.activeHero.positionY])
            }
        case .right:
            if gameSceneEasy.activeHero.positionX > 6 {
                return ([8, gameSceneEasy.activeHero.positionY], [8, gameSceneEasy.activeHero.positionY])
            } else {
                return ([gameSceneEasy.activeHero.positionX+1, gameSceneEasy.activeHero.positionY], [gameSceneEasy.activeHero.positionX+2, gameSceneEasy.activeHero.positionY])
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

