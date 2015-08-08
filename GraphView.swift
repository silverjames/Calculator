//
//  GraphView.swift
//  generic x/y graphing class. Gets data collection via delegate, plus the upper and lower bounds (x-axis)
//
//  Created by Bernhard Kraft on 01.07.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit


protocol graphViewdataSource {
    func getGraphData() -> ([Double: Double], String?)
}

@IBDesignable
class GraphView: UIView {
    
    //    **************************************
    //    properties
    //    **************************************
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
    var programToGraph:String?
    var error:String?

    //    **************************************
    //    computed properties
    //    **************************************

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


    //    **************************************
    //    drawing happens here
    //    **************************************

    override func drawRect(rect: CGRect) {

//      the coordinate system
        axis.drawAxesInRect(bounds, origin: axisCenter! , pointsPerUnit:pointsPerUnit)
        
        
//      the graph itself
        var graph = UIBezierPath()
        if let (data, error) = dataSource?.getGraphData(){
            if error != nil {
                programToGraph = error
            }
            else{
                var keys = [Double]()
                for (x, _) in data{keys.append(x)}
                var sortedKeys = sorted(keys, <)
                var startPointSet: Bool = false
                
                for x in sortedKeys {
                    if startPointSet {
                        graph.addLineToPoint(CGPoint(x: (x  * pointsPerUnit.native + axisCenter!.x.native), y: (-data[x]! * pointsPerUnit.native + axisCenter!.y.native)))
                    }
                    else {
                        graph.moveToPoint(CGPoint(x: (x * pointsPerUnit.native + axisCenter!.x.native) , y: (-data[x]! * pointsPerUnit.native + axisCenter!.y.native)))
                        startPointSet = true
                    }
                    
                }//for..in loop
                
                graph.lineWidth = lineWidth
                color.set()
                graph.stroke()
            }
            
        }
        
//      and now an annotation as to what program was graphed
        if let programDesc = programToGraph{
            let verticalOffset: CGFloat = 70
            let horizontalOffset: CGFloat = 0
            let attributes = [
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(origin: CGPointMake(self.bounds.minX + horizontalOffset, self.bounds.minY + verticalOffset), size: programDesc.sizeWithAttributes(attributes))
            programDesc.drawInRect(textRect, withAttributes: attributes)
           
        }
        
    }

    
//    **************************************
//    gesture handlers
//    **************************************
    
    func scale (gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .Changed:
            pointsPerUnit *= gesture.scale
            gesture.scale = 1
        default:
            break
        }
    }
    
    func handleTap (gesture: UITapGestureRecognizer){
        if gesture.state == .Ended  {
            axisCenter = gesture.locationInView(self)
            setNeedsDisplay()
        }
    }
    
    func handlePan (gesture: UIPanGestureRecognizer){
        var translation = gesture.translationInView(self)
        if let tmpPoint = axisCenter {
            axisCenter!.x = axisCenter!.x + translation.x
            axisCenter!.y = axisCenter!.y + translation.y
            gesture.setTranslation(CGPointZero, inView: self)
            setNeedsDisplay()
        }
        else {
            println("axisCenter not initialized!")
        }
        
    }//end func


}

    
    

