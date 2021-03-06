//
//  ScenarioProrerty.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/08/12.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation

// 0: good scientist, 1: mad scientist, 2: main hero

struct ScenarioProperty {
    static let scenario0: [[String]] = [
        ["2", "はっ！ ふっ！ はっ！ はっ！ ふっ！"],
        ["0", "ほっほっほ\n精がでるな'エックス'よ"],
        ["2", "あ、'アルジェ博士'"],
        ["0", "訓練も大事だが\n勉強もサボるんじゃないぞ"],
        ["2", "はいはい、わかってますよ\n(あんなのやっても意味ないだろ..)"],
        ["pause"],
        ["2", "な、なんだ！？"],
        ["1", "はっはっはっ\n久しぶりだな'アルジェ博士'よ"],
        ["0", "お前は、'ジェブラ博士'！"],
        ["2", "知り合いなんですか！？"],
        ["0", "うむ・・。奴はわしの元弟子じゃ。"],
        ["0", "しかし、危険な研究ばかりするゆえ破門にしたのじゃ・・"],
        ["1", "ははは、嘘をつけ。\n私の才能に嫉妬して追い出したんだろう！"],
        ["0", "ばかをいえ・・・\n今ごろ何をしに来たんじゃ！"],
        ["1", "ふふふ。愚かな我が元師匠に私の研究の素晴らしさを教えてやろうと思ってな!"],
        ["1", "ゆけっ！我がロボット達よ！！奴らの町を破壊するのだ！"],
        ["pause"],
        ["2", "なんだこいつらは！？"],
        ["0", "どうやら、あやつが作り出した兵器のようじゃの"],
        ["2", "町を破壊するって言ってたぞ！なんとかしないと！！"],
        ["0", "わしが奴のロボットを分析する！それまで時間を稼いでくれ！"],
        ["2", "時間を稼げって言われても、どうすりゃいいんだ・・"],
        ["pause"],
        ["2", "なんだ！？何か信号みたいなのを送ってるぞ"],
        ["2", "うわっ！腕が伸びた！？あれに当たったらヤバそうだ"],
        ["0", "わかったぞ！こやつらの仕組みが！"],
        ["2", "本当ですか！？博士！"],
        ["0", "うむ。ジェブラ博士が信号を送っていたじゃろう"],
        ["2", "そうそう！なんか赤い信号があいつからロボットに送られてた！"],
        ["0", "そうじゃ。あのロボットは、送られてきた信号の「回数」と"],
        ["0", "各ロボットにプログラムされている「暗号」に応じて攻撃してくるようじゃ"],
        ["2", "「暗号」？"],
        ["0", "そうじゃ、これが暗号じゃ"],
        ["pause"],
        ["2", "なんかxとか数字が書いてあるな"],
        ["0", "どうやら、xは、信号の回数を表してるようなんじゃ"],
        ["0", "そして、あの暗号と攻撃時のパンチの長さには関係があるようなのじゃが..."],
        ["0", "それ以上はわからん...エックスよ！なんとかその謎を解いて敵を倒してくれ！"],
        ["2", "えーーー、一番肝心なところが分からないのかよ"],
        ["2", "くそぉ。なんとかするしかないか！"],
        ["pause"],
        ["2", "よし！全部やっつけたぞ！"],
        ["1", "ほぅ、なかなかやるようだな"],
        ["1", "だが、我がロボットの恐ろしさはこんなものではないぞ！"],
        ["2", "俺の町を破壊なんかさせないぞ！"],
        ["pause"]
    ]
    
    static let scenario2: [[String]] = [
        ["1", "どうやら、我がロボットの暗号の謎を解いたようだな"],
        ["2", "へっ、余裕のよっちゃんよ！あんたの研究も大した事ないんだな"],
        ["1", "ふっ。今のうちに粋がっておるがよい"],
        ["1", "どれ、もっと複雑な暗号にしてやろう！"],
        ["2", "ふんっ！見た目が少し変わったって、仕組みは一緒さ！"],
        ["pause"],
        ["pause"]
    ]
    
