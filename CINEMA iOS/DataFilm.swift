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
                                //getMovieDetail(idFilm: String(id))
                                getTrailer(id: id)
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
        
        
        func getMovieDetail(idFilm: String?, trailer: [String]) {
            if let movieId = idFilm {
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
                                //print(trailer!)
                                if((trailer.count)>0){
                                self.ref.child("films").child(String(describing: id!)).setValue(["idFilm":  id!,"title": title!,"poster_path": posterPath!,"overview": overview!,"release_date": release_date!,"type": self.typeFilm!,"runtime":  runtime!,"genres": genres!, "trailers": trailer])
                                }
                                
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }).resume()
            }
        }
        
        func getTrailer(id: Int?){
            var trailer = [String]()
            if let movieId = id {
                let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(Api)&language=en-US")
                
                var trailers = [String:Any]()
                let request = NSMutableURLRequest(url: url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
                request.httpMethod = "GET"
                _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (Data, URLResponse, Error) in
                    if (Error != nil) {
                        print(Error!)
                    } else {
                        do {
                           trailers = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String:Any]
                            let results = trailers["results"] as? [[String: Any]]
                            
                            //print(results!)
                            DispatchQueue.main.async {
                                
                                for i in results!{
                                    //print("\(i)\n vinh")
                                    
                                    let t = i["key"] as? String
                                    
                                    //print("\(t!)\n vinh1")
                                    
                                    trailer.append(t!)
                                }
                                self.getMovieDetail(idFilm: String(id!), trailer: trailer)
     
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }).resume()
            }
        }
        
        // check film had book by id
        func checkFilmHadBook(idFilmCurrent: Int, completionHandler: @escaping (_ flag: Bool?, _ error: Error?) -> Void){
            var flag: Bool = false
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyy"
            let today = formatter.date(from: formatter.string(from: date))
            refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
                // Get id film
                let idFilm = Int(snapshot.key)
                if idFilm == idFilmCurrent{
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let days = dictionary["day"] as? [Dictionary<String,Any>]
                        for d in days!{
                            let day = d["day"] as? String
                             let day1 = formatter.date(from: day!)
                            if (day1 == today! || day1! > today!) {
                                flag = true
                            }
                        }
                    }
                    
                }
                else{
                    return
                }
                completionHandler(flag,nil)
                
                
            }, withCancel: nil)
        }

        
        //Get list film from firebase
        func getDataFilmFireBase(type: String, completionHandler: @escaping (_ films: [Film]?, _ error: Error?) -> Void){
            var listFilm = [Film]()
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("films").observe(.childAdded, with:{ (snapshot) in
                // Get user value
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let id = dictionary["idFilm"] as? Int
                    let typeFilm = dictionary["type"] as? String
                    let overview = dictionary["overview"] as? String
                    let poster_path = dictionary["poster_path"] as? String
                    let release_date = dictionary["release_date"] as? String
                
                    let title = dictionary["title"] as? String
                    let runtime = dictionary["runtime"] as? Int
                    let genres = dictionary["genres"] as? [Dictionary<String,Any>]
                    let trailer = dictionary["trailers"]?[0] as? String
        
                    if(typeFilm != "" && typeFilm == type){
                        let F: Film = Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!)
                        F.setTrailers(trailer: trailer!)
                        listFilm.append(F)
                    }
                    completionHandler(listFilm, nil)
                }
                
                
            }, withCancel: nil)
            
        }
        
        // get book from Firebase by idFilm
        func getBookFilmFireBase(idFilmCurrent: Int, completionHandler: @escaping (_ bookFilms: [Book]?, _ error: Error?) -> Void){
            var listBook = [Book]()
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyy"
            
            let tomorrowDay = Calendar.current.date(byAdding: .day, value: 1, to: date)
            let nextTomorrowDay = Calendar.current.date(byAdding: .day, value: 2, to: date)
            
            let today = formatter.string(from: date)
            let tomorrow = formatter.string(from: tomorrowDay!)
            let nextTomorrow = formatter.string(from: nextTomorrowDay!)
            
            refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
                // Get id film
                let idFilm = Int(snapshot.key)
                if idFilm == idFilmCurrent{
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let days = dictionary["day"] as? [Dictionary<String,Any>]
                        for d in days!{
                            let day = d["day"] as? String
                            
                            if (day == today || day == tomorrow || day == nextTomorrow) {
                                var Times = [String]()
                                var Rooms = [Int]()
                                var Seats = [String]()
                                let times = (d["times"] as? [Dictionary<String,Any>])!
                                
                                for t in times{
                                    let time = t["time"] as? String
                                    let seat = t["seats"] as? String
                                    let room = t["room"] as? Int
                                    Times.append(time!)
                                    Seats.append(seat!)
                                    Rooms.append(room!)
                                    
                                }
                                
                                listBook.append(Book(id: idFilm!, day: day!, rooms: Rooms, times: Times, seats: Seats))
                                
                            }
                        }
                    }
                    
                }
                else{
                    return
                }
                completionHandler(listBook,nil)
                
                
            }, withCancel: nil)
            
        }
        
        // get Book film today
        
        func getBookFilmToday(completionHandler: @escaping (_ Films: [Film]?, _ error: Error?) -> Void){
            var listFilm = [Film]()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let today = formatter.string(from: date)
            
            ref.child("bookfilm").observe(.childAdded, with: { (snapshot) in
                
                let filmId = Int(snapshot.key)
                if let dictionary1 = snapshot.value as? [String: AnyObject]{
                    if (filmId != nil) {
                        self.ref.child("films").observe(.childAdded, with: { (snapshot1) in
                            let days = dictionary1["day"] as? [Dictionary<String,Any>]
                            if Int(snapshot1.key) == filmId {
                                //var room: Int?
                                for d in days!{
                                    let day = d["day"] as? String
                                    if day == today {
                                        
                                        if let dictionary = snapshot1.value as? [String: AnyObject]{
                                            
                                            let id = dictionary["idFilm"] as? Int
                                            let overview = dictionary["overview"] as? String
                                            let poster_path = dictionary["poster_path"] as? String
                                            let release_date = dictionary["release_date"] as? String
                                            let title = dictionary["title"] as? String
                                            let runtime = dictionary["runtime"] as? Int
                                            let genres = dictionary["genres"] as? [Dictionary<String,Any>]
                                            let trailer = dictionary["trailers"]?[0] as? String
                                            let F: Film = Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!)
                                            F.setTrailers(trailer: trailer!)
                                            listFilm.append(F)
                                        }
                                        
                                    }
                                    
                                }
                            }
                            completionHandler(listFilm,nil)
                        }, withCancel: nil)
                    }
                }
            }, withCancel: nil)

            
            
        }


    }
