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
    init() {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "madScientist2")
        super.init(charaTexture: texture, charaSize: CharacterController.madDoctorSize)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
