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
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                        return "\(operand)"
                case .UnaryOperation(let symbol, _):
                        return symbol
                case .BinaryOperation(let symbol, _):
                        return symbol
                }
            }
        }
    }
    
    private var operandStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    //initializer
    init() {
        func learnOps (op:Op){
            knownOps[op.description] = op
        }
        learnOps(.BinaryOperation("×", {$0 * $1}))
        learnOps(.BinaryOperation("÷", {$1 / $0}))
        learnOps(.BinaryOperation("+", {$0 + $1}))
        learnOps(.BinaryOperation("−", {$1 - $0}))
        learnOps(.UnaryOperation("√", {sqrt($0)}))
        learnOps(.UnaryOperation("sin", {sin($0)}))
        learnOps(.UnaryOperation("cos", {cos($0)}))
    }
    
    //API
    func pushOperand(operand:Double){
        operandStack.append(Op.Operand (operand))
//        println("CalculatorBrain:pushOperand: pushed \(operand)")

    }
    
    func pushOperation(symbol: String){
        if let operation = knownOps[symbol]{
            operandStack.append(operation)
//            println("CalculatorBrain:pushOperation: pushed \(symbol)")
        }
    }
    
    func evaluate() -> Double?{
        let (result, remainder) = evaluate(operandStack)
        println("\(operandStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clear(){
        operandStack.removeAll(keepCapacity: false)
    }
    
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
                
            }
            
        }
        return (nil, ops)
    }
    

    
}