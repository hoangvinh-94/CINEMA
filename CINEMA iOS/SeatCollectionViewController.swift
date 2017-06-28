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


class SeatCollectionViewController: UICollectionViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool)
        {
            
    }
    
    func loadSeat(){
        
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
            if !self.Seats.contains("0") {
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
//                self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
            }
            
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
        print("\(seats)\n")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SeatCell", for: indexPath) as! SeatCollectionViewCell
        
        cell.numberOfSeat.text = "0" + String(indexPath.row + 1)
        
        if (Seats[indexPath.row] == "0") {
            cell.backgroundColor = UIColor.green
        }
        else {
            cell.backgroundColor = UIColor.red
            cell.isUserInteractionEnabled = false
        }
        
        // Configure the cell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SeatReusable", for: indexPath)

        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         var selectedCell: UICollectionViewCell!
        selectedCell = collectionView.cellForItem(at: indexPath)!
        collectionView.allowsSelection = false
        print("Set color")
        
        if(Seats[indexPath.row] == "0"){
            selectedCell.backgroundColor = UIColor.yellow
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            Seats[indexPath.row] = String(indexPath.row +  1)
        }
            
        else{
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            selectedCell.backgroundColor = UIColor.green
            Seats[indexPath.row] = String(0)
        }
        
        
        
        
    }
    @IBAction func saveSeat(_ sender: Any) {
    
        let seatString = self.Seats.joined(separator: "_")
        
        if(seatString != self.Seat){
            let alert = UIAlertController(title: "Succesful", message: "View Ticket information?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                
                var tickets = [Ticket]()
                
                let filter = self.Seats.filter{!self.userSeat.contains($0)}
                
                for i in filter{
                    let t = Ticket(titleFilm: self.titleFilm!, day: self.day!, time: self.time!, seat: i, room: self.room!)
                    tickets.append(t)
                }
                
                let infTicket = self.storyboard?.instantiateViewController(withIdentifier: "TicketInformation") as! TicketInformationTableViewController
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
