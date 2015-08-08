//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Bernhard Kraft on 19.04.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
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

    private enum Op:Printable {
        case Operand(Double)
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double, Double)->Double)
        case Variable(String)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                        return "\(operand)"
                case .UnaryOperation(let symbol, _):
                        return symbol
                case .BinaryOperation(let symbol, _):
                        return symbol
                case .Variable(let symbol):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }

        var precedence: Int {
            get {
                let precedence = Precedences()
                switch self{
                    case .BinaryOperation(let operation, _):
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
                func checkForNegativeValue (arg: Double) -> String? {
                    if arg < 0 {return errorMessages.negOperand}
                    return nil
                }
                
                func checkForZeroValue (arg: Double) -> String? {
                    if arg == 0 {return errorMessages.operandZero}
                    return nil
                }

                switch self{
                case .UnaryOperation(let operation, _):
                    switch operation{
                        case "√":
                            var checkFunction: (Double) -> String? = checkForNegativeValue
                            return checkFunction
                        default:
                            return nil
                    }
                    
                case .BinaryOperation(let operation, _):
                    switch operation {
                        case "÷":
                            var checkFunction: (Double) -> String? = checkForZeroValue
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

    private let errorMessages = Messages()
    private let precedences = Precedences()
    private let stringSeparator:String = ";"
    private var operandStack = [Op]()
    private var knownOps = [String: Op]()
    private var knownConstants = [String: Op]()
    private var valueFormatter = NSNumberFormatter()
    private var previousPrecedence:Int?
    private var currentPrecedence:Int?
    
    //*******************
    //computed properties
    //*******************
    var program:AnyObject{
        get {
            return operandStack.map {$0.description}
        }
        set {
            if let newProgram = newValue as? [String] {//I am getting an array of strings, good
                var newOps = [Op]()
                for item in newProgram{
                    if let op = knownOps[item]{
                        newOps.append(op)
                    }
                    else {
                        if let operand = NSNumberFormatter().numberFromString(item)?.doubleValue{
                            newOps.append(.Operand(operand))
                        }
                        else {//assume a variable
                            newOps.append(.Variable(item))
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
                    resultString.splice("\(result!)\(stringSeparator)", atIndex: resultString.startIndex)
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
        
        func learnOps (op:Op){
            knownOps[op.description] = op
        }
        func learnConst (op:Op){
            knownConstants[op.description] = op
        }
        learnOps(.BinaryOperation("×", {$0 * $1}))
        learnOps(.BinaryOperation("÷", {$1 / $0}))
        learnOps(.BinaryOperation("+", {$0 + $1}))
        learnOps(.BinaryOperation("−", {$1 - $0}))
        learnOps(.UnaryOperation("√", {sqrt($0)}))
        learnOps(.UnaryOperation("sin", {sin($0)}))
        learnOps(.UnaryOperation("cos", {cos($0)}))
        
        learnConst(.Constant("π", 3.141592653589793))

        valueFormatter.locale = NSLocale.currentLocale()
        valueFormatter.numberStyle = .DecimalStyle
        valueFormatter.generatesDecimalNumbers = true
        
        
    }
    
    //*******************
    //API
    //*******************

    //pushes a number onto the the stack
    func pushOperand(operand:Double?){
        if let tmpOperand = operand{
            operandStack.append(Op.Operand (operand!))
        }
//        println("CalculatorBrain:pushOperand: pushed \(operand)")

    }
    
    //pushes a constant or variable onto the the stack
    func pushOperand(operand: String) -> (Double?, String?){
        if let constant = knownConstants[operand]{
            operandStack.append(constant)
        }
        else{
            operandStack.append(Op.Variable(operand))
        }
        return evaluate()
    }
    
    //pushes an operation onto the stack
    func pushOperation(symbol: String){
        if let operation = knownOps[symbol]{
            operandStack.append(operation)
            println("CalculatorBrain:pushOperation: pushed \(symbol)")
        }
    }
    
    //the heart of it - run the program on the stack
    func evaluate() -> (Double?, String?) {
        let (result, remainder, errMsg) = evaluate(operandStack)
        let msg = errMsg ?? ""
//        println("\(operandStack) = \(result) with \(remainder) and message: \(msg) left over")
        return (result, errMsg)
    }
    
    //clears the program stack and all variable values
    func clear(){
        operandStack.removeAll(keepCapacity: false)
        variableValues.removeAll(keepCapacity: false)
    }
    
    func undo(){
        operandStack.removeLast()
    }
    
    func getConstantValue (symbol: String) -> Double?{
        if let op = knownConstants[symbol]{
            switch op{
            case .Constant(_, let returnValue):
                return returnValue
            
            default:
                break
            }
        }
        return nil
    }
    
    func getCurrentProgram () -> String? {
//        println("CB:description:\(self.description)")
        var (result, remainder, _) = describeStack(operandStack)
        var resultString = result ?? ""
        println("CB:getCurrentProgram: \(resultString)")
        return "\(resultString)"
        }


    //*******************
    //internal functions
    //*******************
    private func evaluate (ops:[Op]) ->(result: Double?, remainingOps:[Op], evalMessage: String?){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                    return (operand, remainingOps, nil)
            case .UnaryOperation(_, let operation):
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
            case .BinaryOperation(_, let operation):
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

            case .Variable(let variable):
                if let variableValue = variableValues[variable]{
                    return (variableValue, remainingOps, nil)
                }
                else{
                    return (nil, remainingOps, nil)
                }
            case .Constant(_, let constValue):
                return (constValue, remainingOps, nil)
                
            }
            
        }
        return (nil, ops, nil)
    }
    
    //returns a textual expression of the stack content
    private func describeStack(ops:[Op]) -> (result:String?, remainingOps:[Op], precedence:Int?){
        
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
            case .Operand( let operand):
                var operandString = valueFormatter.stringFromNumber(operand)
                return (operandString, remainingOps, op.precedence)
            
            case .UnaryOperation (let operation, _):
                let operandEvaluation = describeStack(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(operation)(\(operand))", operandEvaluation.remainingOps, op.precedence)
                }
                else{
                    return ("\(operation)(?)", operandEvaluation.remainingOps, op.precedence)
                }
                
            case .BinaryOperation(let operation, _):
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

            case .Constant(let symbol, _):
                return (symbol, remainingOps, op.precedence)
                
            case .Variable(let symbol):
                return (symbol, remainingOps, op.precedence)
                
            }
            
            
        }
        return (nil, ops, Int.max)
    }
    

    
}