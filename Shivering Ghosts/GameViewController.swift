//
//  GameViewController.swift
//  Shivering Ghosts
//
//  Created by cemal hekimoglu on 23.12.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create scene programmatically for better control
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene
        if let view = self.view as? SKView {
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Debug info - disable for release
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #else
            view.showsFPS = false
            view.showsNodeCount = false
            #endif
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Portrait only for hyper-casual experience
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}
