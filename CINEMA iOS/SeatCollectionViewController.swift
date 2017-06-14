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
    var userSeat = [String]()
    var idFilm : Int?
    var idDay: Int?
    var idTime: Int?
    
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
        
        cell.numberOfSeat.text = "0" + String(indexPath.row + 1)
        
        let c = Int(Seats[indexPath.row])
        
        if c == 0 {
            cell.backgroundColor = UIColor.green
        }
        else{
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
        let c = Int(Seats[indexPath.row])
        collectionView.allowsSelection = false
        if(c == 0){
            selectedCell.contentView.backgroundColor = UIColor.red
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            Seats[indexPath.row] = String(indexPath.row +  1)
            //userSeat[indexPath.row] = String(1)
        }
        else{
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            selectedCell.contentView.backgroundColor = UIColor.green
            Seats[indexPath.row] = String(0)
            //userSeat[indexPath.row] = String(0)
        }
        
        
    }
    @IBAction func saveSeat(_ sender: Any) {
        let seatString = Seats.joined(separator: "_")
        ref = Database.database().reference()
        let idRef = ref.child("bookfilm").child(String(idFilm!)).child("day").child(String(idDay!)).child("times").child(String(idTime!))
        idRef.updateChildValues(["seats": seatString])
        print(seatString)
    }
    
    
}
