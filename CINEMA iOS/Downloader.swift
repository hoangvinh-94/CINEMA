//
//  Downloader.swift
//  CINEMA iOS
//
//  Created by healer on 7/13/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

// MARK: - Downloader

// Download data from internet
public class Downloader{
    // MARK: Internal
    
    // Download image from internet by urlRequest
    public static func downloadImageWithURL(_ url:String) -> UIImage! {
        
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
    
    // Download trailer from internet by urlRequest
     public static func downloadTrailerWithURL(_ url:String) -> URLRequest {
        
        let urlRequest = URL(string: url)
        return URLRequest(url: urlRequest!)
    }
    
}