    static let scenario4: [[String]] = [
        ["0", "エックスよ！あのロボット達を一気に倒せるマシーンを開発したぞ！！"],
        ["2", "一気に倒せる！？\n一体どんなマシーン何ですか！"],
        ["0", "うむ。その名もエクロボじゃ！"],
        ["pause"],
        ["2", "エ,エクロボ？（名前ださいな...）"],
        ["2", "それで、どうやって奴らを倒すんですか？"],
        ["0", "このエクロボにロボットと同じ暗号を入力することで、そのロボットを倒せるのじゃ"],
        ["2", "同じ暗号を入力？"],
        ["0", "そうじゃ。見た目が違っても同じ暗号ならばオーケーじゃ"],
        ["2", "見た目が違っても？うーん..ちょっとよくわからない.."],
        ["0", "実際に使ってみるのがはやいじゃろう！"], //10
        ["pause"],
        ["0", "エクロボをタッチするのじゃ"],
        ["0", "エクロボに敵と同じ暗号を入力しよう"],
        ["0", "この敵と同じ2x+1を入力してみるのじゃ"],
        ["0", "次に、2x+1と同じ暗号を持つ敵をタッチするのじゃ"],
        ["0", "これで、エクロボはそのロボットをロックオンしたぞ"],
        ["0", "ロックオンした敵には後で攻撃しに行くぞ！"],
        ["0", "攻撃した時、入力した暗号と同じ暗号をそのロボットが持ってれば破壊できるんじゃ！"],
        ["pause"],
        ["2", "なるほど！！でも、これだけじゃ全然一気に倒せないよ.."], //20
        ["2", "同じ暗号を持ってる敵も一体しかいないし..."],
        ["0", "見た目に騙されるでないぞ、エックスよ"],
        ["0", "同じ暗号とは、信号の回数に関わらず同じ値になるものじゃ"],
        ["pause"],
        ["0", "例えば、このロボットについて考えよう"],
        ["0", "信号の回数が2回の時、エクロボに入力した2x+1はいくつになるかな？"],
        ["2", "えーっと信号が2回ってことはx=2で、2x+1は2×2+1=5だから、5だ！"],
        ["0", "では、このロボットのx+1+xはどうかな？"],
        ["2", "x+1+xは、2+1+2=5だから、これも5だ"],
        ["2", "でも、これって偶然じゃないの？"], //30
        ["0", "では、信号の回数が3回だったらどうじゃ？"],
        ["2", "うーん、2x+1は2×3+1=7、x+1+xは3+1+3=7。どっちも7だ！"],
        ["0", "そのように、信号の回数がいくつであっても同じ数値になる暗号は同じ暗号じゃ！"],
        ["2", "なるほど！見た目が違っても同じってのは、そういうことか！"],
        ["0", "そうじゃ。結局ロボットのパンチも同じ長さになるからじゃな"],
        ["pause"],
        ["0", "じゃあ、このロボットもタッチするのじゃ"],
        ["2", "他のロボットはどうだろう？"],
        ["0", "同じように考えてみるのじゃ。同じ暗号の敵をタッチしてロックオンをするのじゃぞ"],
        ["0", "エクロボの攻撃を開始するには、エクロボ自身をタッチすると発進するぞ！"], //40
        ["pause"],
        ["0", "パーフェクトじゃ！！"],
        ["2", "すげー！一気に4体もやっつけたぞ！！"],
        ["0", "その調子でうまくエクロボを使って、敵を倒すのじゃ！"],
        ["2", "よーし、これで百人力だ！"],
        ["pause"],
        ["0", "うーむ。取り逃がしがあったようじゃの"],
        ["0", "このロボットの暗号は2x+1と同じじゃ。それを確かめるぞ"],
        ["0", "xの値、つまり信号の回数がいくつでも同じ値になる暗号は同じもの"],
        ["0", "これをしっかり頭に入れておくのじゃ！"],
        ["2", "結局、同じ分だけ攻撃してくるわけだもんね"],
        ["0", "その通りじゃ！うまくエクロボを使って、敵を倒すのじゃ！"],
        ["2", "よーし、これで百人力だ！"],
        ["pause"]
    ]
    
    static let scenario6: [[String]] = [
        ["0", "新たにアルジェブラ砲を開発したぞ！！"],
        ["2", "アルジェブラ砲！？今度はちょっとかっこいい"],
        ["0", "今度はとは何じゃ、今度はとは！"],
        ["2", "ぎくっ...いいからどうやって使うのか教えて！"],
        ["0", "・・・。まあ、聞かなかったことにしておこう"],
        ["0", "アルジェブラ砲は、ジェブラ博士が出す信号をジャックして砲撃する事ができるぞ！"],
        ["pause"],
        ["0", "このアルジェブラ砲をタッチするのじゃ"],
        ["0", "砲撃の飛距離を敵の暗号と同じ仕組みで入力できるぞ"],
        ["0", "x+4を入力してみよう"],
        ["0", "x+4がこのアルジェブラ砲にセットされたぞ！"],
        ["2", "今x=2だから、2+4=6で砲撃の飛距離は6ってこと？"],
        ["0", "その通りじゃ！次のターンに砲撃されるぞ"],
        ["pause"],
        ["2", "やった、撃破した！"],
        ["0", "砲撃が当たると、敵を破壊することができるぞ！"],
        ["2", "なるほど！敵に当たるようにうまく砲撃の飛距離を入力すればいいんだな！"],
        ["0", "そうじゃ！\n敵の数もどんどん増えてきておる.."],
        ["0", "ワシの開発したマシーン達を上手く使って何とか町を守り切ってくれ！"],
        ["2", "まかせて！！アルジェ博士！"],
        ["pause"]
    ]
    
