//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Bernhard Kraft on 19.04.15.
//  Copyright (c) 2015 bfk engineering. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    //declarations
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
    }
    
    private var operandStack = [Op]()
    
    private var knownOps = [String: Op]()
    private var knownConstants = [String: Op]()
    
    
    //initializer
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
        
    }
    
    //*****
    //API
    //*****
    var variableValues = [String: Double]()
    
    var description: String? {
        get {
            var (result, remainder) = describeStack(operandStack)
            var resultString = result ?? ""
            println("result is \(resultString)")
            while !remainder.isEmpty {
                var (result, remainder2) = describeStack(remainder)
                if result != nil {
                    resultString.splice("\(result!),", atIndex: resultString.startIndex)
                    remainder = remainder2
                    println("result is \(resultString)")

                }
            }
            return "\(resultString)="
        }
    }
    
    func pushOperand(operand:Double?){
        if let tmpOperand = operand{
            operandStack.append(Op.Operand (operand!))
        }
//        println("CalculatorBrain:pushOperand: pushed \(operand)")

    }
    
    func pushOperand(operand: String) ->Double?{
        if let constant = knownConstants[operand]{
            operandStack.append(constant)
        }
        else{
            operandStack.append(Op.Variable(operand))
        }
        return evaluate()
    }
    
    func pushOperation(symbol: String){
        if let operation = knownOps[symbol]{
            operandStack.append(operation)
            println("CalculatorBrain:pushOperation: pushed \(symbol)")
        }
    }
    
    func evaluate() -> Double?{
        let (result, remainder) = evaluate(operandStack)
        println("\(operandStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clear(){
        operandStack.removeAll(keepCapacity: false)
        variableValues.removeAll(keepCapacity: false)
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
    

    //
    //internal stuff
    private func evaluate (ops:[Op]) ->(result: Double?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
//                    println("CalculatorBrain:evaluate: pulled operand \(operand)")
                    return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
//                println("CalculatorBrain:evaluate: pulled unary ops \(operation)")
                let operandEvaluation = evaluate(remainingOps)
                if operandEvaluation.result != nil{
                    return (operation(operandEvaluation.result!), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
//                println("CalculatorBrain:evaluate: pulled binary ops \(operation)")
                let operandEvaluation1 = evaluate(remainingOps)
                if let operand1 = operandEvaluation1.result{
                    let operandEvaluation2 = evaluate(operandEvaluation1.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        return (operation(operand1, operand2), operandEvaluation2.remainingOps)
                    }
                }
            case .Variable(let variable):
                if let variableValue = variableValues[variable]{
                    return (variableValue, remainingOps)
                }
                else{
                    return (nil, remainingOps)
                }
            case .Constant(_, let constValue):
                return (constValue, remainingOps)
                
            }
            
        }
        return (nil, ops)
    }
    
    //returns a textual expression of the stack content
    private func describeStack(ops:[Op]) -> (result:String?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand( let operand):
                let operandString = NSNumberFormatter().stringFromNumber(operand)
                return (operandString, remainingOps)
            
            case .UnaryOperation (let operation, _):
                let operandEvaluation = describeStack(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(operation)(\(operand))", operandEvaluation.remainingOps)
                }
                else{
                    return ("\(operation)(?)", operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(let operation, _):
                let operandEvaluation2 = describeStack(remainingOps)
                if let operand2 = operandEvaluation2.result {
                    let operandEvaluation1 = describeStack(operandEvaluation2.remainingOps)
                    if let operand1 = operandEvaluation1.result {
                        return ("\(operand1)\(operation)\(operand2)", operandEvaluation1.remainingOps)
                    }
                    else {
                        return ("?\(operation)\(operand2)", operandEvaluation1.remainingOps)
                    }
                }
                else {
                    return ("?\(operation)?", operandEvaluation2.remainingOps)
                    
                }

            case .Constant(let symbol, _):
                return (symbol, remainingOps)
                
            case .Variable(let symbol):
                return (symbol, remainingOps)
                
            }
            
            
        }
        return (nil, ops)
    }
    

    
}