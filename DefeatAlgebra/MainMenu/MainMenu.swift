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
    
    public static let uncoverSignalStartTurn = 1
    public static let changeMoveSpanStartTurn = 2
    public static let timeBombStartTurn = 3
    public static let moveExplainStartTurn = 5
    public static let showUnsimplifiedStartTurn = 6
    public static let eqRobStartTurn = 7
    public static let secondDayStartTurn = 10
    public static let cannonStartTurn = 14
    public static let invisibleStartTurn = 17
    public static let lastTurn = 19
    
    /* UI Connections */
    var buttonNewGame: MSButtonNode!
    var buttonContinue: MSButtonNode!
    var settingScreen: SettingScreen!
    var confirmScreen: ConfirmScreen!
    var passwordScreen: PasswordScreen!
    var buttonMute: SKSpriteNode!
    var buttonSoundOn: SKSpriteNode!
    
    var confirmingNewGameFlag = false
    
    /* Sound */
    static var soundOnFlag = true
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Check user has played */
        let ud = UserDefaults.standard
        
        MainMenu.soundOnFlag = ud.bool(forKey: "soundOn")
        if !ud.bool(forKey: "notInitialFlag") {
            MainMenu.soundOnFlag = true
            ud.set(true, forKey: "notInitialFlag")
        }
        
        /* Set UI connections */
        buttonNewGame = self.childNode(withName: "buttonNewGame") as! MSButtonNode
        buttonContinue = self.childNode(withName: "buttonContinue") as! MSButtonNode
        
        if !ud.bool(forKey: "initialScenario") {
            buttonContinue.isHidden = true
            buttonNewGame.position = CGPoint(x: buttonNewGame.position.x, y: buttonNewGame.position.y-100)
        } else {
            buttonNewGame.isHidden = true
            buttonContinue.position = CGPoint(x: buttonNewGame.position.x, y: buttonNewGame.position.y-100)
        }
        
        /* Sound */
        SoundController.playBGM(bgm: .MainMenu, isLoop: true)
        
        /* New game */
        buttonNewGame.selectedHandler = { [weak self] in
            if !ud.bool(forKey: "initialScenario") {
                /* Reset game property */
                DAUserDefaultUtility.resetData()
                /* Grab reference to the SpriteKit view */
                let skView = self?.view as SKView?
                /* Play Sound */
                SoundController.sound(scene: self, sound: .ButtonMove)
                
                /* Load Game scene */
                guard let scene = ScenarioScene(fileNamed: "ScenarioScene") as ScenarioScene? else {
                    return
                }
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .aspectFit
                
                /* Restart GameScene */
                skView?.presentScene(scene)
                
            } else {
                self?.showConfirm()
            }
        }
        
        /* Continue */
        buttonContinue.selectedHandler = { [weak self] in
            GameScene.stageLevel = UserDefaults.standard.integer(forKey: "stageLevel")
            GameStageController.stageManager(scene: self, next: 0)
        }
        
        setSoundButton()
        
        passwordScreen = PasswordScreen()
        addChild(passwordScreen)
        
        /* Set setting screen */
        settingScreen = SettingScreen()
        addChild(settingScreen)
        
        /* Set confirm screen for new game */
        confirmScreen = ConfirmScreen()
        addChild(confirmScreen)
        
        if MainMenu.soundOnFlag {
            buttonMute.isHidden = true
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard confirmingNewGameFlag == false else { return }
        
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonSetting" {
            /* Play Sound */
            if settingScreen.isActive {
                SoundController.sound(scene: self, sound: .ButtonBack)
            } else {
                SoundController.sound(scene: self, sound: .ButtonMove)
            }
            
            if settingScreen.isActive {
               settingScreen.isActive = false
            } else {
                passwordScreen.isActive = !passwordScreen.isActive
            }
        }
        
        if nodeAtPoint.name == "buttonMute" {
            buttonMute.isHidden = true
            MainMenu.soundOnFlag = true
            SoundController.playBGM(bgm: .MainMenu, isLoop: true)
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
    
    func setSoundButton() {
        /* Sound button mute */
        buttonMute = SKSpriteNode(imageNamed: "mute")
        buttonMute.position = CGPoint(x: 80, y: 75)
        buttonMute.size = CGSize(width: 95, height: 95)
        buttonMute.name = "buttonMute"
        buttonMute.zPosition = 4
        addChild(buttonMute)
        
        /* Sound button on */
        buttonSoundOn = SKSpriteNode(imageNamed: "soundOn")
        buttonSoundOn.position = CGPoint(x: 80, y: 75)
        buttonSoundOn.size = CGSize(width: 95, height: 95)
        buttonSoundOn.name = "buttonSoundOn"
        buttonSoundOn.zPosition = 3
        addChild(buttonSoundOn)
    }
    
    public func loadLevelSelect() {
        /* Grab reference to the SpriteKit view */
        let skView = self.view as SKView?
        
        /* Debug */
        guard let scene = LevelSelectMenu(fileNamed:"LevelSelectMenu") as LevelSelectMenu? else {
            return
        }
        
        /* Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Restart GameScene */
        skView?.presentScene(scene)
    }
    
    public func showConfirm() {
        self.confirmScreen.isHidden = false
        self.confirmingNewGameFlag = true
        
        /* Play Sound */
        SoundController.sound(scene: self, sound: .UtilButton)
    }
}
