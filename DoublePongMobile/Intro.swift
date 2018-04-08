//
//  Intro.swift
//  DoublePongMobile
//
//  Created by Julian Schiavo on 3/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation
import AVFoundation

// Initialise intro-related variables
public var isIntro:            Bool = (!reset && prefs.object(forKey: "isIntro") != nil) ? prefs.object(forKey: "isIntro") as! Bool : true
public var nextIntro:          Int = (!reset && prefs.object(forKey: "nextIntro") != nil) ? (prefs.object(forKey: "nextIntro") as! Int == 6 ? 6 : 1)  : 1
public var introTitle          = UILabel()
public var introButton         = UIButton()
public var introDescription    = UILabel()

public extension Scene {
    // Change the intro screen when the continue button is pressed
    @objc public func changeSlide() {
        if isIntro {
            introGame()
        } else if nextIntro == 6 {
            beginGame()
            nextIntro = 0
        }
    }
    
    // Show the intro screens and update the different titles and descriptions
    public func introGame() {
        if isIntro {
            if nextIntro == 1 {
                introTitle                      = UILabel(title: "Welcome", size: 60.0, color: UIColor.white, hidden: false, bold: true)
                introTitle.frame                = CGRect(x: ((self.view?.frame.width)! / 2) - 200, y: 30 + (view!.frame.height / 2) - 130, width: 400, height: 72)
                introDescription                = UILabel(title: "Welcome to DoublePong - Pong, with even more paddles.", size: 20.0, color: UIColor.white, hidden: false)
                introDescription.frame          = CGRect(x: ((self.view?.frame.width)! / 2) - 225, y: (((self.view?.frame.height)! / 2) - 60) + 10, width: 450, height: 120)
                introDescription.numberOfLines  = 0
                introButton                     = UIButton(title: "Continue", color: UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.changeSlide), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (self.view?.frame.height)! / 2 + 80, width: 280, height: 45, radius: 18)
                addSubviews(introTitle, introDescription, introButton)
            } else if nextIntro == 2 { introTitle.text = "Controls"
                introDescription.text    = "Pause the game with the pause button, and mute or unmute game sounds with the volume button.\nChange the game color in the pause menu."
            } else if nextIntro == 3 { introTitle.text = "Paddles"
                introDescription.text    = "There are 4 paddles, positioned on each edge of the screen. Touch and drag to move the paddles, and try to block the ball from hitting the edges."
            } else if nextIntro == 4 { introTitle.text = "Motion"
                introDescription.text    = "Touch the motion control button to play the game by tilting your device. If it stops working, put your device on a flat surface for 5 seconds."
            } else if nextIntro == 5 { introTitle.text = "Difficulty"
                introDescription.text    = "The game will constantly get faster and harder. Invisible obstacles will be added after 500 points.\nPress play below to start playing!"
                introButton.setTitle("Play", for: .normal)
                isIntro                         = false
                prefs.set(isIntro, forKey: "isIntro")
            }
            nextIntro                           += 1
            prefs.set(nextIntro, forKey: "nextIntro")
        } else {
            beginGame()
        }
    }
}
