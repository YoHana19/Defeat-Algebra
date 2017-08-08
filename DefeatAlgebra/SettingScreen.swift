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
        
        if nodeAtPoint.name == "buttonTutorial" {
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            Tutorial.tutorialPhase = 0
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        } else if nodeAtPoint.name == "buttonItemList" {
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView!
            
            /* Load Game scene */
            guard let scene = ItemList(fileNamed:"ItemList") as ItemList! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        } else if nodeAtPoint.name == "buttonCredits" {
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView!
            
            /* Load Game scene */
            guard let scene = Credits(fileNamed:"Credits") as Credits! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
    }
    
    func setButtons() {
        /* Set button size */
//        let buttonSize = CGSize(width: 120, height: 120)
        
        /* button Item List */
        let buttonItemList = SKSpriteNode(imageNamed: "buttonItemList")
        buttonItemList.position = CGPoint(x: 0, y: 0)
        buttonItemList.name = "buttonItemList"
        buttonItemList.zPosition = 3
        addChild(buttonItemList)
        
        /* button Tutorial */
        let buttonTutorial = SKSpriteNode(imageNamed: "buttonTutorial")
        buttonTutorial.position = CGPoint(x: 0, y: self.size.height/4)
        buttonTutorial.name = "buttonTutorial"
        buttonTutorial.zPosition = 3
        addChild(buttonTutorial)
        
        /* button Credits */
        let buttonCredits = SKSpriteNode(imageNamed: "buttonCredits")
        buttonCredits.position = CGPoint(x: 0, y: -self.size.height/4)
        buttonCredits.name = "buttonCredits"
        buttonCredits.zPosition = 3
        addChild(buttonCredits)
        
    }
}
