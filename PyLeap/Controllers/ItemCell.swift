//
//  ItemCellCollectionViewCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/3/21.
//

import UIKit

class ItemCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    
    public func setupView(withPeripheral advertisedPeripheral: BlePeripheral) {
        deviceName.text = advertisedPeripheral.localName

        
        
        if advertisedPeripheral.advertisement.manufacturerHexDescription == TableCell.clueID {
            image.image = #imageLiteral(resourceName: "clue")
        } else if advertisedPeripheral.advertisement.manufacturerHexDescription == TableCell.cpbID {
            image.image = #imageLiteral(resourceName: "cpb")
        } else {
            image.image = nil
        }
    }
    
    override func layoutSubviews() {
            // cell rounded section
            self.layer.cornerRadius = 10.0
            self.layer.borderWidth = 20.0
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.masksToBounds = true
            
            // cell shadow section
            self.contentView.layer.cornerRadius = 10
            self.contentView.layer.borderWidth = 5.0
            self.contentView.layer.borderColor = UIColor.clear.cgColor
            self.contentView.layer.masksToBounds = true
            self.layer.shadowColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            self.layer.shadowOffset = CGSize(width: 5, height: 5)
            self.layer.shadowRadius = 6
            self.layer.shadowOpacity = 0.1
            self.layer.cornerRadius = 6
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
