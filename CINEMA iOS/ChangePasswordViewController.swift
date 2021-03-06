//
//  ChangePasswordViewController.swift
//  CINEMA iOS
//
//  Created by TTB on 6/7/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// MARK: - ChangePasswordViewController

class ChangePasswordViewController: UIViewController {
    
    // MARK: Internal

    
    // MARK: - IBOutlet
    final let IDENTIFIER_SIGNINVIEWCONTROLLER: String = "SignInViewController"
    final let BORDER_WIDTH_CELL: Float = 1.0
    final let CORNER_RADIUS_CELL: Float = 5.0
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
     // MARK: - Override funcs
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        confirmPasswordTextField.backgroundColor = UIColor.white
        confirmPasswordTextField.layer.cornerRadius = CGFloat(CORNER_RADIUS_CELL)
        confirmPasswordTextField.layer.borderWidth = CGFloat(BORDER_WIDTH_CELL)
        confirmPasswordTextField.layer.borderColor = UIColor.blue.cgColor
        newPasswordTextField.backgroundColor = UIColor.white
        newPasswordTextField.layer.cornerRadius = CGFloat(CORNER_RADIUS_CELL)
        newPasswordTextField.layer.borderWidth = CGFloat(BORDER_WIDTH_CELL)
        newPasswordTextField.layer.borderColor = UIColor.blue.cgColor
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "nen18.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // change pass button pressed
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
                    print("User loged in")
                    guard let uid = Auth.auth().currentUser?.uid else {
                         print("not valid uid")
                        return
                    }
                    print("valid uid")
                    let ref: DatabaseReference!
                    ref = Database.database().reference()
                    let userRef = ref.child("users").child(uid)
                    Auth.auth().currentUser!.updatePassword(to: newPasswordTextField.text!, completion: { (error) in
                        if error == nil {
                            print("error nil")
                            userRef.updateChildValues(["password" : self.newPasswordTextField.text! ], withCompletionBlock: {(errEM, referenceEM)   in
                                if errEM == nil {
                                    let alertController = UIAlertController(title: "Success!", message: "Change password successfully! Please relogin!", preferredStyle: .alert)
                                    
                                    // add the actions (buttons)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in

                                        do {
                                            try Auth.auth().signOut()
                                        } catch let errorLogout {
                                            print(errorLogout)
                                        }
                                        let homeView = self.storyboard?.instantiateViewController(withIdentifier: self.IDENTIFIER_SIGNINVIEWCONTROLLER) as! SignInViewController
                                        self.navigationController?.pushViewController(homeView, animated: true)
                                    }))
                                    self.present(alertController, animated: true, completion: nil)
                                    print("Change password successfully!")
                                }
                                else {
                                    let alertError = UIAlertController(title: "Error!", message: "Please relogin and try again!", preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    alertError.addAction(defaultAction)
                                    self.present(alertError, animated: true, completion: nil)
                                    print("Error when changing password!")
                                }
                            })
                        }
                        else {
                            if (self.newPasswordTextField.text?.characters.count)! < 6 {
                                let alertError = UIAlertController(title: "Error!", message: "Password much more than 5 characters. Please try again!", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                alertError.addAction(defaultAction)
                                self.present(alertError, animated: true, completion: nil)
                                
                            }
                            else {
                                let alertError1 = UIAlertController(title: "Error!", message: error.debugDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                alertError1.addAction(defaultAction)
                                self.present(alertError1, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
}
