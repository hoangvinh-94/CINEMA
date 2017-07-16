
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


// MARK: - HomeViewController

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    // MARK: Internal
    
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
  
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        self.segmentControl.selectedSegmentIndex = 0
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
        self.segmentControl.selectedSegmentIndex = 0
        loadDataToTableView(type: "now_playing")
    }
    
    func toProfileViewController() {
        
        let profile = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profile, animated: true)
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
        
        refHandler = ref.child("films").observe(.childAdded, with:{ (snapshot) in
            
            // Get user value
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if type == "now_playing" && self.isSlideShowLoaded == false && self.isSlideShowDefaultDeleted == false { // If the the tap choosen is now playing, image is not loaed to scrollview and image default is not deleted
                    self.mainScrollView.auk.removeAll() // remove the default images
                    self.isSlideShowDefaultDeleted = true
                }
                print(dictionary)
                
                let id = dictionary["idFilm"] as? Int
                let typeFilm = dictionary["type"] as? String
                let overview = dictionary["overview"] as? String
                let poster_path = dictionary["poster_path"] as? String
                let release_date = dictionary["release_date"] as? String
                let title = dictionary["title"] as? String
                let runtime = dictionary["runtime"] as? Int
                let genres = dictionary["genres"] as? [Dictionary<String,Any>]
                let trailer = dictionary["trailers"]?[0] as? String
                
                if(typeFilm != "" && typeFilm == type){
                    let F: Film = Film(id: id!,title: title!, poster: poster_path!, overview: overview!, releaseDate: release_date!, runtime: runtime!, genres: genres!)
                    F.setTrailers(trailer: trailer!)
                    self.Films.append(F)
                    DispatchQueue.main.async {
                        self.tableAcIndicator.stopAnimating()
                        self.tableView.reloadData()
                        
                        if type == "now_playing" && self.isSlideShowLoaded == false {
                            self.slideShow(poster_path: poster_path!) // Add image url to scrollview
                            if self.mainScrollView.auk.numberOfPages > self.IMAGE_LOADED_NUMBER { //Image is loaded to scrollview
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
    
    // Add image url is loaded from databse to ScrollView
    func slideShow(poster_path: String){
        
        let size = CGSize(width: Int(self.mainScrollView.frame.width), height: Int(self.mainScrollView.frame.height)) // get scrollView with and height
        self.queue.addOperation { () -> Void in
            if poster_path != "" {
                if var img = Downloader.downloadImageWithURL("\(self.prefixImg)\(poster_path )") {
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
        self.mainScrollView.auk.startAutoScroll(delaySeconds: Double(TIME_DELAY_SLIDE_SHOW))
    }
    
    func scrollViewTapped() {
        let filmDetail = storyboard?.instantiateViewController(withIdentifier: "FILMDETAIL") as! DetailViewController
        filmDetail.film = Films[0]
        navigationController?.pushViewController(filmDetail, animated: true)
        

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
        HomeViewController.searchController.searchBar.isHidden = true
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
        let newFrontController = UINavigationController.init(rootViewController:vc)
        revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
        
    }
    
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


// MARK: UISearchBarDelegate

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


// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
