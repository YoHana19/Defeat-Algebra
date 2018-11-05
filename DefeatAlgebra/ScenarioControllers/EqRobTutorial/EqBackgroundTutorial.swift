//
//  EqBackgroundTutorial.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/11/06.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class EqBackgroundTutorial: EqBackground {
    
    override init(gameScene: GameScene, enemies: [Enemy], eqRob: EqRob?) {
        /* Initialize with enemy asset */
        
        super.init(gameScene: gameScene, enemies: enemies, eqRob: eqRob)
        
        self.enemies = enemies
        self.eqRob = eqRob
        
        isUserInteractionEnabled = true
        
        self.position = CGPoint(x: 0, y: 0)
        /* Set Z-Position, ensure ontop of screen */
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0, y: 0)
        gameScene.addChild(self)
        
        self.name = "eqBackground"
        
        setSimulator()
        curVeSim = enemyVeSim
        
        /* Set buttons */
        setSignals()
        setButton()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
