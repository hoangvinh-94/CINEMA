//
//  BookFilm.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

class BookFilm{
    
    private var Id: String?
    private var idFilm: String?
    private var idDay: [String]?
    private var idRoom: [String]?
    private var idTime: [String]?
    private var idSit: [String]?
    
    func getId() -> String {
        return Id!
    }
    
    func getIdFilm() -> String{
        return idFilm!
    }
    
    
    
}
