//
//  Swap.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 9/2/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

import Foundation

struct Swap: Printable {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie){
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}