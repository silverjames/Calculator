//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Bernhard Kraft on 19.04.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CalculatorBrain {
    //MARK: properties
    //*******************
    //structure and enums
    //*******************

    struct Precedences {
        let high = 5
        let medium = 3
        let low = 1
    }
    struct Messages {
        let argMissing = "error: missing argument"
        let negOperand = "error: illegal negative operand"
        let operandZero = "error: division by zero"
    }

    fileprivate enum Op:CustomStringConvertible {
        case operand(Double)
        case unaryOperation(String, (Double)->Double)
        case binaryOperation(String, (Double, Double)->Double)
        case variable(String)
        case constant(String, Double)
        
        var description: String {
            get {
                switch self{
                case .operand(let operand):
                        return "\(operand)"
                case .unaryOperation(let symbol, _):
                        return symbol
                case .binaryOperation(let symbol, _):
                        return symbol
                case .variable(let symbol):
                    return symbol
                case .constant(let symbol, _):
                    return symbol
                }
            }
        }

        var precedence: Int {
            get {
                let precedence = Precedences()
                switch self{
                    case .binaryOperation(let operation, _):
                        switch operation{
                            case "+", "−":
                                return precedence.low
                            case "×", "÷":
                                return precedence.medium
                            default:
                                return precedence.medium
                        }//end switch operation
                    
                    default:
                        return precedence.high
               }//end switch self
            }//end get
        }//end var
        
        var errorCheck: ((Double) -> String?)? {
            
            get {
                let errorMessages = Messages()
                func checkForNegativeValue (_ arg: Double) -> String? {
                    if arg < 0 {return errorMessages.negOperand}
                    return nil
                }
                
                func checkForZeroValue (_ arg: Double) -> String? {
                    if arg == 0 {return errorMessages.operandZero}
                    return nil
                }

                switch self{
                case .unaryOperation(let operation, _):
                    switch operation{
                        case "√":
                            let checkFunction: (Double) -> String? = checkForNegativeValue
                            return checkFunction
                        default:
                            return nil
                    }
                    
                case .binaryOperation(let operation, _):
                    switch operation {
                        case "÷":
                            let checkFunction: (Double) -> String? = checkForZeroValue
                            return checkFunction
                        default:
                            return nil
                    }
                default:
                    return nil
                    
                }//switch
            }//end get
        }//end var
    }

    //*******************
    //properties
    //*******************
    
    var variableValues = [String: Double]()

    fileprivate let errorMessages = Messages()
    fileprivate let precedences = Precedences()
    fileprivate let stringSeparator:String = ";"
    fileprivate var operandStack = [Op]()
    fileprivate var knownOps = [String: Op]()
    fileprivate var knownConstants = [String: Op]()
    fileprivate var formatter = NumberFormatter()
    fileprivate var localeEN = Locale.init(identifier: "EN-en")
    fileprivate var previousPrecedence:Int?
    fileprivate var currentPrecedence:Int?
    
    //*******************
    //computed properties
    //*******************
    var program:[String]{
        get {
            return operandStack.map {$0.description}
        }
        set {
//            valueFormatter.locale = NSLocale.currentLocale()
//            valueFormatter.numberStyle = .DecimalStyle
            
            if let newProgram = newValue as? [String] {//I am getting an array of strings, good
                var newOps = [Op]()
                formatter.locale = localeEN
                for item in newProgram{
                    if let op = knownOps[item]{
                        newOps.append(op)
                    }
                    else {
                        if let operand = formatter.number(from: item)?.doubleValue{
                            newOps.append(.operand(operand))
                        }
                        else {//assume a variable
                            newOps.append(.variable(item))
                        }
                    }
                    
                }//iterate through newValue
//                println("CB:program setter - newOps: \(newOps)")
                operandStack = newOps
            }//valid input
        }//set
    }
    
    var description: String? {
        get {
            var (result, remainder, _) = describeStack(operandStack)
            var resultString = result ?? ""
            //            println("result is \(resultString)")
            while !remainder.isEmpty {
                var (result, remainder2, _) = describeStack(remainder)
                if result != nil {
                    result?.insert(";", at: (result?.endIndex)!)
                    resultString.insert(contentsOf: result!.characters , at: resultString.startIndex)
                    remainder = remainder2
                }
            }
            return "\(resultString)"
        }
    }
    
    
    //*******************
    //initializer
    //*******************
    init() {
        
        func learnOps (_ op:Op){
            knownOps[op.description] = op
        }
        func learnConst (_ op:Op){
            knownConstants[op.description] = op
        }
        learnOps(.binaryOperation("×", {$0 * $1}))
        learnOps(.binaryOperation("÷", {$1 / $0}))
        learnOps(.binaryOperation("+", {$0 + $1}))
        learnOps(.binaryOperation("−", {$1 - $0}))
        learnOps(.unaryOperation("√", {sqrt($0)}))
        learnOps(.unaryOperation("sin", {sin($0)}))
        learnOps(.unaryOperation("cos", {cos($0)}))
        
        learnConst(.constant("π", 3.141592653589793))

//        formatter.locale = NSLocale.currentLocale()
//        valueFormatter.numberStyle = .DecimalStyle
//        valueFormatter.generatesDecimalNumbers = true
        
        
    }
    //MARK: API
    //*******************
    //API
    //*******************

    //pushes a number onto the the stack
    func pushOperand(_ operand:Double?){
        if let _ = operand{
            operandStack.append(Op.operand (operand!))
        }
//        println("CalculatorBrain:pushOperand: pushed \(operand)")

    }
    
    //pushes a constant or variable onto the the stack
    func pushOperand(_ operand: String) -> (Double?, String?){
        if let constant = knownConstants[operand]{
            operandStack.append(constant)
        }
        else{
            operandStack.append(Op.variable(operand))
        }
        return evaluate()
    }
    
    //pushes an operation onto the stack
    func pushOperation(_ symbol: String){
        if let operation = knownOps[symbol]{
            operandStack.append(operation)
            print("CalculatorBrain:pushOperation: pushed \(symbol)")
        }
    }
    
    //the heart of it - run the program on the stack
    func evaluate() -> (Double?, String?) {
        let (result, remainder, errMsg) = evaluate(operandStack)
//        let msg = errMsg ?? ""
        print("CB:\(operandStack) = \(result) with \(remainder) and message: \(errMsg) left over")
        return (result, errMsg)
    }
    
    //clears the program stack and all variable values
    func clear(){
        operandStack.removeAll(keepingCapacity: false)
        variableValues.removeAll(keepingCapacity: false)
    }
    
    func undo(){
        operandStack.removeLast()
    }
    
    func getConstantValue (_ symbol: String) -> Double?{
        if let op = knownConstants[symbol]{
            switch op{
            case .constant(_, let returnValue):
                return returnValue
            
            default:
                break
            }
        }
        return nil
    }
    
    func getCurrentProgram () -> String? {
//        println("CB:description:\(self.description)")
        let (result, _, _) = describeStack(operandStack)
        let resultString = result ?? ""
        print("CB:getCurrentProgram: \(resultString)")
        return "\(resultString)"
        }

    //MARK: internal functions
    //*******************
    //internal functions
    //*******************

    fileprivate func evaluate (_ ops:[Op]) ->(result: Double?, remainingOps:[Op], evalMessage: String?){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            print ("processing op: \(op)")
            switch op {
            case .operand(let operand):
                    print("this is an operand...")
                    return (operand, remainingOps, nil)
            case .unaryOperation(_, let operation):
                print("this is an unary ops...")
                let operandEvaluation = evaluate(remainingOps)
                if operandEvaluation.result != nil{
                    if let msg = op.errorCheck?(operandEvaluation.result!){
                        return (operation(operandEvaluation.result!), operandEvaluation.remainingOps, msg)
                    }
                    else {
                        return (operation(operandEvaluation.result!), operandEvaluation.remainingOps, nil)
                    }
                }
                else {
                    return (nil, remainingOps, errorMessages.argMissing)
                }
            case .binaryOperation(_, let operation):
                print("this is a binary ops...")
                let operandEvaluation1 = evaluate(remainingOps)
                if let operand1 = operandEvaluation1.result{
                    if let msg = op.errorCheck?(operandEvaluation1.result!){
                        return (nil, operandEvaluation1.remainingOps, msg)
                    }
                    else {
                        let operandEvaluation2 = evaluate(operandEvaluation1.remainingOps)
                        if let operand2 = operandEvaluation2.result {
                            return (operation(operand1, operand2), operandEvaluation2.remainingOps, nil)
                        }
                        else {
                            return (nil, remainingOps, errorMessages.argMissing)
                        }
                    }
                }
                else {
                    return (nil, remainingOps, errorMessages.argMissing)
                }

            case .variable(let variable):
                print("this is a variable...")
                if let variableValue = variableValues[variable]{
                    return (variableValue, remainingOps, nil)
                }
                else{
                    return (nil, remainingOps, nil)
                }
            case .constant(_, let constValue):
                print("this is a    constant...")
                return (constValue, remainingOps, nil)
                
            }
            
        }
        return (nil, ops, nil)
    }
    
    //returns a textual expression of the stack content
    fileprivate func describeStack(_ ops:[Op]) -> (result:String?, remainingOps:[Op], precedence:Int?){
//        valueFormatter.locale = locale
        
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
            case .operand( let operand):
                let operandString = formatter.string(from: NSNumber(value:operand))
                return (operandString, remainingOps, op.precedence)
            
            case .unaryOperation (let operation, _):
                let operandEvaluation = describeStack(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(operation)(\(operand))", operandEvaluation.remainingOps, op.precedence)
                }
                else{
                    return ("\(operation)(?)", operandEvaluation.remainingOps, op.precedence)
                }
                
            case .binaryOperation(let operation, _):
                previousPrecedence = currentPrecedence
                currentPrecedence = op.precedence
//                println("begin case:previous precedence: \(previousPrecedence), current precedence: \(currentPrecedence)")

                let operandEvaluation1 = describeStack(remainingOps)
//                println("operand 1:previous precedence: \(previousPrecedence), current precedence: \(currentPrecedence)")
                if let operand1 = operandEvaluation1.result {
                    let operandEvaluation2 = describeStack(operandEvaluation1.remainingOps)
                    
                    if let operand2 = operandEvaluation2.result {
//                        println("operand 2:previous precedence: \(previousPrecedence), current precedence: \(currentPrecedence)")
 
                        if currentPrecedence < previousPrecedence {
                            currentPrecedence = nil
                            previousPrecedence = nil
                            return ("(\(operand2)\(operation)\(operand1))", operandEvaluation2.remainingOps, operandEvaluation2.precedence)
                        }
                        else {
                              return ("\(operand2)\(operation)\(operand1)", operandEvaluation2.remainingOps, operandEvaluation2.precedence)
                        }
                    }
                    else {
                        return ("?\(operation)\(operand1)", operandEvaluation2.remainingOps, operandEvaluation2.precedence)
                    }
                }
                else {
                    return ("?\(operation)?", operandEvaluation1.remainingOps, operandEvaluation1.precedence)
                    
                }

            case .constant(let symbol, _):
                return (symbol, remainingOps, op.precedence)
                
            case .variable(let symbol):
                return (symbol, remainingOps, op.precedence)
                
            }
            
            
        }
        return (nil, ops, Int.max)
    }
    
}
