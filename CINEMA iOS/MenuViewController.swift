//
//  MenuViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/6/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    // MARK: - Declaration variables
   var searchController = HomeViewController.searchController
    var ref : DatabaseReference!
    var ManuNameArray: Array = [String]()
    var iconArray: Array = [UIImage]()
    
    @IBOutlet var tableView: UITableView!
    
     // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        if(Auth.auth().currentUser?.uid != nil){
            let uid = Auth.auth().currentUser?.uid
            ref.child("users").child(uid!).observe(.value, with: {(snapshot) in
                let user = snapshot.value as? [String: Any]
                self.navigationItem.title = user?["userName"] as? String
                
            })
        }
        else{
            self.navigationItem.title = "Current User"
        }
        tableView.tableHeaderView = searchController.searchBar
        ManuNameArray = ["Home", "Schedule Today", "Now Showing", "Coming Soon", "Had Shown", "Sign In"]
        iconArray = [UIImage(named:"home2")!, UIImage(named:"schedule")!, UIImage(named:"dangchieu")!, UIImage(named:"played1")!,UIImage(named:"oldmovie")!, UIImage(named:"signin")!]
        
        if Auth.auth().currentUser?.uid != nil {
            
            ManuNameArray.remove(at: 5)
            iconArray.remove(at: 5)
            
            ManuNameArray.append("My Profile")
            iconArray.append(UIImage(named:"userinfor")!)
            ManuNameArray.append("Change Password")
            iconArray.append(UIImage(named:"changepassword")!)
            ManuNameArray.append("Sign Out")
            iconArray.append(UIImage(named:"logout")!)
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     // MARK: - Life cycles
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ManuNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        cell.labelMenu.text! = ManuNameArray[indexPath.row]
        cell.imageMenu.image = iconArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HomeViewController.searchController.searchBar.text = ""
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let cell:MenuCell = tableView.cellForRow(at: indexPath) as! MenuCell
        print(cell.labelMenu.text!)
        
        if cell.labelMenu.text! == "Home"
        {
            HomeViewController.searchController.searchBar.isHidden = false
            print("Home Tapped")
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
        
        if cell.labelMenu.text! == "Change Password"
        {
            HomeViewController.searchController.searchBar.isHidden = true

            print("Change Password Tapped")
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
        
        if cell.labelMenu.text! == "Had Shown"
        {
            HomeViewController.searchController.searchBar.isHidden = false
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let PDC = mainstoryboard.instantiateViewController(withIdentifier: "PDC") as! FilmTypeTableViewController
            PDC.typeFilm = 0
            
            let newFrontController = UINavigationController.init(rootViewController: PDC)
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
        }
        
        if cell.labelMenu.text! == "Now Showing"
        {
            HomeViewController.searchController.searchBar.isHidden = false
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let PDC = mainstoryboard.instantiateViewController(withIdentifier: "PDC") as! FilmTypeTableViewController
            PDC.typeFilm = 1
            
            let newFrontController = UINavigationController.init(rootViewController: PDC)
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
        
        if cell.labelMenu.text! == "Coming Soon"
        {
            HomeViewController.searchController.searchBar.isHidden = false
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let PDC = mainstoryboard.instantiateViewController(withIdentifier: "PDC") as! FilmTypeTableViewController
            PDC.typeFilm = 2
            
            let newFrontController = UINavigationController.init(rootViewController: PDC)
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
        
        if cell.labelMenu.text! == "Schedule Today"
        {
            HomeViewController.searchController.searchBar.isHidden = false
            print("Schedule Today Tapped")
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "ScheduleViewController") as! ScheduleTableViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
        
        if cell.labelMenu.text! == "My Profile"
        {
             HomeViewController.searchController.searchBar.isHidden = false
            print("My Profile Tapped")
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
        }
        
        if cell.labelMenu.text! == "Sign In"
        {
            HomeViewController.searchController.searchBar.isHidden = true
            print("My Profile Tapped")
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
        }
        
        if cell.labelMenu.text! == "Sign Out"
        {
            print("Log out Tapped")
            do {
                try Auth.auth().signOut()
            }
            catch let error {
                print(error)
            }
            
            ManuNameArray.remove(at: 5)
            iconArray.remove(at: 5)
            
            ManuNameArray.remove(at: 5)
            iconArray.remove(at: 5)
            
            ManuNameArray.remove(at: 5)
            iconArray.remove(at: 5)
            
            ManuNameArray.append("Sign In")
            iconArray.append(UIImage(named:"signin")!)
            
            tableView.reloadData()
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            navigationItem.title = "Current User"
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        }
    }

}

