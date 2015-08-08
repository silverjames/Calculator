//
//  ViewController.swift
//  Calculator
//
//  Created by Bernhard Kraft on 03.04.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{

 //declarations
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    var brain = CalculatorBrain()
    var valueFormatter = NSNumberFormatter()
    var defaults = NSUserDefaults.standardUserDefaults()
    struct Constants {
        let graphViewSegue = "Show Graph"
        let userDefaultsKey = "Calculator"
        let memoryButton = "M"
    }
    var constants = Constants()

    
    var displayValue: Double?{
        get {
            if let displayTxt = display.text {
                return valueFormatter.numberFromString(display.text!)?.doubleValue
            }
                return nil
        }
        set {
            if let tempValue = newValue{
                display.text = "\(NSNumberFormatter.localizedStringFromNumber(tempValue, numberStyle: .DecimalStyle))"
            }
            else {
                display.text = " "
            }
        }
    }
    
//outlets and actions
//lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        displayValue = nil
        historyLabel.text = " "

        valueFormatter.locale = NSLocale.currentLocale()
        valueFormatter.numberStyle = .DecimalStyle
        valueFormatter.generatesDecimalNumbers = true
        
        for button in view.subviews{
            if button is UIButton {
                    //button.backgroundColor = UIColor.clearColor()
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 0.1
                button.layer.borderColor = UIColor.grayColor().CGColor
//                button.layer.backgroundColor = UIColor.grayColor().CGColor
            }
        }
        
        for label in view.subviews {
            if label is UILabel {
                label.layer.cornerRadius = 5
                label.layer.borderWidth = 0.2
                label.layer.borderColor = UIColor.blueColor().CGColor
            }
        }
        
        if let defaultsData: AnyObject = defaults.objectForKey(constants.userDefaultsKey){
            println("CVC: found defaults data")
            brain.program = defaultsData
 
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
        defaults.setObject(brain.program, forKey: constants.userDefaultsKey)
    }
    
//outlets
    @IBAction func getMemory() {
        let (memory, msg) = brain.pushOperand(constants.memoryButton)

        if memory != nil {
            displayValue = memory
            if let desc = brain.description{
                historyLabel.text = desc + "="
            }
        }
        else{
            display.text = msg
        }
    }
    
    @IBAction func setMemory() {
        if userIsInTheMiddleOfTyping {userIsInTheMiddleOfTyping = false}
        
        if display.text != nil{
            if let value = valueFormatter.numberFromString(display.text!)?.doubleValue {
                brain.variableValues[constants.memoryButton] = value
                println("CVC: set mem to \(brain.variableValues[constants.memoryButton])")
            }
        }
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
        if userIsInTheMiddleOfTyping && (display.text != nil){//backspace

            let lengthOfDisplayText = count (display.text!)
            if lengthOfDisplayText > 1{
                display.text = dropLast (display.text!)
            }
            else {
                displayValue = nil
            }
        } else {// undo
            brain.undo()
            enter()
        }
    }
    
    @IBAction func sendPi() {
//        stackOperand(
        brain.pushOperand("π")
        displayValue = brain.getConstantValue("π")
    }
    
    @IBAction func sendDigit(sender: UIButton){
        let digit = sender.currentTitle!
            if userIsInTheMiddleOfTyping {
                if ((display.text?.rangeOfString(".") != nil) && digit != ".") || display.text?.rangeOfString(".") == nil {
                    display.text = display.text! + digit
                }
            }
            else {
                userIsInTheMiddleOfTyping = true
                display.text = digit
            }
        println("display text: \(display.text)")
    }
    
    
    @IBAction func clearAll() {
        historyLabel.text = " "
        displayValue = nil
        brain.clear()
        defaults.removeObjectForKey(constants.userDefaultsKey)
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTyping{
            stackOperand()
        }
        evaluateAndDisplayResult()

    }
    
// preparing for segues
    override func prepareForSegue(segue: UIStoryboardSegue , sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
            case Constants().graphViewSegue :
                if let vc = segue.destinationViewController as? GraphViewController{
                    vc.programToGraph = brain.getCurrentProgram() ?? ""
                    if let defaults = defaults.valueForKey(constants.userDefaultsKey) as? [String] {
                        vc.programToLoad = defaults
                    }
                }
            default:
                break
            }
        }
    }
    
//helper functions
    private func stackOperand(){
        userIsInTheMiddleOfTyping = false
        brain.pushOperand(displayValue)
    }
    
    private func evaluateAndDisplayResult() {
        let (tmpValue, errMsg) = brain.evaluate()
        if errMsg != nil {
            display.text = errMsg
        }
        else {
            displayValue = tmpValue
        }
        historyLabel.text = brain.description ?? " "
        
    }
    

}

