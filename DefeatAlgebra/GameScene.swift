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
 64: Mine:0
 128:
 1024:
*/

import SpriteKit
import GameplayKit

enum GameSceneState {
    case AddEnemy, PlayerTurn, EnemyTurn, GridFlashing, StageClear, GameOver
}

enum Direction: Int {
    case front = 1, back, left, right
}

enum PlayerTurnState {
    case ItemOn, MoveState, AttackState, UsingItem, TurnEnd
}

enum ItemType {
    case None, Mine
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var hero: Hero!
    var activeHero = Hero()
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var gameOverLabel: SKNode!
    var clearLabel: SKNode!
    var levelLabel: SKLabelNode!
    
    /* Game buttons */
    var buttonAttack: MSButtonNode!
    var buttonItem: MSButtonNode!
    var buttonRetry: MSButtonNode!
    var buttonNextLevel: MSButtonNode!
    var buttonToL1: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let turnEndWait: TimeInterval = 1.0
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .ItemOn
    var itemType: ItemType = .None
    var stageLevel: Int = 0
    var attackType: Int = 0
    var moveLevelArray: [Int] = [1]
    var totalNumOfEnemy: Int = 0
    
    /* Resource of variable expression */
    let variableExpressionSource = [
                                    [[1, 0]],
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
    /* [0: number of adding enemy, 1: inteval of adding enemy, 2: number of times of adding enemy] */
    var addEnemyManagement = [
                              [0, 0, 0],
                              [4, 4, 1]
                             ]
    var numOfAddEnemy: Int = 0
    var countTurnForAddEnemy: Int = 0
    var addInterval: Int = 0
    var countTurnForCompAddEnemy: Int = 0
    var numOfTimeAddEnemy: Int = 0
    var CompAddEnemyFlag = false
    
    /* Flash grid */
    var countTurnForFlashGrid: Int = 0
    var flashInterval: Int = 8
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    
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
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        
        /* Labels */
        gameOverLabel = childNode(withName: "gameOverLabel")
        gameOverLabel.isHidden = true
        clearLabel = childNode(withName: "clearLabel")
        clearLabel.isHidden = true
        levelLabel = childNode(withName: "levelLabel") as! SKLabelNode
        
        /* Connect game buttons */
        buttonAttack = childNode(withName: "buttonAttack") as! MSButtonNode
        buttonItem = childNode(withName: "buttonItem") as! MSButtonNode
        buttonRetry = childNode(withName: "buttonRetry") as! MSButtonNode
        buttonNextLevel = childNode(withName: "buttonNextLevel") as! MSButtonNode
        buttonToL1 = childNode(withName: "buttonToL1") as! MSButtonNode
        buttonAttack.state = .msButtonNodeStateHidden
        buttonItem.state = .msButtonNodeStateHidden
        buttonRetry.state = .msButtonNodeStateHidden
        buttonNextLevel.state = .msButtonNodeStateHidden
        buttonToL1.state = .msButtonNodeStateHidden
        
        /* Attack button */
        buttonAttack.selectedHandler = {
            if self.activeHero.attackDoneFlag {
                return
            } else {
                /* Reset item type */
                self.itemType = .None
                
                /* Reset active area */
                self.gridNode.resetSquareArray(color: "blue")
                self.gridNode.resetSquareArray(color: "green")
                
                /* Set item area cover */
                self.itemAreaCover.isHidden = false
                
                self.activeHero.heroState = .Attack
                self.gridNode.showAttackArea(posX: self.activeHero.positionX, posY: self.activeHero.positionY, attackType: self.attackType)
                self.playerTurnState = .AttackState
            }
        }
        
        /* Item button */
        buttonItem.selectedHandler = {
            /* Reset active area */
            self.gridNode.resetSquareArray(color: "red")
            self.gridNode.resetSquareArray(color: "blue")
            
            /* Remove item area cover */
            self.itemAreaCover.isHidden = true
            
            /* Change state to UsingItem */
            self.playerTurnState = .UsingItem
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
        
        /* Next Level button */
        buttonNextLevel.selectedHandler = {
            /* To next stage level */
            self.stageLevel += 1
            
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(self.stageLevel, forKey: "stageLevel")
            /* Hero */
            self.moveLevelArray = []
            for (i, hero) in self.heroArray.enumerated() {
                self.moveLevelArray.append(hero.moveLevel)
                if i == self.heroArray.count-1 {
                    ud.set(self.moveLevelArray, forKey: "moveLevelArray")
                }
            }
            /* Items */
            var itemIndexArray = [Int]()
            for (i, item) in self.itemArray.enumerated() {
                /* mine */
                if item.name == "mineIcon" {
                    itemIndexArray.append(0)
                }
                if i == self.itemArray.count-1 {
                    ud.set(itemIndexArray, forKey: "itemIndexArray")
                }
            }
            
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
        
        /* Back to Level 1 button */
        buttonToL1.selectedHandler = {
            /* To next stage level */
            self.stageLevel = 0
            
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(self.stageLevel, forKey: "stageLevel")
            /* Hero */
            self.moveLevelArray = [1]
            ud.set(self.moveLevelArray, forKey: "moveLevelArray")
            /* item */
            let itemIndexArray = [Int]()
            ud.set(itemIndexArray, forKey: "itemIndexArray")
            
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
        
        /* Pick game property from user data and set */
        let ud = UserDefaults.standard
        /* stageLevel */
        /* For first time to install */
        stageLevel = ud.integer(forKey: "stageLevel")
        levelLabel.text = String(stageLevel+1)
        /* Hero */
        moveLevelArray = ud.array(forKey: "moveLevelArray") as? [Int] ?? [1]
        /* Set hero */
        setHero()
        /* Items */
        let handedItemIndexArray = ud.array(forKey: "itemIndexArray") as? [Int] ?? []
        for itemIndex in handedItemIndexArray {
            /* Mine */
            if itemIndex == 0 {
                displayitem(name: "mineIcon")
            }
        }
       
        
//        /* For testing: initialize userDefaults */
//        /* Store game property */
//        let ud = UserDefaults.standard
//        /* Stage level */
//        ud.set(1, forKey: "stageLevel")
//        /* Hero */
//        ud.set([1], forKey: "moveLevelArray")
//        /* item */
//        ud.set([], forKey: "itemIndexArray")
        
        
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
        
        /* Set initial objects */
        setInitialObj(level: self.stageLevel)
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set each value of adding enemy management */
        SetAddEnemyMng()
        
        /* Check available fonts */
//        for family in UIFont.familyNames {
//            print("Font family name: \(family)")
//            for fontName in UIFont.fontNames(forFamilyName: family) {
//                print("    > Font name: \(fontName)")
//            }
//        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState {
        case .AddEnemy:
//            print("AddEnemy")
            /* Make sure to call till complete adding enemy */
            if CompAddEnemyFlag == false {
                /* Make sure to call addEnemy once */
                if addEnemyDoneFlag == false {
                    addEnemyDoneFlag = true
                    
                    /* Initial add or add on the way */
                    if initialAddEnemyFlag {
                        initialAddEnemyFlag = false
                        
                        /* Add enemy */
                        let addEnemy = SKAction.run({ self.gridNode.addInitialEnemyAtGrid(enemyPosArray: self.initialEnemyPosArray, variableExpressionSource: self.variableExpressionSource[self.stageLevel]) })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*4+1.0) /* 4 is distance, 1.0 is buffer */
                        let moveState = SKAction.run({
                            /* Create enemy startPosArray */
                            self.gridNode.resetEnemyPositon()
                            
                            /* Move to next state */
                            self.gameState = .GridFlashing
                        
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                        
                        /* The time to add enemy */
                    } else if countTurnForAddEnemy == addInterval {
                        /* Add enemy */
                        let addEnemy = SKAction.run({ self.gridNode.addEnemyAtGrid(self.numOfAddEnemy, variableExpressionSource: self.variableExpressionSource[self.stageLevel]) })
                        let wait = SKAction.wait(forDuration: self.gridNode.addingMoveSpeed*2+1.0) /* 2 is distance, 0.1 is buffer */
                        let moveState = SKAction.run({
                            /* Update enemy position */
                            self.gridNode.resetEnemyPositon()
                            self.gridNode.updateEnemyPositon()
                            print(self.gridNode.positionEnemyAtGrid)
                            
                            /* Count up to complete adding enemy */
                            self.countTurnForCompAddEnemy += 1
                            
                            /* On flag if complete adding enemy */
                            if self.countTurnForCompAddEnemy == self.numOfTimeAddEnemy {
                                self.CompAddEnemyFlag = true
                            }
                            
                            /* Move to next state */
                            self.gameState = .GridFlashing
                        })
                        let seq = SKAction.sequence([addEnemy, wait, moveState])
                        self.run(seq)
                        
                        /* Reset countTurnForAddEnemy */
                        countTurnForAddEnemy = 0
                        
                    } else {
                        /* Count up to adding enemy time */
                        countTurnForAddEnemy += 1
                        /* Move to next state */
                        self.gameState = .GridFlashing
                    }
                }
            } else {
                /* Move to next state */
                self.gameState = .GridFlashing
            }
            break;
        case .PlayerTurn:
//            print("PlayerTurn")
            /* Check if all enemies are defeated or not */
            if totalNumOfEnemy <= 0 {
                gameState = .StageClear
            }
            
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
                                /* Count defeated enemy */
                                totalNumOfEnemy -= 1
                            }
                        }
                        if i == self.gridNode.mineSetArray.count-1 {
                            /* Reset mine array */
                            self.gridNode.mineSetPosArray.removeAll()
                            for (i, mine) in self.gridNode.mineSetArray.enumerated() {
                                mine.removeFromParent()
                                if i == self.gridNode.mineSetArray.count-1 {
                                    /* Reset itemSet arrays */
                                    self.gridNode.mineSetArray.removeAll()
                                }
                            }
                        }
                    }
                    playerTurnState = .MoveState
                } else {
                    playerTurnState = .MoveState
                }
                break;
            case .MoveState:
                if activeHero.moveDoneFlag == false {
                    /* Display move area */
                    self.gridNode.showMoveArea(posX: activeHero.positionX, posY: activeHero.positionY, moveLevel: activeHero.moveLevel)
                }
                
                /* Display action buttons */
                buttonAttack.state = .msButtonNodeStateActive
                buttonItem.state = .msButtonNodeStateActive
                
                /* Wait for player touch to move */
                
                break;
            case .AttackState:
                /* Wait for player touch to attack */
                break;
            case .UsingItem:
                switch itemType {
                case .None:
                    break;
                case .Mine:
                    self.gridNode.showMineSettingArea()
                    break;
                }
                /* Wait for player touch to point position to use item at */
                break;
            case .TurnEnd:
                /* Reset Flags */
                addEnemyDoneFlag = false
                enemyTurnDoneFlag = false
                for hero in heroArray {
                    hero.attackDoneFlag = false
                    hero.moveDoneFlag = false
                }
                
                /* Remove used items from itemArray */
                print("Item index array is \(usedItemIndexArray)")
                self.usedItemIndexArray.sort { $0 < $1 }
                for (i, index) in usedItemIndexArray.enumerated() {
                    itemArray.remove(at: index-i)
                    print("Remove item index of \(index)")
                    if i == usedItemIndexArray.count-1 {
                        print("Item array is \(itemArray)")
                        /* Reset position of display item */
                        self.resetDisplayItem()
                        /* Reset usedItemIndexArray */
                        usedItemIndexArray.removeAll()
                    }
                }
                
                
                /* Hide action buttons */
                buttonAttack.state = .msButtonNodeStateHidden
                buttonItem.state = .msButtonNodeStateHidden
                
                /* Remove move area */
                gridNode.resetSquareArray(color: "blue")
                
                /* Reset hero animation to back */
                activeHero.resetHero()
                
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
//            print("EnemyTurn")
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
                gameState = .AddEnemy
                playerTurnState = .ItemOn
            }
            break;
        case .GridFlashing:
//            print("GridFlashing")
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
        case .StageClear:
            gridNode.resetSquareArray(color: "blue")
            clearLabel.isHidden = false
            buttonNextLevel.state = .msButtonNodeStateActive
            break;

