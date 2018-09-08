//
//  SignalController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/13.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

struct SignalController {
    public static var madPos = CGPoint(x: 0, y: 0)
    public static var gameScene: SKScene?
    private static let speed: CGFloat = 0.006
    private static let gap: TimeInterval = 0.25
    
    public static func send(target: Enemy, num: Int) {
        guard let gameScene = gameScene else { return }
        let distance = getDistance(target: target)
        let lookAtConstraint = SKConstraint.orient(to: target.absolutePos(), offset: SKRange(constantValue: -CGFloat.pi / 2))
        for i in 0..<num {
            let signal = Signal(color: "red")
            signal.position = madPos
            signal.constraints = [ lookAtConstraint ]
            gameScene.addChild(signal)
            let wait = SKAction.wait(forDuration: gap*TimeInterval(i))
            let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
            let actions = SKAction.sequence([wait, move])
            signal.run(actions, completion: {
                signal.removeFromParent()
                target.forcusForAttack(color: UIColor.red)
            })
        }
    }
    
    private static func getDistance(target: Enemy) -> CGFloat {
        let dx = madPos.x - target.absolutePos().x
        let dy = madPos.y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance
    }
    
    public static func signalSentDuration(target: Enemy, xValue: Int) -> TimeInterval {
        let delayTime = gap * TimeInterval(xValue-1)
        let sendingTime = getDistance(target: target) * speed
        return TimeInterval(sendingTime) + delayTime
    }
    
    public static func sendFromHero(target: Enemy, heroPos: CGPoint, num: Int) {
        guard let gameScene = gameScene else { return }
        let distance = getDistanceFromHero(target: target, heroPos: heroPos)
        let lookAtConstraint = SKConstraint.orient(to: target.absolutePos(), offset: SKRange(constantValue: -CGFloat.pi / 2))
        for i in 0..<num {
            let signal = Signal(color: "yellow")
            signal.position = heroPos
            signal.constraints = [ lookAtConstraint ]
            gameScene.addChild(signal)
            let wait = SKAction.wait(forDuration: gap*TimeInterval(i))
            let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
            let actions = SKAction.sequence([wait, move])
            signal.run(actions, completion: {
                signal.removeFromParent()
                target.forcusForAttack(color: UIColor.yellow)
            })
        }
    }
    
    private static func getDistanceFromHero(target: Enemy, heroPos: CGPoint) -> CGFloat {
        let dx = heroPos.x - target.absolutePos().x
        let dy = heroPos.y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance
    }
    
    public static func signalSentDurationFromHero(target: Enemy, heroPos: CGPoint, xValue: Int) -> TimeInterval {
        let delayTime = gap * TimeInterval(xValue-1)
        let sendingTime = getDistanceFromHero(target: target, heroPos: heroPos) * speed
        return TimeInterval(sendingTime) + delayTime
    }
    
}
