//
//  MyOrderCell.swift
//  CINEMA iOS
//
//  Created by TTB on 6/20/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class MyOrderCell: UITableViewCell {
    
    @IBOutlet weak var titleFilm: UILabel!
    
    @IBOutlet weak var dateRelease: UILabel!
    
    @IBOutlet weak var timeTicket: UILabel!
    
    @IBOutlet weak var roomTicket: UILabel!
    
    @IBOutlet weak var seatTicket: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
