//
//  GameScene.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/06/30.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

/* Index of categryBitMask of game objects */
/*
 1: Hero - 4294967258(MAX-4-32-1)
 2: Enemy - 5(1,4)
 4: castleNode - 24(8,16)
 8: EnemyArm - 4
 16: EnemyFist - 5(1,4)
 32: setItems - wall-26(2,8,16)
 64: getItems(Boots,timeBomb,Heart,callHero,catapult,multiAttack) - 1
 128:
 1024:
 */

import SpriteKit
import GameplayKit

class Tutorial1: SKScene, SKPhysicsContactDelegate {
    
    /* Game objects */
    var gridNode: Grid!
    var activeHero = HeroForTutorial()
    var castleNode: SKSpriteNode!
    var itemAreaNode: SKSpriteNode!
    var buttonAttack: SKNode!
    var buttonItem: SKNode!
    var pauseScreen: PauseScreenForTutorial!
    
    /* Game labels */
    var valueOfX: SKLabelNode!
    var touchScreenLabel: SKLabelNode!
    var playerPhaseLabel: SKNode!
    var enemyPhaseLabel: SKNode!
    
    /* Game buttons */
    var buttonPause: MSButtonNode!
    
    /* Distance of objects in Scene */
    var topGap: CGFloat = 0.0  /* the length between top of scene and grid */
    var bottomGap: CGFloat = 0.0  /* the length between castle and grid */
    
    /* Game constants */
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let turnEndWait: TimeInterval = 1.0
    
    /* Game Management */
    var gameState: GameSceneState = .AddEnemy
    var playerTurnState: PlayerTurnState = .DisplayPhase
    var tutorialState: TutorialState = .T0
    static var tutorialPhase = 0
    var itemType: ItemType = .None
    var stageLevel: Int = 0
    var moveLevelArray: [Int] = [1]
    var totalNumOfEnemy: Int = 3
    var tutorialDone = false
    var gameOverDoneFlag = false
    
    /*== Game Sounds ==*/
    var main = BGM(bgm: 0)
    var stageClear = BGM(bgm: 2)
    var gameOver = BGM(bgm: 4)
    var gameOverSoundDone = false
    var stageClearSoundDone = false
    var hitCastleWallSoundDone = false

    /* Game flags */
    var addEnemyDoneFlag = false
    var playerTurnDoneFlag = false
    var enemyTurnDoneFlag = false
    var heroMovingFlag = false
    var punchDoneFlag = false
    var allPunchDoneFlag = false
    var punchTimeFlag = false
    var flashGridDoneFlag = false
    var calPunchLengthDoneFlag = false
    var initialAddEnemyFlag = true
    var showPlayerDiscriptionDone = false
    var showEnemyDiscriptionDone = false
    var enemyPhaseLabelDoneFlag = false
    var bombExplodeDoneFlag = false
    var timeBombDoneFlag = false
    var enemyTurnEndFlag = false
    var pauseFlag = false
    
    /* Chara showing flag */
    var doctorShouldShow = false
    var madDoctorShouldShow = false
    
    /* Player Control */
    var beganPos:CGPoint!
    var heroArray = [HeroForTutorial]()
    var numOfTurnDoneHero = 0
    
    var tutorialLabelArray = [SKNode]()
    
    
    /* Flash grid */
    var numOfFlashArray = [3, 1, 2, 3, 1, 3]
    //    var numOfFlashArray = [1, 1, 1, 1, 1, 1]
    var xValue: Int = 3
    
