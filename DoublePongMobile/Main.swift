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
            scene.scaleMode = .aspectFit
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
                    let xLocation = UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ? CGFloat((data?.gravity.y)!) * 1000) : 960 - (CGFloat((data?.gravity.y)!) * 1000)
                    let xPosition = (xLocation < 1920 - 85 - topPaddle.size.width / 2 && xLocation > topPaddle.size.width / 2 + 85) ? xLocation : ((xLocation > 1920 - 85 - topPaddle.size.width / 2) ? 1920 - 25 - topPaddle.size.width / 2 : topPaddle.size.width / 2 + 25)
                    topPaddle.position.x = xPosition
                    bottomPaddle.position.x = xPosition
                    let yLocation = UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ? 960 - (CGFloat((data?.gravity.x)!) * 1000) : 960 + (CGFloat((data?.gravity.x)!) * 1000)
                    let yPosition = (yLocation < 1080 - 85 - leftPaddle.size.height / 2 && yLocation > leftPaddle.size.height / 2 + 85) ? yLocation : ((yLocation > 1080 - 85 - leftPaddle.size.height / 2) ? 1080 - 27 - leftPaddle.size.height / 2 : leftPaddle.size.height / 2 + 25)
                    leftPaddle.position.y = yPosition
                    rightPaddle.position.y = yPosition
                }
            }
        }
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
