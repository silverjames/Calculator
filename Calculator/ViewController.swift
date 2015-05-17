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

 //declarations
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    var brain = CalculatorBrain()
    var displayValue: Double?{
        get {
            var tmpDisplayText = display.text ?? ""
            if let number = NSNumberFormatter().numberFromString(tmpDisplayText){
                return number.doubleValue
            }
            else{
                display.text = "invalid operation"
                return nil
            }
        }
        set {
            var tempValue = newValue ?? 0
            display.text = "\(tempValue)"
        }
    }
    
//outlets and actions
    @IBAction func getMemory() {
        if let memory = brain.variableValues["M"]{
            displayValue = memory
        }
    }
    
    @IBAction func setMemory() {
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        }
        brain.pushOperand("M")
        brain.variableValues["M"] = NSNumberFormatter().numberFromString(display.text!)?.doubleValue ?? nil
    }
    

    @IBAction func operate(sender: UIButton) {
        let operand = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            stackOperand()
        }
        brain.pushOperation(operand)
        enter()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping && (display.text != nil){
            let lengthOfDisplayText = count (display.text!)
            if lengthOfDisplayText > 1{
                display.text = dropLast (display.text!)
            }
            else {
                display.text = " "
            }
        }
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
        historyLabel.text = " "
        displayValue = nil
        brain.clear()
        
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTyping{
            stackOperand()
        }
        displayValue = brain.evaluate()
        historyLabel.text! = brain.description ?? " "
        
    }
    
//helper functions
    func stackOperand(){
        userIsInTheMiddleOfTyping = false
        var tmpDisplayText = display.text ?? "  "
        brain.pushOperand(displayValue)
    }
    

}

