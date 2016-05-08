//
//  gameOverScene.swift
//  Breakout
//
//  Created by Roman on 5/7/16.
//  Copyright © 2016 Roman Puzey. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    var level = 1
    var score = 0

    init(size: CGSize, playerWon: Bool, level: Int, score: Int)
    {
        super.init(size: size)

        self.level = level
        self.score = score

        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(background)

        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))

        if level == 0
        {
            gameOverLabel.text = "Tap to start the game"
        }
        else if playerWon
        {
            gameOverLabel.text = "YOU WIN! Next Level"
        }
        else if level == 2 || !playerWon
        {
            gameOverLabel.text = "GAME OVER!"
            self.level = 1
        }
        else
        {
            gameOverLabel.text = "You've beaten the game"
            self.level = 1
        }

        self.addChild(gameOverLabel)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if level == 2
        {
            let gameScene = GameScene(size: self.size, level: 2, score: score)
            gameScene.scaleMode = .AspectFill
            self.view?.presentScene(gameScene)
        }
        else if level == 3
        {
            let gameScene = GameScene(size: self.size, level: 3, score: score)
            gameScene.scaleMode = .AspectFill
            self.view?.presentScene(gameScene)
        }
        else
        {
            let gameScene = GameScene(size: self.size, level: 1, score:  score)
            gameScene.scaleMode = .AspectFill
            self.view?.presentScene(gameScene)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}