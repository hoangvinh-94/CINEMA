//
//  TicketInformationTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/16/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class TicketInformationTableViewController: UITableViewController {
    
    @IBOutlet weak var paymentBarButton: UIBarButtonItem!
    
    var tickets: [Ticket]?
    
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
    
    @IBAction func ckickpay(_ sender: UIBarButtonItem) {
        paymentAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.paymentBarButton.title = "Payment"
        self.paymentBarButton.image = nil
        self.paymentBarButton.action = #selector(self.paymentAction)
        
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        
        tableView.backgroundView = tableIndicator
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        
        //ref = Database.database().reference()
        //let uid = Auth.auth().currentUser?.uid
        //loadTicket(id: uid!)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    /*
    func loadTicket(id : String){
        ref.child("tickets").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let idUser = dictionary["idUser"] as? String
                if idUser! == id {
                    let day = dictionary["day"] as? String
                    let time  = dictionary["time"] as? String
                    let seat = dictionary["seat"] as? Int
                    let room = dictionary["room"] as? Int
                    let titleFilm = dictionary["titleFilm"] as? String
                    self.tickets?.append(Ticket(titleFilm: titleFilm!, day: day!, time: time!, seat: seat!, room: room!)
                }
            
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
            
        })
        
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func paymentAction() {
        print("payment")
        let alertController = UIAlertController(title: "Confirm payment!", message: "By click ok, you accept the cinema ticket license and pay your tickets!", preferredStyle: .alert)
        
        // add the actions (buttons)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            self.tableIndicator.startAnimating()
            let uid = Auth.auth().currentUser?.uid
            
            let seatString = self.Seats.joined(separator: "_")
            
            if(seatString != self.Seat){
                let filter = self.Seats.filter{!self.userSeat.contains($0)}
                
                for i in filter{
                    self.ref.child("tickets").childByAutoId().setValue(["idFilm": self.idFilm!, "titleFilm": self.titleFilm!, "day": self.day!, "time": self.time!, "room": self.room!, "seat": i, "idUser": uid!])
                    
                }
                
                let bookRef = self.ref.child("bookfilm").child(String(self.idFilm!)).child("day").child(String(self.idDay!)).child("times").child(String(self.idTime!))
                bookRef.updateChildValues(["seats": seatString])
                self.tableIndicator.stopAnimating()
                //Tells the user that there is an error and then gets firebase to tell them the error
            }
            
            print("payment OK")
            let alert = UIAlertController(title: "Succesful", message: "Pay succesful! Thank you!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                
                let homeView = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(homeView, animated: true)
                
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (tickets?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketInformationTableViewCell
        
        cell.titleFilm.text = tickets?[indexPath.row].getTitleFilm()
        cell.day.text = tickets?[indexPath.row].getDay()
        cell.time.text = tickets?[indexPath.row].getTime()
        cell.seat.text = String((tickets?[indexPath.row].getSeat())!)
        cell.room.text = String((tickets?[indexPath.row].getRoom())!)
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        
        return cell
    }
    
}
