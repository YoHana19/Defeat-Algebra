//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

/* Index of categryBitMask of game objects */
/*
 1: Hero
 2: Enemy
 4: castleNode
 8: EnemyArm
 16: EnemyFist
 32: Boots
 64: Mine
 128:
 1024:
*/

import SpriteKit
import GameplayKit

enum GameSceneState {
    case AddEnemy, PlayerTurn, EnemyTurn, GridFlashing, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case ItemOn, SelectAction, SelectDirection, UsingItem, TurnEnd
}

enum ItemType {
    case Mine
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var castleNode: SKSpriteNode!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    
    /* Game buttons */
    var buttonAttack: MSButtonNode!
    var buttonMove: MSButtonNode!
    var buttonBack: MSButtonNode!
    var buttonRetry: MSButtonNode!
    var buttonAttackDo: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .ItemOn
    var itemType: ItemType = .Mine
    var gameLevel: Int = 0
    var stageLevel: Int = 0
    
    /* Resource of variable expression */
    let variableExpressionSource = [[[1, 0]],
                                    [[1, 0], [1, 1], [1, 2]],
                                    [[1,0],[1,1],[1,2],[1,3],[1,4],[2,0],[2,1],[2,2]]
                                    ]
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var playerTurnDoneFlag = false
    var enemyTurnDoneFlag = false
    var selectDirectionDone = false
    var punchDoneFlag = false
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    
    /* Player Control */
    var beganPos:CGPoint!
    
    /* Add enemy */
    var numOfAddEnemy = 3
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 10 /* Add enemy after enemy move 10 times */
    
    /* Flash grid */
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    
    /* Castle life */
    var lifeLabel: SKLabelNode!
    var life: Int = 5 {
        didSet {
            lifeLabel.text = String(life)
        }
    }
    
