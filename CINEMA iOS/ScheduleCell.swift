//
//  ScheduleCell.swift
//  CINEMA iOS
//
//  Created by TTB on 6/14/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
