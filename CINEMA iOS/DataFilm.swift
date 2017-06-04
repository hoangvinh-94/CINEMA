//
//  Data.swift
//  CINEMA iOS
//
//  Created by healer on 6/1/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class DataFilm{

    
    var ref: DatabaseReference!
    var refHandler: DatabaseHandle!
    var dataTask: URLSessionDataTask?
    var Api: String = "24b1973f805d7f765ee59e3481812a29"
    var Room: Dictionary = ["R1": "Room 1","R2": "Room 2","R3": "Room 3","R4": "Room 4","R5": "Room 5","R6": "Room 6"]
    var Seats = "1_2_3_4_5"
    var Rooms : [String] = ["Room 1","Room 2","Room 3"]
    var Days: [String] = ["12-03-2017","04-06-2017"]
    var Time: [String] = ["7:00","12:30","17:00","20:30"]
    
    var Session = URLSession.shared
    var queue = OperationQueue()
   

    


    
    init() {
        ref = Database.database().reference()
    }
    // Get data from Url Api and Set data into FireBase
    func reloadFilmFromUrlApi(page : Int) {
        //  if the data task is already initialized. you cancel this task
        if dataTask != nil {
            dataTask?.cancel()
        }
        // You enable the network activity indicator on the status bar to indicate to the user that a network process is running.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(Api)&language=en-US&page=\(page)")
        let request = NSMutableURLRequest(url: url! as URL)
        
        // 5
        dataTask = Session.dataTask(with: request as URLRequest) {
            data, response, error in
            // 6
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            // 7
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    //self.updateSearchResults(data)
                    if(data?.count != 0){
                        //let responseJSON = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        self.saveDataIntoFireBase(data: data!)
                    }
                }
            }
        }
        // 8
        self.dataTask?.resume()
    }
    
    // This helper method helps parse response JSON NSData into an array of Track objects.
    private func saveDataIntoFireBase(data: Data?) {
        do {
            if let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions (rawValue: 0)) as? [String: AnyObject] {
                
                // Get the results array
                if let array: AnyObject = response["results"] {
                    for filmDictonary in array as! [AnyObject] {
                        if let filmDictonary = filmDictonary as? [String: AnyObject]{
                            // Parse the search result
                            let posterPath = filmDictonary["poster_path"] as? String
                            let overview = filmDictonary["overview"] as? String
                            let title = filmDictonary["title"] as? String
                            let release_date = filmDictonary["release_date"] as? String
                            let id = filmDictonary["id"] as! Int
                            //let genres = filmDictonary["genre_ids"] as? [Int]
                            // add data to FireBase
                            self.ref.child("films").child(String(describing: id)).setValue(["title": title!,"poster_path": posterPath!,"overview": overview!,"release_date": release_date!])
                            
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
    }
    
    func createDataBookFilm(){
        var str = "BF"
        var count = 0
    
        refHandler = ref.child("films").observe(.childAdded, with:{ (snapshot) in
            count += 1
            str += String(count)
            let room = Int(arc4random_uniform(UInt32(self.Room.count)))
            let day = Int(arc4random_uniform(UInt32(self.Days.count)))
            let time = Int(arc4random_uniform(UInt32(self.Time.count)))

            let idFilm = snapshot.key
            //self.ref.child("books").child(str).setValue(["idFilm": idFilm,"rooms": Room[room],"days":Days[day],"times": Time[time],"seats": self.Seats])
            str = "BF"
        })
        
    }
    
    /*func getDataFromFireBase(tableView: UITableView, Films: [Film]){
            refHandler = ref.child("films").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let overview = dictionary["overview"] as? String
                let poster_path = dictionary["poster_path"] as? String
                let release_date = dictionary["release_date"] as? String
                let title = dictionary["title"] as? String
                Films.append(Film(title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!))
                tableView.reloadData()
            }
            
        })
        
    }*/


}
