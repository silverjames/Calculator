//
//  ViewController.swift
//  Calculator
//
//  Created by Bernhard Kraft on 03.04.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

 
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    var operandStack = Array<Double>()
    var displayValue: Double{
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operand = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            enter()
        }
        //historyLabel.text! = historyLabel.text! + "/\(operand)"
        
        switch operand {
        case "×": performOperations {$0 * $1}
        case "÷": performOperations {$1 / $0}
        case "+": performOperations {$0 + $1}
        case "−": performOperations {$1 - $0}
        case "√": performOperation {sqrt ($0)}
        case "sin": performOperation {sin ($0)}
        case "cos": performOperation {cos($0)}
        default: break
        }
        
    }
    
    //why does it not allow me to use the same func name?
    func performOperations(operation: (Double, Double) -> Double){
        if operandStack.count >= 2 {
            //historyLabel.text! = historyLabel.text! + "/\(operandStack.last)"
            displayValue = operation (operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }

  
    
    func performOperation(operation: Double -> Double){
        if operandStack.count >= 1 {
            displayValue = operation (operandStack.removeLast())
            enter()
        }
    }

    @IBAction func sendPi() {
        if userIsInTheMiddleOfTyping{ enter()}
        operandStack.append(M_PI)
        
    }
    @IBAction func sendDigit(sender: UIButton){
        
        let digit = sender.currentTitle!
        
            if userIsInTheMiddleOfTyping {
                if ((display.text?.rangeOfString(".") != nil) && digit != ".") || display.text?.rangeOfString(".") == nil{
                    display.text = display.text! + digit}
            }
            else {
                userIsInTheMiddleOfTyping = true
                display.text = digit
            }
        
    }
    
    
    @IBAction func clearAll() {
        operandStack.removeAll(keepCapacity: false)
        //historyLabel.text = nil
        displayValue = 0
        
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        operandStack.append(displayValue)
        println("operandStack: \(operandStack)")
    }
}
