//
//  TicketInformationTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/16/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// display tickets information
// MARK: - TicketInformationTableViewController
class TicketInformationTableViewController: UITableViewController {
    
    // MARK: Internal
    
    // MARK: Declare variables
    final let IDENTIFIER_HOMEVIEWCONTROLLER: String = "HomeViewController"
    final let IDENTIFIER_TICKETCELL: String = "TicketCell"
    final let NUMBERSECTION_RETURNED: Int = 1
    final let BORDER_WIDTH_CELL: Float = 1.0
    final let CORNER_RADIUS_CELL: Float = 5.0
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
    
    // MARK: UITableViewController
    
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
    }

    // payment button pressed
    func paymentAction() {

        let alertController = UIAlertController(title: "Confirm payment!", message: "By click ok, you accept the cinema ticket license and pay your tickets!", preferredStyle: .alert)
        
        // add the actions (buttons)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            self.tableIndicator.startAnimating()
            let uid = Auth.auth().currentUser?.uid
            let seatString = self.Seats.joined(separator: "_")
            if seatString != self.Seat {
                let filter = self.Seats.filter{!self.userSeat.contains($0)}
                for i in filter{
                    self.ref.child("tickets").childByAutoId().setValue(["idFilm": self.idFilm!, "titleFilm": self.titleFilm!, "day": self.day!, "time": self.time!, "room": self.room!, "seat": i, "idUser": uid!])
                    
                }
                let bookRef = self.ref.child("bookfilm").child(String(self.idFilm!)).child("day").child(String(self.idDay!)).child("times").child(String(self.idTime!))
                bookRef.updateChildValues(["seats": seatString])
                self.tableIndicator.stopAnimating()
                //Tells the user that there is an error and then gets firebase to tell them the error
            }
            let alert = UIAlertController(title: "Succesful", message: "Pay succesful! Thank you!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                let homeView = self.storyboard?.instantiateViewController(withIdentifier: self.IDENTIFIER_HOMEVIEWCONTROLLER) as! HomeViewController
                self.navigationController?.pushViewController(homeView, animated: true)
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return NUMBERSECTION_RETURNED
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        return (tickets?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_TICKETCELL, for: indexPath) as! TicketInformationTableViewCell
        cell.titleFilm.text = tickets?[indexPath.row].getTitleFilm()
        cell.day.text = tickets?[indexPath.row].getDay()
        cell.time.text = tickets?[indexPath.row].getTime()
        cell.seat.text = String((tickets?[indexPath.row].getSeat())!)
        cell.room.text = String((tickets?[indexPath.row].getRoom())!)
        
        // add border and color
        cell.backgroundColor = UIColor.yellow
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = CGFloat(BORDER_WIDTH_CELL)
        cell.layer.cornerRadius = CGFloat(CORNER_RADIUS_CELL)
        cell.clipsToBounds = true
        return cell
    }
}
