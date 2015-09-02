//
//  GameScene.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 3/7/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    var level: Level!
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int){
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth && point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight{
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)
        }
    }
    
    func addTiles(){
        for row in 0..<NumRows{
            for column in 0..<NumColumns{
                if let tile = level.TileAtColumn(column, row: row){
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 1
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        // 2
        let (success, column, row) = convertPoint(location)
        if success {
            // 3
            if let cookie = level.cookieAtColumn(column, row: row) {
                // 4
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent){
        //1
        if swipeFromColumn == nil { return }
        
        //2
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            //3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn!{
                horzDelta = -1
            } else if column > swipeFromColumn! {
                horzDelta = 1
            } else if row < swipeFromRow! {
                vertDelta = -1
            } else if row > swipeFromRow! {
                vertDelta = 1
            }
            
            //4
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzdela, vertical: vertDelta)
                //5
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent){
        touchesEnded(touches, withEvent: event)
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int){
        //1
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        //2
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        //3
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!){
                //4
                println("*** swapping \(fromCookie) with \(toCookie)")
            }
        }
    }
}