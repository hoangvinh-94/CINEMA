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
    
    var Day = [String]()
    var Time = [String]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
            // Get user value
            self.Day.append(String(describing: snapshot))
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if let room1s = dictionary["room1"] as? [String: AnyObject]{
                    //let idFilm = room1s["film"] as? Int
                    if let time1s = room1s["time1"] as? [String: AnyObject]{
                        self.Time.append((time1s["id"] as? String)!)
                    }
                    if let time2s = room1s["time2"] as? [String: AnyObject]{
                        //let time1 = time1s["id"] as? String
                        self.Time.append((time2s["id"] as? String)!)
                    }
                    
                    if let time3s = room1s["time3"] as? [String: AnyObject]{
                        self.Time.append((time3s["id"] as? String)!)
                    }
                    
                }
                if let room2s = dictionary["room2"] as? [String: AnyObject]{
                    //let idFilm = room2s["film"] as? Int
                    if let time1s = room2s["time1"] as? [String: AnyObject]{
                        self.Time.append((time1s["id"] as? String)!)
                    }
                    if let time2s = room2s["time2"] as? [String: AnyObject]{
                        //let time1 = time1s["id"] as? String
                        self.Time.append((time2s["id"] as? String)!)
                    }
                    
                    if let time3s = room2s["time3"] as? [String: AnyObject]{
                        self.Time.append((time3s["id"] as? String)!)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
                
                
            }
            
            
        })
        
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Day.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Time.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookFilmCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = Time[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Day[section]
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
