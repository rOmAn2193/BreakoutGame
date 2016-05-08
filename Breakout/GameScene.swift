//
//  GameScene.swift
//  Breakout
//
//  Created by Roman on 4/9/16.
//  Copyright (c) 2016 Roman Puzey. All rights reserved.
//

import SpriteKit
import AVFoundation

enum ColliderCategory: UInt32
{
    case ball = 0b0 // 0
    case bottom = 0b1 // 1
    case brick = 0b10 // 2
    case paddle = 0b100 // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let paddle = SKSpriteNode(imageNamed: "paddle.png")
    let ball = SKSpriteNode(imageNamed: "ball.png")
    let scoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
    let maxSpeed: CGFloat = 800.0

    var player: AVAudioPlayer = AVAudioPlayer()

    var score = 0 
    var currLevel = 1
    var fingerIsOnPaddle = false
    let padding: CGFloat = 15

    let multiplier: CGFloat = 5.0
    let yBlockDistance: Float = 170.0
    let arrayHeight = 6
    let arrayWidth = 6

    let LEVEL_1 : [[Int]] = [
        [0,1,1,1,1,0],
        [0,1,0,0,0,0],
        [0,1,0,1,0,1],
        [0,1,1,0,0,0],
        [0,1,0,0,1,0],
        [0,1,1,1,1,0],
        ]

