//
//  Data.swift
//  CINEMA iOS
//
//  Created by healer on 6/1/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DataFilm{

    
    var ref: DatabaseReference!
    var dataTask: URLSessionDataTask?
    var Api: String = "24b1973f805d7f765ee59e3481812a29"
    var Session = URLSession.shared
    var queue = OperationQueue()
    var Films = [Film]()

    


    
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
                        self.updateSearchResults(data: data!)
                    }
                }
            }
        }
        // 8
        self.dataTask?.resume()
    }
    
    // This helper method helps parse response JSON NSData into an array of Track objects.
    private func updateSearchResults(data: Data?) {
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
    func getDataFromFireBase() -> [Film]{
            ref.child("films").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            let title = value?["title"] as? String
            let poster_path = value?["poster_path"] as? String
            let overview = value?["overview"] as? String
            let release_date = value?["release_date"] as? String
            self.Films.append(Film(title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!))

            })
            print(self.Films.count)

        return Films

    }


}
