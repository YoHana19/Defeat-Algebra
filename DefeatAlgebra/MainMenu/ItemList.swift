//
//  MainMenu.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ItemList: SKScene {
    
    let itemArray = ["boots", "timeBomb", "heart", "wall", "multiAttack", "battleShip", "catapult", "resetCatapult", "magicSword", "cane", "teleport", "spear", "callHero"]
    var lockedArray = [SKSpriteNode]()
    var showingCardFlag = false
    
    /* Sound */
    var sound = BGM(bgm: 3)
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Sound */
        if MainMenu.soundOnFlag {
            sound.play()
        }
        
        setItem(itemArray: itemArray)
        setCoverItem()
        
        
        unlockItem()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonBack" {
            
            if showingCardFlag {
                if let card = childNode(withName: "itemCard") {
                    card.removeFromParent()
                }
                showingCardFlag = false
            }
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = MainMenu(fileNamed:"MainMenu") as MainMenu! else {
                return
            }
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonBack.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        if showingCardFlag {
            if let card = childNode(withName: "itemCard") {
                card.removeFromParent()
            }
            showingCardFlag = false
        } else {
            if nodeAtPoint.name == "boots" {
                showItemCard(item: "cardBoots")
            } else if nodeAtPoint.name == "timeBomb" {
                showItemCard(item: "cardTimeBomb")
            } else if nodeAtPoint.name == "heart" {
                showItemCard(item: "cardHeart")
            } else if nodeAtPoint.name == "wall" {
                showItemCard(item: "cardWall")
            } else if nodeAtPoint.name == "multiAttack" {
                showItemCard(item: "cardMultiAttack")
            } else if nodeAtPoint.name == "battleShip" {
                showItemCard(item: "cardBattleShip")
            } else if nodeAtPoint.name == "catapult" {
                showItemCard(item: "cardCatapult")
            } else if nodeAtPoint.name == "resetCatapult" {
                showItemCard(item: "cardResetCatapult")
            } else if nodeAtPoint.name == "cane" {
                showItemCard(item: "cardCane")
            } else if nodeAtPoint.name == "magicSword" {
                showItemCard(item: "cardMagicSword")
            } else if nodeAtPoint.name == "teleport" {
                showItemCard(item: "cardTeleport")
            } else if nodeAtPoint.name == "spear" {
                showItemCard(item: "cardSpear")
            } else if nodeAtPoint.name == "callHero" {
                showItemCard(item: "cardCallHero")
            }
        }
    }
    
    /* Set Algebra Robot */
    func setEnemy() {
        let enemy = SKSpriteNode(imageNamed: "front1")
        enemy.size = CGSize(width: 80, height: 80)
        enemy.position = CGPoint(x: 375, y: 1220)
        let enemyMoveAnimation = SKAction(named: "enemyMoveForward")!
        enemy.run(enemyMoveAnimation)
        addChild(enemy)
    }
    
    func setItem(itemArray: [String]) {
        let bodysize = CGSize(width: 100, height: 100)
        /* calculate margin */
        /* horizontal */
        let marginX = (self.size.width-bodysize.width*3)/4
        /* vertical */
        let marginY = (self.size.height-bodysize.height*5)/6
        for (i, itemName) in itemArray.enumerated() {
            let item = SKSpriteNode(imageNamed: itemName)
            item.size = bodysize
            item.name = itemName
            /* x position */
            let order = (i+1) % 3
            if order == 1 {
                item.position.x = marginX+bodysize.width/2
            } else if order == 2 {
                item.position.x = 2*marginX+1.5*bodysize.width
            } else {
                item.position.x = 3*marginX+2.5*bodysize.width
            }
            /* y position */
            if i < 3 {
                item.position.y = 5*marginY+4.5*bodysize.height
            } else if i < 6 {
                item.position.y = 4*marginY+3.5*bodysize.height
            } else if i < 9 {
                item.position.y = 3*marginY+2.5*bodysize.height
            } else if i < 12 {
                item.position.y = 2*marginY+1.5*bodysize.height
            } else {
               item.position.y = marginY+0.5*bodysize.height
            }
            addChild(item)
        }
    }
    
    func setCoverItem() {
        let bodysize = CGSize(width: 105, height: 105)
        /* calculate margin */
        /* horizontal */
        let marginX = (self.size.width-bodysize.width*3)/4
        /* vertical */
        let marginY = (self.size.height-bodysize.height*5)/6
        
        for i in 0...12 {
            let cover = SKSpriteNode(imageNamed: "lockedIcon")
            cover.size = bodysize
            cover.zPosition = 1
            /* x position */
            let order = (i+1) % 3
            if order == 1 {
                cover.position.x = marginX+bodysize.width/2
            } else if order == 2 {
                cover.position.x = 2*marginX+1.5*bodysize.width
            } else {
                cover.position.x = 3*marginX+2.5*bodysize.width
            }
            /* y position */
            if i < 3 {
                cover.position.y = 5*marginY+4.5*bodysize.height
            } else if i < 6 {
                cover.position.y = 4*marginY+3.5*bodysize.height
            } else if i < 9 {
                cover.position.y = 3*marginY+2.5*bodysize.height
            } else if i < 12 {
                cover.position.y = 2*marginY+1.5*bodysize.height
            } else {
                cover.position.y = marginY+0.5*bodysize.height
            }
            addChild(cover)
            lockedArray.append(cover)
        }
    }
    
    func unlockItem() {
    }
    
    /* Show item card when get it firstly */
    func showItemCard(item: String) {
        let card = SKSpriteNode(imageNamed: item)
        card.size = CGSize(width: 650, height: 903)
        card.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        card.name = "itemCard"
        showingCardFlag = true
        card.zPosition = 50
        addChild(card)
    }
    
}
