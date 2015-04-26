//
//  GameViewController.swift
//  Flappy Duck - Have Fun
//
//  Created by Gregory Lampa on 26/04/2015.
//  Copyright (c) 2015 Gregory Lampa. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skView = self.view as? SKView {
            
            if skView.scene == nil {
                let aspectRatio = skView.bounds.size.height / skView.bounds.size.width
                
                let scene = GameScene(size:CGSize(width: 320, height: 320 * aspectRatio))
                
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsPhysics = true
                skView.ignoresSiblingOrder = true
                
                scene.scaleMode = .AspectFill
                skView.presentScene(scene)
            }
            
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func screenshot() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    
    func shareString(string: String, url: NSURL, image: UIImage) {
        let vc = UIActivityViewController(activityItems: [string,url, image], applicationActivities: nil)
        presentViewController(vc, animated: true, completion: nil)
    }
}