    override func didMove(to view: SKView) {
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        
        /* Connect game buttons */
        buttonAttack = childNode(withName: "buttonAttack") as! MSButtonNode
        buttonMove = childNode(withName: "buttonMove") as! MSButtonNode
        buttonBack = childNode(withName: "buttonBack") as! MSButtonNode
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonAttackDo = childNode(withName: "buttonAttackDo") as! MSButtonNode
        buttonAttack.state = .msButtonNodeStateHidden
        buttonMove.state = .msButtonNodeStateHidden
        buttonBack.state = .msButtonNodeStateHidden
        buttonRetry.state = .msButtonNodeStateHidden
        buttonAttackDo.state = .msButtonNodeStateHidden
        
        buttonAttack.selectedHandler = {
            self.hero.heroState = .Attack
            self.hero.removeAllActions()
            self.gridNode.showAttackArea()
            self.playerTurnState = .SelectDirection
            self.buttonAttackDo.state = .msButtonNodeStateActive
        }
        
        buttonMove.selectedHandler = {
            self.hero.heroState = .Move
            self.gridNode.showMoveArea(posX: self.hero.positionX, posY: self.hero.positionY, moveLevel: self.hero.moveLevel)
            self.playerTurnState = .SelectDirection
        }
        
        buttonBack.selectedHandler = {
            self.gridNode.resetSquareArray()
            self.buttonAttackDo.state = .msButtonNodeStateHidden
            self.playerTurnState = .SelectAction
        }
        
        buttonRetry.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        buttonAttackDo.selectedHandler = {
            /* Remove attack area square */
            self.gridNode.resetSquareArray()
            
            /* Do attack animation */
            self.hero.setSwordAnimation()
            
            /* Hit enemy! */
            for pos in self.gridNode.attackAreaPos {
                if self.gridNode.positionEnemyAtGrid[pos[0]][pos[1]] {
                    let waitAni = SKAction.wait(forDuration: 1.0)
                    let removeEnemy = SKAction.run({
                        /* Look for the enemy to destroy */
                        for enemy in self.gridNode.enemyArray {
                            if enemy.positionX == pos[0] && enemy.positionY == pos[1] {
                                enemy.aliveFlag = false
                                enemy.removeFromParent()
                            }
                        }
                    })
                    let seq = SKAction.sequence([waitAni, removeEnemy])
                    self.run(seq)
                }
            }
            
            /* Move next state */
            self.selectDirectionDone = true
            let wait = SKAction.wait(forDuration: 2.0)
            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
        }
        
        
        /* Game Over label */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Score label */
        lifeLabel = childNode(withName: "lifeLabel") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) 
        
        
        /* Stage Level 1 */
        if stageLevel == 0 {
            /* Set game state */
            gameState = .GridFlashing
            
            /* Set hero */
            hero = Hero()
            hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
            addChild(hero)
            
            /* Set enemy */
            
            
            /* Set boots */
            let boots = Boots()
            self.gridNode.addObjectAtGrid(object: boots, x: 2, y: 3)
            
            /* Set mine */
            let mine = Mine()
            self.gridNode.addObjectAtGrid(object: mine, x: 6, y: 3)
            
        } else {
            
            /* Set game state */
            gameState = .AddEnemy
            
            /* Set hero */
            hero = Hero()
            hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
            addChild(hero)
            
            /* Set boots */
            let boots = Boots()
            self.gridNode.addObjectAtGrid(object: boots, x: 2, y: 3)
            
            /* Set mine */
            let mine = Mine()
            self.gridNode.addObjectAtGrid(object: mine, x: 6, y: 3)
        }
        

    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            /* Make sure to call addEnemy once */
            if addEnemyDoneFlag == false {
                addEnemyDoneFlag = true
                
                /* Add enemy */
                let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSource[self.gameLevel]) })
                let wait = SKAction.wait(forDuration: 2.0)
                let moveState = SKAction.run({
                    /* Create enemy startPosArray */
                    self.gridNode.resetEnemyPositon()
                    self.gameState = .GridFlashing
                })
                let seq = SKAction.sequence([addEnemy, wait, moveState])
                self.run(seq)
            }
            break;
        case .PlayerTurn:
            switch playerTurnState {
            case .ItemOn:
                /* mine */
                if self.gridNode.mineArray.count > 0 {
                    for minePos in self.gridNode.mineArray {
                        /* Look for the enemy to destroy  if any */
                        for (i, enemy) in self.gridNode.enemyArray.enumerated() {
                            /* Hit enemy! */
                            if enemy.positionX == minePos[0] && enemy.positionY == minePos[1] {
                                enemy.aliveFlag = false
                                enemy.removeFromParent()
                            }
                            if i == self.gridNode.enemyArray.count-1 {
                                /* Reset mine array */
                                self.gridNode.mineArray.removeAll()
                            }
                        }
                        if let node = self.gridNode.childNode(withName: "mine") {
                            node.removeFromParent()
                        }
                    }
                    playerTurnState = .SelectAction
                } else {
                    playerTurnState = .SelectAction
                }
                break;
            case .SelectAction:
                
                buttonAttack.state = .msButtonNodeStateActive
                buttonMove.state = .msButtonNodeStateActive
                buttonBack.state = .msButtonNodeStateHidden
//                print("player position (\(self.hero.positionX), \(self.hero.positionY))")
                
                break;
            case .SelectDirection:
                buttonAttack.state = .msButtonNodeStateHidden
                buttonMove.state = .msButtonNodeStateHidden
                
                if selectDirectionDone {
                    buttonBack.state = .msButtonNodeStateHidden
                    self.buttonAttackDo.state = .msButtonNodeStateHidden
                } else {
                    buttonBack.state = .msButtonNodeStateActive
                }
                
                /* In case move */
                if hero.heroState == .Move {
                    
                /* In case attack */
                } else if hero.heroState == .Attack {
                    
                }
                
                break;
            case .UsingItem:
                switch itemType {
                case .Mine:
                    self.gridNode.showMineSettingArea()
                    break;
                }
                break;
            case .TurnEnd:
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                selectDirectionDone = false
                
                /* Reset hero animation to back */
                hero.resetHero()
                
                /* Remove dead enemy from enemyArray */
                self.gridNode.enemyArray = self.gridNode.enemyArray.filter({ $0.aliveFlag == true })
                
                if gridNode.enemyArray.count > 0 {
                    gridNode.enemyArray[0].myTurnFlag = true
                }
                gameState = .EnemyTurn
                break;
            }
            break;
        case .EnemyTurn:
            /* Reset Flags */
            addEnemyDoneFlag = false
            playerTurnDoneFlag = false
            flashGridDoneFlag = false
                
            if enemyTurnDoneFlag == false {
                
                /* Reset enemy position */
                gridNode.resetEnemyPositon()
                
                for enemy in self.gridNode.enemyArray {
                    /* Enemy reach to castle */
                    if enemy.reachCastleFlag {
                        enemy.punchToCastle()
                    /* Enemy move */
                    } else if enemy.punchIntervalForCount > 0 {
                        enemy.enemyMove()
                    /* Enemy punch */
                    } else {
                        enemy.punchAndMove()
                    }
                }
                
                /* If life is 0, GameOver */
                if self.life < 1 {
                    gameState = .GameOver
                }
            }
            
            /* All enemies finish their actions */
            if gridNode.numOfTurnEndEnemy >= gridNode.enemyArray.count {
                
                enemyTurnDoneFlag = true
                /* Reset all stuffs */
                gridNode.turnIndex = 0
                gridNode.numOfTurnEndEnemy = 0
                for enemy in gridNode.enemyArray {
                    enemy.turnDoneFlag = false
                    enemy.myTurnFlag = false
                }
                
                /* Update enemy position */
                gridNode.updateEnemyPositon()
                
                /* Check if enemy reach to castle */
                for enemy in self.gridNode.enemyArray {
                    if enemy.positionY == 0 {
                        enemy.reachCastleFlag = true
                    }
                }
                
//                gameState = .PlayerTurn
                gameState = .GridFlashing
                playerTurnState = .ItemOn
            }
            break;
        case .GridFlashing:
            /* Make sure to call once */
            if flashGridDoneFlag == false {
                flashGridDoneFlag = true
                
                /* Make grid flash */
                let numOfFlash = self.gridNode.flashGrid(labelNode: valueOfX)
                
                /* Calculate each enemy's variable expression */
                for enemy in self.gridNode.enemyArray {
                    enemy.calculatePunchLength(value: numOfFlash)
                }
                
                let wait = SKAction.wait(forDuration: 4.0)
                let moveState = SKAction.run({ self.gameState = .PlayerTurn })
                let seq = SKAction.sequence([wait, moveState])
                self.run(seq)
            }
            break;
        case .GameOver:
            gameOverLabel.isHidden = false
            buttonRetry.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Select direction to attack */
        if playerTurnState == .SelectDirection {
            let touch = touches.first!
            beganPos = touch.location(in: self)
        /* Select item */
        } else if playerTurnState == .SelectAction {
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            /* Use mine */
            if nodeAtPoint.name == "mineIcon" {
                playerTurnState = .UsingItem
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Swipe is available only at the time of selectDirection */
        guard playerTurnState == .SelectDirection else { return }
        
        /* Swipe is available only when heroState is Attack */
        guard self.hero.heroState == .Attack else { return }
        
        let touch = touches.first!
        let endedPos = touch.location(in: self)
        let diffPos = CGPoint(x: endedPos.x - beganPos.x, y: endedPos.y - beganPos.y)
        
        /* Show attack area */
        self.gridNode.showAttackAreaBySwipe(diffPos)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Make sure to stop if game over */
        guard gameState != .GameOver else { return }
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Player hit something */
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            
            /* In player turn, hero doesn't hit enemy */
            if self.gameState == .PlayerTurn {
                /* Get boots */
                if contactA.categoryBitMask == 32 || contactB.categoryBitMask == 32 {
                    if contactA.categoryBitMask == 32 {
                        contactA.node?.removeFromParent()
                        self.hero.moveLevel += 1
                    } else if contactB.categoryBitMask == 32 {
                        contactB.node?.removeFromParent()
                        self.hero.moveLevel += 1
                    }
                /* Get mine */
                } else if contactA.categoryBitMask == 64 || contactB.categoryBitMask == 64 {
                        if contactA.categoryBitMask == 64 {
                            contactA.node?.removeFromParent()
                            displayitem(name: "mineIcon")
                        } else if contactB.categoryBitMask == 64 {
                            contactB.node?.removeFromParent()
                            displayitem(name: "mineIcon")
                        }
                }
            } else if self.gameState == .EnemyTurn {
                if contactA.categoryBitMask == 1 {
                    //                print("\(contactB.categoryBitMask)")
                    contactA.node?.removeFromParent()
                } else if contactB.categoryBitMask == 1 {
                    //                print("\(contactA.categoryBitMask)")
                    contactB.node?.removeFromParent()
                }
                self.gameState = .GameOver
            }
        }
    
        /* Enemy's arm or fist hits castle wall */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            
            if contactA.categoryBitMask == 4 {
                /* Arm hits wall */
                if contactB.categoryBitMask == 8 {
                    /* Get enemy arm */
                    let nodeB = contactB.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeB.removeAllActions()
                    
                /* Fist hits wall */
                } else if contactB.categoryBitMask == 16 {
                    /* Get enemy fist */
                    let nodeB = contactB.node as! EnemyFist
                    
                    /* Stop fist */
                    nodeB.removeAllActions()
                    
                }
            }
    
            if contactB.categoryBitMask == 4 {
                /* In case arm hit wall */
                if contactA.categoryBitMask == 8 {
                    /* Get enemy arm */
                    let nodeA = contactA.node as! EnemyArm
                    
                    /* Stop extending arm */
                    nodeA.removeAllActions()
                    
                /* In case fist hit wall */
                } else if contactA.categoryBitMask == 16 {
                    /* Get enemy fist */
                    let nodeA = contactA.node as! EnemyFist
                    
                    /* Stop of fist */
                    nodeA.removeAllActions()
                    
                }
            }
        }
    }

    
