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

protocol saveGeometry{
    func storeGeometrydata(_: [CGFloat])
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
    var color: UIColor = UIColor.blue {didSet {setNeedsDisplay()}}

    var graphOrigin:CGPoint? {didSet {setNeedsDisplay()}}

    var dataSource: graphViewdataSource? //the delegate
    var geoSaver: saveGeometry?
    var programToGraph:String?
    
    fileprivate var axis = AxesDrawer()
    fileprivate var xyDataToGraph = [Double:Double]()
    

    //    **************************************
    //    computed properties
    //    **************************************
    var sortedKeys: [Double]{
        get{
            var keys = [Double]()
            for (x, _) in xyDataToGraph{keys.append(x)}
            return keys.sorted(by: <)
        }
    }
    //    **************************************
    //    API
    //    **************************************

    //    **************************************
    //    drawing happens here
    //    **************************************

    override func draw(_ rect: CGRect) {

        if graphOrigin == nil{
            graphOrigin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
//      the coordinate system
        axis.contentScaleFactor = self.contentScaleFactor
        axis.drawAxesInRect(bounds, origin: graphOrigin! , pointsPerUnit:scale)
        
        
//      the graph itself
        let graph = UIBezierPath()
        if let (data, error) = dataSource?.getGraphData(){
            xyDataToGraph = data
            if error != nil {
                programToGraph = error
            }
            else{
               var startPointSet: Bool = false
                
                for x in sortedKeys {
                    if let y = xyDataToGraph[x]{
                        let x0 = (CGFloat(x) * scale) + graphOrigin!.x
                        let y0 = (CGFloat(-y) * scale) + graphOrigin!.y
                        
                        if startPointSet {
                            graph.addLine(to: CGPoint(x: x0, y: y0))
                        }
                        else {
                            graph.move(to: CGPoint(x: x0 , y: y0))
                            startPointSet = true
                        }
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
                NSAttributedStringKey.font.rawValue : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor : color
            ] as! [NSAttributedStringKey: Any]
            let tmpAttributedString = NSMutableAttributedString(string: programDesc, attributes: attributes)
            let textRect = CGRect(origin: CGPoint(x: self.bounds.minX + horizontalOffset, y: self.bounds.minY + verticalOffset), size: tmpAttributedString.size())
            programDesc.draw(in: textRect, withAttributes: attributes)
           
        }
        
        // save the geometry changes in user defaults
        var geometry: [CGFloat] = []
        geometry.insert(self.scale, at: 0)
        geometry.insert(self.graphOrigin!.x, at: 1)
        geometry.insert(self.graphOrigin!.y, at: 2)
        geoSaver?.storeGeometrydata(geometry)
        
    }
    
    func getStatistics() -> [String:Double]{
        var statistics: [String:Double] = [:]
        var values = [Double]()
        for (_, y) in xyDataToGraph{values.append(y)}
        let sortedValues = values.sorted(by: <)

        statistics["min(x) = "] = round(sortedKeys.first!*1000)/1000
        statistics["max(x) = "] = round(sortedKeys.last!*1000)/1000
        statistics["min(y) = "] = round(sortedValues.first!*1000)/1000
        statistics["max(y) = "] = round(sortedValues.last!*1000)/1000
        return statistics
    }

    
//    **************************************
//    gesture handlers
//    **************************************
    
    func scale (_ gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .changed:
            scale *= gesture.scale
            gesture.scale = 1
        default:
            break
        }
    }
    
    func handleTap (_ gesture: UITapGestureRecognizer){
        if gesture.state == .ended  {
            self.graphOrigin = gesture.location(in: self)
        }
    }
    
    func handlePan (_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        graphOrigin!.x = graphOrigin!.x + translation.x
        graphOrigin!.y = graphOrigin!.y + translation.y
        gesture.setTranslation(CGPoint.zero, in: self)
    }//end func


}

    
    

