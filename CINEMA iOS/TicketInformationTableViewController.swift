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
    var ref: DatabaseReference!
    @IBOutlet weak var paymentBarButton: UIBarButtonItem!
    var tickets: [Ticket]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentBarButton.title = "Payment"
        paymentBarButton.action = #selector(paymentAction)
        
        
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
        let alertController = UIAlertController(title: "Confirm payment!", message: "By click ok, you accept the cinema ticket license and pay your tickets!", preferredStyle: .alert)
        
        // add the actions (buttons)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            
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
        return cell
    }
    
}
