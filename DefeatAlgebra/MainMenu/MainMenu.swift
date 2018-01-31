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
    var buttonTutorial: MSButtonNode!
    var buttonEasy: SKNode!
    var buttonHard: SKNode!
    var settingScreen: SettingScreen!
    var confirmScreen: ConfirmScreen!
    var bgEasy: SKNode!
    var bgHard: SKNode!
    
    /* Flag */
    static var tutorialHeroDone = false
    static var tutorialEnemyDone = false
    static var tutorialAttackDone = false
    static var tutorialPracticeDone = false
    static var tutorialTimeBombDone = false
    static var tutorialAllDone = false
    
    var confirmingNewGameFlag = false
    
    var notInitialFlag = true
    
    /* Mode easy or hard */
    static var modeHard = false /* Set easy mode initially */
    
    /* Sound */
    static var soundOnFlag = true
    var sound = BGM(bgm: 1)
    var soundHard = BGM(bgm: 3)
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Check user has played */
        let ud = UserDefaults.standard
        notInitialFlag = ud.bool(forKey: "notInitialFlag")
        MainMenu.tutorialHeroDone = ud.bool(forKey: "tutorialHeroDone")
        MainMenu.tutorialEnemyDone = ud.bool(forKey: "tutorialEnemyDone")
        MainMenu.tutorialAttackDone = ud.bool(forKey: "tutorialAttackDone")
        MainMenu.tutorialPracticeDone = ud.bool(forKey: "tutorialPracticeDone")
        MainMenu.tutorialTimeBombDone = ud.bool(forKey: "tutorialTimeBombDone")
        MainMenu.tutorialAllDone = ud.bool(forKey: "tutorialAllDone")
        MainMenu.soundOnFlag = ud.bool(forKey: "soundOn")
        if notInitialFlag == false {
            MainMenu.soundOnFlag = true
            ud.set(true, forKey: "notInitialFlag")
        }
        
        /* Set selected mode last time */
        MainMenu.modeHard = ud.bool(forKey: "mode")
        
        /* Set UI connections */
        buttonNewGame = self.childNode(withName: "buttonNewGame") as! MSButtonNode
        buttonContinue = self.childNode(withName: "buttonContinue") as! MSButtonNode
        buttonTutorial = self.childNode(withName: "buttonTutorial") as! MSButtonNode
        buttonEasy = self.childNode(withName: "buttonEasy")
        buttonHard = self.childNode(withName: "buttonHard")
        /* Before tutorial done */
        if MainMenu.tutorialAllDone == false {
            buttonNewGame.state = .msButtonNodeStateHidden
            buttonContinue.state = .msButtonNodeStateHidden
            buttonEasy.isHidden = true
            buttonHard.isHidden = true
        /* After tutorial done */
        } else {
            buttonTutorial.state = .msButtonNodeStateHidden
        }
        
        /* Back ground picture */
        bgEasy = self.childNode(withName: "bgEasy")
        bgHard = self.childNode(withName: "bgHard")
        /* If mode is hard, hide easy button */
        if MainMenu.modeHard {
            buttonEasy.isHidden = true
            bgEasy.isHidden = true
        }
        
        /* Sound */
        if MainMenu.soundOnFlag {
            /* Easy mode */
            if MainMenu.modeHard == false {
                sound.play()
                sound.numberOfLoops = -1
            /* Hard mode */
            } else {
                soundHard.play()
                soundHard.numberOfLoops = -1
            }
        }
        
        /* Start tutorial */
        buttonTutorial.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView!
            
            /* Load Game scene */
            guard let scene = Tutorial(fileNamed:"Tutorial") as Tutorial! else {
                return
            }
            
            Tutorial.tutorialPhase = 0
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* New game */
        buttonNewGame.selectedHandler = { [weak self] in
            self?.confirmScreen.isHidden = false
            self?.confirmingNewGameFlag = true
                
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("selectNewGame.wav", waitForCompletion: true)
                self!.run(sound)
            }
        }
        
        /* Continue */
        buttonContinue.selectedHandler = { [weak self] in
            
            /* Easy mode */
            if MainMenu.modeHard == false {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                /* Load Game scene */
                guard let scene = GameSceneEasy(fileNamed:"GameSceneEasy") as GameSceneEasy! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: false)
                    scene.run(sound)
                }
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            /* Hard mode */
            } else {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView!
                
                /* Load Game scene */
                guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: false)
                    scene.run(sound)
                }
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            }
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
        
        /* Toggle easy or hard mode */
        /* Select hard mode */
        if nodeAtPoint.name == "buttonEasy" {
            /* Hide easy button and background */
            buttonEasy.isHidden = true
            bgEasy.isHidden = true
            
            /* Set and store mode state */
            MainMenu.modeHard = true
            let ud = UserDefaults.standard
            ud.set(true, forKey: "mode")
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                sound.stop()
                soundHard.play()
                soundHard.numberOfLoops = -1
            }
            
        /* Select easy mode */
        } else if nodeAtPoint.name == "buttonHard" {
            /* Show up easy button and background */
            buttonEasy.isHidden = false
            bgEasy.isHidden = false
            
            /* Set and store mode state */
            MainMenu.modeHard = false
            let ud = UserDefaults.standard
            ud.set(false, forKey: "mode")
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                soundHard.stop()
                sound.play()
                sound.numberOfLoops = -1
            }
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
