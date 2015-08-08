//
//  GraphViewModel.swift
//  Calculator
//
//  Created by Bernhard Kraft on 03.07.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import Foundation


class GraphViewModel: AnyObject, graphViewdataSource  {
  
    var lowerBound: Double = 0.0
    var upperBound: Double = 0.0
    var program: [String] = []
    var increment: Double = 0.1
    var brain = CalculatorBrain()
    
    func getGraphData() -> ([Double: Double], String?) {
        var data = [Double: Double]()
        var stepper = lowerBound
        var error:String?
        brain.program = program
        
        while stepper <= upperBound{
            brain.variableValues["M"] = stepper
            let (result, errMsg) = brain.evaluate()
            if let error = errMsg {break}
            data[stepper] = result
            stepper = stepper + increment
        }
        return (data, error)
        
    }
    
}
