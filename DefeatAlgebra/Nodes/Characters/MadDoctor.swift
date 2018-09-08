//
//  MadDoctor.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class MadDoctor: DACharacter {
    
    let balloonPos = CGPoint(x: 300, y: 0)
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "madScientist2")
        super.init(charaTexture: texture, charaSize: CharacterController.madDoctorSize)
        
        self.balloon.texture = balloon.texture1
        self.balloon.position = balloonPos
        self.balloon.isHidden = true
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
