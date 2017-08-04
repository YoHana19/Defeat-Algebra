//
//  MainMenu.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var buttonNewGame: MSButtonNode!
    var buttonContinue: MSButtonNode!
//    var buttonTutorial: MSButtonNode!
    
    /* Flag */
    static var playDoneFlag = false
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Check user has played */
        let ud = UserDefaults.standard
        MainMenu.playDoneFlag = ud.bool(forKey: "userPlayed")
        
        /* Set UI connections */
        buttonNewGame = self.childNode(withName: "buttonNewGame") as! MSButtonNode
        buttonContinue = self.childNode(withName: "buttonContinue") as! MSButtonNode
//        buttonTutorial = self.childNode(withName: "buttonTutorial") as! MSButtonNode
        if MainMenu.playDoneFlag == false {
            buttonContinue.state = .msButtonNodeStateHidden
//            buttonTutorial.state = .msButtonNodeStateHidden
        }
        
        buttonNewGame.selectedHandler = {
            /* Store game property */
            let ud = UserDefaults.standard
            /* Stage level */
            ud.set(0, forKey: "stageLevel")
            /* Hero */
            ud.set([1], forKey: "moveLevelArray")
            /* item */
            let itemNameArray = [String]()
            ud.set(itemNameArray, forKey: "itemNameArray")
            /* life */
            ud.set(3, forKey: "life")
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        buttonContinue.selectedHandler = {
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
//        buttonTutorial.selectedHandler = {
//            /* Grab reference to the SpriteKit view */
//            let skView = self.view as SKView!
//            
//            /* Load Game scene */
//            guard let scene = Tutorial(fileNamed:"Tutorial") as GameScene! else {
//                return
//            }
//            
//            /* Ensure correct aspect mode */
//            scene.scaleMode = .aspectFill
//            
//            /* Restart GameScene */
//            skView?.presentScene(scene)
//        }       
        
        /* Set Algebra Robot */
//        setEnemy()
        
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
    
}
