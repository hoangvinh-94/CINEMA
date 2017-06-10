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
    var refHandler: UInt!
    var Seats = [String: [Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
            // Get user value
            /*
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if let room1s = dictionary["room1"] as? [String: AnyObject]{
                    let idFilm = room1s["film"] as? Int
                    if let time1s = room1s["time1"] as? [String: AnyObject]{
                        let a = time1s["seat"] as? String
                        let A = (a?.components(separatedBy: "_"))!
                    }
                    if let time2s = room1s["time2"] as? [String: AnyObject]{
                        //let time1 = time1s["id"] as? String
                        self.Seats = time1s["seat"] as? String
                    }
                    
                    if let time3s = room1s["time3"] as? [String: AnyObject]{
                        self.Seats = time1s["seat"] as? String
                    }
                    
                }
                if let room2s = dictionary["room2"] as? [String: AnyObject]{
                    let idFilm = room2s["film"] as? Int
                    if let time1s = room2s["time1"] as? [String: AnyObject]{
                        self.Seats = time1s["seat"] as? String
                    }
                    if let time2s = room2s["time2"] as? [String: AnyObject]{
                        //let time1 = time1s["id"] as? String
                        self.Seats = time1s["seat"] as? String
                    }
                    
                    if let time3s = room2s["time3"] as? [String: AnyObject]{
                        self.Seats = time1s["seat"] as? String
                    }
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
                
 
            }
            */
            
        })
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 25
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SeatCell", for: indexPath) as! SeatCollectionViewCell
        var i = 1
        while i <= 25 {
            cell.numberOfSeat.text = "0"+String(indexPath.row + 1)
            i = i + 1
        }
        
        // Configure the cell
        
        return cell
    }
    
    
}
