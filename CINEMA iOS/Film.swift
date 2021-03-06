//
//  Film.swift
//  CINEMA iOS
//
//  Created by healer on 6/1/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

// MARK: - Film

class Film: NSObject{
    
    //  MARK: Internal
    
    // MARK: Declare variables
    
    private var id: Int?
    private var title: String?
    private var poster: String?
    private var overview: String?
    private var releaseDate: String?
    private var genres: [Dictionary<String,Any>]?
    private var runtime: Int?
    private var trailer: String?
    
    override init(){
        
    }
    
    init(id: Int, title: String, poster: String, overview: String, releaseDate: String, runtime: Int, genres: [Dictionary<String,Any>]) {
        
        self.id = id
        self.title = title
        self.poster = poster
        self.overview = overview
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.genres = genres
    }
    
    func getTrailers() -> String{
        return trailer!;
    }
    
    func setTrailers(trailer: String){
        self.trailer = trailer
    }
    
    func getId() -> Int{
        return id!
    }

    func getRuntime() -> Int{
        return runtime!
    }
    
    func getGenres() -> [Dictionary<String,Any>]{
        return genres!
    }

    func getTitle() -> String{
        return title!
    }
    
    func getPoster() -> String{
        return poster!
    }
    
    func getOverview() -> String{
        return overview!
    }
    
    func getReleaseDate() -> String{
        return releaseDate!
    }
}
