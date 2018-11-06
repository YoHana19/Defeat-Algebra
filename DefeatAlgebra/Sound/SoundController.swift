//
//  SoundController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/29.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

enum Sfx {
    case ActionButton, HeroMove, ButtonMove, ButtonBack, ItemGet, CastleHit, CharaLine, EnemyKilled, CannonBomb, SwordSound, TimeBombExplosion, SignalGot, UtilButton, GameOver, ShowVe, ShowMad, LogDefence, TimeBombAA, BombOk, Input, EqAttack, EqSelected, Flash
}

class SoundController {
    
    private static var currentBgm = BGM(bgm: .Game1)
    
    public static func playBGM(bgm: Bgm, isLoop: Bool) {
        guard MainMenu.soundOnFlag else { return }
        let source = BGM(bgm: bgm)
        currentBgm.stop()
        currentBgm = source
        currentBgm.play()
        if isLoop {
            currentBgm.numberOfLoops = -1
        }
    }
    
    public static func stopBGM() {
        guard MainMenu.soundOnFlag else { return }
        currentBgm.stop()
    }
    
    public static func pauseBGM() {
        guard MainMenu.soundOnFlag else { return }
        currentBgm.pause()
    }
    
    public static func rePlayBGM() {
        guard MainMenu.soundOnFlag else { return }
        currentBgm.play()
    }
    
    public static func sound(scene: SKScene?, sound: Sfx) {
        guard let scene = scene else { return }
        if MainMenu.soundOnFlag {
            let sound = SKAction.playSoundFileNamed(getSound(sound), waitForCompletion: true)
            scene.run(sound)
        }
    }
    
    private static func getSound(_ sound: Sfx) -> String {
        switch sound {
        case .ActionButton:
            return "actionButton.mp3"
        case .HeroMove:
            return "heroMove.mp3"
        case .ButtonMove:
            return "buttonMove.wav"
        case .ButtonBack:
            return "buttonBack.wav"
        case .ItemGet:
            return "ItemGet.wav"
        case .CastleHit:
            return "castleWallHit.mp3"
        case .CharaLine:
            return "charaLine.mp3"
        case .EnemyKilled:
            return "enemyKilled.mp3"
        case .CannonBomb:
            return "cannonBomb.mp3"
        case .SwordSound:
            return "swordSound.wav"
        case .TimeBombExplosion:
            return "timeBombExplosion.mp3"
        case .SignalGot:
            return "signalGot.wav"
        case .UtilButton:
            return "utilButton.wav"
        case .GameOver:
            return "gameOver.wav"
        case .ShowVe:
            return "showVe.mp3"
        case .ShowMad:
            return "showMad.wav"
        case .LogDefence:
            return "logDefence.wav"
        case .TimeBombAA:
            return "timeBombAA.mp3"
        case .BombOk:
            return "bombOk.mp3"
        case .Input:
            return "input.mp3"
        case .EqAttack:
            return "eqAttack.mp3"
        case .EqSelected:
            return "eqSelected.mp3"
        case .Flash:
            return "flash.wav"
        }
    }
}
