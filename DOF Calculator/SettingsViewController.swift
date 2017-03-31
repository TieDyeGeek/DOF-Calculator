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
    var cameraMaker: String!
    var cameraModel: String!
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
        cameraMaker = (settings?.value(forKey: "Camera Maker") as? String)!
        cameraModel = (settings?.value(forKey: "Camera Model") as? String)!
        
       
        //setup cameraMakeData
        //let fileManager = FileManager.default //needed?
        let bundlePath = Bundle.main.path(forResource: "CameraInfo", ofType: "sqlite")
        print(bundlePath ?? "No Path -- Error", "\n") //prints the correct path
        
        
        let cameraDB = FMDatabase(path: bundlePath!)
        
        if (cameraDB?.open())! {
            let querySQL = "SELECT DISTINCT CameraMaker FROM CameraInfo;"
            
            let results:FMResultSet? = cameraDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            while results?.next() == true {
                cameraMakeData.append((results?.string(forColumn: "CameraMaker"))!)
            }
            print("No more camera make data")
            cameraDB?.close()
        } else {
            print("Error: \(String(describing: cameraDB?.lastErrorMessage()))")
        }
        
        //setup cameraModelData
        setupCameraModels()
        

        
        
        //set delegates and data sources for picker
        cameraMakeModelPicker.delegate = self
        cameraMakeModelPicker.dataSource = self
        unitsPicker.delegate = self
        unitsPicker.dataSource = self
        
        //set tag numbers for pickers
        cameraMakeModelPicker.tag = 0
        unitsPicker.tag = 1

        
        //set default value for pickers
        for i in 0 ... cameraMakeData.count-1{
            if cameraMakeData[i] == cameraMaker {
                cameraMakeModelPicker.selectRow(i, inComponent: 0, animated: true)
                print("cameraMake is set to \(i)")
                break
            }
        }
        
        for i in 0 ... cameraModelData.count-1{
            if cameraModelData[i] == cameraModel {
                cameraMakeModelPicker.selectRow(i, inComponent: 1, animated: true)
                print("cameraModel is set to \(i)")
                break
            }
        }
        
        for i in 0 ... unitsData.count-1{ //set unit to current unit
            //print(i)
            //print(unitsData[i])
            if unitsData[i] == unit {
                unitsPicker.selectRow(i, inComponent: 0, animated: true)
                print("picker is set to \(i)")
                break
            }
        }
        
        cameraMakeModelLabel.text = cameraMaker+" "+cameraModel

    }
    
    func setupCameraModels(){
        let bundlePath = Bundle.main.path(forResource: "CameraInfo", ofType: "sqlite")
        print(bundlePath ?? "No Path -- Error", "\n") //prints the correct path
        let cameraDB = FMDatabase(path: bundlePath!)
        
        if (cameraDB?.open())! {
            print(cameraMaker)
            let querySQL = "SELECT CameraModel FROM CameraInfo WHERE CameraMaker = '\(cameraMaker ?? "")';"
            
            let results:FMResultSet? = cameraDB?.executeQuery(querySQL, withArgumentsIn: nil)
            
            cameraModelData = []
            while results?.next() == true {
                cameraModelData.append((results?.string(forColumn: "CameraModel"))!)
            }
            print("No more camera model data")
            cameraDB?.close()
        } else {
            print("Error: \(String(describing: cameraDB?.lastErrorMessage()))")
        }
        
        //reset picker data shown
        cameraMakeModelPicker.reloadComponent(1)
        
        //reset picker to first row
        cameraMakeModelPicker.selectRow(0, inComponent: 1, animated: true)
        print("cameraModel is reset to 0")
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //updates the sensor info stored in the settings plist
    func updateSensorInfo(){
        let bundlePath = Bundle.main.path(forResource: "CameraInfo", ofType: "sqlite")
        print(bundlePath ?? "No Path -- Error", "\n") //prints the correct path
        let cameraDB = FMDatabase(path: bundlePath!)
        
        if (cameraDB?.open())! {
            //Sensor width
            print("SELECT \"SensorWidth(mm)\" FROM CameraInfo WHERE CameraMaker = '\(cameraMaker ?? "")' AND CameraModel = '\(cameraModel ?? "")';")
            let query1SQL = "SELECT \"SensorWidth(mm)\" FROM CameraInfo WHERE CameraMaker = '\(cameraMaker ?? "")' AND CameraModel = '\(cameraModel ?? "")';"
            
            let results1:FMResultSet? = cameraDB?.executeQuery(query1SQL, withArgumentsIn: nil)
            
           if results1?.next() == true {
                let sw = ((results1?.string(forColumn: "SensorWidth(mm)"))!)
                settings?["Sensor Width"] = Double(sw)
                settings?.write(toFile: pathToSettings!, atomically: true)
            } else {
                print("No sensor data")
            }
            print("Sensor Width is \(settings?.value(forKey: "Sensor Width") ?? "NOT DEFINED")")


            //sensor Height
            print("SELECT \"SensorHeight(mm)\" FROM CameraInfo WHERE CameraMaker = '\(cameraMaker ?? "")' AND CameraModel = '\(cameraModel ?? "")';")
            let query2SQL = "SELECT \"SensorHeight(mm)\" FROM CameraInfo WHERE CameraMaker = '\(cameraMaker ?? "")' AND CameraModel = '\(cameraModel ?? "")';"
            
            let results2:FMResultSet? = cameraDB?.executeQuery(query2SQL, withArgumentsIn: nil)
            
            if results2?.next() == true {
                let sh = ((results2?.string(forColumn: "SensorHeight(mm)"))!)
                settings?["Sensor Height"] = Double(sh)
                settings?.write(toFile: pathToSettings!, atomically: true)
                
            } else {
                print("No sensor data")
            }
            print("Sensor Height is \(settings?.value(forKey: "Sensor Height") ?? "NOT DEFINED")")
            //print("Sensor Height is "+(settings?.value(forKey: "Sensor Height") as? String)!)
            
            cameraDB?.close()
        } else {
            print("Error: \(String(describing: cameraDB?.lastErrorMessage()))")
        }

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
    
    //return width of component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width

        if pickerView.tag == 0 {
            if component == 0 {
                return screenWidth * 0.35
            } else if component == 1 {
                return screenWidth * 0.57
            }
        } else if pickerView.tag == 1 {
            return screenWidth * 0.45
        }

        
        
        return CGFloat(25.0)
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
            if component == 0 {
                cameraMaker = cameraMakeData[cameraMakeModelPicker.selectedRow(inComponent: 0)]
                setupCameraModels()
            } else if component == 1 {
                
            }
            cameraModel = cameraModelData[cameraMakeModelPicker.selectedRow(inComponent: 1)]

            //save camera change to settings plist
            settings?["Camera Maker"] = cameraMaker
            settings?["Camera Model"] = cameraModel
            settings?.write(toFile: pathToSettings!, atomically: true)
            cameraMakeModelLabel.text = cameraMaker+" "+cameraModel
            
            //update sensor info
            updateSensorInfo()
            
            print("Camera is "+(settings?.value(forKey: "Camera Maker") as? String)!+" "+(settings?.value(forKey: "Camera Model") as? String)!)
        } else if pickerView.tag == 1 {
            //save to settings.plist
            settings?["Unit"] = unitsData[row]
            settings?.write(toFile: pathToSettings!, atomically: true)
            print("unit is "+(settings?.value(forKey: "Unit") as? String)!)
        }
    }
        

}

