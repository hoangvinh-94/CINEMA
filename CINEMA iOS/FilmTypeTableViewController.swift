//
//  FilmTypeTableViewController.swift
//  CINEMA iOS
//
//  Created by healer on 6/14/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Firebase


class FilmTypeTableViewController: UITableViewController {
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    var queue = OperationQueue()
    var typeFilm : Int?
    @IBOutlet var menuButton: UIBarButtonItem!
    
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        ref = Database.database().reference()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        switch typeFilm! {
        case 0:
             loadDataToTableView(type: "popular")
            break
        case 1:
            loadDataToTableView(type: "now_playing")
            break
        case 2:
            loadDataToTableView(type: "upcoming")
            break
        default:
            break
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
            return FilteredFilms.count
        }
        else{
            return Films.count
        }
    }

    func filterContentForSearchText(searchText: String, scope: String = "All"){
        FilteredFilms = Films.filter{
            st in
            return st.getTitle().lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmTypeCell") as! FilmTypeTableViewCell
        var film: Film
        if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
            film = FilteredFilms[indexPath.row]
            
        }
        else{
            film = Films[indexPath.row]
        }
        
        queue.addOperation { () -> Void in
            if film.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(self.prefixImg)\(film.getPoster())") {
                    OperationQueue.main.addOperation({
                        cell.PosterFilm.image = img
                        cell.TitleFilm.text = film.getTitle()
                        let count = film.getGenres().count
                        var c = 0
                        cell.GenreFilm.text = ""
                        for genre in film.getGenres(){
                            c = c + 1
                            if c < count {
                                let g = genre["name"] as? String
                                cell.GenreFilm.text = cell.GenreFilm.text! + String(g! + ", ")
                            }
                            else{
                                let g = genre["name"] as? String
                                cell.GenreFilm.text = cell.GenreFilm.text! + String(g!)
                                
                            }
                            
                        }
                        
                    })
                }
            }
        }
        return cell
    }
    

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
                FilteredFilms.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            else{
                Films.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

        if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
            // get event dragging
            let film = FilteredFilms[fromIndexPath.row]
            // remove event dragging
            FilteredFilms.remove(at: fromIndexPath.row)
            // insert event into new possition
            FilteredFilms.insert(film, at: to.row)
            
        }
        else{
            // get event dragging
            let film = Films[fromIndexPath.row]
            // remove event dragging
            Films.remove(at: fromIndexPath.row)
            // insert event into new possition
            Films.insert(film, at: to.row)
        }
        
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "FilmTypeDetail"){
            if let index = self.tableView.indexPathForSelectedRow{
                let filmDetail = segue.destination as! DetailViewController
                
                if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
                    filmDetail.film = FilteredFilms[index.row]
                }
                else{
                    filmDetail.film = Films[index.row]
                }
            }
        }

    }
 

}
extension FilmTypeTableViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            tableView?.reloadData()
            self.revealViewController().revealToggle(animated: true)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
}

extension FilmTypeTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
