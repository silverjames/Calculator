//
//  GraphViewContoller.swift
//  Calculator
//
//  Created by Bernhard Kraft on 30.06.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, graphViewdataSource
{
//    initialization and lifecycle functions
    var model  = GraphViewModel()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
            updateUI()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        graphView.axisCenter = graphView.viewCenter
        updateUI()
    }
    
    func updateUI() {
        graphView.setNeedsDisplay()
    }

//    **************************************
//    API
//    **************************************
    
    func    getGraphData() -> [Double : Double] {
        model.lowerBound = graphView.lowerBound
        model.upperBound = graphView.upperBound
        model.increment = 1/graphView.pointsPerUnit.native
        return model.getGraphData()
    }
    
//    **************************************
//    gesture handler
//    **************************************
   
    func pan (gesture: UIPanGestureRecognizer){
        var translation = gesture.translationInView(graphView)
        if let tmpPoint = graphView.axisCenter {
            graphView.axisCenter!.x = graphView.axisCenter!.x + translation.x
            graphView.axisCenter!.y = graphView.axisCenter!.y + translation.y
            gesture.setTranslation(CGPointZero, inView: graphView)
            updateUI()
        }
        else {
            println("axisCenter not initialized!")
        }
        
        
    }//end func
  
    
}