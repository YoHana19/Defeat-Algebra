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
        zPosition = 100
        
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
        let mainMenu = self.parent as! MainMenu
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonTutorial" {
            /*
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView?
            
            /* Load Game scene */
            guard let scene = Tutorial1(fileNamed:"Tutorial1") as Tutorial1? else {
                return
            }
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
            //Tutorial.tutorialPhase = 0
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            */
        } else if nodeAtPoint.name == "buttonItemList" {
            
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView?
            
            /* Load Game scene */
            guard let scene = DataSelectMenu(fileNamed:"DataSelectMenu") as DataSelectMenu? else {
                return
            }
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
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
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        } else if nodeAtPoint.name == "buttonMute" {
            buttonMute.isHidden = true
            MainMenu.soundOnFlag = true
            mainMenu.sound.play()
            mainMenu.sound.numberOfLoops = -1
            let ud = UserDefaults.standard
            ud.set(true, forKey: "soundOn")
        } else if nodeAtPoint.name == "buttonSoundOn" {
            buttonMute.isHidden = false
            MainMenu.soundOnFlag = false
            mainMenu.sound.stop()
            let ud = UserDefaults.standard
            ud.set(false, forKey: "soundOn")
        }
    }
    
    func setButtons() {
        /* Set button size */
//        let buttonSize = CGSize(width: 120, height: 120)
        
        /* button Item List */
        let buttonItemList = SKSpriteNode(imageNamed: "buttonItemList")
        buttonItemList.position = CGPoint(x: 0, y: 30)
        buttonItemList.name = "buttonItemList"
        buttonItemList.zPosition = 3
        addChild(buttonItemList)
        
        /* button Tutorial */
        let buttonTutorial = SKSpriteNode(imageNamed: "buttonTutorial")
        buttonTutorial.position = CGPoint(x: 0, y: self.size.height/4+30)
        buttonTutorial.name = "buttonTutorial"
        buttonTutorial.zPosition = 3
        addChild(buttonTutorial)
        
        /* button Credits */
        let buttonCredits = SKSpriteNode(imageNamed: "buttonCredits")
        buttonCredits.position = CGPoint(x: 0, y: -self.size.height/4+30)
        buttonCredits.name = "buttonCredits"
        buttonCredits.zPosition = 3
        addChild(buttonCredits)
        
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
