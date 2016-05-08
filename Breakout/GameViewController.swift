//
//  GameViewController.swift
//  Breakout
//
//  Created by Roman on 4/9/16.
//  Copyright (c) 2016 Roman Puzey. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView

        if skView.scene == nil
        {
            skView.showsFPS = true
            skView.showsNodeCount = true

            let gameOverScene = GameOverScene(size: skView.bounds.size, playerWon: true, level: 0, score: 0)
            
            gameOverScene.scaleMode = .AspectFill
            skView.presentScene(gameOverScene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
