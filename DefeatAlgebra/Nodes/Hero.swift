//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum MoveDirection {
    case Horizontal, Vertical
}

class Hero: SKSpriteNode {
    
    /* Property */
    var direction: Direction = .back
    var moveDirection: MoveDirection = .Horizontal
    var moveSpeed = 0.2
    var heroMoveAnimation: SKAction!
    var moveLevel: Int = 1
    
    /* Flags */
    var attackDoneFlag = false
    var moveDoneFlag: Bool = false {
        willSet {
            if !moveDoneFlag && newValue {
                posRecord.append((positionX, positionY))
            }
        }
    }
    var aliveFlag = true
    
    /* Position at grid */
    var positionX: Int = 4
    var positionY: Int = 3
    
    var posRecord = [(Int, Int)]()
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "heroFront")
        let heroSize = CGSize(width: 50, height: 50)
        super.init(texture: texture, color: UIColor.clear, size: heroSize)
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 3
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /* Set physics property */
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 4294967258
        
        /* Set initial hero appearance */
        setName()
        setTexture()
        setMovingAnimation()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* Set name */
    func setName() {
        self.name = "hero"
    }
    
    /*================*/
    /*== Animation ==*/
    /*================*/
    
    /* Set texture to hero according to direction */
    func setTexture() {
        switch direction {
        case .front:
            self.texture = SKTexture(imageNamed: "heroFront")
        case .back:
            self.texture = SKTexture(imageNamed: "heroBack")
        case .left:
            self.texture = SKTexture(imageNamed: "heroLeft")
        case .right:
            self.texture = SKTexture(imageNamed: "heroRight")
        }
    }
    
    /* Set animation to hero according to direction */
    func setMovingAnimation() {
        switch direction {
        case .front:
            self.heroMoveAnimation = SKAction(named: "heroMoveForward")!
            self.run(heroMoveAnimation)
        case .back:
            self.heroMoveAnimation = SKAction(named: "heroMoveBackward")!
            self.run(heroMoveAnimation)
        case .left:
            self.heroMoveAnimation = SKAction(named: "heroMoveLeft")!
            self.run(heroMoveAnimation)
        case .right:
            self.heroMoveAnimation = SKAction(named: "heroMoveRight")!
            self.run(heroMoveAnimation)
        }
    }
    
    /* Set hero direction when attacking */
    func setHeroDirection(posX: Int, posY: Int) {
        /* Calculate difference between current position and destination */
        let diffX = posX - self.positionX
        let diffY = posY - self.positionY
        
        /* turn right */
        if diffX > 0 {
            self.direction = .right
            /* turn left */
        } else if diffX < 0 {
            self.direction = .left
        } else {
            /* turn front */
            if diffY < 0 {
                self.direction = .front
                /* turn back */
            } else if diffY < 0 {
                self.direction = .back
            }
        }
    }
    
    /* Set hero sword attack animation */
    func setSwordAnimation(completion: @escaping () -> Void) {
        switch direction {
        case .front:
            self.anchorPoint = CGPoint(x: 0.5, y: 1)
            let heroSwordAnimation = SKAction(named: "heroSwordBackward")!
            self.run(heroSwordAnimation, completion: {
                return completion()
            })
        case .back:
            self.anchorPoint = CGPoint(x: 0.5, y: 0)
            let heroSwordAnimation = SKAction(named: "heroSwordForward")!
            self.run(heroSwordAnimation, completion: {
                return completion()
            })
        case .left:
            self.anchorPoint = CGPoint(x: 1, y: 0.5)
            let heroSwordAnimation = SKAction(named: "heroSwordLeft")!
            self.run(heroSwordAnimation, completion: {
                return completion()
            })
        case .right:
            self.anchorPoint = CGPoint(x: 0, y: 0.5)
            let heroSwordAnimation = SKAction(named: "heroSwordRight")!
            self.run(heroSwordAnimation, completion: {
                return completion()
            })
        }
    }
    
    /* Reset hero position and animation */
    func resetHero() {
        self.direction = .back
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.size = CGSize(width: 50, height: 50)
        self.setTexture()
        self.setMovingAnimation()
    }
    
    func attack(completion: @escaping () -> Void) {
        setSwordAnimation() {
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.size = CGSize(width: 50, height: 50)
            return completion()
        }
    }
    
    func resetPos() {
        let gameScene = self.parent as! GameScene
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.size = CGSize(width: 50, height: 50)
        self.position = CGPoint(x: gameScene.gridNode.position.x+CGFloat(gameScene.gridNode.cellWidth/2)+CGFloat(gameScene.gridNode.cellWidth*Double(self.positionX)), y: gameScene.gridNode.position.y+CGFloat(gameScene.gridNode.cellHeight/2)+CGFloat(gameScene.gridNode.cellHeight*Double(self.positionY)))
    }
    
    public func checkEnemyAround(completion: @escaping (Enemy?) -> Void) {
        guard let gameScene = self.parent as? GameScene else { return }
        guard gameScene.gridNode.enemyArray.count == 1 else { return }
        let x = self.positionX
        let y = self.positionY
        let enemy = gameScene.gridNode.enemyArray[0]
        if (enemy.positionX == x-1 && enemy.positionY == y) || (enemy.positionX == x+1 && enemy.positionY == y) || (enemy.positionX == x && enemy.positionY == y+1) || (enemy.positionX == x && enemy.positionY == y-1) {
            return completion(enemy)
        } else {
            return completion(nil)
        }
    }
    
    public func setPhysics(isActive: Bool) {
        if isActive {
            physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
            physicsBody?.categoryBitMask = 1
            physicsBody?.collisionBitMask = 0
            physicsBody?.contactTestBitMask = 4294967258
        } else {
            physicsBody = nil
        }
    }
    
    
    /*===============*/
    /*== Hero Move ==*/
    /*===============*/
    
    /* Move hero */
    func heroSingleMove() {
        /* Get parent Scene */
        let gameScene = self.parent as! GameScene
        
        /* Set texture and animation */
        self.setTexture()
        self.setMovingAnimation()
        
        switch direction {
        case .front:
            /* Move hero backward */
            let move = SKAction.moveBy(x: 0, y: -CGFloat(gameScene.gridNode.cellHeight), duration: self.moveSpeed)
            self.run(move)
            break;
        case .back:
            /* Move hero forward */
            let move = SKAction.moveBy(x: 0, y: CGFloat(gameScene.gridNode.cellHeight), duration: self.moveSpeed)
            self.run(move)
            break;
        case .left:
            /* Move hero left */
            let move = SKAction.moveBy(x: -CGFloat(gameScene.gridNode.cellWidth), y: 0, duration: self.moveSpeed)
            self.run(move)
            break;
        case .right:
            /* Move hero right */
            let move = SKAction.moveBy(x: CGFloat(gameScene.gridNode.cellWidth), y: 0, duration: self.moveSpeed)
            self.run(move)
            break;
        }
    }
    
    func heroMoveToDest(posX: Int, posY: Int) {
        /* Calculate difference between current position and destination */
        let diffX = posX - self.positionX
        let diffY = posY - self.positionY
        
        if self.moveDirection == .Horizontal {
            /* Move right */
            if diffX > 0 {
                self.direction = .right
                
                /* Move forward */
                if diffY > 0 {
                    /* Move horizontaly */
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                    
                    /* Wait for move horizotaly done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffX)+0.3)) /* 0.3 is buffer */
                    
                    /* Move verticaly */
                    let changeDirect = SKAction.run({ self.direction = .back })
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    
                    let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                    self.run(seq)
                    
                    /* Move backward */
                } else if diffY < 0 {
                    /* Move horizontaly */
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                    
                    /* Wait for move horizotaly done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffX)+0.1)) /* 0.1 is buffer */
                    
                    /* Move verticaly */
                    let changeDirect = SKAction.run({ self.direction = .front })
                    let singleMove = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                    
                    let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                    self.run(seq)
                    
                    /* Only move horizontaly */
                } else {
                    let singleMove = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMove, count: diffX)
                    self.run(moveToDestX)
                }
                
                /* Move Left */
            } else if diffX < 0 {
                self.direction = .left
                
                /* Move forward */
                if diffY > 0 {
                    /* Move horizontaly */
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                    
                    /* Wait for move horizotaly done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffX)+0.3)) /* 0.3 is buffer */
                    
                    /* Move verticaly */
                    let changeDirect = SKAction.run({ self.direction = .back })
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    
                    let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                    self.run(seq)
                    
                    /* Move backward */
                } else if diffY < 0 {
                    /* Move horizontaly */
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                    
                    /* Wait for move horizotaly done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffX)+0.3)) /* 0.3 is buffer */
                    
                    /* Move verticaly */
                    let changeDirect = SKAction.run({ self.direction = .front })
                    let singleMove = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                    
                    let seq = SKAction.sequence([moveToDestX, wait, changeDirect, moveToDestY])
                    self.run(seq)
                    
                    /* Only move horizontaly */
                } else {
                    let singleMove = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMove, count: -diffX)
                    self.run(moveToDestX)
                }
                /* Only move vertically */
            } else {
                /* Move forward */
                if diffY > 0 {
                    /* Move verticaly */
                    self.direction = .back
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    self.run(moveToDestY)
                    
                    /* Move backward */
                } else if diffY < 0 {
                    /* Move verticaly */
                    self.direction = .front
                    let singleMove = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMove, count: -diffY)
                    self.run(moveToDestY)
                    /* Stay */
                } else {
                    return
                }
            }
            
        } else if self.moveDirection == .Vertical {
            /* Move forward */
            if diffY > 0 {
                self.direction = .back
                /* Move right */
                if diffX > 0 {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    
                    /* Wait for move vertically done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffY)+0.3)) /* 0.3 is buffer */
                    
                    /* Move horizontaly */
                    let changeDirect = SKAction.run({ self.direction = .right })
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                    
                    let seq = SKAction.sequence([moveToDestY, wait, changeDirect, moveToDestX])
                    self.run(seq)
                    
                    /* Move left */
                } else if diffX < 0 {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    
                    /* Wait for move vertically done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(diffY)+0.3)) /* 0.3 is buffer */
                    
                    /* Move horizontaly */
                    let changeDirect = SKAction.run({ self.direction = .left })
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                    
                    let seq = SKAction.sequence([moveToDestY, wait, changeDirect, moveToDestX])
                    self.run(seq)
                    /* Only move vertically */
                } else {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: diffY)
                    self.run(moveToDestY)
                }
                
                /* Move backward */
            } else if diffY < 0 {
                self.direction = .front
                /* Move right */
                if diffX > 0 {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: -diffY)
                    
                    /* Wait for move vertically done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffY)+0.3)) /* 0.3 is buffer */
                    
                    /* Move horizontaly */
                    let changeDirect = SKAction.run({ self.direction = .right })
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                    
                    let seq = SKAction.sequence([moveToDestY, wait, changeDirect, moveToDestX])
                    self.run(seq)
                    
                    /* Move left */
                } else if diffX < 0 {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: -diffY)
                    
                    /* Wait for move vertically done */
                    let wait = SKAction.wait(forDuration: TimeInterval(self.moveSpeed*Double(-diffY)+0.3)) /* 0.3 is buffer */
                    
                    /* Move horizontaly */
                    let changeDirect = SKAction.run({ self.direction = .left })
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                    
                    let seq = SKAction.sequence([moveToDestY, wait, changeDirect, moveToDestX])
                    self.run(seq)
                    
                    /* Only move vertically */
                } else {
                    /* Move verticaly */
                    let singleMoveV = SKAction.run({ self.heroSingleMove() })
                    let moveToDestY = SKAction.repeat(singleMoveV, count: -diffY)
                    self.run(moveToDestY)
                }
                /* Only move horizontally */
            } else {
                /* Move right */
                if diffX > 0 {
                    /* Move horizontaly */
                    self.direction = .right
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: diffX)
                    self.run(moveToDestX)
                    
                    /* Move left */
                } else if diffX < 0 {
                    /* Move horizontaly */
                    self.direction = .left
                    let singleMoveH = SKAction.run({ self.heroSingleMove() })
                    let moveToDestX = SKAction.repeat(singleMoveH, count: -diffX)
                    self.run(moveToDestX)
                    /* Stay */
                } else {
                    return
                }
            }
        }
    }
    
    /*==========*/
    /*== Item ==*/
    /*==========*/
    
    /*== Magic Sword ==*/
    /* Display variable expression you attack when using magic sword */
    func setMagicSwordVE(vE: String) {
        /* label of variable expresion */
        let vELabel = SKLabelNode(fontNamed: DAFont.fontName)
        vELabel.text = vE
        vELabel.fontColor = UIColor.purple
        vELabel.name = "vElabel"
        vELabel.fontSize = 50
        vELabel.position = CGPoint(x: 10, y: 55)
        vELabel.zPosition = 102
        addChild(vELabel)
    }
    
    func removeMagicSwordVE() {
        if let label = childNode(withName: "vElabel") {
            label.removeFromParent()
        }
    }
    
}
