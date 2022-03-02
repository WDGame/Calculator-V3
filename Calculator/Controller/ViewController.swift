//
//  ViewController.swift
//  Calculator
//
//  Created by user213353 on 2/9/22.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - OutletLable
    @IBOutlet weak var preResultLabelNorm: UILabel!
    @IBOutlet weak var resultLableNormal: UILabel!
    @IBOutlet weak var memoryLableNormal: UILabel!
    @IBOutlet weak var preResultLableLandscape: UILabel!
    @IBOutlet weak var resultLableLandscape: UILabel!
    @IBOutlet weak var memoryLableLandscape: UILabel!
    
    //MARK: - OutletButton
    @IBOutlet weak var clearLandscapeButton: UIButton!
    @IBOutlet weak var clearNormalButton: UIButton!
    @IBOutlet weak var DegButtonOutlet: UIButton!
    @IBOutlet weak var RadButtonOutled: UIButton!
    
    //MARK: - Variable
    var inMiddle : Bool = false
    var mathSignEnterBefore : Bool = false
    var useParenthesis : Bool = false
    var useDeg : Bool = true
    var countBracket : Int = 0
    var calculator = CalculatorModel()
    var tableViewContr = TableViewController()
    
    var resultDisplayValue : Double{
        get {
            return Double(resultLableNormal.text ?? "0") ?? 0.0
        }
        set{
            resultLableNormal.text = calculator.FormatResult(res: newValue)
            resultLableLandscape.text = calculator.FormatResult(res: newValue)
        }
    }
    
    var preResultDisplayValue : String{
        get{
            return preResultLabelNorm.text ?? ""
        }
        set{
            preResultLabelNorm.text = (preResultLabelNorm.text ?? "") + newValue
            preResultLableLandscape.text = (preResultLableLandscape.text ?? "") + newValue
        }
    }
    
    enum display{
        case resultDisplay
        case preResultDisplay
        case resultAndPreResultDisplay
        case memoryDisplay
    }
    
    //MARK: - SystemSettings
    override func viewDidLoad() {
        super.viewDidLoad()
        DegButtonOutlet.backgroundColor = .systemGray
        
        LoadSave()        
    }
    
    //MARK: - Action Digital
    @IBAction func digitButtons(_ sender: UIButton) {
        
        //Proverka na nazhatiy znak
        if(inMiddle == true){
            resultLableNormal.text = (resultLableNormal.text ?? "") + sender.currentTitle!
            resultLableLandscape.text = (resultLableLandscape.text ?? "") + sender.currentTitle!
        }
        else{
            resultLableNormal.text = sender.currentTitle!
            resultLableLandscape.text = sender.currentTitle!
            InTheMiddle(flag: true)
        }
    }
    
    //MARK: - Action Sign
    @IBAction func calculationButton(_ sender: UIButton) {
        
        if inMiddle {
            calculator.setNumber(Number: resultDisplayValue, fDeg: useDeg)            
        }
        
        if let mathSymbol = sender.currentTitle{
            calculator.performOperation(symbol: mathSymbol, flagNewSign: inMiddle)
            PreResultFormat(digit: resultDisplayValue, sign: mathSymbol)
            //resultDisplayValue = calculator.result
            
            
            if mathSignEnterBefore{
                resultDisplayValue = calculator.result
                PreResultFormat(digit: resultDisplayValue, sign: mathSymbol)
            }
            else{
                PreResultFormat(digit: resultDisplayValue, sign: mathSymbol)
                resultDisplayValue = calculator.result
                mathSignEnterBefore = true
            }
            InTheMiddle(flag: false)
        }
        
    }
    
    @IBAction func SwithRadDeg(_ sender: UIButton) {
        switch sender.currentTitle{
        case "Rad":
            useDeg = false
            RadButtonOutled.backgroundColor = .systemGray
            DegButtonOutlet.backgroundColor = .darkGray
        case "Deg":
            useDeg = true
            RadButtonOutled.backgroundColor = .darkGray
            DegButtonOutlet.backgroundColor = .systemGray
        default : break
        }
    }
    
    @IBAction func randomButton(_ sender: UIButton) {
        resultDisplayValue = Double.random(in: 0.1...1)
        InTheMiddle(flag: true)
    }
    
    
    @IBAction func memoryButtons(_ sender: UIButton) {
        Memory(sender: sender.currentTitle ?? "")
    }
    
    @IBAction func parenthesisButton(_ sender: UIButton) {
        if let title = sender.currentTitle {
            if(title == "("){
                countBracket += 1
                preResultDisplayValue = title
                calculator.performOperation(symbol: title, flagNewSign: true)
            }
            else{
                if countBracket > 0{
                    countBracket -= 1
                    if(inMiddle){
                        calculator.setNumber(Number: resultDisplayValue, fDeg: useDeg)
                        PreResultFormat(digit: resultDisplayValue, sign: title)
                        InTheMiddle(flag: false)
                        calculator.performOperation(symbol: title, flagNewSign: true)
                        return
                    }
                    calculator.performOperation(symbol: title, flagNewSign: true)
                    resultDisplayValue = calculator.result
                }
            }
            
        }
    }
    
    
    @IBAction func clearDisplay(_ sender: UIButton) {
        if sender.currentTitle == "C"{
            ClearDisplay(display: .resultAndPreResultDisplay)
            countBracket = 0
            calculator.calcSave.set(0, forKey: "Result")
            
        }else{
            ClearDisplay(display: .resultDisplay)
        }
    }
    
    @IBAction func decimalSeparator(_ sender: UIButton) {
        DecimalSeparator()
    }
    
    //MARK: - Function Segue in History
    @IBAction func inHistory(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showTVC", sender: calculator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTVC"{
            if let vc = segue.destination as? TableViewController {
                let calc = sender as? CalculatorModel
                vc.calculator = calc
            }
        }
    }
    
    //MARK: - Function
    func LoadSave(){
        if let result = calculator.calcSave.object(forKey: "Result"){
            resultDisplayValue = result as? Double ?? 0.0
        }
        if let arrayOp = calculator.calcSave.object(forKey: "ArrayOperations"){
            calculator.arrayOperations = arrayOp as? [String] ?? [String]()
            calculator.arrayOperations.append("\(calculator.arrayOperations.endIndex + 1)) ")
        }
    }
    
    func Memory(sender : String){
        switch sender{
        case "mc":
            calculator.ClearMemory()
            MemoryDisplayFormat(txt: "")
        case "mr":
            resultDisplayValue = calculator.resultMemory
        case "m-":
            calculator.resultMemory -= resultDisplayValue
            MemoryDisplayFormat(txt: "Memory(\( calculator.FormatResult(res: calculator.resultMemory) ))")
        case "m+":
            calculator.resultMemory += resultDisplayValue
            MemoryDisplayFormat(txt: "Memory(\( calculator.FormatResult(res: calculator.resultMemory) ))")
        default : break
        }
    }
    
    func ClearDisplay(display: display){
        
        switch display {
        case .resultDisplay:
            resultLableNormal.text = ""
            resultLableLandscape.text = ""
            InTheMiddle(flag: false)
            
        case .preResultDisplay:
            preResultLabelNorm.text = ""
            preResultLableLandscape.text = ""
            
        case .resultAndPreResultDisplay:
            resultLableNormal.text = ""
            resultLableLandscape.text = ""
            preResultLabelNorm.text = ""
            preResultLableLandscape.text = ""
            InTheMiddle(flag: false)
            mathSignEnterBefore = false
            calculator.ClearModel()
            
        case .memoryDisplay:
            memoryLableNormal.text = ""
            memoryLableLandscape.text = ""
        }
        
    }
    
    func PreResultFormat(digit: Double, sign: String){
        let res = calculator.FormatResult(res: resultDisplayValue)
        
        ClearDisplay(display: .preResultDisplay)
        switch sign{
        case "+/-","%","e","pi" : break
        case "sin", "cos", "tan" :
            preResultDisplayValue = "\(sign)(\(res))"
        case "x^2":
            preResultDisplayValue = "\(res)^2"
        case "x^3":
            preResultDisplayValue = "\(res)^3"
        case "x^y":
            preResultDisplayValue = "\(res)^"
        case "x!":
            preResultDisplayValue = "\(res)!"
        case "√x":
            preResultDisplayValue = "√\(res)"
        case "+":
            preResultDisplayValue = "\(res)+"
        case "-":
            preResultDisplayValue = "\(res)-"
        case "x":
            preResultDisplayValue = "\(res)x"
        case "/":
            preResultDisplayValue = "\(res)/"
        case "=":
            mathSignEnterBefore = false
        default : break
        }
    }
    
    func MemoryDisplayFormat(txt : String){
        memoryLableNormal.text = txt
        memoryLableLandscape.text = txt
    }
    
    func DecimalSeparator(){
        if let res = resultLableNormal.text{
            if(Int(res) == nil){
                resultLableNormal.text = "0."
                resultLableLandscape.text = "0."
                InTheMiddle(flag: true)
                return
            }else{
                resultLableNormal.text = "\(calculator.FormatResult(res: resultDisplayValue))."
                resultLableLandscape.text = "\(calculator.FormatResult(res: resultDisplayValue))."
            }
            
        }
    }
    
    func InTheMiddle(flag: Bool){
        inMiddle = flag
        
        if flag && clearNormalButton.currentTitle != "AC"{
            clearNormalButton.setTitle("AC", for: .normal)
            clearLandscapeButton.setTitle("AC", for: .normal)
        }
        else if clearNormalButton.currentTitle != "C"{
            clearNormalButton.setTitle("C", for: .normal)
            clearLandscapeButton.setTitle("C", for: .normal)
        }
        
    }
}

