//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Wall: Item {
    
    var posX = 0
    var posY = 0
    let tx = SKTexture(imageNamed: "wall")
    let bodySize = CGSize(width: 60, height: 60)
    
    init() {
        /* Initialize with 'mine' asset */
        super.init(texture: tx, size: bodySize)
    
        /* For detect what object to tougch */
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "wall"
    }
}
