//
//  SecondViewController.swift
//  DOF Calculator
//
//  Created by Cameron Anderson on 5/17/16.
//  Copyright © 2016 Cameron Anderson. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //define UI elements
    @IBOutlet weak var cameraMakeModelPicker: UIPickerView!
    @IBOutlet weak var unitsPicker: UIPickerView!
    @IBOutlet weak var cropFactorField: UITextField!
    
    //define picker view data sources
    var cameraMakeData = [String]()
    var cameraModelData = [String]()
    var unitsData: [String]! = ["cm","in","ft","yd","m"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        //setup cameraMakeData
        
        
        //setup cameraModelData
        
        
        
        //set delegates and data sources for picker
        cameraMakeModelPicker.delegate = self
        cameraMakeModelPicker.dataSource = self
        unitsPicker.delegate = self
        unitsPicker.dataSource = self
        
        //set tag numbers for pickers
        cameraMakeModelPicker.tag = 0
        unitsPicker.tag = 1

        
        //TODO
        //set default value for pickers
        unitsPicker.selectRow(2, inComponent: 0, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    //return number of componetnts (columns) in picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 2
        } else if pickerView.tag == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    //return number of rows in each picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            if component == 0 {
                return cameraMakeData.count
            } else if component == 1 {
                return cameraModelData.count
            } else {
                return 0
            }
        } else if pickerView.tag == 1 {
            return unitsData.count
        } else {
            return 0
        }
    }
    
    //return value of reach row in picker
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            if component == 0 {
                return cameraMakeData[row]
            } else if component == 1 {
                return cameraModelData[row]
            }
        } else if pickerView.tag == 1 {
            return unitsData[row]
        }
        return "picker tag or component error"
    }
    
    //when pickerView selection changes, call calculateValue to update
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        calculateCropFactor()
    }
        
        
        
    func calculateCropFactor(){
        
    }
    
    //TODO
    //return units used
    func getUnit() -> String {
        
//        if let unit = unitsData[unitsPicker.selectedRowInComponent(0)!]{
//            return unit
//        } else {
            return unitsData[2]
//        }
    }
    
    //TODO
    //return camera format
    func getCameraFormat(dimension: String) -> Double {
        if dimension == "Diagonal" {
            return 43.3  //diagonal of 35mm
        } else if dimension == "Width" {
            return 36   //width of 35mm
        } else {
            return 36   //width of 35mm
        }
    }
        

}

