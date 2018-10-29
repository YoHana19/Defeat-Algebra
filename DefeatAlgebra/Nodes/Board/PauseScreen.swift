//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class PauseScreen: SKSpriteNode {
    
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
        let gameScene = self.parent as! GameScene
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "pauseBack" {
            self.isHidden = true
            gameScene.pauseFlag = false
        } else if nodeAtPoint.name == "pauseRetry" {
            /* EqRob */
            EqRobController.back(2)
            
            CharacterController.resetCharacter()
            
            /* Sound */
            SoundController.stopBGM()
            
            /* Grab reference to the SpriteKit view */
            let skView = gameScene.view as SKView?
            
            ResetController.reset()
            
            if let _ = self.parent as? ScenarioScene {
                /* Load Game scene */
                guard let scene = ScenarioScene(fileNamed:"ScenarioScene") as ScenarioScene? else {
                    return
                }
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                /* Restart GameScene */
                skView?.presentScene(scene)
            } else {
                /* Load Game scene */
                guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                    return
                }
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
        } else if nodeAtPoint.name == "pauseHome" {
            /* EqRob */
            EqRobController.back(2)
            
            CharacterController.resetCharacter()
            
            /* Sound */
            SoundController.stopBGM()
            
            gameScene.isCharactersTurn = false
            gameScene.gridNode.isTutorial = false
            
            /* Grab reference to the SpriteKit view */
            let skView = gameScene.view as SKView?
            
            /* Load Game scene */
            guard let scene = MainMenu(fileNamed:"MainMenu") as MainMenu? else {
                return
            }
            
            ResetController.reset()
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        } else if nodeAtPoint.name == "buttonMute" {
            buttonMute.isHidden = true
            MainMenu.soundOnFlag = true
            if let _ = gameScene as? ScenarioScene {
                GameStageController.soundForScenario()
            } else {
                GameStageController.sound()
            }
            let ud = UserDefaults.standard
            ud.set(true, forKey: "soundOn")
        } else if nodeAtPoint.name == "buttonSoundOn" {
            buttonMute.isHidden = false
            SoundController.stopBGM()
            MainMenu.soundOnFlag = false
            let ud = UserDefaults.standard
            ud.set(false, forKey: "soundOn")
        }
        
    }
    
    func setButtons() {
        
        /* button Resume */
        let buttonRetry = SKSpriteNode(imageNamed: "pauseRetryJ")
        buttonRetry.position = CGPoint(x: 0, y: self.size.height/4+30)
        buttonRetry.name = "pauseRetry"
        buttonRetry.zPosition = 3
        addChild(buttonRetry)
        
        /* button Retry */
        let buttonHome = SKSpriteNode(imageNamed: "pauseHomeJ")
        buttonHome.position = CGPoint(x: 0, y: 30)
        buttonHome.name = "pauseHome"
        buttonHome.zPosition = 3
        addChild(buttonHome)
        
        /* button Main Menu */
        let buttonTutorial = SKSpriteNode(imageNamed: "pauseBackJ")
        buttonTutorial.position = CGPoint(x: 0, y: -self.size.height/4+30)
        buttonTutorial.name = "pauseBack"
        buttonTutorial.zPosition = 3
        addChild(buttonTutorial)
        
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
