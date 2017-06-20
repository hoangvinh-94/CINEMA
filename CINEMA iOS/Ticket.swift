//
//  Ticket.swift
//  CINEMA iOS
//
//  Created by healer on 6/15/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation
class Ticket: NSObject{
    
    private var id: Int?
    private var user: String?
    private var titleFilm: String?
    private var day: String?
    private var time: String?
    private var seat: String?
    private var room: Int?
    
    
    override init() {
        
    }
    
    init(titleFilm: String, day: String, time: String, seat: String, room: Int){
        self.titleFilm = titleFilm
        self.day = day
        self.time = time
        self.seat = seat
        self.room = room
    }
    
    func getUsername() -> String{
        return user!
    }
    func getTitleFilm() -> String{
        return titleFilm!
    }
    func getDay() -> String{
        return day!
    }
    func getTime() -> String{
        return time!
    }
    func getSeat() -> String{
        return seat!
    }
    func getRoom() -> Int{
        return room!
    }
}