        case .GameOver:
            gameOverLabel.isHidden = false
            buttonRetry.state = .msButtonNodeStateActive
            buttonToL1.state = .msButtonNodeStateActive
            break;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        /* Select attack position */
        if playerTurnState == .AttackState {
            /* If touch anywhere but activeArea, back to MoveState  */
            if nodeAtPoint.name != "activeArea" {
                self.gridNode.resetSquareArray(color: "red")
                self.activeHero.heroState = .Move
                self.playerTurnState = .MoveState
            }
            
        /* Use item */
        } else if playerTurnState == .UsingItem {
            /* Use mine */
            if nodeAtPoint.name == "mineIcon" {
                /* Set mine using state */
                itemType = .Mine
                
                /* Get index of game using */
                usingItemIndex = (Int(nodeAtPoint.position.x)-50)/90
                print("Now item index is \(usingItemIndex)")
            /* If player touch other place than item icons, back to MoveState */
            } else {
                playerTurnState = .MoveState
                /* Set item area cover */
                itemAreaCover.isHidden = false
                
                /* Reset item type */
                self.itemType = .None
                
                /* Remove active area */
                self.gridNode.resetSquareArray(color: "green")
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
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
                    } else if contactB.categoryBitMask == 32 {
                        contactB.node?.removeFromParent()
                        if activeHero.moveLevel < 4 {
                            self.activeHero.moveLevel += 1
                        }
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
                /* Get heart */
                } else if contactA.categoryBitMask == 128 || contactB.categoryBitMask == 128 {
                    if contactA.categoryBitMask == 128 {
                        contactA.node?.removeFromParent()
                        life += 1
                    } else if contactB.categoryBitMask == 128 {
                        contactB.node?.removeFromParent()
                        life += 1
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
    
    /* Create object blanketting item area */
    func setItemAreaCover() {
        itemAreaCover = SKShapeNode(rectOf: itemAreaNode.size)
        itemAreaCover.fillColor = UIColor.black
        itemAreaCover.alpha = 0.6
        itemAreaCover.position = itemAreaNode.position
        itemAreaCover.zPosition = 100
        addChild(itemAreaCover)
    }
    
    /* Set initial hero */
    func setHero() {
        for (i, moveLevel) in moveLevelArray.enumerated() {
            hero = Hero()
            hero.moveLevel = moveLevel
            hero.positionY = i+3
            heroArray.append(hero)
            hero.position = CGPoint(x: self.size.width/2, y: gridNode.position.y+CGFloat(self.gridNode.cellHeight/2)+CGFloat(self.gridNode.cellHeight*(i+3)))
            addChild(hero)
        }
    }
    
    /* Set initial objects */
    func setInitialObj(level: Int) {
        switch level {
        case 0:
            /* Set enemy */
            initialEnemyPosArray = [[1, 10], [4, 10], [7, 10], [2, 8], [6, 8]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
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
        case 1:
            /* Set enemy */
            initialEnemyPosArray = [[1, 11], [3, 11], [5, 11], [7, 11], [2, 9], [4, 9], [6, 9]]
            
            /* Set total number of enemy */
            totalNumOfEnemy = initialEnemyPosArray.count+addEnemyManagement[stageLevel][0]*addEnemyManagement[stageLevel][2]
            
            /* Set boots */
            let boots = Boots()
            self.gridNode.addObjectAtGrid(object: boots, x: 7, y: 6)
            let boots2 = Boots()
            self.gridNode.addObjectAtGrid(object: boots2, x: 1, y: 6)
            
            /* Set mine */
            let mine = Mine()
            self.gridNode.addObjectAtGrid(object: mine, x: 7, y: 3)
            let mine2 = Mine()
            self.gridNode.addObjectAtGrid(object: mine2, x: 7, y: 9)
            let mine3 = Mine()
            self.gridNode.addObjectAtGrid(object: mine3, x: 1, y: 3)
            let mine4 = Mine()
            self.gridNode.addObjectAtGrid(object: mine4, x: 1, y: 9)
            let mine5 = Mine()
            self.gridNode.addObjectAtGrid(object: mine5, x: 6, y: 0)
            let mine6 = Mine()
            self.gridNode.addObjectAtGrid(object: mine6, x: 2, y: 0)
            
            /* Set heart */
            let heart = Heart()
            self.gridNode.addObjectAtGrid(object: heart, x: 4, y: 6)
        default:
            break;
        }
    }
    
    /* Set each value of adding enemy management */
    func SetAddEnemyMng() {
        numOfAddEnemy = addEnemyManagement[stageLevel][0]
        addInterval = addEnemyManagement[stageLevel][1]
        numOfTimeAddEnemy = addEnemyManagement[stageLevel][2]
    }
    
        
}
