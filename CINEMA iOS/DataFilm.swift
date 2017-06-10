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
        var Api: String = "24b1973f805d7f765ee59e3481812a29"
        var typeFilm : String?
        
        var idFilm: String
        
        
        
        init() {
            ref = Database.database().reference()
            idFilm = ""
        }
        // Get data from Url Api and Set data into FireBase
        func reloadFilmFromUrlApi(page : Int, filmType: String) {
            
            let Session = URLSession.shared
            var dataTask: URLSessionDataTask?
            
            //  if the data task is already initialized. you cancel this task
            typeFilm = filmType
            if dataTask != nil {
                dataTask?.cancel()
            }
            // You enable the network activity indicator on the status bar to indicate to the user that a network process is running.
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let url = URL(string: "https://api.themoviedb.org/3/movie/\(filmType)?api_key=\(Api)&language=en-US&page=\(page)")
            print(url!)
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
            dataTask?.resume()
        }
        
        // This helper method helps parse response JSON NSData into an array of Track objects.
        private func saveDataIntoFireBase(data: Data?) {
            do {
                if let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions (rawValue: 0)) as? [String: AnyObject] {
                    
                    // Get the results array
                    if let array: AnyObject = response["results"] {
                        for filmDictonary in array as! [AnyObject] {
                            if let filmDictonary = filmDictonary as? [String: AnyObject]{
                                // Parse the search resu
                                let id = filmDictonary["id"] as! Int
                                getMovieDetail(id: String(id))
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
                /*
                 let room = Int(arc4random_uniform(UInt32(self.Room.count)))
                 let day = Int(arc4random_uniform(UInt32(self.Days.count)))
                 let time = Int(arc4random_uniform(UInt32(self.Time.count)))
                 
                 let idFilm = snapshot.key
                 */
                //self.ref.child("books").child(str).setValue(["idFilm": idFilm,"rooms": Room[room],"days":Days[day],"times": Time[time],"seats": self.Seats])
                str = "BF"
            })
            
        }
        
        func getMovieDetail(id: String?) {
            if let movieId = id {
                let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(Api)&language=en-US")
                
                var detail = [String:Any]()
                let request = NSMutableURLRequest(url: url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
                request.httpMethod = "GET"
                _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (Data, URLResponse, Error) in
                    if (Error != nil) {
                        print(Error!)
                    } else {
                        do {
                            detail = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String:Any]
                            DispatchQueue.main.async {
                                
                                let genres = detail["genres"] as? [Dictionary<String,Any>]
                                let posterPath = detail["poster_path"] as? String
                                let overview = detail["overview"] as? String
                                let title = detail["title"] as? String
                                let release_date = detail["release_date"] as? String
                                let id = detail["id"] as? Int
                                let runtime = detail["runtime"] as? Int
                                self.ref.child("films5").child(String(describing: id!)).setValue(["idFilm":  id!,"title": title!,"poster_path": posterPath!,"overview": overview!,"release_date": release_date!,"type": self.typeFilm!,"runtime":  runtime!,"genres": genres!])
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }).resume()
            }
        }
    }
