//
//  LikeListTableViewCell.swift
//  YelpHungryApp
//
//  Created by admin on 2/19/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class LikeListTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var categoryLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
