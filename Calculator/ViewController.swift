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
    var brain = CalculatorBrain()
    var displayValue: Double?{
        get {
            if let displayText = display.text{
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
            else{
                return nil
            }
        }
        set {
            var tempValue = newValue ?? 0
            display.text = "\(tempValue)"
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operand = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            enter()
        }
        historyLabel.text! = historyLabel.text! + "/\(operand)"
        brain.pushOperation(operand)
        let result = brain.evaluate()
        displayValue = (result ?? nil)
    }
    
    @IBAction func sendPi() {
        if userIsInTheMiddleOfTyping{ enter()}
        //operandStack.append(M_PI)
        
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
        historyLabel.text = ""
        displayValue = 0
        brain.clear()
        
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        historyLabel.text! = historyLabel.text! + "/\(display.text!)"
        brain.pushOperand(displayValue!)
        let result = brain.evaluate()
        displayValue = (result ?? 0)

    }
}

