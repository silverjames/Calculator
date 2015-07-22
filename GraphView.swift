//
//  GraphView.swift
//  generic x/y graphing class. Gets data collection via delegate, plus the upper and lower bounds (x-axis)
//
//  Created by Bernhard Kraft on 01.07.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit


protocol graphViewdataSource {
    func getGraphData() -> [Double: Double]
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 50.0 { didSet {setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet {setNeedsDisplay()}}
    @IBInspectable
    var color: UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}
    
    var dataSource: graphViewdataSource? //the delegate
    var axis = AxesDrawer()
    var data = [Double : Double]()
    var axisCenter:CGPoint?
    
//  computed properties
    var lowerBound: Double {
        if axisCenter == nil{
            return -(bounds.width.native/2)/pointsPerUnit.native
        }
        else{
            return -axisCenter!.x.native/pointsPerUnit.native
        }
    }
    var upperBound: Double {
        if axisCenter == nil {
            return (bounds.width.native/2)/pointsPerUnit.native
        }
        else {
            return (bounds.width.native - axisCenter!.x.native)/pointsPerUnit.native
        }
    }
    var viewCenter: CGPoint {
        return convertPoint(center, fromView: superview)}


//  drawing goes here
    override func drawRect(rect: CGRect) {

//      the coordinate system
        axis.drawAxesInRect(bounds, origin: axisCenter! , pointsPerUnit:pointsPerUnit)
        
        
//      the graph itself
        var graph = UIBezierPath()
        if let data = dataSource?.getGraphData(){
            var keys = [Double]()
            for (x, _) in data{keys.append(x)}
            var sortedKeys = sorted(keys, <)
            var startPointSet: Bool = false
            
            for x in sortedKeys {
                if startPointSet {
                    graph.addLineToPoint(CGPoint(x: (x  * pointsPerUnit.native + axisCenter!.x.native), y: (data[x]! * pointsPerUnit.native + axisCenter!.y.native)))
                }
                else {
                    graph.moveToPoint(CGPoint(x: (x * pointsPerUnit.native + axisCenter!.x.native) , y: (data[x]! * pointsPerUnit.native + axisCenter!.y.native)))
                    startPointSet = true
                }
                
            }//for..in loop
            
            graph.lineWidth = lineWidth
            color.set()
            graph.stroke()
            
        }// data obtained
        
    }

    //    gesture handlers
    func scale (gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .Changed:
            pointsPerUnit *= gesture.scale
            gesture.scale = 1
        default:
            break
        }
    }

}

    
    

