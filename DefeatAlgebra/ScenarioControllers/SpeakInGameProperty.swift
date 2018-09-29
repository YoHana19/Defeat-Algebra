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
        ["0", "わしが開発したアイテムを届けたぞ"]
    ]
    
    static let punchIntervalExplain: [[String]] = [
        ["2", "くそお。次から次へとどんどん来やがる"],
        ["0", "エックスよ！ロボットの攻撃には周期があることが分かったぞ"],
        ["pause"],
        ["0", "ロボットの下の数字は何ターン後に攻撃してくるかを示しておる"],
        ["2", "なるほど！2だったら2ターン後に攻撃してくるってことだな！"],
        ["0", "そうじゃ！どの敵から倒すべきか判断するのに参考にするのじゃ"],
        ["2", "ありがとう！アルジェ博士"]
    ]
    
    static let logDefenceFirstly: [[String]] = [
        ["0", "町の防御システムは、一度作動すると壊れてしまうぞ"]
    ]
    
    static let bootsGotFirstly: [[String]] = [
        ["0", "ブーツをひろったから、移動できる範囲が増えたぞ！"]
    ]
    
    static let timeBombGotFirstly: [[String]] = [
        ["0", "今ひろったのは爆弾じゃ。"],
        ["0", "使い方を教えよう。アイテムボタンをタッチしてくれ", "user"],
        ["0", "次に爆弾アイコンをタッチしてくれ"],
        ["0", "紫のエリアをタッチすると爆弾を仕掛けられるぞ"],
        ["0", "爆弾は次の自分のターンで爆発するぞ"]
    ]
    
    static let timeBombGotFirstly2: [[String]] = [
        ["0", "敵がどの位置にくるのか予測し、的確に爆弾をおいて倒すのじゃ！"]
    ]
    
    static let heartGotFirstly: [[String]] = [
        ["0", "街のライフが一つ増えたぞ！"]
    ]
    
    static let caneGotFirstly: [[String]] = [
        ["0", "敵の信号をジャックすることに成功したぞ！"],
        ["2", "ホントですか！？\nさすが博士！！"],
        ["0", "今ひろった発信機を使って、信号を操作するのじゃ"],
        ["0", "アイテムボタンをタッチしてくれ", "user"],
        ["0", "発信機アイコンをタッチしてくれ"],
        ["0", "信号の回数を入力すると、ロボットに信号を発信できるぞ！"],
        ["0", "うまく信号を操作して、敵を効率的に倒すのじゃ！"]
    ]
    
    static let wallGotFirstly: [[String]] = [
        ["0", "敵の前方に壁を設置すると、敵の動きを止めることができるぞ！"]
    ]
}
