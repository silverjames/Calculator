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
    var geometry: [CGFloat] = []
    var defaults = NSUserDefaults.standardUserDefaults()

    struct Constants {
        let userDefaultsKey = "graphView"
    }
    let constants = Constants()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "handleTap:"))
            graphView.contentMode = UIViewContentMode.Redraw
            
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
        
        if let defaultsData: AnyObject = defaults.objectForKey(constants.userDefaultsKey){
            println("GVC: found defaults data")
            if let geometryData = defaultsData as? [CGFloat]{
                println("GVC:viewDidLoad: geometry readout: \(geometryData)")
                graphView.scale = geometryData[0]
                graphView.graphOrigin?.x = geometryData[1]
                graphView.graphOrigin?.y = geometryData[2]
            }
        }
        updateUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        geometry.insert(graphView.scale, atIndex: 0)
        geometry.insert(graphView.graphOrigin!.x, atIndex: 1)
        geometry.insert(graphView.graphOrigin!.y, atIndex: 2)
        println("GVC:viewDidAppear: geometry readout: \(geometry)")
        defaults.setObject(geometry, forKey: constants.userDefaultsKey)
    }
    
    func updateUI() {
        graphView.setNeedsDisplay()
    }

    //    **************************************
    //    delegate functions - get stuff from the model
    //    **************************************
    
    func    getGraphData() -> ([Double : Double], String?) {
        var lBounds = -graphView.graphOrigin!.x/graphView.scale
        var uBounds = (graphView.bounds.width - graphView.graphOrigin!.x)/graphView.scale
        model.lowerBound = lBounds.native
        model.upperBound = uBounds.native
        model.increment = 1/graphView.scale.native
        model.program = programToLoad
        return model.getGraphData()
    }
    
 
    
}