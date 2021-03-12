//
//  TableViewCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/7/21.
//

import UIKit

class TableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  @IBOutlet weak var peripheralLabel: UILabel!
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
