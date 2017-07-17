//
//  ScheduleTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/15/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// Display film information had book in today
// MARK: - ScheduleTableViewController

class ScheduleTableViewController: UITableViewController {

    // MARK: Internal
    // MARK: Declare variables
    final let NUMBERSECTION_RETURNED: Int = 1
    final let IDENTIFIER_SCHEDULEFILMCELL: String = "ScheduleFilmCell"
    final let IDENTIFIER_SCHEDULEDETAIL: String = "ScheduleDetail"
    var db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var queue = OperationQueue()
    var tableIndicator = UIActivityIndicatorView()
    @IBOutlet var menuMain: UIBarButtonItem!
    
    // MARK: UITableViewController
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

    // MARK: - UITableViewDataSource
    // load data to TableView
    func loadDataToTableView(){
        
        self.tableIndicator.startAnimating()
        self.Films = [Film]()
        queue.cancelAllOperations()
        db.getBookFilmToday { (Films, error) in
            if error != nil {
                print(error!)
            }
            else {
                self.Films = Films!
                DispatchQueue.main.async {
                    self.tableIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return NUMBERSECTION_RETURNED
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, re   turn the number of rows
        return Films.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_SCHEDULEFILMCELL) as! ScheduleTableViewCell
        var film: Film
        film = Films[indexPath.row]
        queue.addOperation { () -> Void in
            if film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(prefixImg)\(film.getPoster())") {
                    OperationQueue.main.addOperation({
                        cell.posterImage.image = img
                        cell.titleLabel.text = film.getTitle()
                        cell.genreLabel.text = ""
                            let count = film.getGenres().count
                        var c = 0
                        print(film.getGenres())
                        for genre in film.getGenres(){
                            c = c + 1
                            let g = genre["name"] as? String
                             cell.genreLabel.text = cell.genreLabel.text! + String(g!)
                            if c < count {
                                cell.genreLabel.text = cell.genreLabel.text! + String(", ")
                            }
                        }
                    })
                }
            }
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == IDENTIFIER_SCHEDULEDETAIL {
            if let index = self.tableView.indexPathForSelectedRow {
                let filmDetail = segue.destination as! DetailViewController
                filmDetail.film = Films[index.row]
            }
        }
    }
}
