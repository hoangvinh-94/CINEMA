//
//  BookFilm.swift
//  CINEMA iOS
//
//  Created by healer on 6/4/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation

// MARK: - Book

class Book: NSObject{
    
    // MARK: Internal
    
    // MARK: Declare variables
    
    private var idFilm: Int?
    private var Day: String?
    private var Rooms: [Int]?
    private var Times: [String]?
    private var Seats: [String]?
    
    init(id: Int, day: String, rooms: [Int], times: [String], seats: [String]){
        
        self.idFilm = id
        self.Day = day
        self.Rooms = rooms
        self.Times = times
        self.Seats = seats
    }
    
    func getIdFilm() -> Int{
        return idFilm!
    }
    
    func getRooms() -> [Int]{
        return Rooms!
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
