//
//  BookFilm.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

class Book{
    
    private var idFilm: Int?
    private var Day: String?
    private var Rooms: [String]?
    private var Times: [String]?
    private var Seats: [String]?
    

    init(id: Int, day: String, rooms: [String], times: [String], seats: [String]){
        self.idFilm = id
        self.Day = day
        self.Rooms = rooms
        self.Times = times
        self.Seats = seats
    }
    
    func getIdFilm() -> Int{
        return idFilm!
    }
    
    func getTimes() -> [String]{
        return Times!
    }
    
    func getSeats() -> [String]{
        return Seats!
    }
    
    func getDays() -> String{
        return Day!
    }
    
}
