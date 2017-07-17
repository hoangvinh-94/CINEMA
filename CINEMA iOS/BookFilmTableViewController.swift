//
//  BookFilmTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// MARK: - BookFilmTableViewController
class BookFilmTableViewController: UITableViewController {
    
    // MARK: Internal
    
    // MARK: Declare variables
    final let IDENTIFIER_BOOKCELL: String = "BookCell"
    final let IDENTIFIER_BSEAT: String = "BSEAT"
    final let IDENTIFIER_SIGNINVIEWCONTROLLER: String = "SignInViewController"
    final let BORDER_WIDTH_CELL: Float = 1.0
    final let CORNER_RADIUS_CELL: Float = 20.0
    final let HEIGHT_FOR_HEADER: Float = 50.0
    var tableIndicator = UIActivityIndicatorView()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var idFilmCurrent: Int?
    var titleFilm: String?
    var bookFilm = [Book]()
    var db = DataFilm()
    
    // MARK: UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        tableView.backgroundView = tableIndicator
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        ref = Database.database().reference()
        loadBookFilm()
        if tableIndicator.isAnimating {
            tableIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // load list book film
    func loadBookFilm(){
        
        tableIndicator.startAnimating()
        
        // use method from DataFilm
        db.getBookFilmFireBase(idFilmCurrent: idFilmCurrent!) { (bookFilm, error) in
            if error != nil {
                print(error!)
            }
            else {
                self.bookFilm = bookFilm!
                DispatchQueue.main.async {
                    self.tableIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return bookFilm.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        return bookFilm[section].getTimes().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_BOOKCELL, for: indexPath) as! BookTableViewCell
        
        // Configure the cell...
        cell.timeLabel.layer.cornerRadius = CGFloat(CORNER_RADIUS_CELL)
        cell.timeLabel.layer.borderWidth = CGFloat(BORDER_WIDTH_CELL)
        cell.timeLabel.layer.backgroundColor = UIColor.orange.cgColor
        cell.timeLabel?.text =
        bookFilm[indexPath.section].getTimes()[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat(HEIGHT_FOR_HEADER)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor.gray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return bookFilm[section].getDays()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let BSeat = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_BSEAT) as! SeatCollectionViewController
        BSeat.idFilm = idFilmCurrent
        let idDay = indexPath.section
        let idTime = indexPath.row
        let day = bookFilm[indexPath.section].getDays()
        let time = bookFilm[indexPath.section].getTimes()[indexPath.row]
        let room = bookFilm[indexPath.section].getRooms()[indexPath.row]
        BSeat.idDay = idDay
        BSeat.idTime = idTime
        BSeat.titleFilm = self.titleFilm
        BSeat.room = room
        BSeat.time = time
        BSeat.day = day
        
        // check user exist
        if Auth.auth().currentUser?.uid == nil {
            let Login = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_SIGNINVIEWCONTROLLER) as! SignInViewController
            navigationController?.pushViewController(Login, animated: true)
        }
        else {
            navigationController?.pushViewController(BSeat, animated: true)
        }
    }
}
