//
//  SettingsViewController.swift
//  DOF Calculator
//
//  Created by Cameron Anderson on 5/17/16.
//  Copyright © 2017 Cameron Anderson. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var firstOpen: Bool?
    var unit: String!
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    
    //define UI elements
    @IBOutlet weak var cameraMakeModelPicker: UIPickerView!
    @IBOutlet weak var cameraMakeModelPickerLabel: UILabel!
    @IBOutlet weak var cameraMakeModelLabel: UILabel!
    @IBOutlet weak var themeSelector: UISegmentedControl!
    @IBOutlet weak var unitsPicker: UIPickerView!
    @IBOutlet weak var unitsPickerLabel: UILabel!
    @IBOutlet weak var copyrightInfo: UILabel!
    @IBOutlet weak var versionInfo: UILabel!
    
    //define picker view data sources
    var cameraMakeData = [String]()
    var cameraModelData = [String]()
    var unitsData: [String]! = ["cm","in","ft","yd","m"]
    
    
    override func viewWillAppear(_ animated: Bool) {
        //get path to Settings plist
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        let fullDestPathString = fullDestPath?.path
        pathToSettings = fullDestPathString
        
        //read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        print("unit is "+(settings?.value(forKey: "Unit") as? String)!)


    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get path to Settings plist
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        let fullDestPathString = fullDestPath?.path
        pathToSettings = fullDestPathString
        
        //read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        unit = (settings?.value(forKey: "Unit") as? String)!

        
        
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
        for i in 0 ... unitsData.count-1{ //set unit to current unit
            print(i)
            print(unitsData[i])
            if unitsData[i] == unit {
                unitsPicker.selectRow(i, inComponent: 0, animated: true)
                print("picker is set to \(i)")
                break
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //return number of componetnts (columns) in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 2
        } else if pickerView.tag == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    //return number of rows in each picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    //return value of each row in picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    
    //when pickerView selection changes
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0{
            //save camera change to settings plist
            settings?["Camera Make"] = cameraMakeData[row]
            settings?["Camera Model"] = cameraModelData[row]
            settings?.write(toFile: pathToSettings!, atomically: true)
            cameraMakeModelLabel.text = (settings?.value(forKey: "Camera Make") as? String)!+" "+(settings?.value(forKey: "Camera Model") as? String)!
            print("Camera is "+(settings?.value(forKey: "Camera Make") as? String)!+" "+(settings?.value(forKey: "Camera Model") as? String)!)
        } else if pickerView.tag == 1 {
            //save to settings.plist
            settings?["Unit"] = unitsData[row]
            settings?.write(toFile: pathToSettings!, atomically: true)
            print("unit is "+(settings?.value(forKey: "Unit") as? String)!)
        }
    }
        

}

