//
//  TableViewCell.swift
//  Calculator
//
//  Created by user213353 on 2/19/22.
//

import UIKit

class TableViewCell: UITableViewCell {

   
    @IBOutlet weak var cellOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func refresh(_ example: String){
        cellOutlet.text = example
    }

}
