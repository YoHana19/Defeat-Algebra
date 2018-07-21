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
    static let doctorSize = CGSize(width: 264, height: 310.4)
    static let doctorOnPos = CGPoint(x: 170, y: 500)
    static let doctorOffPos = CGPoint(x: -350, y: 500)
    
    static let madDoctorSize = CGSize(width: 228.8, height: 422.5)
    static let madDoctorOnPos = CGPoint(x: 180, y: 1100)
    static let madDoctorOffPos = CGPoint(x: 180, y: 1600)
    
    static let mainHeroOnPos = CGPoint(x: 700, y: 300)
    static let mainHeroOffPos = CGPoint(x: 700, y: 300)
    
    static var doctor: Doctor = Doctor()
    static var madDoctor: MadDoctor = MadDoctor()
    
    public static func setCharacter(scene: SKScene) {
        setDoctor(scene: scene)
        setMadDoctor(scene: scene)
    }
    
    private static func setDoctor(scene: SKScene) {
        doctor.position = doctorOffPos
        scene.addChild(doctor)
    }
    
    private static func setMadDoctor(scene: SKScene) {
        madDoctor.position = madDoctorOffPos
        scene.addChild(madDoctor)
    }
    
    public static func showDoctor() {
        doctor.move(from: nil, to: doctorOnPos)
    }
    
    public static func showMadDoctor() {
        madDoctor.move(from: nil, to: madDoctorOnPos)
    }
    
    public static func retreatDoctor() {
        doctor.move(from: nil, to: doctorOffPos)
    }
    
    public static func retreatMadDoctor() {
        madDoctor.move(from: nil, to: madDoctorOffPos)
    }
    
    public static func shakeDoctor() {
        doctor.shake()
    }
    
    public static func shakeMadDoctor() {
        madDoctor.shake()
    }
}
