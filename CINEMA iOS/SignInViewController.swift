//
//  SignInViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var actIndicator = UIActivityIndicatorView()
    
    weak var activedTextField: UITextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.blue.cgColor
        
        userNameTextField.backgroundColor = UIColor.white
        userNameTextField.layer.cornerRadius = 5
        userNameTextField.layer.borderWidth = 1
        userNameTextField.layer.borderColor = UIColor.blue.cgColor
        
        actIndicator.activityIndicatorViewStyle = .whiteLarge
        actIndicator.color = UIColor.orange
        actIndicator.center = self.view.center
        
        self.view.addSubview(actIndicator)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)) , name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //ScrollView.setContentOffset(CGPoint(x:0,y:250), animated: true)
        self.activedTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activedTextField = nil
    }
    
    
    func keyboardDidShow(notification: NSNotification) {
        
        if let activeField = self.activedTextField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    @IBAction func singInAction(_ sender: Any) {
        actIndicator.startAnimating()
        if self.userNameTextField.text == "" || self.passwordTextField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            actIndicator.stopAnimating()
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.userNameTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    self.actIndicator.stopAnimating()
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController")
                    
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    self.actIndicator.stopAnimating()
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController")
        let newFrontController = UINavigationController.init(rootViewController:vc)
        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
    }
    @IBAction func singInFacebookAction(_ sender: Any) {
        
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        let newFrontController = UINavigationController.init(rootViewController:vc)
        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
    }
    
}
