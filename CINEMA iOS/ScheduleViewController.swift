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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadDataToTableView(type: String){
        
        self.Films = [Film]()
        queue.cancelAllOperations()
        refHandler = ref.child("films5").observe(.childAdded, with:{ (snapshot) in
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
                
                if(typeFilm != "" && typeFilm == type){
                    self.Films.append(Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                }else{
                    return
                }
                
            }
            
            
        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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
