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
    
    func setData(text: String){
        self.deviceName.text = text
    }
    
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
            self.layer.cornerRadius = 15.0
            self.layer.borderWidth = 5.0
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.masksToBounds = true
            
            // cell shadow section
            self.contentView.layer.cornerRadius = 15.0
            self.contentView.layer.borderWidth = 5.0
            self.contentView.layer.borderColor = UIColor.clear.cgColor
            self.contentView.layer.masksToBounds = true
            self.layer.shadowColor = UIColor.white.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            self.layer.shadowRadius = 6.0
            self.layer.shadowOpacity = 0.6
            self.layer.cornerRadius = 15.0
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
