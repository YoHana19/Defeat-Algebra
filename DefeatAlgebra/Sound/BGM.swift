//
//  BGM.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2017/08/08.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation
import AVFoundation

enum Bgm {
    case Opening, Opening2, MainMenu, StageClear, Game1, Game2, Game3, SimBGM, FirstDayLast, Last
}

class BGM: AVAudioPlayer {
    
    init (bgm: Bgm){
        var source: (String, String) = ("", "")
        switch bgm {
        case .Opening:
            source = ("easyJoy", "wav")
        case .Opening2:
            source = ("opening2", "wav")
        case .MainMenu:
            source = ("mainMenu", "mp3")
        case .StageClear:
            source = ("stageClear", "mp3")
        case .Game1:
            source = ("game1", "wav")
        case .Game2:
            source = ("game2", "mp3")
        case .Game3:
            source = ("game3", "wav")
        case .SimBGM:
            source = ("simBGM", "wav")
        case .FirstDayLast:
            source = ("firstDayLast", "wav")
        case .Last:
            source = ("last", "wav")
        }
        
        let bgm_url = NSURL(fileURLWithPath: Bundle.main.path(forResource: source.0, ofType: source.1)!)
        try! super.init(contentsOf: bgm_url as URL, fileTypeHint: source.1)
    }
    
}
