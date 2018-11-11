//
//  EqRob.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/07/15.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKitEasingSwift

class EqRob: SKSpriteNode {
    
    var moveSpeed: CGFloat = 0.002
    var rotateSpeed: CGFloat = 0.1
    var moveSpeedForNmr: CGFloat = 0.002
    var rotateSpeedForNmr: CGFloat = 0.1
    var moveSpeedForAtk: CGFloat = 0.0004
    var rotateSpeedForAtk: CGFloat = 0.02
    var rotateForeverSpeed: TimeInterval = 3
    
    var veCategory: Int = 0
    let attackSpace: CGFloat = 160
    let waitingSpace: CGFloat = 60
    var nearPoint = CGPoint(x: 0, y: 0)
    
    let chargingTurnIndex = 1
    let deadTurnIndex = 2
    var wasDead = false
    var turn = 0 {
        didSet {
            if turn == 0 {
                EqRobController.execute(6, enemy: nil)
            }
        }
    }
    
    var eqPosX = 0
    var eqPosY = 11
    
    var constantsArray = [Int]()
    var coefficientArray = [Int]()
    
    var variableExpressionLabel = SKLabelNode(fontNamed: DAFont.fontName)
    var variableExpressionString = "" {
        didSet {
            variableExpressionLabel.text = variableExpressionString
            if variableExpressionString == "" {
                removeBG()
            }
        }
    }
    
    var state: EqRobState = .Pending
    
    let diffSign = SKSpriteNode(texture: SKTexture(imageNamed: "DifferentBtn"), color: UIColor.clear, size: CGSize(width: 75, height: 39))
    let eqSign = SKSpriteNode(texture: SKTexture(imageNamed: "equivalentBtn"), color: UIColor.clear, size: CGSize(width: 75, height: 39))
    
    init() {
        let texture = SKTexture(imageNamed: "eqRob")
        let size = CGSize(width: 82, height: 77)
        /* Initialize with enemy asset */
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        self.position = CGPoint(x: -60, y: 246.5)
        self.name = "eqRob"
        self.zPosition = 11
        initailizeVariableExpressionLabel()
        setSign()
        self.physicsBody = nil
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setSign() {
        diffSign.name = "eqRobDiff"
        eqSign.name = "eqRobEq"
        diffSign.position = CGPoint(x: 0, y: 0)
        eqSign.position = CGPoint(x: 0, y: 0)
        diffSign.zRotation = .pi * 1/2
        eqSign.zRotation = .pi * 1/2
        diffSign.zPosition = 1
        eqSign.zPosition = 1
        addChild(diffSign)
        addChild(eqSign)
        diffSign.isHidden = true
        eqSign.isHidden = true
    }
    
    func go(to target: SKNode, completion: @escaping () -> Void) {
        self.look(at: target) {
            self.move(to: target, easeFunction: .curveTypeExpo, easeType: nil) {
                return completion()
            }
        }
    }
    
    func go(toPos position: CGPoint, completion: @escaping () -> Void) {
        self.look(atPos: position) {
            self.move(toPos: position, easeFunction: nil, easeType: nil) {
                return completion()
            }
        }
    }
    
    func goNear(to target: SKNode, completion: @escaping () -> Void) {
        self.look(at: target) {
            self.moveNear(to: target) {
                return completion()
            }
        }
    }
    
    func look(at target: SKNode, completion: @escaping () -> Void) {
        let angle = self.angleRadian(with: target)
        let rotate = SKAction.rotate(toAngle: -angle, duration: TimeInterval(rotateSpeed*abs(angle)))
        self.run(rotate, completion: {
            return completion()
        })
    }
    
    func look(atPos position: CGPoint, completion: @escaping () -> Void) {
        let angle = self.angleRadian(withPos: position)
        let rotate = SKAction.rotate(toAngle: -angle, duration: TimeInterval(rotateSpeed*abs(angle)))
        self.run(rotate, completion: {
            return completion()
        })
    }
    
    func rotateForever() {
        let oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotateForeverSpeed)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        self.run(repeatRotation)
    }
    
    func stopAction() {
        self.removeAllActions()
    }

    
    func move(to target: SKNode, easeFunction: CurveType?, easeType: EaseType?, completion: @escaping () -> Void) {
        let easeFunction = easeFunction ?? .curveTypeLinear
        let easeType = easeType ?? .easeTypeOut
        let distance = self.distance(to: target)
        guard distance > 0 else { return completion() }
        let move = SKEase.move(easeFunction: easeFunction,
                    easeType: easeType,
                    time: TimeInterval(moveSpeed*distance),
                    from: self.absolutePos(),
                    to: target.absolutePos())
        //let move = SKAction.move(to: target.absolutePos(), duration: )
        self.run(move, completion: {
            return completion()
        })
    }
    
    func move(toPos position: CGPoint, easeFunction: CurveType?, easeType: EaseType?, completion: @escaping () -> Void) {
        let easeFunction = easeFunction ?? .curveTypeLinear
        let easeType = easeType ?? .easeTypeOut
        let distance = self.distance(toPos: position)
        guard distance > 0 else { return completion() }
        let move = SKEase.move(easeFunction: easeFunction,
                               easeType: easeType,
                               time: TimeInterval(moveSpeed*distance),
                               from: self.absolutePos(),
                               to: position)
        //let move = SKAction.move(to: target.absolutePos(), duration: )
        self.run(move, completion: {
            return completion()
        })
    }
    
