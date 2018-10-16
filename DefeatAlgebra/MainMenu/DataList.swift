//
//  DataList.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/03.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class DataList: SKScene {
    
    /* Sound */
    var sound = BGM(bgm: 3)
    
    let titleSpace = 90
    let topSpace = 20
    let leftSpace: CGFloat = 20
    let lineSpace = 50
    
    var currentLevel = 0
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        createLabel(text: "stage \(currentLevel+1)", posY: -topSpace, fontSize: 45)
        showData()
        
        /* Sound */
        if MainMenu.soundOnFlag {
            sound.play()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        
        if nodeAtPoint.name == "buttonBack" {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView?
            
            /* Load Game scene */
            guard let scene = DataSelectMenu(fileNamed:"DataSelectMenu") as? DataSelectMenu else {
                return
            }
            
            /* Play Sound */
            if MainMenu.soundOnFlag {
                let sound = SKAction.playSoundFileNamed("buttonBack.wav", waitForCompletion: true)
                scene.run(sound)
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
    }
    
    private func showData() {
        for (i, dataType) in DataController.data.enumerated() {
            let valueText = DataController.withDrawData(type: dataType, level: currentLevel)
            let text = "\(dataType.rawValue): \(valueText)"
            createLabel(text: text, posY: -(topSpace+titleSpace+i*lineSpace))
        }
    }
    
    private func createLabel(text: String, posY: Int, fontSize: CGFloat = 35) {
        /* Set label with font */
        let label = SKLabelNode(fontNamed: DAFont.fontNameForTutorial)
        /* Set text */
        label.text = text
        /* Set font size */
        label.fontSize = fontSize
        /* Set zPosition */
        label.zPosition = 1
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .left
        /* Set position */
        label.position = CGPoint(x: leftSpace, y: CGFloat(posY))
        /* Add to Scene */
        addChild(label)
    }
    
}
