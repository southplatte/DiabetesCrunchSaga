//
//  Level.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 3/7/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9


class Level {
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = ASet<Swap>()
    private var comboMultiplier = 0
    
    
    var targetScore = 0
    var maximumMoves = 0
    
    init(filename: String){
        //1
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename){
            //2
            if let tilesArray:  AnyObject = dictionary["tiles"]{
                //3
                for(row, rowArray) in (tilesArray as! [[Int]]).enumerated(){
                //for(row, rowArray) in enumerate(tilesArray as! [[Int]]){
                    //4
                    let tileRow = NumRows - row - 1
                    //5
                    for(column, value) in rowArray.enumerated(){
                        if value == 1{
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
                
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
            }
        }
    }
    
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    func TileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle() -> ASet<Cookie> {
        var set: ASet<Cookie>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        }
        while possibleSwaps.count == 0
        
        return set
    }
    
    func performSwap(swap: Swap){
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    func detectPossibleSwaps(){
        var set = ASet<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row]{
                    // Is it possible to swap this cookie with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = cookies[column + 1, row] {
                            // Swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column: column + 1, row: row) ||
                                hasChainAtColumn(column: column, row: row) {
                                    set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    // Swap them back
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column: column, row: row + 1) ||
                                hasChainAtColumn(column: column, row: row) {
                                    set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }

                }
            }
        }
        possibleSwaps = set
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.containsElement(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookies(chains: horizontalChains)
        removeCookies(chains: verticalChains)
        
        calculateScores(chains: horizontalChains)
        calculateScores(chains: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && cookies[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            // 4
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            // 5
                            array.append(cookie)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .unknown
        
        for column in 0..<NumColumns {
            var array = [Cookie]()
            // 1
            var row = NumRows - 1;
            row.stride(to: 0, by: -1).forEach(cookies[column, row]==nil) {
            //for var row = NumRows - 1; row >= 0 && cookies[column, row] == nil; row -= 1 {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    // 4
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func resetComboMultiplier(){
        comboMultiplier = 1
    }
    
    private func createInitialCookies() -> ASet<Cookie> {
        var set = ASet<Cookie>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil{
                    // 2
                    var cookieType: CookieType
                    repeat{
                        cookieType = CookieType.random()
                    }
                    while (column >= 2 && cookies[column - 1, row]?.cookieType == cookieType && cookies[column - 2, row]?.cookieType == cookieType) || (row >= 2 && cookies[column, row - 1]?.cookieType == cookieType && cookies[column, row - 2]?.cookieType == cookieType)
                    
                    // 3
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    
                    // 4
                    set.addElement(cookie)
                }
                
            }
        }
        return set
    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType;
            i-=1, horzLength+=1 { }
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType;
            i+=1, horzLength+=1 { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            i+=1, vertLength+=1 { }
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType;
            i+=1, vertLength+=1 { }
        return vertLength >= 3
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            for var column in 0..<NumColumns - 2 {
                // 3
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    // 4
                    if cookies[column + 1, row]?.cookieType == matchType &&
                        cookies[column + 2, row]?.cookieType == matchType {
                            // 5
                            let chain = Chain(chainType: .horizontal)
                            repeat {
                                chain.addCookie(cookies[column, row]!)
                                column += 1
                            }
                                while column < NumColumns && cookies[column, row]?.cookieType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                // 6
                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row in 0..<(NumRows - 2) {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                            
                            let chain = Chain(chainType: .vertical)
                            repeat {
                                chain.addCookie(cookies[column, row]!)
                                row += 1
                            }
                                while row < NumRows && cookies[column, row]?.cookieType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    private func removeCookies(chains: Set<Chain>){
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    private func calculateScores(chains: Set<Chain>){
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
}
