//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class SettingScreen: SKSpriteNode {
    
    var isActive: Bool = false {
        didSet {
            /* Visibility */
            self.isHidden = !isActive
        }
    }
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "settingScreen")
        let bodySize = CGSize(width: 630, height: 900)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 100
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 670)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mainMenu = self.parent as! MainMenu
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "hakase" {
            mainMenu.loadLevelSelect()
        } else if nodeAtPoint.name == "buttonItemList" {
            
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView?
            
            /* Load Game scene */
            guard let scene = DataSelectMenu(fileNamed:"DataSelectMenu") as DataSelectMenu? else {
                return
            }
            
            /* Play Sound */
            SoundController.sound(scene: mainMenu, sound: .ButtonMove)
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        } else if nodeAtPoint.name == "buttonCredits" {
            
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView?
            
            /* Load Game scene */
            guard let scene = Credits(fileNamed:"Credits") as Credits? else {
                return
            }
            
            SoundController.sound(scene: mainMenu, sound: .ButtonMove)
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        } else if nodeAtPoint.name == "buttonNewGame" {
            mainMenu.showConfirm()
        }
    }
    
    func setButtons() {
        
        /* button Item List */
        let buttonItemList = SKSpriteNode(imageNamed: "buttonItemList")
        buttonItemList.position = CGPoint(x: 0, y: self.size.height/4+30)
        buttonItemList.name = "buttonItemList"
        buttonItemList.zPosition = 3
        addChild(buttonItemList)
        
        /* button Credits */
        let buttonCredits = SKSpriteNode(imageNamed: "buttonCredits")
        buttonCredits.position = CGPoint(x: 0, y: 30)
        buttonCredits.name = "buttonCredits"
        buttonCredits.zPosition = 3
        addChild(buttonCredits)
        
        /* button NewGame */
        let buttonNewGame = SKSpriteNode(imageNamed: "buttonNewGame")
        buttonNewGame.position = CGPoint(x: 0, y: -self.size.height/4+30)
        buttonNewGame.name = "buttonNewGame"
        buttonNewGame.zPosition = 3
        addChild(buttonNewGame)
        
        let hakase = SKSpriteNode(imageNamed: "goodDoctorDefault")
        hakase.position = CGPoint(x: 195, y: -345)
        hakase.size = CGSize(width: 76, height: 90)
        hakase.name = "hakase"
        hakase.zPosition = 4
        addChild(hakase)
        
    }
}
