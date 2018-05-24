//
//  CharacterController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/23.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CharacterController {
    static let doctorPos = CGPoint(x: -100, y: 300)
    static let madDoctorPos = CGPoint(x: 300, y: 1000)
    static let mainHeroPos = CGPoint(x: 700, y: 300)
    
    public static func setCharacter(scene: GameScene) {
        setDoctor(scene: scene)
        setMadDoctor(scene: scene)
    }
    
    private static func setDoctor(scene: GameScene) {
        let doctor = Doctor()
        doctor.position = doctorPos
        scene.addChild(doctor)
    }
    
    private static func setMadDoctor(scene: GameScene) {
        let madDoctor = MadDoctor()
        madDoctor.position = madDoctorPos
        scene.addChild(madDoctor)
    }
}
