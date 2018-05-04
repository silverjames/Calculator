//
//  GraphViewContoller.swift
//  Calculator
//
//  Created by Bernhard Kraft on 30.06.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, graphViewdataSource, saveGeometry, UIPopoverPresentationControllerDelegate
{
    //MARK: properties
    //    **************************************
    //    properties and outlets
    //    **************************************
    var model  = GraphViewModel()
    var programToGraph: String = ""
    var programToLoad: [String] = []
    fileprivate var defaults = UserDefaults.standard

    var geometry: [CGFloat]{
        get {return defaults.object(forKey: Constants.userDefaultsKey) as? [CGFloat] ?? []}
        set {defaults.set(newValue, forKey: Constants.userDefaultsKey)}
    }

    struct Constants {
        static let userDefaultsKey = "GraphViewController.geometryData"
        static let statisticsSegue = "showStats"
    }
    let constants = Constants()


    
    //MARK: outlets
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            print("GVC: setting outlet")
            graphView.dataSource = self
            graphView.geoSaver = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: Selector(("scale:"))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "handleTap:"))
            graphView.contentMode = UIViewContentMode.redraw
            
            updateUI()
        }
    }
    

    //MARK: lifecycle function overrides
    //    **************************************
    //    lifecycle function overrides
    //    **************************************

   override func viewDidLoad() {
        print("GVC: viewDidLoad")
        super.viewDidLoad()
        graphView.programToGraph = self.programToGraph
        let countGestures = graphView.gestureRecognizers?.count ?? 0
        for idx in 0 ..< countGestures {
            if let gr = graphView.gestureRecognizers?[idx] as? UITapGestureRecognizer{
                gr.numberOfTapsRequired = 2
                break
            }
        }
    
        if !geometry.isEmpty{
            graphView.scale = geometry[0]
            graphView.graphOrigin = CGPoint(x: geometry[1], y: geometry[2])
        }
    
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("GVC: viewWillAppear")
        super.viewWillAppear(true)
    }
    
    
    override func viewDidLayoutSubviews() {
        print("GVC: viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("GVC: viewDidAppear")
        super.viewDidAppear(animated)
    }
    //MARK: prepare for segues
    //    **************************************
    //    preparing for segues
    //    **************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsPopover = segue.destination as? StatisticsViewController{
            if let identifier = segue.identifier{
                switch identifier{
                case Constants.statisticsSegue:
                    if let ppc = statsPopover.popoverPresentationController {
                        ppc.delegate = self
                    }
                    for (stat, value) in graphView.getStatistics(){
                        if statsPopover.text == nil{
                            statsPopover.text = ""
                        }
                        statsPopover.text = statsPopover.text! + stat
                        statsPopover.text = statsPopover.text! + "\(value)"
                        statsPopover.text = statsPopover.text! + "\n"
                    }
                default:
                    break
                }
            }
        }
    }

    //MARK:  API
    //    **************************************
    //    internal functions
    //    **************************************
    func updateUI() {
        print("GVC: updateUI")
        graphView.setNeedsDisplay()
    }

    //    **************************************
    //    delegate functions - get stuff from the model
    //    **************************************
    
    func    getGraphData() -> ([Double : Double], String?) {
//        print("GVC: getGraphData")
        let lBounds = -graphView.graphOrigin!.x/graphView.scale
        let uBounds = (graphView.bounds.width - graphView.graphOrigin!.x)/graphView.scale
        model.lowerBound = lBounds.native
        model.upperBound = uBounds.native
        model.increment = 1/graphView.scale.native
        model.program = programToLoad
        return model.getGraphData()
    }
    
    func    storeGeometrydata(_ data: [CGFloat]) {
        geometry = data
        
    }
 
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.popover
    }
    
}
