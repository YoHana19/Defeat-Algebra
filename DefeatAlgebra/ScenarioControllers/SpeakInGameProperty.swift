//
//  SpeakInGameProperty.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/23.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

struct SpeakInGameProperty {
    static let planeExplain: [[String]] = [
        ["0", "爆弾を届けたぞ！"],
        ["pause"]
    ]
    
    static let timeBombGotFirstly: [[String]] = [
        ["0", "爆弾を使うにはアイテムアイコンをタッチするのじゃ！"]
    ]
    
    static let veScaleExplain: [[String]] = [
        ["pause"],
        ["pause"]
        ]
    
    static let eqRobFirstly: [[String]] = [
        ["0", "エクロボを使いたい時は、エクロボ自身をタッチするのじゃ！"]
    ]
    
    static let secondDay: [[String]] = [
        ["0", "すまぬエックスよ！エクロボはしばし充電が必要じゃ！"],
        ["0", "しばらくエクロボなしで戦ってくれ・・・"],
        ["2", "そんなー！"],
        ["0", "また爆弾を開発したゆえ、それで凌いでくれ！"],
        ["2", "くそお！やるしかない！"],
        ["pause"]
    ]
    
    static let eqRobReturn: [[String]] = [
        ["0", "エクロボの充電が完了したぞ！"],
    ]
    
    static let logDefenceFirstly: [[String]] = [
        ["0", "町の防御システムは、一度作動すると壊れてしまうぞ"]
    ]
    
}
