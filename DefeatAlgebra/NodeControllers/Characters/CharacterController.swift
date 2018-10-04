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
    
    static let mainHeroSize = CGSize(width: 230, height: 426)
    static let mainHeroOnPos = CGPoint(x: 630, y: 230)
    static let mainHeroOffPos = CGPoint(x: 1000, y: 230)
    
    static let miniMainHeroOnPos = CGPoint(x: 250, y: 120)
    static let miniMainHeroOffPos = CGPoint(x: 250, y: -300)
    
    static var doctor: Doctor = Doctor()
    static var madDoctor: MadDoctor = MadDoctor()
    static var mainHero: MainHero = MainHero()
    static var miniMainHero: MainHero = MainHero()
    
    public static func setCharacter(scene: SKScene) {
        setDoctor(scene: scene)
        setMadDoctor(scene: scene)
        setMainHero(scene: scene)
        setMiniMainHero(scene: scene)
    }
    
    public static func resetCharacter() {
        retreatDoctor()
        retreatMadDoctor()
        retreatMainHero()
    }
    
    private static func setDoctor(scene: SKScene) {
        doctor.position = doctorOffPos
        if let _ = doctor.parent {
            doctor.removeFromParent()
        }
        scene.addChild(doctor)
    }
    
    private static func setMadDoctor(scene: SKScene) {
        madDoctor.position = madDoctorOffPos
        if let _ = madDoctor.parent {
            madDoctor.removeFromParent()
        }
        scene.addChild(madDoctor)
    }
    
    private static func setMainHero(scene: SKScene) {
        mainHero.position = mainHeroOffPos
        if let _ = mainHero.parent {
            mainHero.removeFromParent()
        }
        scene.addChild(mainHero)
    }
    
    private static func setMiniMainHero(scene: SKScene) {
        miniMainHero.position = miniMainHeroOffPos
        if let _ = miniMainHero.parent {
            miniMainHero.removeFromParent()
        }
        miniMainHero.setScale(0.5)
        miniMainHero.balloon.texture = miniMainHero.balloon.texture1
        miniMainHero.balloon.position = miniMainHero.balloon1Pos
        miniMainHero.balloon.isHidden = false
        scene.addChild(miniMainHero)
    }
    
    public static func showDoctor() {
        if doctor.position != doctorOnPos {
            doctor.move(from: nil, to: doctorOnPos)
        }
    }
    
    public static func showMadDoctor() {
        if madDoctor.position != madDoctorOnPos {
            madDoctor.move(from: nil, to: madDoctorOnPos)
        }
    }
    
    public static func showMainHero() {
        if mainHero.position != mainHeroOnPos {
            mainHero.move(from: nil, to: mainHeroOnPos)
        }
    }
    
    public static func showMiniMainHero() {
        if miniMainHero.position != miniMainHeroOnPos {
            miniMainHero.move(from: nil, to: miniMainHeroOnPos)
        }
    }
    
    public static func retreatDoctor() {
        doctor.move(from: nil, to: doctorOffPos)
        doctor.balloon.isHidden = true
    }
    
    public static func retreatMadDoctor() {
        madDoctor.move(from: nil, to: madDoctorOffPos)
        madDoctor.balloon.isHidden = true
    }
    
    public static func retreatMainHero() {
        mainHero.move(from: nil, to: mainHeroOffPos)
        mainHero.balloon.isHidden = true
    }
    
    public static func retreatMiniMainHero() {
        miniMainHero.move(from: nil, to: miniMainHeroOffPos)
        miniMainHero.balloon.isHidden = true
    }
    
    public static func shakeDoctor() {
        doctor.shake()
    }
    
    public static func shakeMadDoctor() {
        madDoctor.shake()
    }
    
    public static func shakeMainHero() {
        mainHero.shake()
    }
    
    public static func doctorBaloon(isVisible: Bool) {
        doctor.balloon.isHidden = !isVisible
        if (!isVisible) {
            if let label = doctor.balloon.childNode(withName: "line") {
                label.removeFromParent()
            }
        }
    }
    
    public static func madDoctorBaloon(isVisible: Bool) {
        madDoctor.balloon.isHidden = !isVisible
        if (!isVisible) {
            if let label = madDoctor.balloon.childNode(withName: "line") {
                label.removeFromParent()
            }
        }
    }
    
    public static func mainHeroBaloon(isVisible: Bool) {
        mainHero.balloon.isHidden = !isVisible
        if (!isVisible) {
            if let label = mainHero.balloon.childNode(withName: "line") {
                label.removeFromParent()
            }
        }
    }
    
    public static func miniMainHeroBaloon(isVisible: Bool) {
        miniMainHero.balloon.isHidden = !isVisible
        if (!isVisible) {
            if let label = miniMainHero.balloon.childNode(withName: "line") {
                label.removeFromParent()
            }
        }
    }
}
