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
    var tableIndicator = UIActivityIndicatorView()
    
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
        
        
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        
        tableView.backgroundView = tableIndicator
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        ref = Database.database().reference()
        loadDataToTableView()
        if tableIndicator.isAnimating {
            tableIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func loadDataToTableView(){
        self.tableIndicator.startAnimating()
        self.Films = [Film]()
        queue.cancelAllOperations()
        
        
        db.getBookFilmToday { (Films, error) in
            if(error != nil) {
                print(error!)
            } else {
                self.Films = Films!
                DispatchQueue.main.async {
                    self.tableIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, re   turn the number of rows
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
                        cell.genreLabel.text = ""
                            let count = film.getGenres().count
                        var c = 0
                        print(film.getGenres())
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

}
