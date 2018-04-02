import AppKit
import SpriteKit
import Foundation
import AVFoundation

// Initialise intro-related variables
public var isIntro:            Bool = (!reset && prefs.object(forKey: "isIntro") != nil) ? prefs.object(forKey: "isIntro") as! Bool : true
public var nextIntro:          Int = (!reset && prefs.object(forKey: "nextIntro") != nil) ? (prefs.object(forKey: "nextIntro") as! Int == 5 ? 5 : 1)  : 1
public var introTitle          = NSTextField()
public var introButton         = NSButton()
public var introProgress       = NSProgressIndicator()
public var introDescription    = NSTextField()

public extension Scene {
    // Change the intro screen when the continue button is pressed
    @objc public func changeSlide() {
        if isIntro {
            introGame()
        } else if nextIntro == 5 {
            beginGame()
            nextIntro = 0
        }
    }
    
    // Show the intro screens and update the different titles and descriptions
    public func introGame() {
        if isIntro {
            if nextIntro == 1 {
                introTitle                      = createLabel(title: "Welcome", size: 60.0, color: NSColor.white, hidden: false, bold: true)
                introTitle.frame                = NSRect(x: ((self.view?.frame.width)! / 2) - 200, y: 90 + ((self.view?.frame.height)! / 2) - 36, width: 400, height: 72)
                introDescription                = createLabel(title: "Welcome to DoublePong - Pong, with even more paddles.", size: 20.0, color: NSColor.white, hidden: false)
                introDescription.frame          = NSRect(x: ((self.view?.frame.width)! / 2) - 300, y: (((self.view?.frame.height)! / 2) - 60) - 20, width: 600, height: 120)
                introButton                     = createButton(title: "Continue", color: NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.changeSlide), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (((self.view?.frame.height)! / 2) - 8) - 130, width: 280, height: 45, radius: 18)
                introProgress.style             = NSProgressIndicator.Style.bar
                introProgress.isIndeterminate   = false
                introProgress.minValue          = 0
                introProgress.maxValue          = 4
                introProgress.frame             = NSRect(x: 0, y: 0, width: (self.view?.frame.width)!, height: 5)
                introProgress.increment(by: 1)
                addSubviews(introTitle, introDescription, introButton, introProgress)
            } else if nextIntro == 2 { introTitle.stringValue = "Controls"
                introDescription.stringValue    = "Pause the game by pressing the space bar or the pause button.\nUse the volume button to mute or unmute game sounds.\nUse the color picker in the pause menu or the Touch Bar to change the color of the paddles and ball."
                introProgress.increment(by: 1)
            } else if nextIntro == 3 { introTitle.stringValue = "Paddles"
                introDescription.stringValue    = "There are 4 paddles, positioned on each edge of the screen. Move your cursor to move the paddles, and try to block the ball from hitting the edges."
                introProgress.increment(by: 1)
            } else if nextIntro == 4 { introTitle.stringValue = "Difficulty"
                introDescription.stringValue    = "The game will constantly get faster and harder. Invisible obstacles will be added after 500 points.\n\nPress play below to start playing!"
                updateButton(button: introButton, title: "Play")
                introProgress.increment(by: 1)
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
