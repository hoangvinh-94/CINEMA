//
//  ViewController.swift
//  CINEMA iOS
//
//  Created by healer on 5/27/17.
//  Copyright © 2017 healer. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import Auk

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    public static var searchController = UISearchController(searchResultsController: nil)
    var db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320/"
    var prefixImgSlideshow: String = "https://image.tmdb.org/t/p/w1400_and_h450_bestv2"
    var queue = OperationQueue()

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var segmentControl: UISegmentedControl!

    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        ref = Database.database().reference()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "upcoming")
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "popular")
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "now_playing")

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataToTableView(type: "popular")
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let pageIndex = mainScrollView.auk.currentPageIndex else { return }
        let newScrollViewWidth = size.width // Assuming scroll view occupies 100% of the screen width
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.mainScrollView.auk.scrollToPage(atIndex: pageIndex, pageWidth: newScrollViewWidth, animated: false)
            }, completion: nil)
    }
    
    func loadDataToTableView(type: String){
        self.Films = [Film]()
        refHandler = ref.child("films2").observe(.childAdded, with:{ (snapshot) in
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
                        
                        
                        
                        print("This is slideshow url images: ttb \(self.Films.count) items.")
                        //myImageView.image! = imageResize(myImageView.image!,sizeChange: size)
                        
                            print("This is slideshow url images: \(self.prefixImgSlideshow)\(poster_path)")
                            self.queue.addOperation { () -> Void in
                                if poster_path != "" {
                                    if var img = Downloader.downloadImageWithURL("\(self.prefixImgSlideshow)\(poster_path ?? "https://image.tmdb.org/t/p/w1400_and_h450_bestv2/9EXnebqbb7dOhONLPV9Tg2oh2KD.jpg")") {
                                        OperationQueue.main.addOperation({
                                            img = self.imageResize(image: img,sizeChange: size)
                                            self.mainScrollView.auk.show(image: img)
                                        })
                                    }
                                }
                                
                            }
                        // Scroll images automatically with the interval of 3 seconds
                        self.mainScrollView.auk.startAutoScroll(delaySeconds: 3)
                        
                        // Return the number of pages in the scroll view
                        print("Number of pages: \(self.mainScrollView.auk.numberOfPages)")
                        
                        // Get the index of the current page or nil if there are no pages
                        print("Number of pages: \(String(describing: self.mainScrollView.auk.currentPageIndex))")
                        
                        // Return currently displayed images
                        print("Number of pages: \(self.mainScrollView.auk.images)")
                        
                        // Stop auto-scrolling of the images
                        // mainScrollView.auk.stopAutoScroll()
                        
                        
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
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            //db.reloadFilmFromUrlApi(page: 1	, filmType: "popular")
            loadDataToTableView(type: "popular")
            break
        case 1:
            //db.reloadFilmFromUrlApi(page: 1	, filmType: "now_playing")
             loadDataToTableView(type: "now_playing")
            break
        case 2:
            //db.reloadFilmFromUrlApi(page: 1	, filmType: "upcoming")
             loadDataToTableView(type: "upcoming")
            break
        default: break
        }
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(HomeViewController.searchController.isActive && HomeViewController.searchController.searchBar.text != ""){
            return FilteredFilms.count
        }
        else{
            return Films.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell") as! FilmTableViewCell
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
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        FilteredFilms = Films.filter{
            st in
            return st.getTitle().lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "FilmDetail"){
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
    
    @IBAction func logOutAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }


}

extension HomeViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            tableView?.reloadData()
           
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

extension HomeViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
extension UIImage {
    
    func resize(maxWidthHeight : Double)-> UIImage? {
        
        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0
        
        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        }else{
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
            maxWidth = actualWidth
        }
        
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
}
