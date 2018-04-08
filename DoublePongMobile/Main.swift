//
//  GameViewController.swift
//  DoublePongMobile
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion
import GameplayKit

class GameViewController: UIViewController {
    let manager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            scene.size = CGSize(width: 1920, height: 1080)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
        
        // If reset is true (in Declarations.swift), reset all the UserDefaults
        if reset {
            prefs.set(nil, forKey: "isIntro")
            prefs.set(nil, forKey: "topScore")
            prefs.set(nil, forKey: "nextIntro")
            prefs.set(nil, forKey: "customColor")
            prefs.set(nil, forKey: "motionEnabled")
            prefs.set(nil, forKey: "soundsEnabled")
        }
        
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                (data: CMDeviceMotion?, error: Error?) in
                if (motionEnabled) {
                    let xLocation = UIApplication.shared.statusBarOrientation == .landscapeLeft ? scene.size.width / 2 + CGFloat((data?.gravity.y)!) * 1000 : scene.size.width / 2 - CGFloat((data?.gravity.y)!) * 1000
                    let yLocation = UIApplication.shared.statusBarOrientation == .landscapeLeft ? scene.size.width / 2 - (CGFloat((data?.gravity.x)!) * 1000) : scene.size.width / 2 + (CGFloat((data?.gravity.x)!) * 1000)
                    scene.positionChanged(xLocation, yLocation)
                    /*
                    let xPosition = (xLocation < width - modifier - topPaddle.frame.width / 2 && xLocation > topPaddle.frame.width / 2 + modifier) ? xLocation : ((xLocation > width - modifier - topPaddle.frame.width / 2) ? width - setToH - topPaddle.frame.width / 2 : topPaddle.frame.width / 2 + setToH)
                    topPaddle.position.x = xPosition
                    bottomPaddle.position.x = xPosition
                    let yPosition = (yLocation < height - modifier - leftPaddle.frame.height / 2 && yLocation > leftPaddle.frame.height / 2 + modifier) ? yLocation : ((yLocation > height - modifier - leftPaddle.frame.height / 2) ? height - setToV - leftPaddle.frame.height / 2 : leftPaddle.frame.height / 2 + setToV)
                    leftPaddle.position.y = yPosition
                    rightPaddle.position.y = yPosition*/
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        var sceneBound = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: 18, y: 18), size: CGSize(width: scene.size.width - 36, height: scene.size.height - 36)))
        if #available(iOS 11.0, *) {
            safeTop = CGFloat((self.view?.safeAreaInsets.top)!)
            safeLeft = CGFloat((self.view?.safeAreaInsets.left)!)
            safeRight = CGFloat((self.view?.safeAreaInsets.right)!)
            safeBottom = CGFloat((self.view?.safeAreaInsets.bottom)!)
            topPaddle.position.y = topPaddle.position.y - safeTop
            leftPaddle.position.x = leftPaddle.position.x + safeLeft
            rightPaddle.position.x = rightPaddle.position.x - safeRight
            bottomPaddle.position.y = bottomPaddle.position.y + safeBottom
            setToH += (safeLeft + safeRight) / 2
            setToV += (safeTop + safeBottom) / 2
            
            sceneBound = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: 18 + safeLeft, y: 18 + safeBottom), size: CGSize(width: scene.size.width - 36 - safeLeft - safeRight, height: scene.size.height - 36 - safeTop - safeBottom)))
        }
        sceneBound.friction                     = 0
        sceneBound.restitution                  = 0
        scene.physicsBody                       = sceneBound
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
