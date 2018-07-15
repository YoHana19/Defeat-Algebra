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
    
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "goodDoctorDefault")
        super.init(charaTexture: texture, charaSize: CharacterController.doctorSize)
        
        self.balloon.position = CGPoint(x: 300, y: 170)
        self.balloon.isHidden = true
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
