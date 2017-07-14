//
//  ConnectAgainViewController.swift
//  CINEMA iOS
//
//  Created by healer on 7/13/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class ConnectAgainViewController: UIViewController {
    var tableIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectAgain(_ sender: Any) {
        tableIndicator.center = self.view.center
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.black
        tableIndicator.hidesWhenStopped = true
        
        self.view.addSubview(tableIndicator)
        
        tableIndicator.startAnimating()
        
        if self.currentReachabilityStatus == .notReachable {
            tableIndicator.stopAnimating()
            
        } else {
            
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "SWRevealViewController")
           present(newViewcontroller, animated: true, completion: nil)
            tableIndicator.stopAnimating()
            
        }
       
    }

}
