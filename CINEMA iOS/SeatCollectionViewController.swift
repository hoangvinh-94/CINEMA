//
//  SeatCollectionViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/6/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

// Display all seats in Room
// MARK: - SeatCollectionViewController
class SeatCollectionViewController: UICollectionViewController {
    
    // MARK: Internal
    
    // MARK: Declare variables
    
    final let SEAT_EMPTY: String = "0"
    final let NUMBERSECTION_RETURNED: Int = 1
    final let IDENTIFIER_TICKETINFO: String = "TicketInformation"
    final let IDENTIFIER_SEAT_REUSABLE: String = "SeatReusable"
    final let IDENTIFIER_SEATCELL: String = "SeatCell"
    var ref: DatabaseReference!
    var Seats = [String]()
    var Seat : String?
    var userSeat = [String]()
    var idFilm : Int?
    var idDay: Int?
    var idTime: Int?
    var day: String?
    var room: Int?
    var time: String?
    var titleFilm: String?
    var tableIndicator = UIActivityIndicatorView()
    
    // MARK: UICollectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        collectionView?.backgroundView = tableIndicator
        ref = Database.database().reference()
        loadSeat()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                // Do any additional setup after loading the view.
    }
    
    // load all seat in room
    func loadSeat() {
        
        tableIndicator.startAnimating()
        let idRef1 = ref.child("bookfilm").child(String(idFilm!)).child("day").child(String(idDay!)).child("times").child(String(idTime!))
        idRef1.queryOrdered(byChild: "seats").observe(.value, with: {snapshot in
            if let s = snapshot.value! as? [String: Any] {
                let seat = s["seats"] as? String
                self.time = s["time"] as? String
                self.Seat = seat!
                self.Seats = (self.Seat?.components(separatedBy: "_"))!
                self.userSeat = (self.Seat?.components(separatedBy: "_"))!
            }
            if !self.Seats.contains(self.SEAT_EMPTY) {
                 let alert = UIAlertController(title: "Information", message: "Room is full\nplease choice others time", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                    
                   _ = self.navigationController?.popViewController(animated: true)
                }))
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            DispatchQueue.main.async {
                self.tableIndicator.stopAnimating()
                self.collectionView?.reloadData()
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return NUMBERSECTION_RETURNED
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of items
        return Seats.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var seats = ""
        for s in Seats {
            seats = seats + " " + s
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IDENTIFIER_SEATCELL, for: indexPath) as! SeatCollectionViewCell
        cell.numberOfSeat.text = "0" + String(indexPath.row + 1)
        if Seats[indexPath.row] == SEAT_EMPTY {
            cell.backgroundColor = UIColor.green
        }
        else {
            cell.backgroundColor = UIColor.red
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: IDENTIFIER_SEAT_REUSABLE, for: indexPath)
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         var selectedCell: UICollectionViewCell!
        selectedCell = collectionView.cellForItem(at: indexPath)!
        collectionView.allowsSelection = false
        if Seats[indexPath.row] == SEAT_EMPTY {
            selectedCell.backgroundColor = UIColor.yellow
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            Seats[indexPath.row] = String(indexPath.row +  1)
        }
        else {
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            selectedCell.backgroundColor = UIColor.green
            Seats[indexPath.row] = SEAT_EMPTY
        }
    }
    
    // save Seat pressed
    @IBAction func saveSeat(_ sender: Any) {
    
        let seatString = self.Seats.joined(separator: "_")
        if seatString != self.Seat {
            let alert = UIAlertController(title: "Succesful", message: "View Ticket information?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                var tickets = [Ticket]()
                // filter element not contain in Seats, but userSeat is contain
                let filter = self.Seats.filter{!self.userSeat.contains($0)}
                for i in filter{
                    let t = Ticket(titleFilm: self.titleFilm!, day: self.day!, time: self.time!, seat: i, room: self.room!)
                    tickets.append(t)
                }
                let infTicket = self.storyboard?.instantiateViewController(withIdentifier: self.IDENTIFIER_TICKETINFO) as! TicketInformationTableViewController
                infTicket.tickets = tickets
                infTicket.Seats = self.Seats
                infTicket.userSeat = self.userSeat
                infTicket.idFilm = self.idFilm
                infTicket.idDay = self.idDay
                infTicket.idTime = self.idTime
                infTicket.titleFilm = self.titleFilm
                infTicket.room = self.room
                infTicket.time = self.time
                infTicket.day = self.day
                self.navigationController?.pushViewController(infTicket, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Infor!", message: "Please choose seat!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