//    func heroActionBySwipe(_ diffPos: CGPoint) {
//        
//        var degree:Int
//        
//        if diffPos.x != 0 {
//            /* horizontal move */
//            let radian = atan(diffPos.y/fabs(diffPos.x)) // calculate radian by arctan
//            degree = Int(radian * CGFloat(180 * M_1_PI)) // convert radian to degree
//        } else {
//            /* just touch */
//            if diffPos.y == 0 {
//                degree = 1000
//            } else {
//                /* vertical move */
//                degree = diffPos.y < 0 ? -90:90;
//            }
//        }
//        
//        switch degree {
//        case -90 ..< -45:
//            hero.direction = .front
//            if hero.heroState == .Move {
//                self.hero.heroMove()
//            } else if hero.heroState == .Attack {
//                /* Hit enemy! */
//                if self.gridNode.positionEnemyAtGrid[self.hero.positionX][self.hero.positionY-1] {
//                    let attackAni = SKAction.run({ self.hero.setSwordAnimation() })
//                    let wait = SKAction.wait(forDuration: 1.0)
//                    let removeEnemy = SKAction.run({
//                        /* Look for the enemy to destroy */
//                        for enemy in self.gridNode.enemyArray {
//                            if enemy.positionX == self.hero.positionX && enemy.positionY == self.hero.positionY-1 {
//                                enemy.aliveFlag = false
//                                enemy.removeFromParent()
//                            }
//                        }
//                    })
//                    let seq = SKAction.sequence([attackAni, wait, removeEnemy])
//                    self.run(seq)
//                /* Miss! */
//                } else {
//                    self.hero.setSwordAnimation()
//                }
//            }
//
//            selectDirectionDone = true
//            let wait = SKAction.wait(forDuration: 2.0)
//            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
//            let seq = SKAction.sequence([wait, moveState])
//            self.run(seq)
//        case -45 ..< 45:
//            if diffPos.x >= 0 {
//                hero.direction = .right
//                if hero.heroState == .Move {
//                    self.hero.heroMove()
//                } else if hero.heroState == .Attack {
//                    /* Hit enemy! */
//                    if self.gridNode.positionEnemyAtGrid[self.hero.positionX+1][self.hero.positionY] {
//                        let attackAni = SKAction.run({ self.hero.setSwordAnimation() })
//                        let wait = SKAction.wait(forDuration: 1.0)
//                        let removeEnemy = SKAction.run({
//                            /* Look for the enemy to destroy */
//                            for enemy in self.gridNode.enemyArray {
//                                if enemy.positionX == self.hero.positionX+1 && enemy.positionY == self.hero.positionY {
//                                    enemy.aliveFlag = false
//                                    enemy.removeFromParent()
//                                }
//                            }
//                        })
//                        let seq = SKAction.sequence([attackAni, wait, removeEnemy])
//                        self.run(seq)
//                        /* Miss! */
//                    } else {
//                        self.hero.setSwordAnimation()
//                    }
//                }
//                
//            } else {
//                hero.direction = .left
//                if hero.heroState == .Move {
//                    self.hero.heroMove()
//                } else if hero.heroState == .Attack {
//                    /* Hit enemy! */
//                    if self.gridNode.positionEnemyAtGrid[self.hero.positionX-1][self.hero.positionY] {
//                        let attackAni = SKAction.run({ self.hero.setSwordAnimation() })
//                        let wait = SKAction.wait(forDuration: 1.0)
//                        let removeEnemy = SKAction.run({
//                            /* Look for the enemy to destroy */
//                            for enemy in self.gridNode.enemyArray {
//                                if enemy.positionX == self.hero.positionX-1 && enemy.positionY == self.hero.positionY {
//                                    enemy.aliveFlag = false
//                                    enemy.removeFromParent()
//                                }
//                            }
//                        })
//                        let seq = SKAction.sequence([attackAni, wait, removeEnemy])
//                        self.run(seq)
//                        /* Miss! */
//                    } else {
//                        self.hero.setSwordAnimation()
//                    }
//                }
//            }
//            selectDirectionDone = true
//            let wait = SKAction.wait(forDuration: 2.0)
//            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
//            let seq = SKAction.sequence([wait, moveState])
//            self.run(seq)
//        case 45 ... 90:
//            hero.direction = .back
//            if hero.heroState == .Move {
//                self.hero.heroMove()
//            } else if hero.heroState == .Attack {
//                /* Hit enemy! */
//                if self.gridNode.positionEnemyAtGrid[self.hero.positionX][self.hero.positionY+1] {
//                    let attackAni = SKAction.run({ self.hero.setSwordAnimation() })
//                    let wait = SKAction.wait(forDuration: 1.0)
//                    let removeEnemy = SKAction.run({
//                        /* Look for the enemy to destroy */
//                        for enemy in self.gridNode.enemyArray {
//                            if enemy.positionX == self.hero.positionX && enemy.positionY == self.hero.positionY+1 {
//                                enemy.aliveFlag = false
//                                enemy.removeFromParent()
//                            }
//                        }
//                    })
//                    let seq = SKAction.sequence([attackAni, wait, removeEnemy])
//                    self.run(seq)
//                    /* Miss! */
//                } else {
//                    self.hero.setSwordAnimation()
//                }
//            }
//            selectDirectionDone = true
//            let wait = SKAction.wait(forDuration: 2.0)
//            let moveState = SKAction.run({ self.playerTurnState = .TurnEnd })
//            let seq = SKAction.sequence([wait, moveState])
//            self.run(seq)
//        default:
//            /* Stop movement */
//            hero.setTexture()
//            break;
//        }
//        
//    }
    
    /* Add enemy in fixed interval */
    func addEnemy() {
        /* Time to add enemy */
        if countTurnForAddEnemy > addInterval {
            
            /* Stop all enemy's movement */
            for enemy in self.gridNode.enemyArray {
                enemy.removeAllActions()
                enemy.setStandingtexture()
            }
            
            /* Make sure to stop all enemy before move to addEnemy state */
            let wait = SKAction.wait(forDuration: 1.0)
            let moveState = SKAction.run({ self.gameState = .AddEnemy })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
            
        }
    }
    
    /* Make grid flash in fixed interval */
    func flashGrid() {
        /* Time to flash grid */
        if countTurnForFlashGrid > flashInterval {
            
            /* Stop all enemy's movement */
            for enemy in self.gridNode.enemyArray {
                enemy.removeAllActions()
                enemy.setStandingtexture()
            }
            
            /* Make sure to stop all enemy before move to GridFlashing state */
            let wait = SKAction.wait(forDuration: 1.0)
            let moveState = SKAction.run({ self.gameState = .GridFlashing })
            let seq = SKAction.sequence([wait, moveState])
            self.run(seq)
            
        }
    }
    
    /* Create item to display */
    func displayitem(name: String) {
        let item = SKSpriteNode(imageNamed: name)
        item.position = CGPoint(x: 50, y: 50)
        item.zPosition = 2
        item.name = name
        self.itemArray.append(item)
        addChild(item)
    }
    
        
}
