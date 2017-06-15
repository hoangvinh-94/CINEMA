//
//  ScheduleViewController.swift
//  CINEMA iOS
//
//  Created by TTB on 6/14/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    var prefixImgSlideshow: String = "https://image.tmdb.org/t/p/w1400_and_h450_bestv2"
    var queue = OperationQueue()
    
    @IBOutlet var tableView: UITableView!
    
    
    
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadDataToTableView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadDataToTableView(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyy"
        let today = formatter.string(from: date)
        
        self.Films = [Film]()
        queue.cancelAllOperations()
        
        ref.child("bookfilm").observe(.childAdded, with: { (snapshot) in
            
        let filmId = Int(snapshot.key)
            print("key book: \(filmId)")
            if let dictionary1 = snapshot.value as? [String: AnyObject]{
                if (filmId != nil) {
                    self.ref.child("films5").observe(.childAdded, with: { (snapshot1) in
                        let days = dictionary1["day"] as? [Dictionary<String,Any>]
                        if Int(snapshot1.key) == filmId {
                            print("key films5: \(snapshot1.key)")
                            //var room: Int?
                            
                            for d in days!{
                                let day = d["day"] as? String
                                print("Ngay \(day)")
                                if day == "09/06/2017" {
                                    print(" Bang")
                                    if let dictionary = snapshot1.value as? [String: AnyObject]{
                                        
                                        let id = dictionary["idFilm"] as? Int
                                        let overview = dictionary["overview"] as? String
                                        let poster_path = dictionary["poster_path"] as? String
                                        let release_date = dictionary["release_date"] as? String
                                        let title = dictionary["title"] as? String
                                        let runtime = dictionary["runtime"] as? Int
                                        let genres = dictionary["genres"] as? [Dictionary<String,Any>]
                                        
                        
                                        self.Films.append(Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!))
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                                self.tableView.setContentOffset(CGPoint.zero, animated: false)
                                            }
                                       
                                        
                                    }

                                }
                                else {
                                    print("KHong Bang")
                                }
                            }
                            
                            
                        }
                    })
                }
            }
        })
        
        
        
        
        
        
        
        
        
//        self.Films = [Film]()
//        queue.cancelAllOperations()
//        refHandler = ref.child("films5").observe(.childAdded, with:{ (snapshot) in
//            // Get user value
//            if let dictionary = snapshot.value as? [String: AnyObject]{
//                
//                let id = dictionary["idFilm"] as? Int
//                let typeFilm = dictionary["type"] as? String
//                let overview = dictionary["overview"] as? String
//                let poster_path = dictionary["poster_path"] as? String
//                let release_date = dictionary["release_date"] as? String
//                let title = dictionary["title"] as? String
//                let runtime = dictionary["runtime"] as? Int
//                let genres = dictionary["genres"] as? [Dictionary<String,Any>]
//                
//                if(typeFilm != "" && typeFilm == type){
//                    self.Films.append(Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!))
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
//                    }
//                }else{
//                    return
//                }
//                
//            }
//            
//            
//        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Films.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell
        var film: Film
       
        film = Films[indexPath.row]
        
        
        queue.addOperation { () -> Void in
            if film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(self.prefixImg)\(film.getPoster())") {
                    OperationQueue.main.addOperation({
                        cell.posterImage.image = img
                        cell.titleLabel.text = film.getTitle()
                        cell.timeLabel.text = String(film.getRuntime()) + " minutes"
                        let count = film.getGenres().count
                        var c = 0
                        for genre in film.getGenres(){
                            c = c + 1
                            if c < count {
                                let g = genre["name"] as? String
                                cell.genreLabel.text = cell.genreLabel.text! + String(g! + ", ")
                            }
                            else{
                                let g = genre["name"] as? String
                                cell.genreLabel.text = cell.genreLabel.text! + String(g!)
                                
                            }
                            
                        }
                    })
                }
            }
        }
        return cell

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ScheduleDetail"){
            if let index = self.tableView.indexPathForSelectedRow{
                let filmDetail = segue.destination as! DetailViewController
                
                filmDetail.film = Films[index.row]
                
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
