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
    var activeHero = Hero()
    var castleNode: SKSpriteNode!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    
    /* Game buttons */
    var buttonAttack: MSButtonNode!
    var buttonItem: MSButtonNode!
    var buttonRetry: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let turnEndWait: TimeInterval = 1.0
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .ItemOn
    var itemType: ItemType = .Mine
    var gameLevel: Int = 0
    var stageLevel: Int = 0
    var attackType: Int = 0
    
    /* Resource of variable expression */
    let variableExpressionSource = [[[1, 0]],
                                    [[1, 0], [1, 1], [1, 2]],
                                    [[1,0],[1,1],[1,2],[1,3],[1,4],[2,0],[2,1],[2,2]]
                                    ]
    
    /* Game flags */
    var addEnemyDoneFlag = false
    var playerTurnDoneFlag = false
    var enemyTurnDoneFlag = false
    
    var punchDoneFlag = false
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    var initialAddEnemyFlag = true
    
    /* Player Control */
    var beganPos:CGPoint!
    var heroArray = [Hero]()
    
    /* Add enemy */
    var initialEnemyPosArray = [[Int]]()
    var numOfAddEnemy = 3
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 10 /* Add enemy after enemy move 10 times */
    
    /* Flash grid */
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    
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
        buttonItem = childNode(withName: "buttonItem") as! MSButtonNode
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonAttack.state = .msButtonNodeStateHidden
        buttonItem.state = .msButtonNodeStateHidden
        buttonRetry.state = .msButtonNodeStateHidden
        
        /* Attack button */
        buttonAttack.selectedHandler = {
            if self.activeHero.attackDoneFlag {
                return
            } else {
                self.gridNode.resetSquareArray(color: "blue")
                self.activeHero.heroState = .Attack
                self.gridNode.showAttackArea(posX: self.activeHero.positionX, posY: self.activeHero.positionY, attackType: self.attackType)
                self.playerTurnState = .SelectDirection
            }
        }
        
        /* Retry button */
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
            
        /* Set hero */
        hero = Hero()
        heroArray.append(hero)
        hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*3))
        addChild(hero)
        
        /* Set initial enemy position */
        if stageLevel == 0 {
            initialEnemyPosArray = [[1, 10], [4, 10], [7, 10], [2, 8], [6, 8]]
        } else {
            initialEnemyPosArray = [[1, 10], [4, 10], [7, 10]]
        }
        
        
        /* Set boots */
        let boots = Boots()
        self.gridNode.addObjectAtGrid(object: boots, x: 3, y: 3)
        let boots2 = Boots()
        self.gridNode.addObjectAtGrid(object: boots2, x: 7, y: 5)
        
        /* Set mine */
        let mine = Mine()
        self.gridNode.addObjectAtGrid(object: mine, x: 5, y: 3)
        let mine2 = Mine()
        self.gridNode.addObjectAtGrid(object: mine2, x: 1, y: 5)

    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
            /* Make sure to call addEnemy once */
            if addEnemyDoneFlag == false {
                addEnemyDoneFlag = true
                
                /* Initial add or add on the way */
                if initialAddEnemyFlag {
                    initialAddEnemyFlag = false
                    
                    /* Add enemy */
                    let addEnemy = SKAction.run({ self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSource[self.gameLevel]) })
                    let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                    let moveState = SKAction.run({
                        /* Create enemy startPosArray */
                        self.gridNode.resetEnemyPositon()
                        self.gameState = .GridFlashing
                    })
                    let seq = SKAction.sequence([addEnemy, wait, moveState])
                    self.run(seq)
                    
                } else {
                    /* Add enemy */
                    let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSource[self.gameLevel]) })
                    let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                    let moveState = SKAction.run({
                        /* Create enemy startPosArray */
                        self.gridNode.resetEnemyPositon()
                        self.gameState = .GridFlashing
                    })
                    let seq = SKAction.sequence([addEnemy, wait, moveState])
                    self.run(seq)
                }
            }
            break;
        case .PlayerTurn:
            switch playerTurnState {
            case .ItemOn:
                /* Activate initial hero */
                activeHero = heroArray[0]
                
                /* mine */
                if self.gridNode.mineSetArray.count > 0 {
                    for (i, minePos) in self.gridNode.mineSetPosArray.enumerated() {
                        /* Look for the enemy to destroy  if any */
                        for enemy in self.gridNode.enemyArray {
                            /* Hit enemy! */
                            if enemy.positionX == minePos[0] && enemy.positionY == minePos[1] {
                                enemy.aliveFlag = false
                                enemy.removeFromParent()
                            }
                        }
                        if i == self.gridNode.mineSetArray.count-1 {
                            /* Reset mine array */
                            self.gridNode.mineSetPosArray.removeAll()
                            for mine in self.gridNode.mineSetArray {
                                mine.removeFromParent()
                            }
                        }
                    }
                    playerTurnState = .SelectAction
                } else {
                    playerTurnState = .SelectAction
                }
                break;
            case .SelectAction:
                
                /* Display action buttons */
                buttonAttack.state = .msButtonNodeStateActive
                buttonItem.state = .msButtonNodeStateActive
                
                break;
            case .SelectDirection:
                /* Wait for player touch */
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
                for hero in heroArray {
                    hero.attackDoneFlag = false
                }
                
                /* Hide action buttons */
                buttonAttack.state = .msButtonNodeStateHidden
                buttonItem.state = .msButtonNodeStateHidden
                
                /* Reset hero animation to back */
                hero.resetHero()
                
                /* Reset position of display item */
                self.resetDisplayItem()
                
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
                
                let wait = SKAction.wait(forDuration: TimeInterval(self.gridNode.flashSpeed*Double(self.gridNode.numOfFlashUp)))
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
        
        if playerTurnState == .SelectAction {
            
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            
            /* Touch hero */
            if nodeAtPoint.name == "hero" {
                /* Set hero touched active */
                activeHero = nodeAtPoint as! Hero
                activeHero.heroState = .Move
                self.playerTurnState = .SelectDirection
                self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
            
            /* Select item */
            /* Use mine */
            } else if nodeAtPoint.name == "mineIcon" {
                /* Set mine using state */
                itemType = .Mine
                playerTurnState = .UsingItem
                
                /* Get index of game using */
                usingItemIndex = (Int(nodeAtPoint.position.x)-50)/90
            }
            
        /* If touch another item when selecting a item */
        } else if playerTurnState == .UsingItem {
            /* Reset active area */
            self.gridNode.resetSquareArray(color: "blue")
            
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            let nodeAtPoint = atPoint(location)     // Find the node at that location
            /* Use mine */
            if nodeAtPoint.name == "mineIcon" {
                /* Set mine using state */
                itemType = .Mine
                playerTurnState = .UsingItem
                
                /* Get index of game using */
                usingItemIndex = (Int(nodeAtPoint.position.x)-50)/90
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
    
    /* Create item icons to display when you get items */
    func displayitem(name: String) {
        let index = self.itemArray.count
        let item = SKSpriteNode(imageNamed: name)
        item.position = CGPoint(x: index*90+50, y: 50)
        item.zPosition = 2
        item.name = name
        self.itemArray.append(item)
        addChild(item)
    }
    
    /* Reset position of item when use any */
    func resetDisplayItem() {
        for (i, item) in itemArray.enumerated() {
            item.position = CGPoint(x: i*90+50, y: 50)
        }
    }
    
        
}
