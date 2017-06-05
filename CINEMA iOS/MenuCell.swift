//
//  MenuCell.swift
//  CINEMA iOS
//
//  Created by TTB on 6/3/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var imageMenu: UIImageView!
    @IBOutlet weak var labelMenu: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
