//
//  CalculatorModel.swift
//  Calculator
//
//  Created by user213353 on 2/17/22.
//

import Foundation

class CalculatorModel{
    //MARK: - Variable
    var accum = 0.0
    var resultMemory : Double = 0.0
    var flagRepeat : Bool = false
    var flagDeg : Bool = true
    var flagNewSign : Bool = true
    let massSign = ["+":1,"-":1,"x":2,"/":2,"x^y":3,"":0, "=":0, "(":0]
    var stackDigits = [Double]()
    var stackSigns = [String]()
    var pending : pendingBinaryOperationInfo?
    var arrayOperations = [String]()
    let calcSave = UserDefaults.standard
    var Operations : Dictionary<String,oper> = [
        "e" : oper.Constant(M_E),
        "pi": oper.Constant(Double.pi),
        "√x": oper.UnaryOperation(sqrt),
        "x^2":oper.UnaryOperation({pow($0, 2)}),
        "x^3":oper.UnaryOperation({pow($0, 3)}),
        "sin":oper.UnaryOperation(sin),
        "cos":oper.UnaryOperation(cos),
        "tan":oper.UnaryOperation(tan),
        "+/-":oper.UnaryOperation({$0 * -1}),
        "%":oper.UnaryOperation({$0 / 100}),
        "1/x":oper.UnaryOperation({1 / $0}),
        "x!":oper.UnaryOperation(factorial),
        "=" : oper.Equals,
        "x" : oper.BinaryOperation({$1 * $0}),
        "/" : oper.BinaryOperation({$1 / $0}),
        "-" : oper.BinaryOperation({$1 - $0}),
        "+" : oper.BinaryOperation({$1 + $0}),
        "x^y":oper.BinaryOperation({pow($1, $0)})
    ]
    
    var result : Double{
        get {
            return stackDigits.last ?? 0
        }
    }
    
    enum oper{
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    //MARK: - Struct
    struct pendingBinaryOperationInfo{
        
        var binaryOper : (Double, Double) -> Double
        var firstNumer : Double
        
    }
    
    //MARK: - Functions
    func setNumber (Number : Double, fDeg : Bool){
        flagDeg = fDeg
        stackDigits.append(Number)
        setExample(symb: String(FormatResult(res: Number)))
    }
    
    func setExample(symb: String){
        if arrayOperations.isEmpty{
            arrayOperations.append("1) ")
        }
        
        switch symb{
        case "=":
            arrayOperations.append((arrayOperations.popLast() ?? "") + symb + String(FormatResult(res: stackDigits.last ?? 0)))
            calcSave.set((stackDigits.last ?? 0), forKey: "Result")
            calcSave.set(arrayOperations, forKey: "ArrayOperations")
            arrayOperations.append("\(arrayOperations.endIndex + 1)) ")
            return
        case "x^y":
            arrayOperations.append((arrayOperations.popLast() ?? "") + "^")
            return
        case "Clear":
            _ = arrayOperations.popLast()
            arrayOperations.append("\(arrayOperations.endIndex + 1)) ")
            return
        default:arrayOperations.append((arrayOperations.popLast() ?? "") + symb)
        }
        
    }
    
    func performOperation (symbol: String, flagNewSign: Bool){
        
        //Udalaet posledniy znak esli
        let exampl = arrayOperations.last
        if !flagNewSign && symbol != "=" && exampl?.last != ")"{
            _ = stackSigns.popLast()
            var str: String = arrayOperations.popLast() ?? " "
            str.remove(at: str.index(before: str.endIndex))
            arrayOperations.append(str)
        }
        
        repeat{
            flagRepeat = false
            
            if(symbol == "("){
                stackSigns.append(symbol)
                continue
            }
            
            if(!stackSigns.isEmpty){
                //Propuskaet tolko Binary
                switch symbol{
                case "x","/","+","-","x^y","(",")","=":
                    break
                default:
                    Calculate(symbol: symbol)
                    continue
                }
                                    
                //rabota so skobkami -----------------------
                if(stackSigns.last == "("){
                    if(symbol != ")"){
                        stackSigns.append(symbol)
                    }
                    else{
                        _ = stackSigns.removeLast()
                    }
                    continue
                }
                
                if(symbol == ")"){
                    Calculate(symbol: stackSigns.popLast() ?? "pi")
                    Calculate(symbol: "=")
                    flagRepeat = true
                    continue
                }
                //------------------------------------------
                
                //Esli operacia v stack prioritetna to
                if massSign[stackSigns.last!] ?? 0 >= massSign[symbol] ?? 0 {
                    Calculate(symbol: stackSigns.popLast() ?? "pi")
                    Calculate(symbol: "=")
                    flagRepeat = true
                }
                else{
                    stackSigns.append(symbol)
                }
               
                
            }
            else{ //Esli stack pustoy
                switch symbol{
                case "x","/","+","-","x^y","(":
                    stackSigns.append(symbol)
                case "sin","cos","tan":
                    if flagDeg {
                        UseDeg(symbol: symbol)
                    }else{
                        Calculate(symbol: symbol)
                    }
                default: Calculate(symbol: symbol)
                }
            }
             
            
        }while flagRepeat
        setExample(symb: symbol)
    }
    
    func UseDeg(symbol:String){
        switch symbol{
        case "sin": stackDigits.append(__sinpi((stackDigits.popLast() ?? 0) / 180))
        case "cos": stackDigits.append(__cospi((stackDigits.popLast() ?? 0) / 180))
        case "tan": stackDigits.append(__tanpi((stackDigits.popLast() ?? 0) / 180))
        default: break
        }
        
    }
    
    func Calculate(symbol: String){
        if let operation = Operations[symbol]{
            switch operation{
            case .Constant(let value) : stackDigits.append(value)
            case .UnaryOperation(let function) : stackDigits.append(function(stackDigits.popLast() ?? 0))
            case .BinaryOperation(let function) :
                //executeEquals()
                pending = pendingBinaryOperationInfo(binaryOper: function, firstNumer: stackDigits.popLast() ?? 0)
            case .Equals : executeEquals()
            }
        }
    }
    
    func executeEquals(){
        if pending != nil{
            if let n = stackDigits.popLast(){
                stackDigits.append(pending!.binaryOper(pending!.firstNumer,  n))
            }
            pending = nil
        }
    }
    
    func ClearModel(){
        setExample(symb: "Clear")
        pending = nil
        accum = 0.0
        stackSigns.removeAll()
        stackDigits.removeAll()
    }
    
    func ClearMemory(){
        resultMemory = 0
    }
    
    func FormatResult(res: Double) -> String{
        if(res.truncatingRemainder(dividingBy: 1) == 0){
            return String(Int(res))
        }
        else{
            return String(res)
        }
    }
}
//MARK: - Global Function
func factorial(x: Double) -> Double{
    let xInt = Int(x)
    var ansver : Double = 1
    
    for i in 1...xInt {
        ansver *= Double(i)
    }
    return ansver
}
