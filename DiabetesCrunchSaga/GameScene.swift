//
//  GameScene.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 3/7/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

import SpriteKit

class GameScene:SKScene {
    
    var swipeHandler: ((Swap) -> ())?
    
    var level: Level!
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    var selectionSprite = SKSpriteNode()
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    //include sounds
    let swapSound = SKAction.playSoundFileNamed("Sounds/Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Sounds/Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Sounds/Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Sounds/Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Sounds/Drip.wav", waitForCompletion: false)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
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
    func addSpritesForCookies(cookies: ASet<Cookie>) {
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
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                }
            }
        }
        
    }
    
    func animateSwap(swap: Swap, completion: () -> ()){
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
        runAction(swapSound)
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        runAction(invalidSwapSound)
    }
    
    func showSelectionIndicatorforCookie(cookie: Cookie){
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite{
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator(){
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
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
                showSelectionIndicatorforCookie(cookie)
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
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                //5
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent){
        touchesEnded(touches, withEvent: event)
    }
}