    static let scenario7: [[String]] = [
        ["2", "どうやら、俺たちを甘く見ていたようだな！"],
        ["0", "ジェブラ博士よ。バカなことはやめて、もっと人のためになる研究をしたらどうじゃ"],
        ["1", "ふっふっふ。甘く見ているのはどちらかな？"],
        ["pause"],
        ["2", "うわっ！ロボットが攻撃してきた！？"],
        ["2", "いつの間に信号を送ってたんだ！？"],
        ["1", "はっはっは。私は、ついに信号を透明にすることに成功したのだ！！"],
        ["1", "これでロボットの暗号の仕組みがわかっていても意味があるまい"],
        ["2", "くそっ！これじゃあいつが何回信号を送ったのかわからない！"],
        ["0", "あわてるでない、エックスよ！"],
        ["0", "わしがこれまで開発したものを駆使すれば、何とかなるはずじゃ"], //10
        ["2", "たしかにエクロボなら倒せるけど、、全部の敵が同じ暗号を持つわけじゃないし..."],
        ["0", "他にもアルジェブラ砲があるじゃろう"],
        ["2", "でも信号の回数がわからないと、砲撃の飛距離もわからないから"],
        ["2", "それだと、敵に砲撃を当てられるかわからないよ！"],
        ["0", "そうとも限らないぞ！エックスよ！"],
        ["pause"],
        ["0", "例えば、この敵はx+1の暗号を持っているから"],
        ["0", "信号の回数が1回の時はパンチの長さはいくつじゃ？"],
        ["2", "1+1で2だよ！"],
        ["0", "3回の時は？"], //20
        ["2", "3+1で4だね"],
        ["0", "その通りじゃ"],
        ["0", "そして今、敵はアルジェブラ砲から2の長さだけ前におる"],
        ["0", "じゃから、敵のパンチの長さがいくつになっても、それより2だけ大きい値を"],
        ["0", "砲撃の飛距離にすれば信号の回数がいくつでも必ず当たるのじゃ！"],
        ["2", "え、つまりどういうこと？"],
        ["pause"],
        ["0", "つまりx+1より2大きい、x+3を飛距離として入力すれば良い"],
        ["2", "そっか！x+3を入力すれば"],
        ["2", "x=1の時は、x+1が2で、x+3が4になるから砲撃が当たるし"], //30
        ["2", "x=3の時でも、x+1が4で、x+3が6になるからこれも砲撃が当たる！"],
        ["2", "パンチの長さをx+1と考えて、それより2大きいx+3を砲撃の飛距離とすればいいんだね！"],
        ["0", "その通りじゃ！！\nでは、アルジェブラ砲に飛距離を入力するのじゃ！"],
        ["pause"],
        ["0", "x+3を入力するのじゃ"],
        ["0", "では、もう片方の敵はどうかな"],
        ["2", "こっちも同じように考えればいいよね！"],
        ["2", "この敵が持つ暗号は、3x-x-1で、アルジェブラ砲から4だけ前にあるから"],
        ["pause"],
        ["2", "パンチの長さが3x-x-1で、それより4大きい数を砲撃の飛距離とすればいいんだけど、、"], //40
        ["0", "どうしたのじゃ？"],
        ["2", "うん。3x-x-1より4大きいってなると、3x-x-1+4だけど"],
        ["2", "そんな長い暗号、アルジェブラ砲に入力できないと思って、、"],
        ["0", "うむ。確かにそうじゃな。じゃがエクロボを使う時と同じように考えてみるのじゃ"],
        ["2", "エクロボと同じように？"],
        ["0", "そうじゃ。3x-x-1と同じ暗号でより短いものがないかな？"],
        ["2", "なるほど。それだったら3x-x-1は2x-1と同じだ！"],
        ["pause"],
        ["0", "では、2x-1より4大きい数は？"],
        ["2", "2x-1+4で2x+3だ！"], //50
        ["0", "その通りじゃ！！それならアルジェブラ砲に入力できるじゃろ"],
        ["0", "2x+3を入力するのじゃ"],
        ["2", "おお！ジャストミートだ！"],
        ["0", "今回は、信号の回数が2回だったようじゃ。見事に撃破できたのう！"],
        ["0", "奴のロボットもそろそろ残り少ないはず！"],
        ["0", "もう一踏ん張りじゃ！エックスよ！！"],
        ["2", "合点承知の助！"],
        ["pause"]
    ]
}
