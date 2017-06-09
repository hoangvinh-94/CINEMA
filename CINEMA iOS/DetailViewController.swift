//
//  DetailViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/6/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var posterImage: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var runtimeLabel: UILabel!
    
    @IBOutlet var directorLabel: UILabel!
    
    @IBOutlet var actorLabel: UILabel!
    @IBOutlet var cinemaLabel: UILabel!
    
    @IBOutlet var overviewLabel: UILabel!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320/"
    var queue = OperationQueue()

    

    var film = Film()
    var db = DataFilm()
    
    
   
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue.addOperation { () -> Void in
            if self.film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(self.prefixImg)\(self.film.getPoster())") {
                    OperationQueue.main.addOperation({
                        self.posterImage.image = img
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
