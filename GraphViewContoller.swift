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
    //    **************************************
    //    initialization and lifecycle functions
    //    **************************************
    var model  = GraphViewModel()
    var programToGraph: String = ""
    var programToLoad: [String] = []
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "handleTap:"))
            
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.programToGraph = self.programToGraph
        var countGestures = graphView.gestureRecognizers?.count ?? 0
        for var idx = 0; idx < countGestures; idx++ {
            if let gr = graphView.gestureRecognizers?[idx] as? UITapGestureRecognizer{
                gr.numberOfTapsRequired = 2
                break
            }
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
    //    delegate functions - get stuff from the model
    //    **************************************
    
    func    getGraphData() -> ([Double : Double], String?) {
        model.lowerBound = graphView.lowerBound
        model.upperBound = graphView.upperBound
        model.increment = 1/graphView.pointsPerUnit.native
        model.program = programToLoad
        return model.getGraphData()
    }
    
 
    
}