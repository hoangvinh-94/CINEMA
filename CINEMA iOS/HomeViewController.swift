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
    
    @IBOutlet weak var tableAcIndicator: UIActivityIndicatorView!
    public static var searchController = UISearchController(searchResultsController: nil)
    var db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    var prefixImgSlideshow: String = "https://image.tmdb.org/t/p/w1400_and_h450_bestv2"
    var queue = OperationQueue()
    var isSlideShowLoaded: Bool!
    var isSlideShowDefaultDeleted: Bool!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var signIn: UIBarButtonItem!
    var LoadView : UIView = UIView()
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        if currentReachabilityStatus == .notReachable {
//            print("vinh")
//        } else {
//            return
//            print("vinh1")
//            let font = UIFont.systemFont(ofSize: 10)
//            segmentControl.setTitleTextAttributes([NSFontAttributeName: font],
//                                                  for: .normal)
//            
//            ref = Database.database().reference()
//            if(Auth.auth().currentUser?.uid != nil){
//                    self.signIn.isEnabled = false
//                    
//            }
//        
//            // Do any additional setup after loading the view, typically from a nib.
//            HomeViewController.searchController.searchResultsUpdater = self
//            definesPresentationContext = true
//            HomeViewController.searchController.dimsBackgroundDuringPresentation = true
//            HomeViewController.searchController.searchBar.delegate = self
//            
//            menuButton.target = revealViewController()
//            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
//            //db.reloadFilmFromUrlApi(page: 1	, filmType: "popular")
//            //db.reloadFilmFromUrlApi(page: 1	, filmType: "upcoming")
//            //db.reloadFilmFromUrlApi(page: 1	, filmType: "now_playing")
//        }
        ref = Database.database().reference()
        if(Auth.auth().currentUser?.uid != nil){
            self.signIn.isEnabled = false
            
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "popular")
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "upcoming")
        //db.reloadFilmFromUrlApi(page: 1	, filmType: "now_playing")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        self.segmentControl.selectedSegmentIndex = 0
    //    loadDataToTableView(type: "popular")
        if currentReachabilityStatus == .notReachable {
            print("vinh")
        } else {
            let font = UIFont.systemFont(ofSize: 10)
            segmentControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                  for: .normal)
            //db.reloadFilmFromUrlApi(page: 1	, filmType: "now_playing")
        }
    }
    
    func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
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
        queue.cancelAllOperations()
        tableAcIndicator.startAnimating()
        refHandler = ref.child("films5").observe(.childAdded, with:{ (snapshot) in
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if (type == "now_playing" && self.isSlideShowLoaded == false && self.isSlideShowDefaultDeleted == false) {
                    self.mainScrollView.auk.removeAll()
                    self.isSlideShowDefaultDeleted = true
                }
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
                        self.tableAcIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                        if (type == "now_playing" && self.isSlideShowLoaded == false) {
                            self.slideShow(poster_path: poster_path!)
                            if self.mainScrollView.auk.numberOfPages > 3 {
                                self.isSlideShowLoaded = true
                            }
                        }
                    }
                }else{
                    return
                }
            }
            
            
        })
        
    }
    
    func slideShow(poster_path: String){
        
        let size = CGSize(width: Int(self.mainScrollView.frame.width), height: Int(self.mainScrollView.frame.height))
        self.queue.addOperation { () -> Void in
            if poster_path != "" {
                if var img = Downloader.downloadImageWithURL("\(self.prefixImg)\(poster_path )") {
                    OperationQueue.main.addOperation({
                        img = self.imageResize(image: img, sizeChange: size)
                        self.mainScrollView.auk.show(image: img)
                    })
                }
            }
            
        }
        // Scroll images automatically with the interval of 3 seconds
        self.mainScrollView.auk.startAutoScroll(delaySeconds: 3)
        
        
    }
    
    func slideShowDefault() {
        let size = CGSize(width: Int(self.mainScrollView.frame.width), height: Int(self.mainScrollView.frame.height))
        //let image1 = imageResize(image: UIImage(named:"movietime1.jpg")!, sizeChange: size)
        let image2 = imageResize(image: UIImage(named:"gameot.jpg")!, sizeChange: size)
        //let image3 = imageResize(image: UIImage(named:"007.jpg")!, sizeChange: size)
        //self.mainScrollView.auk.show(image: image1)
        self.mainScrollView.auk.show(image: image2)
        //self.mainScrollView.auk.show(image: image3)
        
        // Scroll images automatically with the interval of 3 seconds
        self.mainScrollView.auk.startAutoScroll(delaySeconds: 3)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            loadDataToTableView(type: "now_playing")
            break
        case 1:
            loadDataToTableView(type: "upcoming")
            break
        case 2:
            loadDataToTableView(type: "popular")
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
    
    @IBAction func signInAction(_ sender: Any) {
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
            let newFrontController = UINavigationController.init(rootViewController:vc)
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        
    }
}

extension HomeViewController : UISearchBarDelegate{
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

extension HomeViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
