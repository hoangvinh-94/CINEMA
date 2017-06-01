//
//  TabBarController.swift
//  CINEMA iOS
//
//  Created by healer on 5/27/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITableViewDelegate, UITableViewDataSource {

    var MenuButton: UIButton = UIButton()
    var ViewMenu: UIView = UIView()
    var TableViewMenu: UITableView = UITableView()
    var Menus: Array<String> = ["Home","Page 1","Page 2"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenuButton()
        setupViewMenu()
        setupTableViewMenu()
        swipeGesture()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // init Swipe
    func swipeGesture(){
        let right = UISwipeGestureRecognizer(target: self, action: #selector(TabBarController.swipeRight))
        right.direction = .right
        view.addGestureRecognizer(right)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(TabBarController.swipeLeft))
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
        MenuButton.addTarget(self, action: #selector(TabBarController.showMenu), for: .touchUpInside)
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
        ViewMenu.addSubview(TableViewMenu)
        TableViewMenu.delegate = self
        TableViewMenu.dataSource = self
        TableViewMenu.register(MenuTableViewCell.self, forCellReuseIdentifier: "CellMenu")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewMenu.dequeueReusableCell(withIdentifier: "CellMenu", for: indexPath) as! MenuTableViewCell
        cell.textLabel?.text = Menus[indexPath.row]
        return cell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