    /* Items */
    var itemArray = [SKSpriteNode]()
    var usingItemIndex = 0
    var usedItemIndexArray = [Int]()
    var itemAreaCover: SKShapeNode!
    
    
    /* Castle life */
    var maxLife = 3
    var life: Int = 3
    
    
    override func didMove(to view: SKView) {
        
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        gridNode.isTutorial = true
        castleNode = childNode(withName: "castleNode") as! SKSpriteNode
        itemAreaNode = childNode(withName: "itemAreaNode") as! SKSpriteNode
        buttonAttack = childNode(withName: "buttonAttack")
        buttonItem = childNode(withName: "buttonItem")
        buttonAttack.isHidden = true
        buttonItem.isHidden = true
        
        /* Sound */
        if MainMenu.soundOnFlag {
            main.play()
            main.numberOfLoops = -1
        }
        
        /* Labels */
        playerPhaseLabel = childNode(withName: "playerPhaseLabel")
        playerPhaseLabel.isHidden = true
        enemyPhaseLabel = childNode(withName: "enemyPhaseLabel")
        enemyPhaseLabel.isHidden = true
        touchScreenLabel = childNode(withName: "touchScreenLabel") as! SKLabelNode
        touchScreenLabel.isHidden = true
        
        /* Connect game buttons */
        buttonPause = childNode(withName: "buttonPause") as! MSButtonNode
        
        /* Pause button */
        buttonPause.selectedHandler = { [weak self] in
            self?.pauseFlag = true
            self?.pauseScreen.isHidden = false
        }
        
        /* Set puase screen */
        pauseScreen = PauseScreenForTutorial()
        addChild(pauseScreen)
        
        
        /* Calculate dicetances of objects in Scene */
        topGap =  self.size.height-(self.gridNode.position.y+self.gridNode.size.height)
        bottomGap = self.gridNode.position.y-(self.castleNode.position.y+self.castleNode.size.height/2)
        
        /* Display value of x */
        valueOfX = childNode(withName: "valueOfX") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set no gravity */
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* Set castleWall physics property */
        castleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: castleNode.size.width, height: 80))
        castleNode.physicsBody?.categoryBitMask = 4
        castleNode.physicsBody?.collisionBitMask = 0
        castleNode.physicsBody?.contactTestBitMask = 24
        
        /* Set item area */
        setItemAreaCover()
        
        /* Set life */
        setLife(numOflife: maxLife)
        
        /* Set Character */
        CharacterController.setCharacter(scene: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pauseFlag == false else { return }
        CharacterController.shakeDoctor()
        CharacterController.shakeMadDoctor()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pauseFlag == false else { return }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pauseFlag == false else { return }
        doctorShouldShow = !doctorShouldShow
        madDoctorShouldShow = !madDoctorShouldShow
        if doctorShouldShow {
            CharacterController.showDoctor()
        } else {
            CharacterController.retreatDoctor()
        }
        if madDoctorShouldShow {
            CharacterController.showMadDoctor()
        } else {
            CharacterController.retreatMadDoctor()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    /* Create item icons to display when you get items */
    func displayitem(name: String) {
        let index = self.itemArray.count
        let item = SKSpriteNode(imageNamed: name)
        item.size = CGSize(width: 69, height: 69)
        item.position = CGPoint(x: Double(index)*91+56.5, y: 47.5)
        item.zPosition = 2
        item.name = name
        self.itemArray.append(item)
        addChild(item)
    }
    
    /* Reset position of item when use any */
    func resetDisplayItem(index: Int) {
        itemArray[index].removeFromParent()
        itemArray.remove(at: index)
        for (i, item) in itemArray.enumerated() {
            item.position = CGPoint(x: Double(i)*91+56.5, y: 47.5)
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
    
    /* Create label for tutorial */
    func createTutorialLabel(text: String, posY: Int) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set text */
        label.text = text
        
        /* Set name */
        label.name = "tutorialLabel"
        
        /* Set font size */
        label.fontSize = 35
        
        /* Set zPosition */
        label.zPosition = 50
        
        /* Set position */
        label.position = CGPoint(x: self.size.width/2, y: CGFloat(posY))
        
        tutorialLabelArray.append(label)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    func createTutorialLabel2(text: String, posX: CGFloat, posY: Int, color: UIColor, size: CGFloat) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        
        /* Set text */
        label.text = text
        
        /* Set name */
        label.name = "tutorialLabel"
        
        /* Set font size */
        label.fontSize = size
        
        /* Set font color */
        label.fontColor = color
        
        /* Set zPosition */
        label.zPosition = 50
        
        /* Set position */
        label.position = CGPoint(x: posX, y: CGFloat(posY))
        
        tutorialLabelArray.append(label)
        
        /* Add to Scene */
        self.addChild(label)
    }
    
    /* Set pointing icon */
    func setPointingIcon(position: CGPoint, size: CGSize) {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.size = size
        icon.position = position
        icon.zPosition = 120
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        tutorialLabelArray.append(icon)
        addChild(icon)
    }
    
    /* Set pointing icon another angle */
    func setPointingIcon2(position: CGPoint, size: CGSize) -> SKSpriteNode {
        let icon = SKSpriteNode(imageNamed: "pointing")
        icon.position = position
        icon.zRotation = -.pi
        icon.zPosition = 120
        icon.size = size
        let shakePoint = SKAction(named: "shakePoint")
        let repeatAction = SKAction.repeatForever(shakePoint!)
        icon.run(repeatAction)
        tutorialLabelArray.append(icon)
        return icon
    }
    
    /* Set pointing icon for swiping */
    func setMovePointingIcon(position: CGPoint) {
        let single = SKAction.run({
            let icon = SKSpriteNode(imageNamed: "pointing")
            icon.position = position
            icon.zPosition = 5
            icon.name = "movingPoint"
            self.tutorialLabelArray.append(icon)
            self.addChild(icon)
            let moveUp = SKAction.moveBy(x: 0, y: -CGFloat(self.gridNode.cellHeight), duration: 1.0)
            let moveLeft = SKAction.moveBy(x: CGFloat(self.gridNode.cellWidth), y: 0, duration: 1.0)
            let seq = SKAction.sequence([moveUp, moveLeft])
            icon.run(seq)
        })
        
        let wait2 = SKAction.wait(forDuration: 2.2)
        let remove = SKAction.run({
            if let node = self.childNode(withName: "movingPoint") {
                node.removeFromParent()
            }
        })
        
        let seq2 = SKAction.sequence([single, wait2, remove])
        let repeatAction = SKAction.repeatForever(seq2)
        self.run(repeatAction)
    }
    
    /* Set pointing icon for cancell swiping */
    func setMovePointingIcon2(position: CGPoint) {
        let single = SKAction.run({
            let icon = SKSpriteNode(imageNamed: "pointing")
            icon.position = position
            icon.zPosition = 5
            icon.name = "movingPoint"
            self.tutorialLabelArray.append(icon)
            self.addChild(icon)
            let moveUp = SKAction.moveBy(x: -3*CGFloat(self.gridNode.cellWidth), y: 0, duration: 2.0)
            icon.run(moveUp)
        })
        
        let wait2 = SKAction.wait(forDuration: 2.2)
        let remove = SKAction.run({
            if let node = self.childNode(withName: "movingPoint") {
                node.removeFromParent()
            }
        })
        
        let seq2 = SKAction.sequence([single, wait2, remove])
        let repeatAction = SKAction.repeatForever(seq2)
        self.run(repeatAction)
    }
    
    /* Show touch screen popUp */
    func showTouchScreen(waitTime: TimeInterval) {
        let wait = SKAction.wait(forDuration: waitTime)
        let show = SKAction.run({ self.touchScreenLabel.isHidden = false })
        let seq = SKAction.sequence([wait, show])
        self.run(seq)
    }
    
    /* Reset stuff when moving next discription */
    func resetDiscription() {
        removeTutorial()
        self.removeAllActions()
        touchScreenLabel.isHidden = true
    }
    
    /* Remove tutorial */
    func removeTutorial() {
        for (i, label) in tutorialLabelArray.enumerated() {
            label.removeFromParent()
            if i == tutorialLabelArray.count-1 {
                tutorialLabelArray.removeAll()
            }
        }
    }
    
    /* Life */
    func setLife(numOflife: Int) {
        for i in 0..<maxLife {
            if let node = childNode(withName: "life") {
                node.removeFromParent()
            }
            if i == maxLife-1 {
                for i in 0..<numOflife {
                    let life = SKSpriteNode(imageNamed: "heart")
                    life.size = CGSize(width: 50, height: 50)
                    life.position = CGPoint(x: Double(i)*60+45, y: 140)
                    life.name = "life"
                    life.zPosition = 90
                    addChild(life)
                }
            }
        }
    }
    
    /*== Time bomb ==*/
    /* Effect */
    func timeBombEffect(timeBomb: TimeBomb) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "TimeBombExplode")!
        let particles2 = SKEmitterNode(fileNamed: "TimeBombSmoke")!
        particles.position = CGPoint(x: timeBomb.position.x+gridNode.position.x, y: timeBomb.position.y+gridNode.position.y)
        particles2.position = CGPoint(x: timeBomb.position.x+gridNode.position.x, y: timeBomb.position.y+gridNode.position.y)
        /* Add particles to scene */
        self.addChild(particles)
        self.addChild(particles2)
        let waitRemoveExplode = SKAction.wait(forDuration: 0.5)
        let waitRemoveSmoke = SKAction.wait(forDuration: 3.0)
        let removeParticles = SKAction.removeFromParent()
        let onFlag = SKAction.run({
            self.timeBombDoneFlag = true
            /* Reset itemSet arrays */
            self.gridNode.timeBombSetArray.removeAll()
        })
        let seqEffect = SKAction.sequence([waitRemoveExplode, removeParticles])
        let seqEffect2 = SKAction.sequence([waitRemoveSmoke, removeParticles, onFlag])
        particles.run(seqEffect)
        particles2.run(seqEffect2)
    }
    
    /* Show item card when get it */
    func showItemCard(item: String) {
        let card = SKSpriteNode(imageNamed: item)
        card.size = CGSize(width: 550, height: 769)
        card.position = CGPoint(x: self.size.width/2, y: self.size.height/2+100)
        card.name = "itemCard"
        card.zPosition = 10
        addChild(card)
    }
}
