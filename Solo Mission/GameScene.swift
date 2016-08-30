//
//  GameScene.swift
//  Solo Mission
//
//  Created by Amazing Daria on 26.08.16.
//  Copyright (c) 2016 Amazing Daria. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let player = SKSpriteNode (imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("soundeffect1" , waitForCompletion: false)
    
    struct PhysicsCategories {
        
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
        
    }
    
    func random() -> CGFloat {
        
        return CGFloat (Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        
        return random() * (max - min) + min
        
    }

    
    var gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect (x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode (imageNamed: "background")
        background.size = self.size
        background.position = CGPoint (x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        startNewLevel()
        
    }
    
    
    func startNewLevel() {
        
        let spawn = SKAction.runBlock(spawnEnemy)
        let waitToSpawn = SKAction.waitForDuration(1)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatActionForever(spawnSequence)
        self.runAction(spawnForever)
    }
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode (imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveToY(self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.runAction(bulletSequence)
        
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: CGRectGetMinX(gameArea) , max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode (imageNamed: "enemyShip")
        enemy.setScale (1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.runAction(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }

   

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        fireBullet()
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.locationInNode(self)
            let previousPoinOfTouch = touch.previousLocationInNode(self)
            
            let amountDragged = pointOfTouch.x - previousPoinOfTouch.x
            
            player.position.x += amountDragged
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width / 2 {
                
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width / 2
                
            }
            
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width / 2 {
                
                player.position.x = CGRectGetMinX(gameArea) + player.size.width / 2
                
            }
            
        }
        
    }
}



