//
//  ScheduleTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/15/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

class ScheduleTableViewController: UITableViewController {

    var db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    var prefixImgSlideshow: String = "https://image.tmdb.org/t/p/w1400_and_h450_bestv2"
    var queue = OperationQueue()
    
    @IBOutlet var menuMain: UIBarButtonItem!
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuMain.target = revealViewController()
        menuMain.action = #selector(SWRevealViewController.revealToggle(_:))
        ref = Database.database().reference()
        loadDataToTableView()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func loadDataToTableView(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let today = formatter.string(from: date)
        
        self.Films = [Film]()
        queue.cancelAllOperations()
        
        ref.child("bookfilm").observe(.childAdded, with: { (snapshot) in
            
            let filmId = Int(snapshot.key)
            if let dictionary1 = snapshot.value as? [String: AnyObject]{
                if (filmId != nil) {
                    self.ref.child("films5").observe(.childAdded, with: { (snapshot1) in
                        let days = dictionary1["day"] as? [Dictionary<String,Any>]
                        if Int(snapshot1.key) == filmId {
                            //var room: Int?
                            
                            for d in days!{
                                let day = d["day"] as? String
                                if day == today {
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
        
        
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Films.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleFilmCell") as! ScheduleTableViewCell
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ScheduleDetail"){
            if let index = self.tableView.indexPathForSelectedRow{
                let filmDetail = segue.destination as! DetailViewController
                
                filmDetail.film = Films[index.row]
                
            }
        }
    }

}
