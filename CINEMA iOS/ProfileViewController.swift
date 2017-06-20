//
//  ProfileViewController.swift
//  CINEMA iOS
//
//  Created by TTB on 6/20/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var myOrdersTableView: UITableView!
    
    // MARK: - Variables
    
    var tickets = [Ticket]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.myOrdersTableView.separatorColor = UIColor.red
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfor()
        loadDataToTableView()
    }
    
    // MARK: - LoadData
    
    //Load user infor
    func loadUserInfor() {
        if let uid = Auth.auth().currentUser?.uid {
            refHandler = ref.child("users").child(uid).observe(.value, with:{ (snapshot) in
                if let userInforDic = snapshot.value as? [String: AnyObject] {
                    let userName = userInforDic["userName"] as! String
                    let email = userInforDic["email"] as! String
                    self.userNameLabel.text = userName
                    self.emailLabel.text = email
                }
            })
        }
    }
    
    //Load the tickets current user have ordered
    
    func loadDataToTableView(){
        
        self.tickets = [Ticket]()
        let uid = Auth.auth().currentUser?.uid
        
        refHandler = ref.child("tickets").observe(.childAdded, with:{ (snapshot) in
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let idUser = dictionary["idUser"] as? String
                if (idUser == uid) {
                    let title = dictionary["titleFilm"] as? String
                    print("title \(String(describing: title))")
                    let date = dictionary["day"] as? String
                    print("title \(String(describing: date))")
                    let time = dictionary["time"] as? String
                    print("time \(String(describing: time))")
                    let room = dictionary["room"] as? Int
                    print("room \(String(describing: room))")
                    let seat = dictionary["seat"] as? String
                    print("seat \(String(describing: seat))")
                    
                    self.tickets.append(Ticket(titleFilm: title!,day: date!, time: time!, seat: seat!, room: room!))
                    DispatchQueue.main.async {
                        self.myOrdersTableView.reloadData()
                        self.myOrdersTableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    
                    
                }else {
                    return
                }
                
            }
            
            
        })
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tickets.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrder_Cell") as! MyOrderCell
        var ticket: Ticket
        
        ticket = tickets[indexPath.row]
        
        cell.dateRelease.text = ticket.getDay()
        cell.roomTicket.text = String(ticket.getRoom())
        cell.titleFilm.text = ticket.getTitleFilm()
        cell.timeTicket.text = ticket.getTime()
        cell.seatTicket.text = String(ticket.getSeat())
        
        
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
