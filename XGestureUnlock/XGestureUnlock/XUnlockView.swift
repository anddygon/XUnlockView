//
//  UnlockView.swift
//  XGestureUnlock
//
//  Created by eduo_xiaoP on 15/4/6.
//  Copyright (c) 2015年 eduo. All rights reserved.
//

import Foundation
import UIKit

@objc protocol UnlockViewDelegate: NSObjectProtocol {
    optional func trackFinished(track: NSString)
}

class XUnlockView: UIView {
    
    struct Constant {
        static let Line_Width: CGFloat = 12
        static let Line_Color = UIColor(red: 32/255.0, green: 210/255.0, blue: 254/255.0, alpha: 0.7)
        static let rows: Int = 3
        static let cols: Int = 3
        static let totalNodes = Constant.rows * Constant.cols
    }
    
    @IBOutlet  var nodes = [Node]()
    
    weak var delegate: UnlockViewDelegate?
    
    var movePoint: CGPoint = CGPointMake(-1, -1)
    
    var selectNodes = [Node]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildNodes()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildNodes()
    }
    
    func buildNodes() {
        for var index = 0; index < Constant.totalNodes; index++ {
            let node = Node.node()
            node.tag = index
            addSubview(node)
            nodes.append(node)
        }
    }
    
    override func layoutSubviews() {
        for var index = 0; index < Constant.totalNodes; index++ {
            let node             = nodes[index]
            let marginX: CGFloat = 20
            let marginY: CGFloat = 20
            let nodeWidth        = (bounds.size.width - 4 * marginX) / CGFloat(Constant.cols)
            let nodeHeight       = nodeWidth
            let nodeRow          = index / Constant.rows
            let nodeCol          = index % Constant.cols
            let nodeX            = CGFloat(nodeCol) * (nodeWidth + marginX) + marginX
            let nodeY            = CGFloat(nodeRow) * (nodeHeight + marginY) + marginY
            node.frame           = CGRectMake(nodeX, nodeY, nodeWidth, nodeHeight)
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if selectNodes.count == 0 {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter)
        
        Constant.Line_Color.set()

        let path           = UIBezierPath()
        path.lineJoinStyle = kCGLineJoinBevel
        path.lineCapStyle  = kCGLineCapRound
        path.lineWidth     = Constant.Line_Width
        
        for index in 0..<selectNodes.count {
        let node = selectNodes[index]
            index == 0 ? path.moveToPoint(node.center) : path.addLineToPoint(node.center)
        }

        if movePoint != CGPointMake(-1, -1) {
            path.addLineToPoint(movePoint)
        }

        path.stroke()
        
    }
    
    func getPointWithTouches(touches: NSSet) -> CGPoint{
        let touch = touches.anyObject() as UITouch
        return touch.locationInView(touch.view)
    }
    
    func getNodeWithPoint(point: CGPoint) -> Node? {
        for node in nodes {
            if node.frame.contains(point) && (node.selected == false) {
                return node
            }
        }
        return nil
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let point = getPointWithTouches(touches)
        if let node = getNodeWithPoint(point) {
            selectNodes.append(node)
            node.selected = true
            movePoint = point
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let point = getPointWithTouches(touches)
        if let node = getNodeWithPoint(point) {
            selectNodes.append(node)
            node.selected = true
        }else {
            movePoint = point
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var track = NSMutableString()
        for node in selectNodes {
            node.selected = false
            track.appendFormat("%d", node.tag)
        }
        
        if track.length != 0 {
            if delegate != nil && delegate!.respondsToSelector("trackFinished:") {
                delegate!.trackFinished!(track)
            }
        }
        
        selectNodes.removeAll(keepCapacity: false)
        movePoint = CGPointMake(-1, -1)
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
}

class Node: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        build()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        build()
    }
    
    func build() {
        setBackgroundImage(UIImage(named: "gesture_node_normal"), forState: .Normal)
        setBackgroundImage(UIImage(named: "gesture_node_highlighted"), forState: .Selected)
        userInteractionEnabled = false
    }
    
    class func node() -> Node {
        return super.buttonWithType(.Custom) as Node
    }
}