    func moveNear(to target: SKNode, completion: @escaping () -> Void) {
        let distance = self.distance(to: target)
        if distance - attackSpace > 0 {
            let dx = target.absolutePos().x - self.absolutePos().x
            let dy = target.absolutePos().y - self.absolutePos().y
            let ratio = attackSpace / distance
            let move = SKAction.move(by: CGVector(dx: dx*(1-ratio), dy: dy*(1-ratio)), duration: TimeInterval(moveSpeed*(distance-attackSpace)))
            self.run(move, completion: {
                self.nearPoint = self.absolutePos()
                return completion()
            })
        } else {
            self.nearPoint = self.absolutePos()
            return completion()
        }
    }
    
    func stepOff(toPos position: CGPoint, completion: @escaping () -> Void) {
        let distance = self.distance(toPos: position)
        if distance - waitingSpace > 0 {
            let dx = position.x - self.absolutePos().x
            let dy = position.y - self.absolutePos().y
            let ratio = waitingSpace / distance
            let move = SKAction.move(by: CGVector(dx: dx*ratio, dy: dy*ratio), duration: TimeInterval(moveSpeed*waitingSpace))
            self.run(move, completion: {
                return completion()
            })
        } else {
            return completion()
        }
    }
    
    func attack(to target: SKNode, completion: @escaping () -> Void) {
        move(to: target, easeFunction: .curveTypeElastic, easeType: .easeTypeOut) {
            return completion()
        }
    }

    func goAndAttack(to target: SKNode, completion: @escaping () -> Void) {
        moveSpeed = moveSpeedForAtk
        rotateSpeed = rotateSpeedForAtk
        go(to: target) {
            self.moveSpeed = self.moveSpeedForNmr
            self.rotateSpeed = self.rotateSpeedForNmr
            return completion()
        }
    }
    
    func kill(_ target: Enemy, completion: @escaping () -> Void) {
        goAndAttack(to: target) {
            let wait = SKAction.wait(forDuration: 0.2)
            self.run(wait, completion: {
                return completion()
            })
        }
    }
    
    func killed(_ target: Enemy, completion: @escaping () -> Void) {
        goAndAttack(to: target) {
            self.stepOff(toPos: self.nearPoint) {
                self.destroyed {
                    return completion()
                }
            }
        }
    }
    
    func destroyed(completion: @escaping () -> Void) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "DestroyEnemy")!
        particles.zPosition = 102
        particles.position = CGPoint(x: self.position.x, y: self.position.y-20)
        /* Add particles to scene */
        self.parent!.addChild(particles)
        let waitEffectRemove = SKAction.wait(forDuration: 2.0)
        let removeParticles = SKAction.removeFromParent()
        let seqEffect = SKAction.sequence([waitEffectRemove, removeParticles])
        /* Play Sound */
        SoundController.sound(scene: self.parent as? SKScene, sound: .EnemyKilled)
        particles.run(seqEffect, completion: {
            self.isHidden = true
            return completion()
        })
    }
    
    func calculateValue(value: Int) -> Int {
        var outPut = 0
        for constant in constantsArray {
            outPut += constant
        }
        for coeffcient in coefficientArray {
            outPut += coeffcient*value
        }
        return outPut
    }
    
    func resetVEElementArray() {
        constantsArray.removeAll()
        coefficientArray.removeAll()
    }
    
    func initailizeVariableExpressionLabel() {
        /* text */
        variableExpressionLabel.text = ""
        /* name */
        variableExpressionLabel.name = "eqVELabel"
        /* font size */
        variableExpressionLabel.fontSize = 35
        /* zPosition */
        variableExpressionLabel.zPosition = 3
        /* position */
        variableExpressionLabel.position = CGPoint(x: 50, y: 0)
        variableExpressionLabel.zRotation = .pi * -1/2
        variableExpressionLabel.verticalAlignmentMode = .center
        variableExpressionLabel.horizontalAlignmentMode = .center
        variableExpressionLabel.isHidden = true
        /* Add to Scene */
        self.addChild(variableExpressionLabel)
    }
    
    func changeVeLabelRot(isUp: Bool) {
        if isUp {
            variableExpressionLabel.zRotation = .pi * 1/2
        } else {
            variableExpressionLabel.zRotation = .pi * -1/2
        }
    }
    
    func addBGForVeLabel() {
        let veBG = SKShapeNode(rectOf: CGSize(width: variableExpressionLabel.frame.height+10, height: variableExpressionLabel.frame.width+10))
        veBG.fillColor = UIColor.red
        veBG.zPosition = -1
        veBG.position = CGPoint(x: 0, y: 0)
        veBG.name = "eqRobVEBG"
        variableExpressionLabel.addChild(veBG)
    }
    
    func removeBG() {
        for child in variableExpressionLabel.children {
            if child.name == "eqRobVEBG" {
                child.removeFromParent()
            }
        }
    }
    
    func showVELabel() {
        /* font size */
        variableExpressionLabel.fontSize = 40
        /* position */
        variableExpressionLabel.position = CGPoint(x: 0, y: 0)
        variableExpressionLabel.zRotation = .pi * 1/2
        variableExpressionLabel.isHidden = false
        addBGForVeLabel()
    }
    
    public func forcus() {
        variableExpressionLabel.fontColor = UIColor.red
    }
    
}
