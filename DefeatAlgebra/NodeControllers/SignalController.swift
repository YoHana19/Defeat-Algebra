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
    public static var speed: CGFloat = 0.006
    private static let gap: TimeInterval = 0.25
    
//    public static func send(target: Enemy, num: Int) {
//        guard let gameScene = gameScene else { return }
//        let distance = getDistance(target: target)
//        let lookAtConstraint = SKConstraint.orient(to: target.absolutePos(), offset: SKRange(constantValue: -CGFloat.pi / 2))
//        for i in 0..<num {
//            let signal = Signal(color: "red")
//            signal.position = madPos
//            signal.constraints = [ lookAtConstraint ]
//            gameScene.addChild(signal)
//            let wait = SKAction.wait(forDuration: gap*TimeInterval(i))
//            let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
//            let actions = SKAction.sequence([wait, move])
//            signal.run(actions, completion: {
//                signal.removeFromParent()
//                target.forcusForAttack(color: UIColor.red)
//            })
//        }
//    }
    
    public static func send(target: Enemy, num: Int, from: CGPoint? = nil, zPos: CGFloat? = nil, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let distance = getDistance(target: target, from: from)
        let signal = SignalValueHolder(value: num)
        signal.position = from ?? madPos
        signal.zPosition = zPos ?? 2
        gameScene.addChild(signal)
        if GameScene.stageLevel < 1, ScenarioController.currentActionIndex < 14, let _ = gameScene as? ScenarioScene {
            signal.xValue.isHidden = true
        } else if GameScene.stageLevel == 8 {
            signal.xValue.isHidden = true
        }
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move, completion: {
            signal.removeFromParent()
            target.forcusForAttack(color: UIColor.red, value: num)
            return completion()
        })
    }
    
    public static func sendToEqRob(target: EqRob, num: Int, from: CGPoint, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let origin = from
        let dx = origin.x - target.absolutePos().x
        let dy = origin.y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        
        let signal = SignalValueHolder(value: num)
        signal.position = from
        signal.zPosition = 10
        gameScene.addChild(signal)
        
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move, completion: {
            signal.removeFromParent()
            target.forcus()
            return completion()
        })
    }
    
    public static func sendToCannon(target: Cannon, num: Int, from: CGPoint, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let origin = from
        let dx = origin.x - target.absolutePos().x
        let dy = origin.y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        
        let signal = SignalValueHolder(value: num)
        signal.position = from
        signal.zPosition = 10
        gameScene.addChild(signal)
        
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move, completion: {
            signal.removeFromParent()
            return completion()
        })
    }
    
    public static func sendToEqRobForInstruction(target: EqRobForInstruction, num: Int, from: CGPoint, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let origin = from
        let dx = origin.x - target.absolutePos().x
        let dy = origin.y - target.absolutePos().y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        
        let signal = SignalValueHolder(value: num)
        signal.position = from
        signal.zPosition = 10
        gameScene.addChild(signal)
        
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move, completion: {
            signal.removeFromParent()
            target.forcus()
            return completion()
        })
    }
    
    public static func sendHalf(target: Enemy, num: Int, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let distance = getDistance(target: target)
        let signal = SignalValueHolder(value: num)
        signal.xValue.isHidden = true
        signal.position = madPos
        gameScene.addChild(signal)
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move)
        let wait = SKAction.wait(forDuration: TimeInterval(speed*distance/2))
        gameScene.run(wait, completion: {
            signal.removeAllActions()
            return completion()
        })
    }
    
    public static func sendHalf2(signal: SignalValueHolder, target: Enemy, num: Int, completion: @escaping () -> Void) {
        let distance = getDistance(target: target)
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance/2))
        signal.run(move, completion: {
            signal.removeFromParent()
            target.forcusForAttack(color: UIColor.red, value: num)
            return completion()
        })
    }
    
    private static func getDistance(target: Enemy, from: CGPoint? = nil) -> CGFloat {
        let origin = from ?? madPos
        let dx = origin.x - target.absolutePos().x
        let dy = origin.y - target.absolutePos().y
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
                target.forcusForAttack(color: UIColor.yellow, value: num)
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
