//
//  FilmTypeTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/14/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase

// Display all film each type film
// MARK: - FilmTypeTableViewController
class FilmTypeTableViewController: UITableViewController {
    
    // MARK: Internal
    
    // MARK: Variables
    final let NUMBERSECTION_RETURNED: Int = 1
    final let IDENTIFIER_FILMTYPETABLEVIEWCELL: String = "FilmTypeCell"
    final let IDENTIFIER_DETAILTABLEVIEWCELL: String = "FilmTypeDetail"
    final let IDENTIFIER_CONNECTAGAINVIEWCONTROLLER: String = "ConnectAgain"
    final let TYPE_NOW_PLAYING: String = "now_playing"
    final let TYPE_UPCOMING: String = "upcoming"
    final let TYPE_POPULAR: String = "popular"
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var queue = OperationQueue()
    var typeFilm : Int?
    var db = DataFilm()
    
    var tableIndicator = UIActivityIndicatorView()
    
    @IBOutlet var menuButton: UIBarButtonItem!

    // MARK: UITableViewController

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // load view
    func load(){
        
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        ref = Database.database().reference()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        tableIndicator.activityIndicatorViewStyle = .whiteLarge
        tableIndicator.color = UIColor.orange
        tableView.backgroundView = tableIndicator
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check connect to internet
        if currentReachabilityStatus != .notReachable {
            load()
            switch typeFilm! {
            case 0:
                loadDataToTableView(type: TYPE_POPULAR)
                break
            case 1:
                loadDataToTableView(type: TYPE_NOW_PLAYING)
                break
            case 2:
                loadDataToTableView(type: TYPE_UPCOMING)
                break
            default:
                break
            }
        }
        else {
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: IDENTIFIER_CONNECTAGAINVIEWCONTROLLER)
            present(newViewcontroller, animated: true, completion: nil)
        }
    }

    // load data to tableView
    func loadDataToTableView(type: String) {
        
        self.Films = [Film]()
        queue.cancelAllOperations()
        tableIndicator.startAnimating()
    
        // use method getData from DataFilm class
        db.getDataFilmFireBase(type: type) { (Films, error) in
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Search film by Title Film
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        FilteredFilms = Films.filter{
            st in
            return st.getTitle().lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return NUMBERSECTION_RETURNED
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        if HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != "" {
            return FilteredFilms.count
        }
        else {
            return Films.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_FILMTYPETABLEVIEWCELL) as! FilmTypeTableViewCell
        var film: Film
        if HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != "" {
            film = FilteredFilms[indexPath.row]
        }
        else {
            film = Films[indexPath.row]
        }
        queue.addOperation { () -> Void in
            if film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(prefixImg)\(film.getPoster())") {
                    OperationQueue.main.addOperation({
                        cell.PosterFilm.image = img
                        cell.TitleFilm.text = film.getTitle()
                        let count = film.getGenres().count
                        var c = 0
                        cell.GenreFilm.text = ""
                        for genre in film.getGenres(){
                            c = c + 1
                            let g = genre["name"] as? String
                            cell.GenreFilm.text = cell.GenreFilm.text! + String(g!)
                            if c < count {
                                cell.GenreFilm.text = cell.GenreFilm.text! + String(", ")
                            }
                        }
                    })
                }
            }
        }
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == IDENTIFIER_DETAILTABLEVIEWCELL {
            if let index = self.tableView.indexPathForSelectedRow{
                let filmDetail = segue.destination as! DetailViewController
                if HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != "" {
                    filmDetail.film = FilteredFilms[index.row]
                }
                else {
                    filmDetail.film = Films[index.row]
                }
            }
        }
    }
}

// MARK: UISearchBarDelegate
extension FilmTypeTableViewController : UISearchBarDelegate{
    
    // MARK: Internal
    
    // button search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !(searchBar.text?.isEmpty)! {
            tableView?.reloadData()
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
    
    // update data when search begin change
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty)! {
            
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
}

// MARK: UISearchResultsUpdating
extension FilmTypeTableViewController: UISearchResultsUpdating{
    
    // MARK: Internal
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
