//
//  MainMenu.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Credits: SKScene {
    
    let textArray = [
        "* Time Bomb is from AstroMenace Artwork ver 1.2 Assets",
        " Copyright (c) 2006-2007 Michael Kurinnoy, Viewizard",
        "* Enemy was created by Stephen Challener (Redshrike),",
        "hosted by OpenGameArt.org",
        "* Hero was created by Sharm (Lanea Zimmerman)",
        "* BackGround Image is from the PlatForge project",
        "created by Summer Thaxton and Hannah Cohan",
        "* Wall item was by Alejandro Ballestrino, made for",
        "Exiled Kingdoms game: http://www.exiledkingdoms.com",
        "* Some buttons were created by Ironthunder",
        "* Spear Icon was created by Scrittl",
        "* Battle Ship Icon was created by Skorpio",
        "* Sword Icon was created by Ironthunder",
        "* Wrench Icon was created by RDT",
        "* Teleport Icon was created by craftpix.net",
        "* Reinforcement Icon was created by Santiago Iborra",
        "* Town Wall image was created by Hyptosis",
        "* Town Floor image was created by jesusmora",
        "* Main BGM was created by Snabisch",
        "* Game Over sound was created by remaxim",
        "* Featuring Music by Matthew Pablo",
        "http://www.matthewpablo.com",
        "* Some button sounds were created",
        "by ViRiX Dreamcore soundcloud.com/virix",
        "* Some button sounds were created",
        "by David McKee (ViRiX) soundcloud.com/virix",
        "* Some BGM were created by syncopika",
        "* Some sounds were created by spookymodem, Foundation",
        "submitted by Lamoot, Bart Kelsey submitted by bart"
    ]
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        for (i, text) in textArray.enumerated() {
            let positionY = self.size.height-CGFloat(i*40+60)
            createTutorialLabel(text: text, posY: positionY)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonBack" {
            
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
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
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
    
    /* Create label for tutorial */
    func createTutorialLabel(text: String, posY: CGFloat) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        /* Set text */
        label.text = text
        /* Set font size */
        label.fontSize = 25
        /* Set zPosition */
        label.zPosition = 2
        /* Set position */
        label.position = CGPoint(x: self.size.width/2, y: posY)
        /* Add to Scene */
        self.addChild(label)
    }
    
}
