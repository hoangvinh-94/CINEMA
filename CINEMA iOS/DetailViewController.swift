//
//  DetailViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/6/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet var posterImage: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var runtimeLabel: UILabel!
    
    @IBOutlet var directorLabel: UILabel!
    
    @IBOutlet var actorLabel: UILabel!
    
    @IBOutlet var overviewLabel: UILabel!
    
    @IBOutlet var trailer: UIWebView!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    var queue = OperationQueue()

    

    var film = Film()
    var db = DataFilm()
    var flag: Bool = false
    var tableIndicator = UIActivityIndicatorView()
   
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       db.checkFilmHadBook(idFilmCurrent: film.getId(), completionHandler: { (flag, error) in
            if(error != nil) {
                print(error!)
            } else {
                self.flag = flag!
               
            }
        })
        
        tableIndicator.center = self.view.center
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        tableIndicator.hidesWhenStopped = true
        
        self.view.addSubview(tableIndicator)
        
        tableIndicator.startAnimating()
        
        queue.addOperation { () -> Void in
            if self.film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(self.prefixImg)\(self.film.getPoster())") {
                    OperationQueue.main.addOperation({
                        self.tableIndicator.stopAnimating()
                        self.posterImage.image = img
                        let url = URL(string: "https://www.youtube.com/embed/\(self.film.getTrailers())")
                        self.trailer.loadRequest(URLRequest(url: url! as URL))
                        self.titleLabel.text = self.film.getTitle().uppercased()
                        self.releaseDateLabel.text = self.film.getReleaseDate()
                        self.runtimeLabel.text = String(self.film.getRuntime()) + " minutes"
                        self.overviewLabel.text = self.film.getOverview()
                        let count = self.film.getGenres().count
                        var c = 0
                        for genre in self.film.getGenres(){
                            c = c + 1
                            if c < count {
                                let g = genre["name"] as? String
                                self.genreLabel.text = self.genreLabel.text! + String(g! + ", ")
                            }
                            else{
                                let g = genre["name"] as? String
                                self.genreLabel.text = self.genreLabel.text! + String(g!)

                            }
                            
             	           }
                        
                })
                }
            }
        }
        
        

        // Do any additional setup after loading the view.
    }

    @IBAction func bookFilm(_ sender: Any) {
        if(self.flag){
            let id = film.getId()
            let title = film.getTitle()
            let book = storyboard?.instantiateViewController(withIdentifier: "BFILM") as! BookFilmTableViewController
            book.idFilmCurrent = id
            book.titleFilm = title
            navigationController?.pushViewController(book, animated: true)

        }
        else{
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
