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
            if let number = NSNumberFormatter().numberFromString(display.text!){
                return number.doubleValue
            }
            else{
                return nil
            }
        }
        set {
            if let tempValue = newValue{
                display.text = "\(tempValue)"
            }
            else {
                display.text = " "
            }
        }
    }
    
//outlets and actions
    override func viewDidLoad() {
        super.viewDidLoad()
        displayValue = nil
        historyLabel.text = ""
    }
    
    @IBAction func getMemory() {
        if let memory = brain.pushOperand("M"){
            displayValue = memory
            historyLabel.text = brain.description ?? " "
        }
    }
    
    @IBAction func setMemory() {
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        }
        brain.variableValues["M"] = NSNumberFormatter().numberFromString(display.text!)?.doubleValue ?? nil
        displayValue = brain.evaluate()
        historyLabel.text = brain.description ?? " "
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
//        stackOperand()
        brain.pushOperand("π")
        displayValue = brain.getConstantValue("π")
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
        evaluateAndDisplayResult()
    }
    
//helper functions
    private func stackOperand(){
        userIsInTheMiddleOfTyping = false
        brain.pushOperand(displayValue)
    }
    
    private func evaluateAndDisplayResult() {
        displayValue = brain.evaluate()
        historyLabel.text = brain.description ?? " "
        
    }
    

}

