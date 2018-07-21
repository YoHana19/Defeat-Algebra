//
//  Doctor.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Doctor: DACharacter {
    
    let balloon0Pos = CGPoint(x: 300, y: 170)
    let balloon1Pos = CGPoint(x: 300, y: -120)
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "goodDoctorDefault")
        super.init(charaTexture: texture, charaSize: CharacterController.doctorSize)
        
        self.balloon.position = balloon0Pos
        self.balloon.isHidden = true
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func changeBalloonTexture(index: Int) {
        if index == 0 {
            balloon.texture = balloon.texture0
            balloon.position = balloon0Pos
        } else {
            balloon.texture = balloon.texture1
            balloon.position = balloon1Pos
        }
    }
    
}
