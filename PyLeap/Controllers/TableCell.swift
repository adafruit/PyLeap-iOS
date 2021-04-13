//
//  TableViewCell.swift
//  PyLeap
//
//  Created by Trevor Beaton For Adafruit Industries on 3/7/21.
//

import UIKit

class TableCell: UITableViewCell {


  @IBOutlet weak var peripheralLabel: UILabel!
  @IBOutlet weak var deviceIcon: UIImageView!
    
    static let clueID = "22 08 0A 04 00 9A 23 00 00 72 80 00 00 "
    static let cpbID = "22 08 0A 04 00 9A 23 00 00 46 80 00 00 "
    
    
    static let reuseIdentifier = "blueCell"
    private var lastUpdateTimestamp = Date()
    
    public func setupView(withPeripheral advertisedPeripheral: BlePeripheral) {
        peripheralLabel.text = advertisedPeripheral.localName

        
        
        if advertisedPeripheral.advertisement.manufacturerHexDescription == TableCell.clueID {
            deviceIcon.image = #imageLiteral(resourceName: "clue")
        } else if advertisedPeripheral.advertisement.manufacturerHexDescription == TableCell.cpbID {
            deviceIcon.image = #imageLiteral(resourceName: "cpb")
        } else {
            deviceIcon.image = nil
        }
    }
//    if manufacturerDataString == "22 08 0A 04 00 9A 23 00 00 72 80 00 00 " {
//        manufacturerLabel.text = "Adafruit CLUE nRF52840 Express with nRF52840"
//    } else {
//        manufacturerLabel.text = "Unknown"
//    }
    
    public func peripheralUpdatedAdvertisementData(_ aPeripheral: BlePeripheral) {
        if Date().timeIntervalSince(lastUpdateTimestamp) > 1.0 {
            lastUpdateTimestamp = Date()
            setupView(withPeripheral: aPeripheral)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
