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
    
    var settingScreen: SettingScreen!
    var confirmScreen: ConfirmScreen!
    
    /* Flag */
    static var tutorialHeroDone = false
    static var tutorialEnemyDone = false
    static var tutorialAttackDone = false
    static var tutorialPracticeDone = false
    static var tutorialTimeBombDone = false
    static var tutorialAllDone = false
    
    var confirmingNewGameFlag = false
    
    /* Sound */
    static var soundOnFlag = true
    var sound = BGM(bgm: 1)
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Check user has played */
        let ud = UserDefaults.standard
        MainMenu.tutorialHeroDone = ud.bool(forKey: "tutorialHeroDone")
        MainMenu.tutorialEnemyDone = ud.bool(forKey: "tutorialEnemyDone")
        MainMenu.tutorialAttackDone = ud.bool(forKey: "tutorialAttackDone")
        MainMenu.tutorialPracticeDone = ud.bool(forKey: "tutorialPracticeDone")
        MainMenu.tutorialTimeBombDone = ud.bool(forKey: "tutorialTimeBombDone")
        MainMenu.tutorialAllDone = ud.bool(forKey: "tutorialAllDone")
        MainMenu.soundOnFlag = ud.bool(forKey: "soundOn")
        
        /* Set UI connections */
        buttonNewGame = self.childNode(withName: "buttonNewGame") as! MSButtonNode
        buttonContinue = self.childNode(withName: "buttonContinue") as! MSButtonNode
        if MainMenu.tutorialAllDone == false {
            buttonContinue.state = .msButtonNodeStateHidden
            buttonNewGame.position.y = 365
        }
        
        /* Sound */
        if MainMenu.soundOnFlag {
            sound.play()
            sound.numberOfLoops = -1
        }
        
        buttonNewGame.selectedHandler = { [weak self] in
            if MainMenu.tutorialAllDone {
                self?.confirmScreen.isHidden = false
                self?.confirmingNewGameFlag = true
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("selectNewGame.wav", waitForCompletion: true)
                    self!.run(sound)
                }
            /* First Play */
            } else {
                
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                /* Load Game scene */
                guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                    return
                }
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                    scene.run(sound)
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFill
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
        }
        
        buttonContinue.selectedHandler = { [weak self] in
            
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: false)
                scene.run(sound)
            }
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
                
        /* Set Algebra Robot */
//        setEnemy()
        
        /* Set setting screen */
        settingScreen = SettingScreen()
        addChild(settingScreen)
        
        /* Set confirm screen for new game */
        confirmScreen = ConfirmScreen()
        addChild(confirmScreen)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard confirmingNewGameFlag == false else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonSetting" {
            /* Play Sound */
            if MainMenu.soundOnFlag {
                if settingScreen.isActive {
                    let sound = SKAction.playSoundFileNamed("buttonBack.wav", waitForCompletion: true)
                    self.run(sound)
                } else {
                    let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                    self.run(sound)
                }
            }
            settingScreen.isActive = !settingScreen.isActive
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
    
}
