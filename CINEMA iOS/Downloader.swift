//
//  Downloader.swift
//  CINEMA iOS
//
//  Created by healer on 7/13/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

// Download data from internet
class Downloader{
    
    // Download image from internet by urlRequest
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
    
    // Download trailer from internet by urlRequest
    class func downloadTrailerWithURL(_ url:String) -> URLRequest {
        let urlRequest = URL(string: url)
        return URLRequest(url: urlRequest!)
    }
    
}
