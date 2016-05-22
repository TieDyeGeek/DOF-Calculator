//
//  FirstViewController.swift
//  DOF Calculator
//
//  Created by Cameron Anderson on 5/17/16.
//  Copyright © 2016 Cameron Anderson. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
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
    
    //define picker view data sources
    var lensData = [String]()
    let fstopData = ["f/1.8","f/2.0","f/3.5"]
    var distanceData = [Int]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //TODO
        //setup distance label to show unit
        let settings = SecondViewController()
        let unit = settings.getUnit()
        distanceLabel.text = "Distance (\(unit))"
        
        
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
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    //return number of componetnts (columns) in picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //return number of rows in each picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        calculate()
    }
    
    
    func calculate(){
        let settings = SecondViewController()
        let unit = settings.getUnit()
        let focus = distanceData[lensFstopDistancePickerView.selectedRowInComponent(2)]
        let lens = Double(lensData[lensFstopDistancePickerView.selectedRowInComponent(0)].componentsSeparatedByString(" ").first!)
        
        
        //get mm values
        let focusMM = convertToMM(focus, unit: unit)
        let hfocalMM = (pow(lens!,2.0) / (getFNumber() * (settings.getCameraFormat("Diagonal")/1500))) + focusMM
        let nearFocusMM = calculateNearFocus(focusMM, hfocal: hfocalMM, lens: lens!)
        let farFocusMM = calculateFarFocus(focusMM, hfocal: hfocalMM, lens: lens!)
        let nearHFocalMM = calculateNearFocus(hfocalMM, hfocal: hfocalMM, lens: lens!)
        let farHFocalMM = calculateFarFocus(hfocalMM, hfocal: hfocalMM, lens: lens!)
        let widthAtFocusMM = 2 * focusMM * (settings.getCameraFormat("Width") / (2 * lens!))
    
        
        //get unit values
        let nearFocus = round(convertToUnit(nearFocusMM, unit: unit)*100)/100
        let farFocus = round(convertToUnit(farFocusMM, unit: unit)*100)/100
        let nearHFocal = round(convertToUnit(nearHFocalMM, unit: unit)*100)/100
        let hFocal = round(convertToUnit(hfocalMM, unit: unit)*100)/100
        let farHFocal = round(convertToUnit(farHFocalMM, unit: unit)*100)/100
        let dof = round((farFocus - nearFocus)*100)/100
        let widthAtFocus = round(convertToUnit(widthAtFocusMM, unit: unit)*100)/100
        
        
        nearFocusLabel.text = "\(nearFocus) \(unit)"
        focusLabel.text = "\(focus) \(unit)"
        farFocusLabel.text = "\(farFocus) \(unit)"
        nearHFocalLabel.text = "\(nearHFocal) \(unit)"
        hFocalLabel.text = "\(hFocal) \(unit)"
        farHFocalLabel.text = "\(farHFocal) \(unit)"
        totalDOFLabel.text = "\(dof) \(unit)"
        focalWidthLabel.text = "\(widthAtFocus) \(unit)"
    }
    
    func calculateNearFocus(focus: Double, hfocal: Double, lens: Double) -> Double {
        return (focus * (hfocal - lens) / (hfocal + focus - 2 * lens))
    }
    
    func calculateFarFocus(focus: Double, hfocal: Double, lens: Double) -> Double {
        return (focus * (hfocal - lens) / (hfocal - focus))
    }
    
    //TODO
    func getFNumber() -> Double {
        let i: Double = 1 //f/1.4
        
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
        return convertToMM(Double(value), unit: unit)
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
        return convertToMM(Double(value), unit: unit)
    }

    
}