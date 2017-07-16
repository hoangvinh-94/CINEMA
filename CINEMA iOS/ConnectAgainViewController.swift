//
//  ConnectAgainViewController.swift
//  CINEMA iOS
//
//  Created by healer on 7/13/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit


// MARK: - ConnectAgainViewController

class ConnectAgainViewController: UIViewController {
    
    
    // MARK: Internal
    
    var tableIndicator = UIActivityIndicatorView()
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Main func
    
    @IBAction func connectAgain(_ sender: Any) {
        
        self.addActIndicatorToView()
        
        tableIndicator.startAnimating()
        
        if self.currentReachabilityStatus == .notReachable {
            tableIndicator.stopAnimating()
        }
        else {
            
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            present(newViewcontroller, animated: true, completion: nil)
            tableIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - Rest options
    
    func addActIndicatorToView() {
        
        tableIndicator.center = self.view.center
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.black
        tableIndicator.hidesWhenStopped = true
        
        self.view.addSubview(tableIndicator)
    }
    
}
