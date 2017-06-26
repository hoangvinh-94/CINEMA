//
//  SignUpViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var actIndicator = UIActivityIndicatorView()
    
    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        confirmPasswordTextField.backgroundColor = .clear
        confirmPasswordTextField.layer.cornerRadius = 5
        confirmPasswordTextField.layer.borderWidth = 1
        confirmPasswordTextField.layer.borderColor = UIColor.blue.cgColor
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.blue.cgColor
        
        emailTextField.backgroundColor = .clear
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.blue.cgColor
        
        
        userNameTextField.backgroundColor = .clear
        userNameTextField.layer.cornerRadius = 5
        userNameTextField.layer.borderWidth = 1
        userNameTextField.layer.borderColor = UIColor.blue.cgColor
        
        actIndicator.activityIndicatorViewStyle = .whiteLarge
        actIndicator.color = UIColor.orange
        actIndicator.center = self.view.center
        
        self.view.addSubview(actIndicator)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInAction(_ sender: Any) {
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
        let newFrontController = UINavigationController.init(rootViewController:vc)
        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
    }
    //MARK: - Main func
    @IBAction func signUpAction(_ sender: Any) {
        actIndicator.startAnimating()
        if emailTextField.text == "" || passwordTextField.text == "" || userNameTextField.text == ""  {
            actIndicator.stopAnimating()
            let alertController = UIAlertController(title: "Error", message: "Please fill the informations!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            if passwordTextField.text != confirmPasswordTextField.text {
                actIndicator.stopAnimating()
                let alertController = UIAlertController(title: "Error", message: "Your confirm password is wrong!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            }
            else{
                
                if (passwordTextField.text?.characters.count)! < 6 {
                    actIndicator.stopAnimating()
                    let alertController = UIAlertController(title: "Error", message: "Strong password must have at least 6 characters! Try again!", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    present(alertController, animated: true, completion: nil)
                }
                else {
                    guard let name = userNameTextField.text, let email = emailTextField.text, let mk = passwordTextField.text else {
                        actIndicator.stopAnimating()
                        print("Form is not valid!")
                        return
                    }
                    Auth.auth().createUser(withEmail: email, password: mk) { (user, error) in
                        
                        if error == nil {
                            //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                            guard let uid = user?.uid else {
                                self.actIndicator.stopAnimating()
                                print("user id not valid!")
                                return
                            }
                            self.actIndicator.stopAnimating()
                            var ref: DatabaseReference!
                            ref = Database.database().reference()
                            let values = ["userName": name, "email": email, "password": mk]
                            
                            let userRef = ref.child("users").child(uid)
                            
                            userRef.updateChildValues(values, withCompletionBlock: {
                                (err, ref) in
                                if err != nil {
                                    self.actIndicator.stopAnimating()
                                    print("Not valid user")
                                    return
                                }
                                else {
                                    self.actIndicator.stopAnimating()
                                    let alertController = UIAlertController(title: "Success!", message: "Sign up successfully! Welcome!", preferredStyle: .alert)
                                    
                                    // add the actions (buttons)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                                        
                                        let revealviewcontroller:SWRevealViewController = self.revealViewController()
                                        
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
                                        let newFrontController = UINavigationController.init(rootViewController:vc)
                                        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
                                        
                                    }))
                                    self.present(alertController, animated: true, completion: nil)
                                    print("Change password successfully!")
                                }
                                
                            })
                            
                        } else {
                            self.actIndicator.stopAnimating()
                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription,   preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
    
}
