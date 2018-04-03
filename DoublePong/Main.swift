//
//  Main.swift
//  DoublePong
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import Cocoa
import AppKit
import SpriteKit
import Foundation
import AVFoundation

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            scene.scaleMode = .fill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }

        // If reset is true (in Declarations.swift), reset all the UserDefaults
        if reset {
            prefs.set(nil, forKey: "isIntro")
            prefs.set(nil, forKey: "topScore")
            prefs.set(nil, forKey: "nextIntro")
            prefs.set(nil, forKey: "customColor")
            prefs.set(nil, forKey: "soundsEnabled")
        }
    }
    
    override func viewDidAppear() {
        view.window?.delegate = self
        view.window?.aspectRatio = NSSize(width: (view.window?.frame.width)!, height: (view.window?.frame.height)!)
    }
    
    func windowDidResize(_ notification: Notification) {
        muteButton.frame.origin.x               = view.frame.width - 47
        scoreLabel.frame.origin.y               = view.frame.height - 24 - 9
        
        overLabel.frame.origin                  = CGPoint(x: view.frame.width / 2 - 250, y: view.frame.height / 2 + 30 - 50)
        livesLabel.frame.origin                 = CGPoint(x: view.frame.width - 113 - 9, y: view.frame.height - 19 - 9)
        colorPanel.frame.origin                 = CGPoint(x: view.frame.width / 2 - 175, y: view.frame.height / 2 - 40)
        colorSlider.frame.origin                = CGPoint(x: view.frame.width / 2 - 175, y: view.frame.height / 2 - 40)
        pausedLabel.frame.origin                = CGPoint(x: view.frame.width / 2 - 250, y: view.frame.height / 2 + 30 - 50)
        curScoreLabel.frame.origin              = CGPoint(x: view.frame.width / 2 - 260, y: view.frame.height / 2 - 65)
        topScoreLabel.frame.origin              = CGPoint(x: view.frame.width / 2 - 260, y: view.frame.height / 2 - 100)
        pauseButtonBig.frame.origin             = CGPoint(x: view.frame.width / 2 - 140, y: view.frame.height / 2 - 8 - 130)
        restartButtonBig.frame.origin           = CGPoint(x: view.frame.width / 2 - 140, y: view.frame.height / 2 - 8 - 130)
    }
}

