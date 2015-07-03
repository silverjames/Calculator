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
    let divider = 0.1
    
    func getGraphData() -> [Double: Double] {
        var data = [Double: Double]()
        var stepper = lowerBound
        while stepper <= upperBound{
            data[stepper] = sin(stepper)
            stepper = stepper + divider
        }
        return data
        
    }
    
}
