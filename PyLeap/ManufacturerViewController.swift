//
//  ManufacturerViewViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/6/21.
//

import UIKit

class ManufacturerViewController: UIViewController {

    var manufacturerDataString: String = ""
    var manufacturerDataDict: [String: Any] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        if manufacturerDataString == "22 08 0A 04 00 9A 23 00 00 72 80 00 00 " {
            manufacturerLabel.text = "Adafruit CLUE nRF52840 Express with nRF52840"
        } else {
            manufacturerLabel.text = "Unknown"
        }
        
        //22 08 0A 04 00 9A 23 00 00 46 80 00 00
        
        if manufacturerDataString == "22 08 0A 04 00 9A 23 00 00 72 80 00 00 " {
            manufacturerLabel.text = "Adafruit Feather nRF52840 Express with nRF52840"
        } else {
            manufacturerLabel.text = "Unknown"
        }
        
        print(manufacturerDataDict.keys)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View Dismissed")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
