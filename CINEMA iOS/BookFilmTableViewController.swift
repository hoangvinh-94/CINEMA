//
//  TimeFilmTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase
class BookFilmTableViewController: UITableViewController {
    
    var Days = [String]()
    var Times = [String]()
    var Rooms = [String]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var idFilmCurrent: Int?
    var bookFilm = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        refHandler = ref.child("book1").observe(.childAdded, with:{ (snapshot) in
            
            // Get id film
            let idFilm = Int(snapshot.key)
            if idFilm == self.idFilmCurrent{
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let day = dictionary["day"] as? String
                //let room = dictionary["room"] as? Int
                let seats = "1_0_1_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0"
                let times = dictionary["times"] as? [Dictionary<String,Any>]
                print(times!)
                for t in times!{
                    let time = t["time"] as? String
                    self.Times.append(time!)
                }
            
                self.Days.append(day!)
                self.bookFilm.append(Book(id: idFilm!, days: self.Days, rooms: self.Rooms, times: self.Times, seats: seats))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
            }
            else{
                return
                }
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
        return bookFilm.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookFilm[section].getTimes().count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookFilmCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = Times[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Days[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let BSeat = storyboard?.instantiateViewController(withIdentifier: "BSEAT") as! SeatCollectionViewController
        BSeat.Seat = bookFilm[indexPath.row].getSeats()
        //print(bookFilm[indexPath.row].getSeats())
        navigationController?.pushViewController(BSeat, animated: true)

    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}