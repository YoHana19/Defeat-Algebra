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
    public static var speedFast: CGFloat = 0.003
    private static let gap: TimeInterval = 0.25
    
    public static func send(target: Enemy, num: Int, from: CGPoint? = nil, zPos: CGFloat? = nil, completion: @escaping () -> Void) {
        guard let gameScene = gameScene else { return }
        let distance = getDistance(target: target, from: from)
        var duration: TimeInterval = TimeInterval(speed*distance)
        if let _ = from {} else {
            if target.positionY < 6 {
                duration = TimeInterval(speedFast*distance)
            }
        }
        let signal = SignalValueHolder(value: num)
        signal.position = from ?? madPos
        signal.zPosition = zPos ?? 2
        gameScene.addChild(signal)
        GameStageController.signalVisibility(signal: signal)
        let move = SKAction.move(to: target.absolutePos(), duration: duration)
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
        
        GameStageController.signalVisibilityForCannon(signal: signal)
        
        let move = SKAction.move(to: target.absolutePos(), duration: TimeInterval(speed*distance))
        signal.run(move, completion: {
            signal.removeFromParent()
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
}
