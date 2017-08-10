//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class PauseScreenForTutorial: SKSpriteNode {
    
    var buttonMute: SKSpriteNode!
    var buttonSoundOn: SKSpriteNode!
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "settingScreen")
        let bodySize = CGSize(width: 630, height: 900)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        /* Enable own touch implementation for this node */
        isUserInteractionEnabled = true
        
        /* Set Z-Position, ensure ontop of grid */
        zPosition = 200
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 375, y: 670)
        self.isHidden = true
        
        /* Set buttons */
        setButtons()
        
        if MainMenu.soundOnFlag {
            buttonMute.isHidden = true
        }
        
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = self.parent as! Tutorial
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "pauseResume" {
            gameScene.pauseFlag = false
            self.isHidden = true
            
        } else if nodeAtPoint.name == "pauseRetry" {
            /* Stop Sound */
            gameScene.main.stop()
            
            /* Grab reference to the SpriteKit view */
            let skView = gameScene.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        } else if nodeAtPoint.name == "pauseMainMenu" {
            /* Stop Sound */
            gameScene.main.stop()
            
            /* Grab reference to the SpriteKit view */
            let skView = gameScene.view as SKView!
            
            /* Load Game scene */
            guard let scene = MainMenu(fileNamed:"MainMenu") as MainMenu! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        
        } else if nodeAtPoint.name == "buttonMute" {
            buttonMute.isHidden = true
            MainMenu.soundOnFlag = true
            gameScene.main.play()
            gameScene.stageClear.stop()
            let ud = UserDefaults.standard
            ud.set(true, forKey: "soundOn")
        } else if nodeAtPoint.name == "buttonSoundOn" {
            buttonMute.isHidden = false
            MainMenu.soundOnFlag = false
            gameScene.main.stop()
            gameScene.stageClear.stop()
            let ud = UserDefaults.standard
            ud.set(false, forKey: "soundOn")
        }
        
    }
    
    func setButtons() {
        
        /* button Resume */
        let buttonResume = SKSpriteNode(imageNamed: "pauseResume")
        buttonResume.position = CGPoint(x: 0, y: self.size.height/4+30)
        buttonResume.name = "pauseResume"
        buttonResume.zPosition = 3
        addChild(buttonResume)
        
        /* button Retry */
        let buttonRetry = SKSpriteNode(imageNamed: "pauseRetry")
        buttonRetry.position = CGPoint(x: 0, y: 30)
        buttonRetry.name = "pauseRetry"
        buttonRetry.zPosition = 3
        addChild(buttonRetry)
        
        /* button Main Menu */
        let buttonMainMenu = SKSpriteNode(imageNamed: "pauseMainMenu")
        buttonMainMenu.position = CGPoint(x: 0, y: -self.size.height/4+30)
        buttonMainMenu.name = "pauseMainMenu"
        buttonMainMenu.zPosition = 3
        addChild(buttonMainMenu)
        
        /* Sound button mute */
        buttonMute = SKSpriteNode(imageNamed: "mute")
        buttonMute.position = CGPoint(x: 195, y: -345)
        buttonMute.size = CGSize(width: 80, height: 80)
        buttonMute.name = "buttonMute"
        buttonMute.zPosition = 4
        addChild(buttonMute)
        
        /* Sound button on */
        buttonSoundOn = SKSpriteNode(imageNamed: "soundOn")
        buttonSoundOn.position = CGPoint(x: 195, y: -345)
        buttonSoundOn.size = CGSize(width: 80, height: 80)
        buttonSoundOn.name = "buttonSoundOn"
        buttonSoundOn.zPosition = 3
        addChild(buttonSoundOn)
    }
}
