//
//  BalloonController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/17.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class BalloonController {
    static let offPos = CGPoint(x: -300, y: 500)
    static let forDoctorOnPos = CGPoint(x: 470, y: 670)
    static let forDoctorOffPos = CGPoint(x: -170, y: 500)
    static let forMadDoctorOnPos = CGPoint(x: 180, y: 1100)
    static let forMadDoctorOffPos = CGPoint(x: 180, y: 1600)
    static let forMainHeroOnPos = CGPoint(x: 700, y: 300)
    static let forMainHeroOffPos = CGPoint(x: 700, y: 300)
    
    static var balloon: Balloon = Balloon()
    
    public static func setBaloon(scene: SKScene) {
        balloon.position = offPos
        scene.addChild(balloon)
    }
    
    public static func setBaloonForDoctor(scene: SKScene) {
        balloon.position = forDoctorOnPos
    }
    
    public static func setBaloonForMadDoctor(scene: SKScene) {
        balloon.position = forMadDoctorOnPos
    }
    
    public static func setBaloonForMainHero(scene: SKScene) {
        balloon.position = forMainHeroOnPos
    }
    
}
