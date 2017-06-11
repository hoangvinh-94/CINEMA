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
    var Seats = [String]()
    var Seat : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Seat!)
        Seats = (Seat?.components(separatedBy: "_"))!
        collectionView?.reloadData()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return Seats.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SeatCell", for: indexPath) as! SeatCollectionViewCell
        let c = Int(Seats[indexPath.row])
        
        if c == 0 {
            cell.backgroundColor = UIColor.green
        }
        else{
            cell.backgroundColor = UIColor.red
        }
        
        var i = 1
        while i <= Seats.count {
            cell.numberOfSeat.text = "0"+String(indexPath.row + 1)
            i = i + 1
        }
        
        // Configure the cell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         var selectedCell: UICollectionViewCell!
        selectedCell = collectionView.cellForItem(at: indexPath)!
        let c = Int(Seats[indexPath.row])
        collectionView.allowsSelection = false
        if(c == 0){
            selectedCell.contentView.backgroundColor = UIColor.red
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            Seats[indexPath.row] = String(1)
        }
        else{
            selectedCell.contentView.backgroundColor = UIColor.green
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            Seats[indexPath.row] = String(0)
        }
        
        
    }
    
    
}
