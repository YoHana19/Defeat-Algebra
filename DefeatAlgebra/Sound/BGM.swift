//
//  BGM.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/08.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import AVFoundation

class BGM: AVAudioPlayer {
    //使用するBGMファイルのリスト配列を作っときます
    let bgm_list = [
        0: "mainBGM",
        1: "mainMenu",
        2: "stageClear",
        3: "mainMenuHard"
    ]
    init (bgm:Int){
        if bgm < 4 {
            let bgm_url = NSURL(fileURLWithPath: Bundle.main.path(forResource: bgm_list[bgm], ofType:"mp3")!)
            try! super.init(contentsOf: bgm_url as URL, fileTypeHint: "mp3")
        } else {
            let bgm_url = NSURL(fileURLWithPath: Bundle.main.path(forResource: bgm_list[bgm], ofType:"wav")!)
            try! super.init(contentsOf: bgm_url as URL, fileTypeHint: "wav")
        }
        
    }
}
