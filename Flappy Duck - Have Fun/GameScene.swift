//
//  GameScene.swift
//  Flappy Duck - Have Fun
//
//  Created by Gregory Lampa on 26/04/2015.
//  Copyright (c) 2015 Gregory Lampa. All rights reserved.
//

import SpriteKit

enum Layer: CGFloat {
    case Background
    case Obstacle
    case Foreground
    case Player
    case UI
    case Flash
}

enum GameState {
    case MainMenu
    case Tutorial
    case Play
    case Falling
    case ShowingScore
    case GameOver
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 =     0b1 // 1
    static let Obstacle: UInt32 =  0b10 // 2
    static let Ground: UInt32 =   0b100 // 4
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let kGravity: CGFloat = -1500.0
    let kImpulse: CGFloat = 400.0
    let kNumForegrounds = 2
    let kGroundSpeed: CGFloat = 150.0
    let kBottomObstacleMinFraction: CGFloat = 0.1
    let kBottomObstacleMaxFraction: CGFloat = 0.6
    let kGapMultiplier: CGFloat = 3.5
    let kFirstSpawnDelay: NSTimeInterval = 1.75
    let kEverySpawnDelay: NSTimeInterval = 1.5
    let kFontName = "AmericanTypewriter-Bold"
    let kMargin: CGFloat = 20.0
    let kAnimDelay = 0.3
    let kAppStoreID = 820464950
    let kNumBirdFrames = 3
    let kMinDegrees: CGFloat = -90
    let kMaxDegrees: CGFloat = 25
    let kAngularVelocity: CGFloat = 1000.0
    
    let worldNode = SKNode()
    var playableStart: CGFloat = 0
    var playableHeight: CGFloat = 0
    let player = SKSpriteNode(imageNamed: "duck0")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var playerVelocity = CGPoint.zeroPoint
    var hitGround = false
    var hitObstacle = false
    var gameState: GameState = .Play
    var scoreLabel: SKLabelNode!
    var score = 0
//    var gameSceneDelegate: GameSceneDelegate
    var playerAngularVelocity: CGFloat = 0.0
    var lastTouchTime: NSTimeInterval = 0
    var lastTouchY: CGFloat = 0.0
    
    let dingAction = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flapAction = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let whackAction = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let fallingAction = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hitGroundAction = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let popAction = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coinAction = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        addChild(worldNode)
        
        setupBackground()
        setupForeground()
        setupPlayer()
        setupPlayerAnimation()
        startSpawning()
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Setup methods
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        background.position = CGPoint(x: size.width/2, y: size.height)
        background.zPosition = Layer.Background.rawValue
        worldNode.addChild(background)
        
        playableStart = size.height - background.size.height
        playableHeight = background.size.height
    
    }
    
    func setupForeground() {
        
        for i in 0..<kNumForegrounds {
            let foreground = SKSpriteNode(imageNamed: "ground")
            foreground.anchorPoint = CGPoint(x: 0, y: 1)
            foreground.position = CGPoint(x: CGFloat(i) * size.width, y: playableStart)
            foreground.zPosition = Layer.Foreground.rawValue
            foreground.name = "foreground"
            worldNode.addChild(foreground)
        }
        
    }
    
    func setupPlayer() {
        
        player.position = CGPoint(x: size.width * 0.2, y: playableHeight * 0.4 + playableStart)
        player.zPosition = Layer.Player.rawValue
        
        
        worldNode.addChild(player)
        
    }
    
    func spawnObstacle() {
        
        let bottomObstacle = createBottomObstacle()
        let startX = size.width + bottomObstacle.size.width/2
        
        let bottomObstacleMin = (playableStart - bottomObstacle.size.height/2) + playableHeight * kBottomObstacleMinFraction
        let bottomObstacleMax = (playableStart - bottomObstacle.size.height/2) + playableHeight * kBottomObstacleMaxFraction
        bottomObstacle.position = CGPointMake(startX, CGFloat.random(min: bottomObstacleMin, max: bottomObstacleMax))
        bottomObstacle.name = "BottomObstacle"
        worldNode.addChild(bottomObstacle)
        
        let topObstacle = createBottomObstacle()
        topObstacle.zRotation = CGFloat(180).degreesToRadians()
        topObstacle.position = CGPoint(x: startX, y: bottomObstacle.position.y + bottomObstacle.size.height/2 + topObstacle.size.height/2 + player.size.height * kGapMultiplier)
        topObstacle.name = "TopObstacle"
        worldNode.addChild(topObstacle)
        
        let moveX = size.width + topObstacle.size.width
        let moveDuration = moveX / kGroundSpeed
        let sequence = SKAction.sequence([
            SKAction.moveByX(-moveX, y: 0, duration: NSTimeInterval(moveDuration)),
            SKAction.removeFromParent()
            ])
        topObstacle.runAction(sequence)
        bottomObstacle.runAction(sequence)
        
    }
    
    
    func createTopObstacle() -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "top_obsticale")
        sprite.zPosition = Layer.Obstacle.rawValue
        
        return sprite
    }
 
    func createBottomObstacle() -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "bottom_obsticale")
        sprite.zPosition = Layer.Obstacle.rawValue
        
        return sprite
    }
    
    func startSpawning() {
        
        let firstDelay = SKAction.waitForDuration(kFirstSpawnDelay)
        let spawn = SKAction.runBlock(spawnObstacle)
        let everyDelay = SKAction.waitForDuration(kEverySpawnDelay)
        let spawnSequence = SKAction.sequence([
            spawn, everyDelay
            ])
        let foreverSpawn = SKAction.repeatActionForever(spawnSequence)
        let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])
        runAction(overallSequence, withKey: "spawn")
        
    }
    
    func stopSpawning() {
        
        removeActionForKey("spawn")
        
        worldNode.enumerateChildNodesWithName("TopObstacle", usingBlock: { node, stop in
            node.removeAllActions()
        })
        worldNode.enumerateChildNodesWithName("BottomObstacle", usingBlock: { node, stop in
            node.removeAllActions()
        })
        
    }
    
    func setupPlayerAnimation(){
        var textures: Array<SKTexture> = []
        
        for i in 0..<kNumBirdFrames {
            textures.append(SKTexture(imageNamed: "Duck\(i)"))
        }
        
        for i in stride(from: kNumBirdFrames - 1, through: 0, by: -1) {
            textures.append(SKTexture(imageNamed: "Duck\(i)"))
        }
        
        let playerAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.14)
        player.runAction(SKAction.repeatActionForever(playerAnimation))
    }
    
    // MARK: Physics
    
    func didBeginContact(contact: SKPhysicsContact) {
    
    }
}
