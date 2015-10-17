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

    //    **************************************
    //    properties
    //    **************************************
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    var brain = CalculatorBrain()
    var valueFormatter = NSNumberFormatter()
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    var program: [String]{
        get{return defaults.objectForKey(Constants.userDefaultsKey) as? [String] ?? []}
        set{defaults.setObject(newValue, forKey: Constants.userDefaultsKey)}
    }
    struct Constants {
        static let graphViewSegue = "Show Graph"
        static let userDefaultsKey = "CalculatorViewController.program"
        static let memoryButton = "M"
    }

    
    var displayValue: Double?{
        get {
            if let _ = display.text {
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
    
    //    **************************************
    //    outlets
    //    **************************************
    @IBAction func getMemory() {
        let (memory, msg) = brain.pushOperand(Constants.memoryButton)
        
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
                brain.variableValues[Constants.memoryButton] = value
//                println("CVC: set mem to \(brain.variableValues[Constants.memoryButton])")
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
            
            let lengthOfDisplayText = (display.text!).characters.count
            if lengthOfDisplayText > 1{
                display.text = String((display.text!).characters.dropLast ())
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
        print("display text: \(display.text)")
    }
    
    
    @IBAction func clearAll() {
        historyLabel.text = " "
        displayValue = nil
        brain.clear()
        defaults.removeObjectForKey(Constants.userDefaultsKey)
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTyping{
            stackOperand()
        }
        evaluateAndDisplayResult()
        
    }

    //    **************************************
    //    lifecycle function overrides
    //    **************************************
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
        
          brain.program = program
 
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
        program = brain.program as! [String]
    }
    
    
    //    **************************************
    //    preparing for segues
    //    **************************************
    override func prepareForSegue(segue: UIStoryboardSegue , sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController

        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController
        }
        
        if let gvc = destination as? GraphViewController{
            if let identifier = segue.identifier{
                switch identifier{
                case Constants.graphViewSegue :
                    gvc.programToGraph = brain.getCurrentProgram() ?? ""
                    gvc.programToLoad = brain.program as! [String]
                default:
                    break
                }
            }
        }
   }
    
    //    **************************************
    //    private API
    //    **************************************

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

