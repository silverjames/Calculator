//
//  GraphView.swift
//  Calculator
//
//  Created by Bernhard Kraft on 01.07.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit


protocol graphViewdataSource {
    var lowerBound: Double {get}
    var upperBound: Double {get}
    
    func getGraphData() -> [Double: Double]
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit = CGFloat(50.0) { didSet {setNeedsDisplay()}}
    
    var dataSource: graphViewdataSource? //the delegate
    var axis = AxesDrawer()
    var origin = CGPoint (x: CGFloat(0), y: CGFloat(0))
    var data = [Double : Double]()
    
//  computed properties
    var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }

//  drawing goes here
    override func drawRect(rect: CGRect) {
        axis.drawAxesInRect(bounds, origin: graphCenter , pointsPerUnit:pointsPerUnit)
        if let data = dataSource?.getGraphData(){
            println("got data")
        }
        
    }

    //    gesture handlers
    func scale (gesture: UIPinchGestureRecognizer){
        
        switch gesture.state{
        case .Changed:
            pointsPerUnit *= gesture.scale
//            println("pinch recognized, scale is: \(gesture.scale)")
            gesture.scale = 1
        default:
            break
        }
        
        
    }

    
    
}
