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
    var lowerBound: Double = -1
    var upperBound: Double = 1
    var model  = GraphViewModel()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            updateUI()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUI() {
        graphView.setNeedsDisplay()
    }

//    **************************************
//    API
//    **************************************
    
    func    getGraphData() -> [Double : Double] {
        model.lowerBound = lowerBound
        model.upperBound = upperBound
        return model.getGraphData()
    }
    
    
    
}