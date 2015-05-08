//
//  GameViewController.swift
//  Flappy Duck - Have Fun
//
//  Created by Gregory Lampa on 26/04/2015.
//  Copyright (c) 2015 Gregory Lampa. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GameSceneDelegate, GADInterstitialDelegate {
    
    private var interstitial: GADInterstitial?

    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = createInterstitial()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skView = self.view as? SKView {
            
            if skView.scene == nil {
                let aspectRatio = skView.bounds.size.height / skView.bounds.size.width
                
                let scene = GameScene(size:CGSize(width: 320, height: 320 * aspectRatio), delegate: self, gameState: .MainMenu)
                
//                skView.showsFPS = true
//                skView.showsNodeCount = true
//                skView.showsPhysics = true
//                skView.ignoresSiblingOrder = true
                
                scene.scaleMode = .AspectFill
                skView.presentScene(scene)
            }
            
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6032654838692373/5394764440")
        interstitial.delegate = self
        let request = GADRequest()
        /* To serve test ads on your physical device (and you really should be!) uncomment the line below, and then copy and paste the UUID
        printed to the log when the app first starts. Look for the message starting "<Google> To get test ads on this device..." */
         request.testDevices = ["56D7C673-E2AF-4FAC-98F4-ECACBA5FEFE6"] 
        interstitial.loadRequest(request)
        return interstitial
    }
    
    // MARK: GADInterstitialDelegate
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        interstitial = createInterstitial()
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        /* Note: When running on the iOS simulator AdMob don't mediate, so you'll only ever see GADMAdapterGoogleAdMobAds printed here */
        println("Serving interstitial ad of type: \(ad.adNetworkClassName)")
    }
    
    
    func screenshot() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    
    
    func shareString(string: String, url: NSURL, image: UIImage) {
        let vc = UIActivityViewController(activityItems: [string, url, image], applicationActivities: nil)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func didShowScore() {
        if let interstitial = interstitial {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1.4 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                if interstitial.isReady {
                    interstitial.presentFromRootViewController(self)
                }
            }
        }
    }
    
}