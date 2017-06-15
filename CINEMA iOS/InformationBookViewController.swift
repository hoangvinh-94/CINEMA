//
//  InformationBookViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/14/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class InformationBookViewController: UIViewController {

    var titleFilm: String?
    var day: String?
    var time: String?
    var seat: String?
    var room: Int?
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var seatLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = titleFilm!
        dayLabel.text = day!
        timeLabel.text = time!
        seatLabel.text = seat!
        roomLabel.text = String(room!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
