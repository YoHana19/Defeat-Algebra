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
    var button10: MSButtonNode!
    var button11: MSButtonNode!
    var button12: MSButtonNode!
    var button13: MSButtonNode!
    var button14: MSButtonNode!
    var button15: MSButtonNode!
    var button16: MSButtonNode!
    var button17: MSButtonNode!
    var button18: MSButtonNode!
    var button19: MSButtonNode!
    var button20: MSButtonNode!
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
        button10 = self.childNode(withName: "button10") as! MSButtonNode
        button11 = self.childNode(withName: "button11") as! MSButtonNode
        button12 = self.childNode(withName: "button12") as! MSButtonNode
        button13 = self.childNode(withName: "button13") as! MSButtonNode
        button14 = self.childNode(withName: "button14") as! MSButtonNode
        button15 = self.childNode(withName: "button15") as! MSButtonNode
        button16 = self.childNode(withName: "button16") as! MSButtonNode
        button17 = self.childNode(withName: "button17") as! MSButtonNode
        button18 = self.childNode(withName: "button18") as! MSButtonNode
        button19 = self.childNode(withName: "button19") as! MSButtonNode
        button20 = self.childNode(withName: "button20") as! MSButtonNode
        buttonBack = self.childNode(withName: "buttonBack") as! MSButtonNode
        
        /* Start tutorial */
        button1.selectedHandler = { [weak self] in
            self?.loadScene(level: 1)
            
        }
        
        button2.selectedHandler = { [weak self] in
            self?.loadScene(level: 2)
        }
        
        button3.selectedHandler = { [weak self] in
            self?.loadScene(level: 3)
        }
        
        button4.selectedHandler = { [weak self] in
            self?.loadScene(level: 4)
        }
        
        button5.selectedHandler = { [weak self] in
            self?.loadScene(level: 5)
        }
        
        button6.selectedHandler = { [weak self] in
            self?.loadScene(level: 6)
        }
        
        button7.selectedHandler = { [weak self] in
            self?.loadScene(level: 7)
        }
        
        button8.selectedHandler = { [weak self] in
            self?.loadScene(level: 8)
        }
        
        button9.selectedHandler = { [weak self] in
            self?.loadScene(level: 9)
        }
        
        button10.selectedHandler = { [weak self] in
            self?.loadScene(level: 10)
        }
        
        button11.selectedHandler = { [weak self] in
            self?.loadScene(level: 11)
        }
        
        button12.selectedHandler = { [weak self] in
            self?.loadScene(level: 12)
        }
        
        button13.selectedHandler = { [weak self] in
            self?.loadScene(level: 13)
        }
        
        button14.selectedHandler = { [weak self] in
            self?.loadScene(level: 14)
        }
        
        button15.selectedHandler = { [weak self] in
            self?.loadScene(level: 15)
        }
        
        button16.selectedHandler = { [weak self] in
            self?.loadScene(level: 16)
        }
        
        button17.selectedHandler = { [weak self] in
            self?.loadScene(level: 17)
        }
        button18.selectedHandler = { [weak self] in
            self?.loadScene(level: 18)
        }
        button19.selectedHandler = { [weak self] in
            self?.loadScene(level: 19)
        }
        button20.selectedHandler = { [weak self] in
            self?.loadScene(level: 20)
        }
        
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
    
    private func loadScene(level: Int) {
        GameScene.stageLevel = level-1
        self.ud.set(level-1, forKey: "stageLevel")
        GameStageController.stageManager(scene: self, next: 0)
    }
}
