//
//  CannonRecordBoard.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/10/08.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class CannonRecordBoard: SKSpriteNode {
    
    let posLeft = CGPoint(x: 30, y: 1215)
    let posRight = CGPoint(x: 440, y: 1215)
    
    let marginWidth: CGFloat = 20
    let marginHeight: CGFloat = 40
    
    let leftMarginX: CGFloat = 15
    let leftMarginEnemy: CGFloat = 70
    let leftMarginCannon: CGFloat = 140
    let leftMarginDistTitle: CGFloat = 210
    let leftMarginRecordL: CGFloat = 0
    let leftMarginRecordE: CGFloat = 80
    let leftMarginRecordC: CGFloat = 140
    let leftMarginDist: CGFloat = 210
    
    let topMargin: CGFloat = 40
    let gapBtwNodeNVe: CGFloat = 25
    let gapBtwTitleNLog: CGFloat = 35
    let lineSpace: CGFloat = 55
    
    let oneBlock: CGFloat = 225
    
    var distanceFromTop: CGFloat = 0
    
    var scrollViewYPos: CGFloat = 0
    var startTouchYPos: CGFloat = 0
    var scrollView = SKSpriteNode()
    var isScrollable = false
    var numOfCannon = 1 {
        didSet {
            if numOfCannon > 3 {
                isScrollable = true
                scrollView.position = CGPoint(x: scrollView.position.x, y: scrollView.position.y+oneBlock)
            }
        }
    }
    var numOfXValue = 3
    var currentVeLabel = SKLabelNode()
    var distLabel: [SKLabelNode] = [SKLabelNode]() {
        didSet {
            if distLabel.count == 3 {
                if distLabel[0].text! == distLabel[1].text! && distLabel[1].text! == distLabel[2].text! {
                    if distLabel[0].text! == "0" {
                        for label in distLabel {
                            label.fontColor = UIColor.blue
                        }
                        currentVeLabel.fontColor = UIColor.blue
                        CannonTryController.isCorrect = true
                        DataController.setDataForGetAnswer()
                    } else {
                        for label in distLabel {
                            label.fontColor = UIColor.red
                        }
                        currentVeLabel.fontColor = UIColor.red
                        CannonTryController.hintOn = true
                        DataController.setDataForGetHint()
                    }
                }
            }
        }
    }
    
    var enemyVE = ""
    var visualNodes = [SKSpriteNode]()
    
    
    init(isLeft: Bool, enemyVe: String, cannonVe: String, gap: Int) {
        /* Initialize with enemy asset */
        let texture = SKTexture(imageNamed: "cannonRecordBoard")
        let bodySize = CGSize(width: 285, height: 900)
        super.init(texture: texture, color: UIColor.clear, size: bodySize)
        
        isUserInteractionEnabled = true
        self.enemyVE = enemyVe
        
        zPosition = 2
        if isLeft {
            position = posLeft
        } else {
            position = posRight
        }
        anchorPoint = CGPoint(x: 0.0, y: 1.0)
        
        distanceFromTop = topMargin
        setScrollView()
        setInitial(veForEnemy: enemyVe, veForCannon: cannonVe)
        
        lineUpVisualNode(gap: gap)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollable else { return }
        /* Get touch point */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "scrollView" {
            scrollViewYPos = scrollView.position.y
            startTouchYPos = location.y
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollable else { return }
        if startTouchYPos != 0 {
            /* Get touch point */
            let touch = touches.first!              // Get the first touch
            let location = touch.location(in: self) // Find the location of that touch in this view
            CharacterController.doctor.balloon.isHidden = true
            let dif = location.y - startTouchYPos
            if scrollView.position.y > self.frame.height/2-marginHeight-10 {
                scrollView.position = CGPoint(x: scrollView.position.x, y: scrollViewYPos+dif)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollable else { return }
        if scrollView.position.y < self.frame.height/2-marginHeight {
            let move = SKAction.moveTo(y: self.frame.height/2-marginHeight, duration: 0.1)
            scrollView.run(move)
        }
        startTouchYPos = 0
    }
    private func setScrollView() {
        let texture = SKTexture(imageNamed: "ScrollViewForCannonLog")
        let bodySize = CGSize(width: self.frame.width-marginWidth*2, height: self.frame.height-marginHeight*2)
        scrollView = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        scrollView.name = "scrollView"
        scrollView.anchorPoint = CGPoint(x: 0, y: 1)
        scrollView.position = CGPoint(x: -self.frame.width/2+marginWidth, y: self.frame.height/2-marginHeight)
        scrollView.zPosition = 1
        
        let mask = SKShapeNode(rectOf: CGSize(width: scrollView.frame.width, height: scrollView.frame.height))
        mask.fillColor = UIColor.white
        
        //クロップノードを作成する。
        let cropNode = SKCropNode()
        cropNode.zPosition = 1
        cropNode.name = "mask"
        cropNode.maskNode = mask
        cropNode.addChild(scrollView)
        cropNode.position = CGPoint(x: self.frame.width/2, y: -self.frame.height/2)
        addChild(cropNode)
    }
    
    func setInitial(veForEnemy: String, veForCannon: String) {
        setXLabel()
        setCannon(ve: veForCannon)
        setDistLabel()
        setEnemy()
    }
    
    func setXLabel() {
        let labelPos = CGPoint(x: leftMarginX, y: -topMargin+10)
        createLabel(text: "x", color: nil, pos: labelPos, name: nil, fontSize: 35, font: DAFont.fontName)
    }
    
    func setEnemy() {
        let texture = SKTexture(imageNamed: "front1")
        let bodySize = CGSize(width: 40, height: 40)
        let enemyNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        enemyNode.zPosition = 1
        enemyNode.position = CGPoint(x: leftMarginEnemy, y: -distanceFromTop)
        scrollView.addChild(enemyNode)
        let labelPos = CGPoint(x: leftMarginEnemy, y: -(distanceFromTop+gapBtwNodeNVe))
        createMultiLineLabel(text: self.enemyVE, color: nil, pos: labelPos, name: nil, fontSize: 25)
    }
    
    func setCannon(ve: String) {
        let texture = SKTexture(imageNamed: "cannonFront")
        let bodySize = CGSize(width: 40, height: 40)
        let cannonNode = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        cannonNode.zPosition = 1
        cannonNode.position = CGPoint(x: leftMarginCannon, y: -distanceFromTop)
        scrollView.addChild(cannonNode)
        let labelPos = CGPoint(x: leftMarginCannon, y: -(distanceFromTop+gapBtwNodeNVe))
        createLabel(text: ve, color: nil, pos: labelPos, name: nil, fontSize: 25, isCannon: true)
    }
    
    func setXValue() {
        distanceFromTop += gapBtwTitleNLog
        for i in 1...3 {
            let xlabelPos = CGPoint(x: leftMarginX, y: -distanceFromTop)
            let signal = SignalValueHolder(value: i)
            signal.setScale(0.55)
            signal.zPosition = 1
            signal.position = xlabelPos
            scrollView.addChild(signal)
            distanceFromTop += lineSpace
        }
    }
    
    func setDistLabel() {
        let labelPos1 = CGPoint(x: leftMarginDistTitle, y: -topMargin+20)
        let labelPos2 = CGPoint(x: leftMarginDistTitle, y: -topMargin)
        let labelPos3 = CGPoint(x: leftMarginDistTitle, y: -topMargin-20)
        createLabel(text: "砲撃と", color: nil, pos: labelPos1, name: nil, fontSize: 20, font: DAFont.fontNameForTutorial)
        createLabel(text: "敵との", color: nil, pos: labelPos2, name: nil, fontSize: 20, font: DAFont.fontNameForTutorial)
        createLabel(text: "距離", color: nil, pos: labelPos3, name: nil, fontSize: 20, font: DAFont.fontNameForTutorial)
    }
    
    public func createRecord(xValue: Int, distanse: Int, enemyValue: Int, cannonValue: Int) {
        let lineIndex = xValue - 4
        let enemyLabelPos = CGPoint(x: leftMarginEnemy, y: -(distanceFromTop+lineSpace*CGFloat(lineIndex)))
        createLabel(text: String(enemyValue), color: nil, pos: enemyLabelPos, name: "record", fontSize: 30, isRecord: true)
        let cannonLabelPos = CGPoint(x: leftMarginCannon, y: -(distanceFromTop+lineSpace*CGFloat(lineIndex)))
        createLabel(text: String(cannonValue), color: nil, pos: cannonLabelPos, name: "record", fontSize: 30, isRecord: true)
        let distlabelPos = CGPoint(x: leftMarginDist, y: -(distanceFromTop+lineSpace*CGFloat(lineIndex)))
        createLabel(text: String(distanse), color: nil, pos: distlabelPos, name: "record", fontSize: nil, isDistanse: true, isRecord: true)
        showValueArea(xValue: xValue, enemyValue: enemyValue, cannonValue: cannonValue)
    }
    
    public func createCannon(ve: String) {
        setCannon(ve: ve)
        numOfCannon += 1
        setEnemy()
        distLabel.removeAll()
    }
    
    func createLabel(text: String, color: UIColor?, pos: CGPoint, name: String?, fontSize: CGFloat?, font: String? = DAFont.fontName, isDistanse: Bool = false, isCannon: Bool = false, isRecord: Bool = false) {
        let veLabel = SKLabelNode(fontNamed: font)
        veLabel.text = text
        veLabel.horizontalAlignmentMode = .center
        if isRecord {
            veLabel.verticalAlignmentMode = .center
        } else {
            veLabel.verticalAlignmentMode = .top
        }
        veLabel.fontSize = fontSize ?? 30
        veLabel.position = pos
        veLabel.zPosition = 1
        veLabel.fontColor = color ?? UIColor.white
        veLabel.name = name ?? ""
        if isDistanse {
            distLabel.append(veLabel)
        } else if isCannon {
            currentVeLabel = veLabel
        }
        scrollView.addChild(veLabel)
    }
    
    func createMultiLineLabel(text: String, color: UIColor?, pos: CGPoint, name: String?, fontSize: CGFloat?, font: String? = DAFont.fontName, isDistanse: Bool = false, isCannon: Bool = false) {
        let veLabel = SKLabelNode(fontNamed: font)
        veLabel.text = text
        veLabel.horizontalAlignmentMode = .center
        veLabel.verticalAlignmentMode = .top
        veLabel.fontSize = fontSize ?? 30
        veLabel.position = pos
        veLabel.zPosition = 1
        veLabel.fontColor = color ?? UIColor.white
        veLabel.name = name ?? ""
        if text.count > 4 {
            text.DAMultilined(length: 4) { multiText in
                veLabel.text = multiText
                veLabel.multilinedForVE() { multiLabel in
                    self.scrollView.addChild(multiLabel)
                    self.distanceFromTop += self.gapBtwNodeNVe + 42
                    self.setXValue()
                }
            }
        } else {
            scrollView.addChild(veLabel)
            self.distanceFromTop += self.gapBtwNodeNVe + 21
            self.setXValue()
        }
    }
    
    public func changeCannonVe(newVe: String) {
        currentVeLabel.text = newVe
        removeArea()
        removeRecord()
    }
    
    private func setXValueForVisual() {
        for i in 1...3 {
            let xlabelPos = CGPoint(x: 40+CGFloat(i-1)*80, y: -300)
            let signal = SignalValueHolder(value: i)
            signal.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            signal.setScale(0.55)
            signal.zPosition = 1
            signal.position = xlabelPos
            scrollView.addChild(signal)
        }
    }
    
    let cellLength: CGFloat = 35
    let gapH: CGFloat = 40
    let marginFromLeft: CGFloat = 20
    let marginFromTop: CGFloat = -350
    
    private func lineUpVisualNode(gap: Int) {
        setXValueForVisual()
        if gap > 0 {
            for i in 0...5 {
                if i % 2 == 0 {
                    let pos = CGPoint(x: marginFromLeft+gapH*CGFloat(i), y: marginFromTop-CGFloat(gap)*cellLength)
                    setVisualNode(imgName: "front1", pos: pos)
                } else {
                    let pos = CGPoint(x: marginFromLeft+gapH*CGFloat(i), y: marginFromTop)
                    setVisualNode(imgName: "cannonFront", pos: pos)
                }
            }
        } else {
            for i in 0...5 {
                if i % 2 == 0 {
                    let pos = CGPoint(x: marginFromLeft+gapH*CGFloat(i), y: marginFromTop)
                    setVisualNode(imgName: "front1", pos: pos)
                } else {
                    let pos = CGPoint(x: marginFromLeft+gapH*CGFloat(i), y: marginFromTop-CGFloat(-gap)*cellLength)
                    setVisualNode(imgName: "cannonFront", pos: pos)
                }
            }
        }
    }
    
    private func setVisualNode(imgName: String, pos: CGPoint) {
        let texture = SKTexture(imageNamed: imgName)
        let bodySize = CGSize(width: cellLength, height: cellLength)
        let node = SKSpriteNode(texture: texture, color: UIColor.clear, size: bodySize)
        node.zPosition = 1
        node.position = pos
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scrollView.addChild(node)
        visualNodes.append(node)
    }
    
    private func showValueArea(xValue: Int, enemyValue: Int, cannonValue: Int) {
        switch xValue {
        case 1:
            setValueArea(pos: visualNodes[0].position, value: enemyValue, color: UIColor.red)
            setValueArea(pos: visualNodes[1].position, value: cannonValue, color: UIColor.yellow)
            break;
        case 2:
            setValueArea(pos: visualNodes[2].position, value: enemyValue, color: UIColor.red)
            setValueArea(pos: visualNodes[3].position, value: cannonValue, color: UIColor.yellow)
            break;
        case 3:
            setValueArea(pos: visualNodes[4].position, value: enemyValue, color: UIColor.red)
            setValueArea(pos: visualNodes[5].position, value: cannonValue, color: UIColor.yellow)
            break;
        default:
            break;
        }
    }
    
    private func setValueArea(pos: CGPoint, value: Int, color: UIColor) {
        let length = CGFloat(value)*cellLength
        let area = SKShapeNode(rectOf: CGSize(width: cellLength, height: length))
        area.fillColor = color
        area.alpha = 0.4
        area.zPosition = 2
        area.name = "area"
        area.position = CGPoint(x: pos.x, y: pos.y-(cellLength+area.frame.height)/2)
        scrollView.addChild(area)
        let label = SKLabelNode(fontNamed: DAFont.fontName)
        label.text = String(value)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontSize = 30
        label.name = "record"
        label.position = area.position
        label.zPosition = 5
        label.fontColor = UIColor.white
        scrollView.addChild(label)
    }
    
    private func removeArea() {
        for child in scrollView.children {
            if child.name == "area" {
                child.removeFromParent()
            }
        }
    }
    
    private func removeRecord() {
        for child in scrollView.children {
            if child.name == "record" {
                child.removeFromParent()
            }
        }
    }
}
