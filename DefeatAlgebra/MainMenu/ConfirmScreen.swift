//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class ConfirmScreen: SKSpriteNode {
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "confirmBase")
        let bodySize = CGSize(width: 700, height: 454)
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
        
        if nodeAtPoint.name == "yes" {
            
            /* Reset game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(0, forKey: "stageLevelEasy")
            /* Hero */
            ud.set([1], forKey: "moveLevelArrayEasy")
            /* item */
            let itemNameArray = [String]()
            ud.set(itemNameArray, forKey: "itemNameArrayEasy")
            /* life */
            ud.set(3, forKey: "lifeEasy")
            
            /* Grab reference to the SpriteKit view */
            let skView = mainMenu.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                self.run(sound)
            }
            
            mainMenu.confirmingNewGameFlag = false
            self.isHidden = true
            
        } else if nodeAtPoint.name == "no" {
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonBack.wav", waitForCompletion: true)
                self.run(sound)
            }
            
            mainMenu.confirmingNewGameFlag = false
            self.isHidden = true
        }
        
    }
    
    func setButtons() {
        /* Set button size */
        //        let buttonSize = CGSize(width: 120, height: 120)
        
        /* Yes */
        let buttonItemList = SKSpriteNode(imageNamed: "confirmYes")
        buttonItemList.position = CGPoint(x: 150, y: -70)
        buttonItemList.name = "yes"
        buttonItemList.zPosition = 3
        addChild(buttonItemList)
        
        /* No */
        let buttonTutorial = SKSpriteNode(imageNamed: "confirmNo")
        buttonTutorial.position = CGPoint(x: -150, y: -70)
        buttonTutorial.name = "no"
        buttonTutorial.zPosition = 3
        addChild(buttonTutorial)
        
    }
}
