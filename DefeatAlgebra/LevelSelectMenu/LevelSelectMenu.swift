//
//  LevelSelectMenu.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/23.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class LevelSelectMenu: SKScene {
    /* UI Connections */
    var button1: MSButtonNode!
    var button2: MSButtonNode!
    var button3: MSButtonNode!
    var button4: MSButtonNode!
    var button5: MSButtonNode!
    var button6: MSButtonNode!
    var button7: MSButtonNode!
    var button8: MSButtonNode!
    var button9: MSButtonNode!
    var buttonBack: MSButtonNode!
    
    let ud = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        button1 = self.childNode(withName: "button1") as! MSButtonNode
        button2 = self.childNode(withName: "button2") as! MSButtonNode
        button3 = self.childNode(withName: "button3") as! MSButtonNode
        button4 = self.childNode(withName: "button4") as! MSButtonNode
        button5 = self.childNode(withName: "button5") as! MSButtonNode
        button6 = self.childNode(withName: "button6") as! MSButtonNode
        button7 = self.childNode(withName: "button7") as! MSButtonNode
        button8 = self.childNode(withName: "button8") as! MSButtonNode
        button9 = self.childNode(withName: "button9") as! MSButtonNode
        button9.isHidden = true
        buttonBack = self.childNode(withName: "buttonBack") as! MSButtonNode
        
        /* Start tutorial */
        button1.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
             /* Load Game scene */
             guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
             }
            
            scene.selectedLevel = 0
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 0
            self?.ud.set(0, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button2.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 1
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 1
            self?.ud.set(1, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button3.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 2
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 2
            self?.ud.set(2, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button4.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 3
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 3
            self?.ud.set(3, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button5.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 4
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 4
            self?.ud.set(4, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button6.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 5
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 5
            self?.ud.set(5, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button7.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 6
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 6
            self?.ud.set(6, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        button8.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 7
            self?.ud.set(4, forKey: "moveLevel")
            GameScene.stageLevel = 7
            self?.ud.set(7, forKey: "stageLevel")
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
            
        }
        
        /*
        button9.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
                return
            }
            
            scene.selectedLevel = 8
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        */
        
        buttonBack.selectedHandler = { [weak self] in
            let skView = self?.view as SKView?
            
            /* Load Game scene */
            guard let scene = MainMenu(fileNamed: "MainMenu") as MainMenu? else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
    }
}
