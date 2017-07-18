    //
    //  Data.swift
    //  CINEMA iOS
    //
    //  Created by healer on 6/1/17.
    //  Copyright © 2017 healer. All rights reserved.
    //
    
    import Foundation
    import UIKit
    import FirebaseDatabase   //Firebase library
    
    // Support get data from firebase
    // MARK: - DataFilm
    class DataFilm{
        // MARK: Internal
        
        var ref: DatabaseReference!
        var refHandler: DatabaseHandle!
        final let DATE_FORMAT: String = "dd/MM/yyy"
        final let TRAILER_FIRST: Int = 0
        var typeFilm : String?
        var idFilm: String
        
        init() {
            
            ref = Database.database().reference()
            idFilm = ""
            
        }
        
        // Get data from Url Api and Set data into FireBase by page and film type
        // MARK: Private
        private func reloadFilmFromUrlApi(page : Int, filmType: String) {
            
            let Session = URLSession.shared
            var dataTask: URLSessionDataTask?
            
            //  if the data task is already initialized. you cancel this task
            typeFilm = filmType
            if dataTask != nil {
                dataTask?.cancel()
            }
            
            // You enable the network activity indicator on the status bar to indicate to the user that a network process is running.
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let url = URL(string: "\(urlFilm)\(filmType)?api_key=\(Api)\(language)=\(page)")
            let request = NSMutableURLRequest(url: url! as URL)
            
            dataTask = Session.dataTask(with: request as URLRequest) {
                data, response, error in
                DispatchQueue.main.async() {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                if let error = error {
                    print(error.localizedDescription)
                }
                else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if data?.count != 0 {
                            self.saveDataIntoFireBase(data: data!)
                        }
                    }
                }
            }
            dataTask?.resume()
        }
        
        // This helper method helps parse response JSON NSData into an array of Track objects.
        // MARK: Private
        private func saveDataIntoFireBase(data: Data?) {
            do {
                if let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions (rawValue: 0)) as? [String: AnyObject] {
                    
                    // Get the results array
                    if let array: AnyObject = response["results"] {
                        for filmDictonary in array as! [AnyObject] {
                            if let filmDictonary = filmDictonary as? [String: AnyObject] {
                                // Parse the search result
                                let id = filmDictonary["id"] as! Int	
                                getTrailer(id: id)
                            }
                            else {
                                print("Not a dictionary")
                            }
                        }
                    }
                    else {
                        print("Results key not found in dictionary")
                    }
                }
            } catch let error as NSError {
                print("Error parsing results: \(error.localizedDescription)")
            }
        }
        
        // get Detail film by idfilm and passed into trailer parameter
        // MARK: Private
        func getMovieDetail(idFilm: String?, trailer: [String]) {
            
            if let movieId = idFilm {
                let url = NSURL(string: "\(urlFilm)\(movieId)?api_key=\(Api)\(language)")
                var detail = [String:Any]()
                let request = NSMutableURLRequest(url: url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5) // after 5 seconds request timeout
                request.httpMethod = "GET"
                _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (Data, URLResponse, Error) in
                    if Error != nil {
                        print(Error!)
                    }
                    else {
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
        
        // Get trailer film by id film
        // MARK: Private
        private func getTrailer(id: Int?){
            
            var trailer = [String]()
            if let movieId = id {
                let url = NSURL(string: "\(urlFilm)\(movieId)/videos?api_key=\(Api)\(language)")
                var trailers = [String:Any]()
                let request = NSMutableURLRequest(url: url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
                request.httpMethod = "GET"
                _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (Data, URLResponse, Error) in
                    if (Error != nil) {
                        print(Error!)
                    }
                    else {
                        do {
                           trailers = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String:Any]
                            let results = trailers["results"] as? [[String: Any]]
                            DispatchQueue.main.async {
                                for i in results!{
                                    let t = i["key"] as? String
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
        // MARK: Private
        func checkFilmHadBook(idFilmCurrent: Int, completionHandler: @escaping (_ flag: Bool?, _ error: Error?) -> Void){
            
            var flag: Bool = false
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATE_FORMAT
            let today = formatter.date(from: formatter.string(from: date))
            refHandler = ref.child("bookfilm").observe(.childAdded, with:{ (snapshot) in
                
                // Get id film
                let idFilm = Int(snapshot.key)
                if idFilm == idFilmCurrent {
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
                else {
                    return
                }
                completionHandler(flag,nil)
            }, withCancel: nil)
        
        }

        //Get list film from firebase passed into type film parameter
        // MARK: Private
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
                    let trailer = dictionary["trailers"]?[self.TRAILER_FIRST] as? String
                    if typeFilm != "" && typeFilm == type {
                        let F: Film = Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!)
                        F.setTrailers(trailer: trailer!)
                        listFilm.append(F)
                    }
                    completionHandler(listFilm, nil)
                }
            }, withCancel: nil)
            
        }
        
        // get book from Firebase by idFilm
        // MARK: Private
        func getBookFilmFireBase(idFilmCurrent: Int, completionHandler: @escaping (_ bookFilms: [Book]?, _ error: Error?) -> Void){
            
            var listBook = [Book]()
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATE_FORMAT
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
                            if day == today || day == tomorrow || day == nextTomorrow {
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
                else {
                    return
                }
                completionHandler(listBook,nil)
            }, withCancel: nil)
        }
        
        // get Book film today
        // MARK: Private
        func getBookFilmToday(completionHandler: @escaping (_ Films: [Film]?, _ error: Error?) -> Void){
            
            var listFilm = [Film]()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATE_FORMAT
            let today1 = formatter.string(from: date)
            let today = formatter.date(from: today1)
            ref.child("bookfilm").observe(.childAdded, with: { (snapshot) in
                let filmId = Int(snapshot.key)
                if let dictionary1 = snapshot.value as? [String: AnyObject]{
                    if filmId != nil {
                        self.ref.child("films").observe(.childAdded, with: { (snapshot1) in
                            let days = dictionary1["day"] as? [Dictionary<String,Any>]
                            if Int(snapshot1.key) == filmId {
                                for d in days!{
                                    let day1 = d["day"] as? String
                                    let day = formatter.date(from: day1!)
                                    if day == today {
                                        if let dictionary = snapshot1.value as? [String: AnyObject]{
                                            let id = dictionary["idFilm"] as? Int
                                            let overview = dictionary["overview"] as? String
                                            let poster_path = dictionary["poster_path"] as? String
                                            let release_date = dictionary["release_date"] as? String
                                            let title = dictionary["title"] as? String
                                            let runtime = dictionary["runtime"] as? Int
                                            let genres = dictionary["genres"] as? [Dictionary<String,Any>]
                                            let trailer = dictionary["trailers"]?[self.TRAILER_FIRST] as? String
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
