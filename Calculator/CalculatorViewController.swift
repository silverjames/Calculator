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
    //MARK: properties
    //    **************************************
    //    properties
    //    **************************************
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var messageLine: UILabel!
    
    
    var userIsInTheMiddleOfTyping: Bool = false
    var brain = CalculatorBrain()
    fileprivate var formatter = NumberFormatter()
    fileprivate var locale = Locale.current
    fileprivate var defaults = UserDefaults.standard
    fileprivate var localeDecimalSeparator:String?
    
    var program: [String]{
        get{return defaults.object(forKey: Constants.userDefaultsKey) as? [String] ?? []}
        set{defaults.set(newValue, forKey: Constants.userDefaultsKey)}
    }
    struct Constants {
        static let graphViewSegue = "Show Graph"
        static let userDefaultsKey = "CalculatorViewController.program"
        static let memoryButton = "M"
    }

    
    var displayValue: Double?{
        get {
            if let _ = display.text {
                return formatter.number(from: display.text!)?.doubleValue
            }
                return nil
        }
        set {
            if let tempValue = newValue{
                display.text = "\(NumberFormatter.localizedString(from: NSNumber(value:tempValue), number: .decimal))"
            }
            else {
                display.text = " "
            }
        }
    }
    //MARK: outlets
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
            if let value = formatter.number(from: display.text!)?.doubleValue {
                brain.variableValues[Constants.memoryButton] = value
//                println("CVC: set mem to \(brain.variableValues[Constants.memoryButton])")
            }
        }
    }
    
    
    @IBAction func operate(_ sender: UIButton) {
        let operand = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            stackOperand()
        }
        brain.pushOperation(operand)
        enter()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping && (display.text != nil){//backspace
            
//            let lengthOfDisplayText = (display.text!).characters.count
            let lengthOfDisplayText = (display.text!).count
            if lengthOfDisplayText > 1{
                display.text = String((display.text!).dropLast ())
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
        brain.pushOperand("π")
        displayValue = brain.getConstantValue("π")
    }
    
    @IBAction func sendDigit(_ sender: UIButton){
        messageLine.text = " "
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if ((display.text?.range(of: localeDecimalSeparator!) != nil) && digit != localeDecimalSeparator!) || display.text?.range(of: localeDecimalSeparator!) == nil {
                display.text = display.text! + digit
            }
        }
        else {
            userIsInTheMiddleOfTyping = true
            display.text = digit
        }
        print("display text: \(String(describing: display.text))")
    }
    
    
    @IBAction func clearAll() {
        historyLabel.text = " "
        messageLine.text = " "
        displayValue = nil
        brain.clear()
        defaults.removeObject(forKey: Constants.userDefaultsKey)
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTyping{
            stackOperand()
        }
        evaluateAndDisplayResult()
        
    }
    
    
    //MARK: lifecycle function overrides
    //    **************************************
    //    lifecycle function overrides
    //    **************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        displayValue = nil
        historyLabel.text = " "
        messageLine.text = " "

//        valueFormatter.locale = NSLocale.currentLocale()
//        valueFormatter.numberStyle = .DecimalStyle
//        valueFormatter.generatesDecimalNumbers = true
        localeDecimalSeparator = formatter.decimalSeparator
        
        for button in view.subviews{
            if button is UIButton {
                    //button.backgroundColor = UIColor.clearColor()
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 0.1
                button.layer.borderColor = UIColor.gray.cgColor
//                button.layer.backgroundColor = UIColor.grayColor().CGColor
            }
        }
        
        for label in view.subviews {
            if label is UILabel {
                label.layer.cornerRadius = 5
                label.layer.borderWidth = 0.2
                label.layer.borderColor = UIColor.blue.cgColor
            }
        }
        
          brain.program = (program as AnyObject) as! [String]
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        program = brain.program
    }
    
    
    //MARK: prepare for segues
    //    **************************************
    //    preparing for segues
    //    **************************************
    override func prepare(for segue: UIStoryboardSegue , sender: Any?) {
        var destination = segue.destination

        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController!
        }
        
        if let gvc = destination as? GraphViewController{
            if let identifier = segue.identifier{
                switch identifier{
                case Constants.graphViewSegue :
                    gvc.programToGraph = brain.getCurrentProgram() ?? ""
                    gvc.programToLoad = brain.program 
                default:
                    break
                }
            }
        }
   }
    
    //MARK: private API
    //    **************************************
    //    private API
    //    **************************************

    fileprivate func stackOperand(){
        userIsInTheMiddleOfTyping = false
        brain.pushOperand(displayValue)
    }
    
    fileprivate func evaluateAndDisplayResult() {
        let (tmpValue, errMsg) = brain.evaluate()
        if errMsg != nil {
            messageLine.text = errMsg
        }
        else {
            displayValue = tmpValue
        }
        historyLabel.text = brain.description ?? " "
        
    }
    

}

