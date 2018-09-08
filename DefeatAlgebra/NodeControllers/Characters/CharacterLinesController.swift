//
//  CharacterLinesController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/05/11.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CharacterLinesController {
    static func doctorSay(line: String) {
        CharacterController.doctorBaloon(isVisible: true)
        CharacterController.madDoctorBaloon(isVisible: false)
        CharacterController.mainHeroBaloon(isVisible: false)
        line.DAMultilined() { multiLine in
            CharacterController.doctor.balloon.setLines(with: multiLine, pos: 0)
        }
    }
    
    static func madDoctorSay(line: String) {
        CharacterController.doctorBaloon(isVisible: false)
        CharacterController.madDoctorBaloon(isVisible: true)
        CharacterController.mainHeroBaloon(isVisible: false)
        line.DAMultilined() { multiLine in
            CharacterController.madDoctor.balloon.setLines(with: multiLine, pos: 1)
        }
    }
    
    static func mainHeroSay(line: String) {
        CharacterController.doctorBaloon(isVisible: false)
        CharacterController.madDoctorBaloon(isVisible: false)
        CharacterController.mainHeroBaloon(isVisible: true)
        line.DAMultilined() { multiLine in
            CharacterController.mainHero.balloon.setLines(with: multiLine, pos: 2)
        }
    }
    
    static func miniMainHeroSay(line: String) {
        CharacterController.miniMainHeroBaloon(isVisible: true)
        line.DAMultilined() { multiLine in
            CharacterController.miniMainHero.balloon.setLines(with: multiLine, pos: 2)
        }
    }
    
    static func miniMainHeroSayLoop() {
        miniMainHeroSay(line: miniHeroLines[0])
        selectedLine = miniHeroLines[0]
        let wait = SKAction.wait(forDuration: 10.0)
        let say = SKAction.run({
            miniMainHeroSay(line: getLineRandom(lines: miniHeroLines))
        })
        let seq = SKAction.sequence([wait, say])
        let loop = SKAction.repeatForever(seq)
        CharacterController.miniMainHero.run(loop)
    }
    
    static func stopMiniMainHeroSayLoop() {
        CharacterController.miniMainHero.removeAllActions()
    }
    
    static var selectedLine = ""
    
    static func getLineRandom(lines: [String]) -> String {
        let otherLines = lines.filter { $0 != selectedLine }
        let index = arc4random_uniform(UInt32(otherLines.count))
        selectedLine = otherLines[Int(index)]
        return selectedLine
    }
    
    static let miniHeroLines = [
        "ここからじゃ攻撃が届かないな。まずは、なんとかして敵のとなりまで行こう",
        "えーっと、xが「信号の回数」だったな..",
        "パンチの長さは、毎回違うようだな",
        "暗号、か...あれは計算するのか..？",
    ]
}
