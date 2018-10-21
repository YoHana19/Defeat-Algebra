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
    var enemyArray = [Enemy]() {
        didSet {
            guard let gameScene = self.parent as? GameScene else { return }
            guard !gameScene.compAddEnemyFlag else { return }
            if enemyArray.count == 0 {
                gameScene.willFastForward = true
            }
        }
    }
    var enemySUPairDict = [Enemy: Enemy]()
    var positionEnemyAtGrid = [[Bool]]()
    var currentPositionOfEnemies = [[Int]]()
    var numOfTurnEndEnemy = 0
    var turnIndex = 0
    var startPosArray = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var touchingEnemyFlag = false
    var touchedEnemy = Enemy(variableExpressionSource: ["x"], forEdu: false) /* temporally */
    var editedEnemy  = Enemy(variableExpressionSource: ["x"], forEdu: false) /* temporally */
    
    /* Move & Attack & item setting area for player */
    var squareRedArray = [[SKShapeNode]]() /* for attack */
    var squareBlueArray = [[SKShapeNode]]() /* for move */
    var squarePurpleArray = [[SKShapeNode]]() /* for item */
    var squareYellowArray = [[SKShapeNode]]() /* for item */
    var squareGreenArray = [[SKShapeNode]]() /* for item */
    
    /*== Items ==*/
    var itemsOnField = [Item]()
    
    /* timeBomb */
    var timeBombSetPosArray = [[Int]]()
    var timeBombSetArray = [TimeBomb]()
    /* Wall */
    var wallSetArray = [Wall]()
    
    var touchedGridPos: (Int, Int) = (-1, -1)
    
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
            
            /*
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
            */
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
            /* Get gameScene */
            if let scenaioScene = self.parent as? ScenarioScene {
                switch scenaioScene.tutorialState {
                case .None:
                    break;
                case .Converstaion:
                    ScenarioController.nextLine()
                    break;
                case .Action:
                    let touch = touches.first!
                    let location = touch.location(in: self)
                    let nodeAtPoint = atPoint(location)     
                    ScenarioTouchController.controllerForGrid(location: location, nodeAtPoint: nodeAtPoint)
                }
                return
            } else if let gameScene = self.parent as? GameScene {
                switch gameScene.tutorialState {
                case .None:
                    break;
                case .Converstaion:
                    SpeakInGameController.nextLine()
                    break;
                case .Action:
                    if gameScene.playerTurnState == .UsingItem && gameScene.itemType == .Cannon && CannonTouchController.state == .Trying {
                        let touch = touches.first!
                        let location = touch.location(in: self)
                        let nodeAtPoint = atPoint(location)
                        guard let enemy = nodeAtPoint as? Enemy else { return }
                        if enemy.positionX == CannonController.selectedCannon.spotPos[0] {
                            if enemy.state == .Attack {
                                CannonTouchController.onEvent(cannon: nil, enemy: enemy)
                            }
                        }
                    }
                    break;
                }
                return
            }
        } else {
            /* Get gameScene */
            let gameScene = self.parent as! GameScene
            
            guard gameScene.pauseFlag == false else { return }
            guard gameScene.gameState == .PlayerTurn else { return }
            guard gameScene.timeBombConfirming == false else { return }
            
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
            
            if GameScene.stageLevel == 0 || GameScene.stageLevel == MainMenu.timeBombStartTurn+2 {
                let gridX = Int(Double(location.x) / cellWidth)
                let gridY = Int(Double(location.y) / cellHeight)
                touchedGridPos = (gridX, gridY)
            }
            
            guard TutorialController.userTouch(on: nodeAtPoint.name) else { return }
            
            if nodeAtPoint.name == "cannon" || nodeAtPoint.name == "cannonVE" {
                if let cannon = nodeAtPoint as? Cannon {
                    AllTouchController.cannonTouched(node: cannon)
                } else if let cannon = nodeAtPoint.parent as? Cannon {
                    AllTouchController.cannonTouched(node: cannon)
                }
            
            /* Touch point to move to */
            } else if gameScene.playerTurnState == .MoveState {
                
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
                
                } else if nodeAtPoint.name == "enemy" {
                    guard let enemy = nodeAtPoint as? Enemy else { return }
                    AllTouchController.enemyTouched(enemy: enemy)
                }
                
            /* Touch point to attack to */
            } else if gameScene.playerTurnState == .AttackState {
                
                /* Touch ends on active area */
                if nodeAtPoint.name == "activeArea" {
                    AttackTouchController.activeAreaTouched(touchedPoint: location)
                    
                } else if nodeAtPoint.name == "enemy" {
                    guard let enemy = nodeAtPoint as? Enemy else { return }
                    AllTouchController.enemyTouched(enemy: enemy)
                    
                /* If touch anywhere but activeArea, back to MoveState  */
                } else {
                    AttackTouchController.othersTouched()
                }
                
            /* Touch position to use item at */
            } else if gameScene.playerTurnState == .UsingItem {
                
                /* Touch ends on active area */
                if nodeAtPoint.name == "activeArea" {
                    
                    /* Caclulate grid array position */
                    let gridX = Int(Double(location.x) / cellWidth)
                    let gridY = Int(Double(location.y) / cellHeight)
                    
                    /* Use timeBomb */
                    if gameScene.itemType == .timeBomb {
                        ItemTouchController.AAForTimeBombTapped(gridX: gridX, gridY: gridY)
                    }
                } else if nodeAtPoint.name == "enemy" {
                    guard let enemy = nodeAtPoint as? Enemy else { return }
                    /* Touch ends enemy for eqRob */
                    if gameScene.itemType == .EqRob {
                        ItemTouchController.enemyTapped(enemy: enemy)
                    } else {
                        AllTouchController.enemyTouched(enemy: enemy)
                    }
                    
                /* Touch ends on anywhere except active area or enemy */
                } else {
                    ItemTouchController.othersTouched()
                }
            } 
        }
    }
    
    /*== Items ==*/
    
    /* Add a new object at grid position*/
    func addObjectAtGrid(object: SKSpriteNode, x: Int, y: Int) {
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: (Double(x)+0.5)*cellWidth, y: (Double(y)+0.5)*cellHeight)
        object.position = gridPosition
        addChild(object)
        if let item = object as? Item {
            item.spotPos = [x, y]
            itemsOnField.append(item)
        }
    }
}

