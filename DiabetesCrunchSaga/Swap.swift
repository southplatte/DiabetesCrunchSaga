//
//  Swap.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 9/2/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible, Hashable {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie){
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
    
    var hashValue: Int{
        return cookieA.hashValue ^ cookieB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) || (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}