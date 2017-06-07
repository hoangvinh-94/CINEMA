//
//  ChangePasswordViewController.swift
//  CINEMA iOS
//
//  Created by TTB on 6/7/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {
    
    // MARK: - IBOutlet

    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
     // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     // MARK: - Main func
    @IBAction func confirmChangePasswordAction(_ sender: Any) {
        if 	self.newPasswordTextField.text == "" || self.confirmPasswordTextField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password, confirm Password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            if self.newPasswordTextField.text != self.confirmPasswordTextField.text {
                let alertController = UIAlertController(title: "Error", message: "Confirm password does not match", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            else {
                if Auth.auth().currentUser?.uid == nil {
                    print("User not loged in")
                }
                else {
                    
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    let ref: DatabaseReference!
                    ref = Database.database().reference()
                    let userRef = ref.child("users").child(uid)
                    Auth.auth().currentUser!.updatePassword(to: newPasswordTextField.text!, completion: { (error) in
                        if error == nil{
                            userRef.updateChildValues(["password" : self.newPasswordTextField.text! ], withCompletionBlock: {(errEM, referenceEM)   in
                                
                                if errEM == nil{
                                    let alertController = UIAlertController(title: "Success!", message: "Change password successfully!", preferredStyle: .alert)
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    alertController.addAction(defaultAction)
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                    print("Change password successfully!")
                                }else{
                                    print("Error when changing password!")
                                }
                            })
                        }
                        
                    })
                }
                
            }
        }
        
    }
    
}
