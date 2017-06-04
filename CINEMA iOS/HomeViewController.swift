//
//  ViewController.swift
//  CINEMA iOS
//
//  Created by healer on 5/27/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    var MenuButton: UIButton = UIButton()
    var ViewMenu: UIView = UIView()
    var TableViewMenu: UITableView = UITableView()
    var Menus: Array<String> = ["Home","Page 1","Page 2"]
    var db = DataFilm()
    var Films = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt! 

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        db.reloadFilmFromUrlApi(page: 1)
        //db.getDataFromFireBase(tableView: self.tableView, Films: Films)
        ref = Database.database().reference()
        refHandler = ref.child("films").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let overview = dictionary["overview"] as? String
                let poster_path = dictionary["poster_path"] as? String
                let release_date = dictionary["release_date"] as? String
                let title = dictionary["title"] as? String
                print(title!)	
                self.Films.append(Film(title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!))
         
            }
         self.tableView.reloadData()
        
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // init Swipe
    func swipeGesture(){
        let right = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.swipeRight))
        right.direction = .right
        view.addGestureRecognizer(right)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.swipeLeft))
        left.direction = .left
        view.addGestureRecognizer(left)
    }
    
    // swipe right
    func swipeRight(){
        UIView.animate(withDuration: 0.5){
            self.ViewMenu.frame.origin.x += self.view.frame.width / 2
        }
    }
    
    // swipe right
    func swipeLeft(){
        UIView.animate(withDuration: 0.5){
            self.ViewMenu.frame.origin.x -= self.view.frame.width / 2
        }
    }
    // set size, background for MenuButton and add it to NavigationBar
    func setMenuButton(){
        MenuButton = UIButton(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        MenuButton.setBackgroundImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        // assign to navigationBar
        navigationController?.navigationBar.addSubview(MenuButton)
        MenuButton.addTarget(self, action: #selector(HomeViewController.showMenu), for: .touchUpInside)
    }
    
    func showMenu(){
        print("Menu clicked!")
        if(ViewMenu.frame.origin.x < 0){
            UIView.animate(withDuration: 0.5){
                self.ViewMenu.frame.origin.x += self.view.frame.width / 2
            }
        }
        else{
            UIView.animate(withDuration: 0.5){
                self.ViewMenu.frame.origin.x -= self.view.frame.width / 2
            }
            
        }
    }
    
    // set position for ViewMenu
    func setupViewMenu(){
        ViewMenu = UIView(frame: CGRect(x: -view.frame.width / 2, y: 20 + (navigationController?.navigationBar.frame.height)!	, width: view.frame.width / 2, height: view.frame.height - 20 + (navigationController?.navigationBar.frame.height)!))
        view.addSubview(ViewMenu)
        ViewMenu.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
    // setup TableViewMenu
    func setupTableViewMenu(){
        TableViewMenu = UITableView(frame: CGRect(x: 0, y: 0, width: ViewMenu.frame.width, height: ViewMenu.frame.height))
        //ViewMenu.addSubview(TableViewMenu)
        //TableViewMenu.delegate = self
        //TableViewMenu.dataSource = self
        //TableViewMenu.register(MenuTableViewCell.self, forCellReuseIdentifier: "CellMenu")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Films.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell") as! FilmTableViewCell
        cell.TitleFilm.text = Films[indexPath.row].getTitle()
        return cell
    }


}

