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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