    let LEVEL_2 : [[Int]] = [
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,1,0,1,0,1],
        [0,1,1,0,0,0],
        [0,1,0,0,1,0],
        [0,0,1,1,1,0],
        ]

    let LEVEL_3 : [[Int]] = [
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,1],
        [0,0,1,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
    ]

    init(size: CGSize, level: Int, score: Int)
    {
        super.init(size: size)
        self.score = score
        self.currLevel = level

        setupWorld()
        setPaddle()
        setBottom()

        setLevel()
        setScore()
        setLevelLabel()
        setBall()
        setupBackgroundMusic()
    }

    func setupBackgroundMusic()
    {
        do
        {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("backgroundMusic", ofType: "mp3")!))
            player.play()
        }
        catch
        {
            print("Couldn't setup the background music")
        }
    }

    func setScore()
    {
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPointMake(self.frame.size.width * 0.9, self.frame.size.height * 0.9)
        addChild(scoreLabel)
    }

    func setLevelLabel()
    {
        let levelLabel = SKLabelNode(fontNamed: "Avenir-Black")
        levelLabel.text = "Level: \(currLevel)"
        levelLabel.fontSize = 20
        levelLabel.position = CGPointMake(self.frame.size.width * 0.1, self.frame.size.height * 0.9)
        addChild(levelLabel)
    }


    func setLevel()
    {
        switch currLevel
        {
        case 1 :
            buildLevel(LEVEL_1)
        case 2 :
            buildLevel(LEVEL_2)
        case 3:
            buildLevel(LEVEL_3)
        default:
            buildLevel(LEVEL_1)
        }
    }

    func buildLevel(level: [[Int]])
    {
        for i in 0 ..< arrayHeight
        {
            for j in 0 ..< arrayWidth
            {
                if level [i][j] == 1
                {
                    let brick = SKSpriteNode(imageNamed: "brick.png")

                    let var1: Float = Float(j) + 1
                    let var2: Float = Float(i) - 1

                    let xPos = CGFloat((var1) * Float(brick.frame.size.width + padding))
                    let yPos = CGFloat(var2 * Float(brick.frame.size.height + padding ) + yBlockDistance)

                    brick.position = CGPointMake(xPos, yPos)
                    self.addChild(brick)

                    brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                    brick.physicsBody?.allowsRotation = false
                    brick.physicsBody?.friction = 0
                    brick.name = "brick"
                    brick.physicsBody?.categoryBitMask = ColliderCategory.brick.rawValue
                }
            }
        }
    }

    func setupWorld()
    {
        self.physicsWorld.contactDelegate = self
        let backgroundImage = SKSpriteNode(imageNamed: "background.png")
        backgroundImage.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        backgroundImage.size = self.frame.size
        self.addChild(backgroundImage)

        self.physicsWorld.gravity = CGVectorMake(0, 0)

        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0.2
    }

    func setBall()
    {
        ball.name = "ball"
        ball.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/5)

        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        self.addChild(ball)

        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0

        ball.physicsBody?.applyImpulse(CGVectorMake(1, 1.5))

        ball.physicsBody?.categoryBitMask = ColliderCategory.ball.rawValue
        ball.physicsBody?.contactTestBitMask = ColliderCategory.bottom.rawValue | ColliderCategory.brick.rawValue | ColliderCategory.paddle.rawValue

    }

    func setBottom()
    {
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)

        self.addChild(bottom)

        bottom.physicsBody?.categoryBitMask = ColliderCategory.bottom.rawValue
    }

    func setPaddle()
    {
        paddle.name = "paddle"
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 2)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.dynamic = false

        paddle.physicsBody?.categoryBitMask = ColliderCategory.paddle.rawValue

        self.addChild(paddle)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)

        let body: SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)

        if body?.node?.name == "paddle"
        {
            fingerIsOnPaddle = true
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if fingerIsOnPaddle
        {
            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)
            let previousTouchLocation = touch!.previousLocationInNode(self)

            let paddle = self.childNodeWithName("paddle") as! SKSpriteNode

            var newXPosition = paddle.position.x + (touchLocation.x - previousTouchLocation.x)

            newXPosition = max(newXPosition, paddle.size.width / 2)
            newXPosition = min(newXPosition, self.size.width - paddle.size.width / 2)

            paddle.position = CGPointMake(newXPosition, paddle.position.y)
        }
    }

    func didBeginContact(contact: SKPhysicsContact)
    {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Game OVER Situation

        if firstBody.categoryBitMask == ColliderCategory.ball.rawValue && secondBody.categoryBitMask == ColliderCategory.bottom.rawValue
        {
            let gameOverScene = GameOverScene(size: self.frame.size, playerWon: false, level: currLevel, score: score)
            self.view?.presentScene(gameOverScene, transition: SKTransition.crossFadeWithDuration(0.5))
        }

        if firstBody.categoryBitMask == ColliderCategory.ball.rawValue && secondBody.categoryBitMask == ColliderCategory.brick.rawValue
        {
            secondBody.node?.removeFromParent()
            score += 1

            self.runAction(SKAction.playSoundFileNamed("ballBrick", waitForCompletion: false))

            print(score)

            if isGameWon()
            {
                currLevel += 1
                let youWinScene = GameOverScene(size: self.frame.size, playerWon: true, level: currLevel, score: score)
                self.view?.presentScene(youWinScene, transition: SKTransition.doorsCloseVerticalWithDuration(0.5))
            }
        }

        if firstBody.categoryBitMask == ColliderCategory.ball.rawValue && secondBody.categoryBitMask == ColliderCategory.paddle.rawValue
        {
            self.runAction(SKAction.playSoundFileNamed("paddleBall", waitForCompletion: false))

            let ball = self.childNodeWithName("ball") as! SKSpriteNode
            let paddle = self.childNodeWithName("paddle") as! SKSpriteNode
            let relativePosition = ((ball.position.x - paddle.position.x) / paddle.size.width/2)

            let xImpulse = relativePosition * multiplier
            let impulseVector = CGVector(dx: xImpulse, dy: CGFloat(0))

            ball.physicsBody?.applyImpulse(impulseVector)
        }
    }

    func isGameWon() -> Bool
    {
        var bricksLeft = 0

        for nodeObject in self.children
        {
            let node = nodeObject as SKNode
            if node.name == "brick"
            {
                bricksLeft += 1
            }
        }
        return bricksLeft == 0
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        fingerIsOnPaddle = false
    }

    override func update(currentTime: CFTimeInterval)
    {
        scoreLabel.text = "Score: \(score)"
        let ball = self.childNodeWithName("ball") as! SKSpriteNode

        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)

        if speed > maxSpeed
        {
            ball.physicsBody!.linearDamping = 0.4
        }
        else
        {
            ball.physicsBody!.linearDamping = 0.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
