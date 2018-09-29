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
    var settingScreen: SettingScreen!
    var confirmScreen: ConfirmScreen!
    var buttonLevelSelect: MSButtonNode!
    
    var confirmingNewGameFlag = false
    var notInitialFlag = true
    
    /* Sound */
    static var soundOnFlag = true
    var sound = BGM(bgm: 1)
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Check user has played */
        let ud = UserDefaults.standard
        notInitialFlag = ud.bool(forKey: "notInitialFlag")
        MainMenu.soundOnFlag = ud.bool(forKey: "soundOn")
        if notInitialFlag == false {
            MainMenu.soundOnFlag = true
            ud.set(true, forKey: "notInitialFlag")
        }
        
        /* Set UI connections */
        buttonNewGame = self.childNode(withName: "buttonNewGame") as! MSButtonNode
        buttonContinue = self.childNode(withName: "buttonContinue") as! MSButtonNode
        buttonLevelSelect = self.childNode(withName: "LevelSelect") as! MSButtonNode
        
        if !ud.bool(forKey: "initialScenarioFirst") {
            buttonContinue.isHidden = true
            buttonNewGame.position = CGPoint(x: buttonNewGame.position.x, y: buttonNewGame.position.y-100)
        }
        
        /* Sound */
        if MainMenu.soundOnFlag {
            sound.play()
            sound.numberOfLoops = -1
        }
        
        /* For Debug */
        buttonLevelSelect.selectedHandler = { [weak self] in
            /* Grab reference to the SpriteKit view */
            let skView = self?.view as SKView?
            
            /* Debug */
            guard let scene = LevelSelectMenu(fileNamed:"LevelSelectMenu") as LevelSelectMenu? else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
        
        /* New game */
        buttonNewGame.selectedHandler = { [weak self] in
            if !ud.bool(forKey: "initialScenarioFirst") {
                /* Reset game property */
                DAUserDefaultUtility.resetData()
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView?
                
                /* Load Game scene */
                guard let scene = ScenarioScene(fileNamed: "ScenarioScene") as ScenarioScene? else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("buttonMove.wav", waitForCompletion: true)
                    self?.run(sound)
                }
            } else {
                self?.confirmScreen.isHidden = false
                self?.confirmingNewGameFlag = true
                
                /* Play Sound */
                if MainMenu.soundOnFlag {
                    let sound = SKAction.playSoundFileNamed("selectNewGame.wav", waitForCompletion: true)
                    self!.run(sound)
                }
            }
        }
        
        /* Continue */
        buttonContinue.selectedHandler = { [weak self] in
            
            GameScene.stageLevel = UserDefaults.standard.integer(forKey: "stageLevel")
            
            if GameScene.stageLevel == 0 || GameScene.stageLevel == 2 || GameScene.stageLevel == 4 || GameScene.stageLevel == 6 || GameScene.stageLevel == 7 {
                
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView?
                
                /* Load Game scene */
                guard let scene = ScenarioScene(fileNamed:"ScenarioScene") as ScenarioScene? else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
            } else {
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView?
                
                /* Load Game scene */
                guard let scene = GameScene(fileNamed:"GameScene") as GameScene? else {
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
}
