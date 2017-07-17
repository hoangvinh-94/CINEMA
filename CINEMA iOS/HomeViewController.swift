
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

// Display base information of film with 3 type film
// MARK: - HomeViewController
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    // MARK: Internal
    
    @IBOutlet weak var tableAcIndicator: UIActivityIndicatorView! //  load internet
    public static var searchController = UISearchController(searchResultsController: nil)
    let db = DataFilm()
    var Films = [Film]()
    var FilteredFilms = [Film]()
    var ref: DatabaseReference!
    var refHandler: UInt!
    final let SELECTED_SEGMENT_DEFAUT: Int = 0
    final let TIME_DELAY_SLIDESHOW: Int = 3
    final let TRAILER_FIRST: Int = 0
    final let NUMBERSECTION_RETURNED: Int = 1
    final let IDENTIFIER_FILMTABLEVIEWCELL: String = "FilmCell"
    final let IDENTIFIER_PROFILETABLEVIEWCELL: String = "ProfileViewController"
    final let IDENTIFIER_DETAILTABLEVIEWCELL: String = "FilmDetail"
    final let IDENTIFIER_SIGNINVIEWCONTROLLER: String = "SignInViewController"
    final let TYPE_NOW_PLAYING: String = "now_playing"
    final let TYPE_UPCOMING: String = "upcoming"
    final let TYPE_POPULAR: String = "popular"
    var queue = OperationQueue()
    var isSlideShowLoaded: Bool! // Check if image is load to scrollView or not
    var isSlideShowDefaultDeleted: Bool! // Check if the image default is deleted or not
    
    let DEFAULT_IMAGE_SLIDE_SHOW = "noimagefound"
    let TIME_DELAY_SLIDE_SHOW = 3
    let IMAGE_LOADED_NUMBER = 3
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var signIn: UIBarButtonItem!
    var LoadView : UIView = UIView()
    
    @IBOutlet weak var mainScrollView: UIScrollView!
  
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        self.segmentControl.selectedSegmentIndex = SELECTED_SEGMENT_DEFAUT
        
        // connected to internet
        if(currentReachabilityStatus != .notReachable){
            loadInterface()
        }
        else{
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "ConnectAgain")
            present(newViewcontroller, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let pageIndex = mainScrollView.auk.currentPageIndex else { return }
        let newScrollViewWidth = size.width // Assuming scroll view occupies 100% of the screen width
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.mainScrollView.auk.scrollToPage(atIndex: pageIndex, pageWidth: newScrollViewWidth, animated: false)
            }, completion: nil)
    }
    
    // load all interface for view
    func loadInterface(){
        
        ref = Database.database().reference()
        if(Auth.auth().currentUser?.uid != nil){
            let uid = Auth.auth().currentUser?.uid
            ref.child("users").child(uid!).observe(.value, with: {(snapshot) in
                let user = snapshot.value as? [String: Any]
                self.signIn.title = "Hi, " + (user?["userName"] as? String)!
                self.signIn.image = nil
                self.signIn.action = #selector(self.toProfileViewController)
            })
        }
        
        self.isSlideShowLoaded = false
        self.isSlideShowDefaultDeleted = false
        
        // Do any additional setup after loading the view, typically from a nib.
        HomeViewController.searchController.searchResultsUpdater = self
        definesPresentationContext = true
        HomeViewController.searchController.dimsBackgroundDuringPresentation = true
        HomeViewController.searchController.searchBar.delegate = self
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.segmentControl.selectedSegmentIndex = SELECTED_SEGMENT_DEFAUT
        loadDataToTableView(type: TYPE_NOW_PLAYING)
        
    }
    
    // Covert to ProfileViewController
    func toProfileViewController() {
        
        let profile = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_PROFILETABLEVIEWCELL) as! ProfileViewController
        self.navigationController?.pushViewController(profile, animated: true)
        
    }
    
    // Set image size in slide image
    func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    // Load Data film from firebase
    func loadDataToTableView(type: String){
        
        self.Films = [Film]()
        queue.cancelAllOperations()
        tableAcIndicator.startAnimating()
        
        refHandler = ref.child("films").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if (type == self.TYPE_NOW_PLAYING && self.isSlideShowLoaded == false && self.isSlideShowDefaultDeleted == false) {
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
                let trailer = dictionary["trailers"]?[self.TRAILER_FIRST] as? String
                if(typeFilm != "" && typeFilm == type){
                    let F: Film = Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!)
                    F.setTrailers(trailer: trailer!)
                    self.Films.append(F)
                    DispatchQueue.main.async {
                        self.tableAcIndicator.stopAnimating()
                        self.tableView.reloadData()
                        if ((type == self.TYPE_NOW_PLAYING) && (self.isSlideShowLoaded == false)) {
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
    
    // display image to slide show scrollView
    func slideShow(poster_path: String){
        
        let size = CGSize(width: Int(self.mainScrollView.frame.width), height: Int(self.mainScrollView.frame.height)) // get scrollView with and height
        self.queue.addOperation { () -> Void in
            if poster_path != "" {
                if var img = Downloader.downloadImageWithURL("\(prefixImg)\(poster_path )") {
                    OperationQueue.main.addOperation({
                        img = self.imageResize(image: img, sizeChange: size) // Call resize func to change iamge size
                        self.mainScrollView.auk.show(image: img)
                        self.mainScrollView.auk.settings.placeholderImage = UIImage(named: self.DEFAULT_IMAGE_SLIDE_SHOW)
                        self.mainScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.scrollViewTapped)))
                    })
                }
            }
        }
        
        // Scroll images automatically with the interval of 3 seconds
        self.mainScrollView.auk.startAutoScroll(delaySeconds: Double(TIME_DELAY_SLIDESHOW))
        
        
        // Scroll images automatically with the interval of 3 seconds
        self.mainScrollView.auk.startAutoScroll(delaySeconds: Double(TIME_DELAY_SLIDE_SHOW))
    }
    
    // catch event clicked picture in slideshow
    func scrollViewTapped() {
        
        // perform not finish
        let filmDetail = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_DETAILTABLEVIEWCELL) as! DetailViewController
        filmDetail.film = Films[0]
        navigationController?.pushViewController(filmDetail, animated: true)
    
    }
    
    // MARK: UISegmentedControl
    
    @IBAction func indexChanged(_ sender: Any) {
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
            loadDataToTableView(type: TYPE_NOW_PLAYING)
            break
        case 1:
            loadDataToTableView(type: TYPE_UPCOMING)
            break
        case 2:
            loadDataToTableView(type: TYPE_POPULAR)
            break
        default: break
        }
        
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.NUMBERSECTION_RETURNED
        
    }
    
     // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (HomeViewController.searchController.isActive && (HomeViewController.searchController.searchBar.text != "")) {
            return FilteredFilms.count
        }else{
            return Films.count
        }
        
    }
    
     // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_FILMTABLEVIEWCELL) as! FilmTableViewCell
        var film: Film
        if (HomeViewController.searchController.isActive && (HomeViewController.searchController.searchBar.text != "")){
            film = FilteredFilms[indexPath.row]
            
        }else{
            film = Films[indexPath.row]
        }
        queue.addOperation { () -> Void in
            if (film.getPoster() != "") {
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
                                //cell.GenreFilm.text = cell.GenreFilm.text! + String(g! + ", ")
                                cell.GenreFilm.text = cell.GenreFilm.text! + String(", ")
                            }
                        }
                    })
                }
            }
        }
        return cell
    }
    
    // Search film by Title Film
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        
        FilteredFilms = Films.filter{
            st in
            return st.getTitle().lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == IDENTIFIER_DETAILTABLEVIEWCELL){
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
    
    // Action click signIn button
    @IBAction func signInAction(_ sender: Any) {
        
        HomeViewController.searchController.searchBar.isHidden = true
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: IDENTIFIER_SIGNINVIEWCONTROLLER)
        let newFrontController = UINavigationController.init(rootViewController:vc)
        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        
    }
    
    // Download image from internet
    class Downloader {
        
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
        
    }
    
    
    // MARK: Rest options
    
    func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale) // Change size image to scroll view size
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}


extension HomeViewController : UISearchBarDelegate{
    
    // MARK: Internal
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (!(searchBar.text?.isEmpty)!) {
            tableView?.reloadData()
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (!searchText.isEmpty) {
            
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if (!(searchBar.text?.isEmpty)!) {
            
            //reload your data source if necessary
            tableView?.reloadData()
        }
    }
    
}


extension HomeViewController: UISearchResultsUpdating{
    
    // MARK: Internal
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
