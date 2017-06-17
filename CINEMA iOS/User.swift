//
//  user.swift
//  CINEMA iOS
//
//  Created by healer on 6/15/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation
class User: NSObject{
    
    private var userName: String?
    private var password: String?
    private var email: String?
    private var ticket: [Ticket]?
    
    override init() {
        
    }
    
    init(username: String, password: String, email: String, ticket: [Ticket]){
        self.userName = username
        self.password = password
        self.email = email
        self.ticket = ticket
    }
    
}
