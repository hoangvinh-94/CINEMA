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
    
   
    var ref: DatabaseReference!
    var refHandler: UInt!
    var idFilmCurrent: Int?
    var titleFilm: String?
    var bookFilm = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadBookFilm()
        
    }
    
    func loadBookFilm(){
        refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
            // Get id film
            let idFilm = Int(snapshot.key)
            if idFilm == self.idFilmCurrent{
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let days = dictionary["day"] as? [Dictionary<String,Any>]
                    //var room: Int?
                    
                    for d in days!{
                        let day = d["day"] as? String
                        var Times = [String]()
                        var Rooms = [Int]()
                        var Seats = [String]()
                        let times = (d["times"] as? [Dictionary<String,Any>])!
                        
                        for t in times{
                            let time = t["time"] as? String
                            let seat = t["seats"] as? String
                            let room = t["room"] as? Int
                            Times.append(time!)
                            Seats.append(seat!)
                            Rooms.append(room!)
                            
                        }
                        
                        self.bookFilm.append(Book(id: idFilm!, day: day!, rooms: Rooms, times: Times, seats: Seats))
                        
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                }
                
            }
            else{
                return
            }
            
            
        })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookFilmCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = bookFilm[indexPath.section].getTimes()[indexPath.row]
        return cell
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
        BSeat.idDay = idDay
        BSeat.idTime = idTime
        if Auth.auth().currentUser?.uid == nil {
            print("==nil")
            let Login = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            navigationController?.pushViewController(Login, animated: true)
        }
        else {
            print("!=nil \(String(describing: Auth.auth().currentUser?.uid))")
            navigationController?.pushViewController(BSeat, animated: true)
        }
    }
    
}
