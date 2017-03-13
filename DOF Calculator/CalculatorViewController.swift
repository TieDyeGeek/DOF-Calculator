//
//  CalculatorViewController.swift
//  DOF Calculator
//
//  Created by Cameron Anderson on 5/17/16.
//  Copyright © 2017 Cameron Anderson. All rights reserved.
//

import UIKit


class CalculatorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    //define UI elements
    @IBOutlet weak var lensFstopDistancePickerView: UIPickerView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var nearFocusLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var farFocusLabel: UILabel!
    @IBOutlet weak var nearHFocalLabel: UILabel!
    @IBOutlet weak var hFocalLabel: UILabel!
    @IBOutlet weak var farHFocalLabel: UILabel!
    @IBOutlet weak var totalDOFLabel: UILabel!
    @IBOutlet weak var focalWidthLabel: UILabel!
    
    let INFINITY: Double = 16000000 //in mm
        //400000000 is 250 miles
        //80000000 is 50 miles
        //16000000 is 10 miles
    
    var pathToSettings: String!
    var settings: NSMutableDictionary!

    var unit = "ft" // setup as ft. will update below
    //var unit: String!
    
    
    //define picker view data sources
    var lensData = [String]()
    let fstopData = ["f/0.7","f/0.8","f/0.9","f/1.0","f/1.1","f/1.2","f/1.4","f/1.6","f/1.7","f/1.8","f/2","f/2.2","f/2.4","f/2.5","f/2.8","f/3.2","f/3.3","f/3.5","f/4","f/4.5","f/4.8","f/5.0","f/5.6","f/6.3","f/6.7","f/7.1","f/8","f/9","f/9.5","f/10","f/11","f/13","f/14","f/16","f/18","f/19","f/20","f/22","f/25","f/27","f/29","f/32","f/36","f/38","f/40","f/45","f/51","f/54","f/57","f/64"]
    var distanceData = [Int]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        //copy plist file
        let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "plist")
        //print(bundlePath, "\n") //prints the correct path
        let fileManager = FileManager.default
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        let fullDestPathString = fullDestPath?.path
        //print(fileManager.fileExists(atPath: bundlePath!)) // prints true
        pathToSettings = fullDestPathString

        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
        }catch{
            print("\n")
            print(error) // file already exists (most likely)
        }
        
        //read plist file
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        print("unit is "+(settings?.value(forKey: "Unit") as? String)!)
        unit = (settings?.value(forKey: "Unit") as? String)!

        //setup distance label to show unit
        distanceLabel.text = "Distance (\(unit))"
        calculate()
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //setup lensData
        for i in 1...85 {
            if (i <= 50){
                lensData.append("\(i) mm")                 //1-50 count by 1
            } else if (i <= 60){
                lensData.append("\((i-50)*5 + 50) mm")     //50-100 count by 5
            } else if (i <= 75) {
                lensData.append("\((i-60)*10 + 100) mm")   //100-250 count by 10
            } else if (i <= 80) {
                lensData.append("\((i-75)*50 + 250) mm")   //250-500 count by 50
            } else if (i <= 85) {
                lensData.append("\((i-80)*100 + 500) mm")  //500-1000 count by 100
            }

        }
        
        //setup distance data
        for i in 1...155 {
            if (i <= 100){
                distanceData.append(i)                  //1-100 count by 1
            } else if (i <= 130){
                distanceData.append((i-100)*5 + 100)    //100-250 count by 5
            } else if (i <= 155) {
                distanceData.append((i-130)*10 + 250)   //250-500 count by 10
            }
            
        }
        
        
        //set delegates and data sources for picker
        lensFstopDistancePickerView.delegate = self
        lensFstopDistancePickerView.dataSource = self
        
        //set tag numbers for pickers
        lensFstopDistancePickerView.tag = 0
        
        
        //set default for labels
        nearFocusLabel.text = "----"
        focusLabel.text = "----"
        farFocusLabel.text = "----"
        nearHFocalLabel.text = "----"
        hFocalLabel.text = "----"
        farHFocalLabel.text = "----"
        totalDOFLabel.text = "----"
        focalWidthLabel.text = "----"
        
        
        //set default values for pickers
        lensFstopDistancePickerView.selectRow(23, inComponent: 0, animated: true)
        lensFstopDistancePickerView.selectRow(17, inComponent: 1, animated: true)
        lensFstopDistancePickerView.selectRow(9, inComponent: 2, animated: true)

        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    //return number of componetnts (columns) in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //return number of rows in each picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return lensData.count
        }else if component == 1{
            return fstopData.count
        } else if component == 2{
            return distanceData.count
        } else {
            return 0
        }
    }
    
    //return value of reach row in picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return lensData[row]
        }else if component == 1{
            return fstopData[row]
        } else if component == 2{
            return "\(distanceData[row])"
        } else {
            return "component doesn't exist"
        }
    }
    
    //when pickerView selection changes, call calculateValue to update
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        calculate()
    }
    
    
    func calculate(){
        //TODO setup cameraFormat from secondViewController
        let cameraFormatDiagnal: Double = 43.3
        let cameraFormatWidth: Double = 36
        
        let focus = distanceData[lensFstopDistancePickerView.selectedRow(inComponent: 2)]
        let lens = Double(lensData[lensFstopDistancePickerView.selectedRow(inComponent: 0)].components(separatedBy: " ").first!)
        
        
        //get mm values
        let focusMM = convertToMM(value: focus, unit: unit)
        let hfocalMM = (pow(lens!,2.0) / (getFNumber() * (cameraFormatDiagnal / 1500))) + focusMM
        let nearFocusMM = calculateNearFocus(focus: focusMM, hfocal: hfocalMM, lens: lens!)
        let farFocusMM = calculateFarFocus(focus: focusMM, hfocal: hfocalMM, lens: lens!)
        let nearHFocalMM = calculateNearFocus(focus: hfocalMM, hfocal: hfocalMM, lens: lens!)
        let farHFocalMM = calculateFarFocus(focus: hfocalMM, hfocal: hfocalMM, lens: lens!)
        let widthAtFocusMM = 2 * focusMM * (cameraFormatWidth / (2 * lens!))
    
        
        //get unit values
        let nearFocus = round(convertToUnit(value: nearFocusMM, unit: unit)*100)/100
        let farFocus = round(convertToUnit(value: farFocusMM, unit: unit)*100)/100
        let nearHFocal = round(convertToUnit(value: nearHFocalMM, unit: unit)*100)/100
        let hFocal = round(convertToUnit(value: hfocalMM, unit: unit)*100)/100
        let farHFocal = round(convertToUnit(value: farHFocalMM, unit: unit)*100)/100
        let dof = round((farFocus - nearFocus)*100)/100
        let widthAtFocus = round(convertToUnit(value: widthAtFocusMM, unit: unit)*100)/100
        
        
        //update lables
        nearFocusLabel.text = "\(nearFocus) \(unit)"
        focusLabel.text = "\(focus) \(unit)"
        if farFocusMM > INFINITY {
            farFocusLabel.text = "∞"
        } else {
            farFocusLabel.text = "\(farFocus) \(unit)"
        }
        nearHFocalLabel.text = "\(nearHFocal) \(unit)"
        hFocalLabel.text = "\(hFocal) \(unit)"
        if farHFocalMM > INFINITY {
            farHFocalLabel.text = "∞"
        } else {
            farHFocalLabel.text = "\(farHFocal) \(unit)"
        }
        if (farFocusMM - nearFocusMM) > INFINITY {
            totalDOFLabel.text = "∞"
        } else {
            totalDOFLabel.text = "\(dof) \(unit)"
        }
        focalWidthLabel.text = "\(widthAtFocus) \(unit)"
      
            
    }
    
    func calculateNearFocus(focus: Double, hfocal: Double, lens: Double) -> Double {
        return (focus * (hfocal - lens) / (hfocal + focus - 2 * lens))
    }
    
    func calculateFarFocus(focus: Double, hfocal: Double, lens: Double) -> Double {
        return (focus * (hfocal - lens) / (hfocal - focus))
    }
    
    //return f number for calculations
    func getFNumber() -> Double {
        
        let fString = fstopData[lensFstopDistancePickerView.selectedRow(inComponent: 1)]
        //let fValue = Double(fString.substring(from: fString.startIndex.successor().successor())
        let fValue = Double(fString.substring(from: fString.index(fString.startIndex, offsetBy: 2)))
        
        let i = pow( pow(2.0,fValue!), 0.5)
        
        return pow(2, i/2.0)
    }
    
    
    //Double convert TO MM
    @nonobjc
    func convertToMM(value: Double, unit: String) -> Double {
        if unit == "cm" {
            return value * 10
        } else if unit == "m" {
            return value * 1000
        } else if unit == "in" {
            return value * 25.4
        } else if unit == "ft" {
            return value * 304.8
        } else if unit == "yd" {
            return value * 914.4
        } else {
            return value
        }
    }
    
    //int convert TO MM
    @nonobjc
    func convertToMM(value: Int, unit: String) -> Double {
        return convertToMM(value: Double(value), unit: unit)
    }
    
    
    //Double convert FROM MM
    @nonobjc
    func convertToUnit(value: Double, unit: String) -> Double {
        if unit == "cm" {
            return value / 10
        } else if unit == "m" {
            return value / 1000
        } else if unit == "in" {
            return value / 25.4
        } else if unit == "ft" {
            return value / 304.8
        } else if unit == "yd" {
            return value / 914.4
        } else {
            return value
        }
    }
    
    //int convert FROM MM
    @nonobjc
    func convertToUnit(value: Int, unit: String) -> Double {
        return convertToMM(value: Double(value), unit: unit)
    }

    
}
