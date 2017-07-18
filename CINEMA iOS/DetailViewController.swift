//
//  DetailViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/6/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import WebKit

// Display detail information film
// MARK: - DetailViewController
class DetailViewController: UIViewController {
    
    // MARK: Internal

    // MARK: Declare variables
    final let IDENTIFIER_CONNECTAGAINVIEWCONTROLLER: String = "ConnectAgain"
    final let IDENTIFIER_BOOKFILMVIEWCONTROLLER: String = "BFILM"
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var runtimeLabel: UILabel!
    @IBOutlet var directorLabel: UILabel!
    @IBOutlet var actorLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var trailer: UIWebView!
    var queue = OperationQueue()
    var film = Film()
    var db = DataFilm()
    var flag: Bool = false
    var tableIndicator = UIActivityIndicatorView()

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    // Load
    func load() {
        
        // check had film booked in today
        db.checkFilmHadBook(idFilmCurrent: film.getId(), completionHandler: { (flag, error) in
            if error != nil {
                print(error!)
            }
            else {
                self.flag = flag!
                
            }
        })
        
        // set attributes for tableIndicator
        tableIndicator.center = self.view.center
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        tableIndicator.hidesWhenStopped = true
        self.view.addSubview(tableIndicator)
        tableIndicator.startAnimating()
        queue.addOperation { () -> Void in
            if self.film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(prefixImg)\(self.film.getPoster())") {
                    OperationQueue.main.addOperation({
                        self.tableIndicator.stopAnimating()
                        self.posterImage.image = img
                        self.trailer.loadRequest(Downloader.downloadTrailerWithURL("\(prefixTrailer)\(self.film.getTrailers())"))
                        self.titleLabel.text = self.film.getTitle().uppercased()
                        self.releaseDateLabel.text = self.film.getReleaseDate()
                        self.runtimeLabel.text = String(self.film.getRuntime()) + " minutes"
                        self.overviewLabel.text = self.film.getOverview()
                        let count = self.film.getGenres().count
                        var c = 0
                        for genre in self.film.getGenres(){
                            c = c + 1
                            let g = genre["name"] as? String
                            self.genreLabel.text = self.genreLabel.text! + String(g!)
                            if c < count {
                                self.genreLabel.text = self.genreLabel.text! + String(", ")
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check connect to internet
        if currentReachabilityStatus != .notReachable {
            load()
        }
        else {
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: IDENTIFIER_CONNECTAGAINVIEWCONTROLLER)
            present(newViewcontroller, animated: true, completion: nil)
        }
    }
    
    // save button pressed
    @IBAction func bookFilm(_ sender: Any) {
        
        if self.flag {
            let id = film.getId()
            let title = film.getTitle()
            let book = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_BOOKFILMVIEWCONTROLLER) as! BookFilmTableViewController
            book.idFilmCurrent = id
            book.titleFilm = title
            navigationController?.pushViewController(book, animated: true)

        }
        else {
            let alert = UIAlertController(title: "Information" ,message: "This Film hasn't book! You can choose another Film", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
