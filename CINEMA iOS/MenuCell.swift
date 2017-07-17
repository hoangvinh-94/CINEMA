//
//  MenuCell.swift
//  CINEMA iOS
//
//  Created by TTB on 6/3/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit


// MARK: - MenuCell

class MenuCell: UITableViewCell {

    
    // MARK: Internal
    
    @IBOutlet weak var imageMenu: UIImageView!
    @IBOutlet weak var labelMenu: UILabel!
    
    // MARK: UITableViewCell
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
