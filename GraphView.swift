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
    var scale: CGFloat = 50.0 { didSet {setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet {setNeedsDisplay()}}
    @IBInspectable
    var color: UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}

    var graphOrigin:CGPoint? {didSet {setNeedsDisplay()}}
    
    var dataSource: graphViewdataSource? //the delegate
    var axis = AxesDrawer()
    var data = [Double : Double]()
    var programToGraph:String?
    var error:String?
    
    

    //    **************************************
    //    computed properties
    //    **************************************


    //    **************************************
    //    drawing happens here
    //    **************************************

    override func drawRect(rect: CGRect) {

        if graphOrigin == nil{
            graphOrigin = CGPointMake(bounds.midX, bounds.midY)
        }
        
//      the coordinate system
        axis.contentScaleFactor = self.contentScaleFactor
        axis.drawAxesInRect(bounds, origin: graphOrigin! , pointsPerUnit:scale)
        
        
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
                    var x0 = (CGFloat(x) * scale) + graphOrigin!.x
                    var y0 = (CGFloat(-data[x]!) * scale) + graphOrigin!.y

                    if startPointSet {
                        graph.addLineToPoint(CGPointMake(x0, y0))
                    }
                    else {
                        graph.moveToPoint(CGPointMake(x0 , y0))
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
            scale *= gesture.scale
            gesture.scale = 1
        default:
            break
        }
    }
    
    func handleTap (gesture: UITapGestureRecognizer){
        if gesture.state == .Ended  {
            self.graphOrigin = gesture.locationInView(self)
        }
    }
    
    func handlePan (gesture: UIPanGestureRecognizer){
        var translation = gesture.translationInView(self)
        graphOrigin!.x = graphOrigin!.x + translation.x
        graphOrigin!.y = graphOrigin!.y + translation.y
        gesture.setTranslation(CGPointZero, inView: self)
    }//end func


}

    
    

