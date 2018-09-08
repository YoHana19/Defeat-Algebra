//
//  MainHero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class MainHero: DACharacter {
    
    let balloonPos = CGPoint(x: -300, y: -70)
    let balloon1Pos = CGPoint(x: 300, y: -70)
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "mainHero")
        super.init(charaTexture: texture, charaSize: CharacterController.mainHeroSize)
        
        self.balloon.position = balloonPos
        self.balloon.texture = balloon.texture2
        self.balloon.isHidden = true
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
