//
//  TableViewCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/7/21.
//

import UIKit

class TableCell: UITableViewCell {


  @IBOutlet weak var peripheralLabel: UILabel!
    
    static let reuseIdentifier = "blueCell"
    private var lastUpdateTimestamp = Date()
    
    public func setupView(withPeripheral advertisedPeripheral: BlePeripheral) {
        peripheralLabel.text = advertisedPeripheral.localName

    }
    
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
