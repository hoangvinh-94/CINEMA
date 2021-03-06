//
//  ProfileViewController.swift
//  CINEMA iOS
//
//  Created by TTB on 6/20/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// Display user information
// MARK: - ProfileViewController

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Internal
    
    // MARK: - IBOutlet
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var myOrdersTableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - Variables
    final let DATE_FORMAT: String = "dd/MM/yyyy"
    final let NUMBERSECTION_RETURNED: Int = 1
    final let IDENTIFIER_ORDERCELL: String = "MyOrder_Cell"
    final let BORDER_WIDTH_CELL: Float = 1.0
    final let CORNER_RADIUS_CELL: Float = 5.0
    var tickets = [Ticket]()
    var filteredTickets = [Ticket]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    let cellSpacingHeight: CGFloat = 5
    var tableIndicator = UIActivityIndicatorView()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        ref = Database.database().reference()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        myOrdersTableView.backgroundView = tableIndicator
        myOrdersTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        loadUserInfor()
        loadDataToTableView()
        if tableIndicator.isAnimating {
            tableIndicator.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: - LoadData
    
    //Load user infor
    func loadUserInfor() {
        tableIndicator.startAnimating()
        if let uid = Auth.auth().currentUser?.uid {
            refHandler = ref.child("users").child(uid).observe(.value, with:{ (snapshot) in
                if let userInforDic = snapshot.value as? [String: AnyObject] {
                    let userName = userInforDic["userName"] as! String
                    let email = userInforDic["email"] as! String
                    self.userNameLabel.text = userName
                    self.emailLabel.text = email
                    self.tableIndicator.stopAnimating()
                }
            })
        }
    }
    
    //Load the tickets current user have ordered
    func loadDataToTableView() {
        tableIndicator.startAnimating()
        self.tickets = [Ticket]()
        let uid = Auth.auth().currentUser?.uid
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATE_FORMAT
        let today = formatter.date(from: formatter.string(from: date))
        
        refHandler = ref.child("tickets").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let idUser = dictionary["idUser"] as? String
                let day = dictionary["day"] as? String
                let day1 = formatter.date(from: day!)
                if idUser == uid && ((day1! == today!) || (day1! > today!)) {
                    let title = dictionary["titleFilm"] as? String
                    let time = dictionary["time"] as? String
                    let room = dictionary["room"] as? Int
                    let seat = dictionary["seat"] as? String
                    self.tickets.append(Ticket(titleFilm: title!,day: day!, time: time!, seat: seat!, room: room!))
                    DispatchQueue.main.async {
                        self.tableIndicator.stopAnimating()
                        self.myOrdersTableView.reloadData()
                    }
                }
                else {
                    return
                }
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return NUMBERSECTION_RETURNED
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != "" {
            return filteredTickets.count
        }
        else {
            return tickets.count
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_ORDERCELL) as! MyOrderCell
        var ticket: Ticket
        if HomeViewController.searchController.searchBar.text != "" && HomeViewController.searchController.isActive {
            ticket = filteredTickets[indexPath.row]
        }
        else {
            ticket = tickets[indexPath.row]
        }
        cell.dateRelease.text = ticket.getDay()
        cell.roomTicket.text = String(ticket.getRoom())
        cell.titleFilm.text = ticket.getTitleFilm()
        cell.timeTicket.text = ticket.getTime()
        cell.seatTicket.text = String(ticket.getSeat())
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = CGFloat(BORDER_WIDTH_CELL)
        cell.layer.cornerRadius = CGFloat(CORNER_RADIUS_CELL)
        cell.clipsToBounds = true
        return cell
    }
    
   // Search film by Title Film
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        
        filteredTickets = tickets.filter {
            st in
            return st.getTitleFilm().lowercased().contains(searchText.lowercased())
        }
        myOrdersTableView.reloadData()
    }
}

// MARK: UISearchBarDelegate

extension ProfileViewController : UISearchBarDelegate {
    
    // MARK: Internal
    
    // MARK: UISearchBarDelegate
    // button search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !(searchBar.text?.isEmpty)! {
            myOrdersTableView?.reloadData()
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            //reload your data source if necessary
            myOrdersTableView?.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if !(searchBar.text?.isEmpty)! {
            //reload your data source if necessary
            myOrdersTableView?.reloadData()
        }
    }
}

// MARK: UISearchResultsUpdating

extension ProfileViewController: UISearchResultsUpdating {
    
     // MARK: Internal
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

