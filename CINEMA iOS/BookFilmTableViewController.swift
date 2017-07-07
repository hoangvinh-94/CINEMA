//
//  BookFilmTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class BookFilmTableViewController: UITableViewController {
    
    var tableIndicator = UIActivityIndicatorView()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var idFilmCurrent: Int?
    var titleFilm: String?
    var bookFilm = [Book]()
    var db = DataFilm()
    
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
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func loadBookFilm(){
        tableIndicator.startAnimating()
        db.getBookFilmFireBase(idFilmCurrent: idFilmCurrent!) { (bookFilm, error) in
            if(error != nil) {
                print(error!)
            } else {
                self.bookFilm = bookFilm!
                DispatchQueue.main.async {
                    self.tableIndicator.stopAnimating()
                    self.tableView.reloadData()
                }

            }

        }
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(bookFilm.count)
        return bookFilm.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookFilm[section].getTimes().count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell
        
        // Configure the cell...
        cell.timeLabel.layer.cornerRadius = 20.0
        cell.timeLabel.layer.borderWidth = 1.0
        cell.timeLabel.layer.backgroundColor = UIColor.orange.cgColor
        cell.timeLabel?.text =
    bookFilm[indexPath.section].getTimes()[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
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
        
        let BSeat = storyboard?.instantiateViewController(withIdentifier: "BSEAT") as! SeatCollectionViewController
       // BSeat.Seat = bookFilm[indexPath.section].getSeats()[indexPath.row]
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
        if Auth.auth().currentUser?.uid == nil {
            print("==nil")
            let Login = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            navigationController?.pushViewController(Login, animated: true)
        }
        else {
            navigationController?.pushViewController(BSeat, animated: true)
        }
    }
    
}
