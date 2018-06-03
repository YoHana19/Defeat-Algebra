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
    static let doctorOnPos = CGPoint(x: 170, y: 500)
    static let doctorOffPos = CGPoint(x: -170, y: 500)
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
        CharacterAniController.move(character: doctor, dest: doctorOnPos, duration: 0.5)
    }
    
    public static func showMadDoctor() {
        CharacterAniController.move(character: madDoctor, dest: madDoctorOnPos, duration: 0.5)
    }
    
    public static func retreatDoctor() {
        CharacterAniController.move(character: doctor, dest: doctorOffPos, duration: 0.5)
    }
    
    public static func retreatMadDoctor() {
        CharacterAniController.move(character: madDoctor, dest: madDoctorOffPos, duration: 0.5)
    }
    
    public static func shakeDoctor() {
        CharacterAniController.shake(node: doctor)
    }
    
    public static func shakeMadDoctor() {
        CharacterAniController.shake(node: madDoctor)
    }
}
