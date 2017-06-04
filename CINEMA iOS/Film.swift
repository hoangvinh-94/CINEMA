//
//  Film.swift
//  CINEMA iOS
//
//  Created by healer on 6/1/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

class Film: NSObject{
    private var id: String?
    private var title: String?
    private var poster: String?
    private var overview: String?
    private var releaseDate: String?
    private var genres: [Int]?
    
    
    
    init(title: String, poster: String, overview: String, releaseDate: String) {
        self.title = title
        self.poster = poster
        self.overview = overview
        self.releaseDate = releaseDate
    }
    
    //init(dictionary: [String: AnyObject]) {
        //super.init()
        
       // self.title = dictionary["title"] as? String
       // self.poster = dictionary["poster"] as? String
       // self.overview = dictionary["overview"] as? String
       // self.releaseDate = dictionary["release_date"] as? String
   // }
    
    func getId() -> String{
        return id!;
    }
    func getTitle() -> String{
        return title!;
    }
    func getPoster() -> String{
        return poster!;
    }
    func getOverview() -> String{
        return overview!;
    }
    func getReleaseDate() -> String{
        return releaseDate!;
    }
    

}
