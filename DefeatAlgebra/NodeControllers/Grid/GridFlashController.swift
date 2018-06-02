//
//  GridFlashController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class GridFlashController {
    public static var flashSpeed: Double = 0.5
    public static var numOfFlashUp = 3
    
    static func flashGrid(labelNode: SKLabelNode, grid: Grid) -> Int {
        /* Set the number of times of flash randomly */
        let numOfFlash = Int(arc4random_uniform(UInt32(numOfFlashUp)))+1
        
        flash(grid: grid, color: UIColor.red, numOfFlash: numOfFlash)
        
        /* Display the number of flash */
        displayFlashNum(grid: grid, labelNode: labelNode, numOfFlash: numOfFlash)
        
        return numOfFlash
    }
    
    static func flashGridForCane(labelNode: SKLabelNode, numOfFlash: Int, grid: Grid) {
        flash(grid: grid, color: UIColor.red, numOfFlash: numOfFlash)
        
        displayFlashNum(grid: grid, labelNode: labelNode, numOfFlash: numOfFlash)
    }
    
    private static func flash(grid: Grid, color: UIColor, numOfFlash: Int) {
        /* Play Sound */
        if MainMenu.soundOnFlag {
            let sound = SKAction.playSoundFileNamed("flash.wav", waitForCompletion: true)
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: color, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let group = SKAction.group([sound, seqFlash])
            let flash = SKAction.repeat(group, count: numOfFlash)
            grid.run(flash)
            
        } else {
            /* Set flash animation */
            let fadeInColorlize = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: TimeInterval(self.flashSpeed/4))
            let wait = SKAction.wait(forDuration: TimeInterval(self.flashSpeed/4))
            let fadeOutColorlize = SKAction.colorize(with: color, colorBlendFactor: 0, duration: TimeInterval(self.flashSpeed/4))
            let seqFlash = SKAction.sequence([fadeInColorlize, wait, fadeOutColorlize, wait])
            let flash = SKAction.repeat(seqFlash, count: numOfFlash)
            grid.run(flash)
            
        }
    }
    
    private static func displayFlashNum(grid: Grid, labelNode: SKLabelNode, numOfFlash: Int) {
        /* Display the number of flash */
        let wholeWait = SKAction.wait(forDuration: TimeInterval((self.flashSpeed+0.2)*Double(numOfFlash)))
        let display = SKAction.run({ labelNode.text = String(numOfFlash) })
        let seq = SKAction.sequence([wholeWait, display])
        grid.run(seq)
    }
}
