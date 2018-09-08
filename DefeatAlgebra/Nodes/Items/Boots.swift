//
//  Hero.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/07/09.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class Boots: Item {
    
    let tx = SKTexture(imageNamed: "boots")
    
    init() {
        /* Initialize with enemy asset */
        
        super.init(texture: tx, size: tx.size())
        
        setName()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setName() {
        self.name = "boots"
    }
}
