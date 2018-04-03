//
//  Declarations.swift
//  DoublePongMobile
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation
import AVFoundation

// Initialise all variables except for touch bar, intro, sound, and image variables

// Set debug to true to show debug elements
public let debug               = false
// Set reset to true to reset preferences on next run
public let reset               = false

// Initialise Bit Masks and the scene
public let scene               = Scene()
public let Ball:               UInt32 = 0x1 << 0
public let topPaddleI:         UInt32 = 0x1 << 1
public let leftPaddleI:        UInt32 = 0x1 << 2
public let rightPaddleI:       UInt32 = 0x1 << 3
public let bottomPaddleI:      UInt32 = 0x1 << 4
public let randomObstacleI:    UInt32 = 0x1 << 5

// Initislise preferences variables and pick a random color if a custom color isn't selected
public let prefs               = UserDefaults.standard
public let randomIndex         = colorArray.random()
public let randomColor:        UIColor = (!reset && prefs.getColor(key: "customColor") != nil) ? (prefs.getColor(key: "customColor"))! : UIColor(rgb: randomIndex!)

// Initialise SKNode variables (paddles and ball)
public var ball                = SKShapeNode(circleOfRadius: 30)
public var topPaddle           = SKSpriteNode()
public var leftPaddle          = SKSpriteNode()
public var rightPaddle         = SKSpriteNode()
public var bottomPaddle        = SKSpriteNode()
public var randomObstacle      = SKSpriteNode()

// Initialise main variables
public var score               = 0
public var lives               = 5
public var topScore:           Int = (!reset && prefs.object(forKey: "topScore") != nil) ? prefs.object(forKey: "topScore") as! Int : 0
public let colorArray          = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
public var gamePlaying         = true
public let verticalRand        = CGFloat(randomNumber(inRange: 325...755))
public let horizontalRan       = CGFloat(randomNumber(inRange: 325...1595))
public var motionEnabled:      Bool = (!reset && prefs.object(forKey: "motionEnabled") != nil) ? prefs.object(forKey: "motionEnabled") as! Bool : true
public var soundsEnabled:      Bool = (!reset && prefs.object(forKey: "soundsEnabled") != nil) ? prefs.object(forKey: "soundsEnabled") as! Bool : true

// Initialise buttons
public var muteButton          = UIButton()
public var pauseButton         = UIButton()
public var motionButton        = UIButton()
public var restartButton       = UIButton()
public var pauseButtonBig      = UIButton()
public var restartButtonBig    = UIButton()

// Initialise text fields and other controls
public var overLabel           = UILabel()
public var scoreLabel          = UILabel()
public var livesLabel          = UILabel()
public var pausedLabel         = UILabel()
public var curScoreLabel       = UILabel()
public var topScoreLabel       = UILabel()
public var colorPanel          = UIImageView()
public var colorSlider         = UISlider()

// Prepare the sounds with SKAction
public let pongSound           = SKAction.playSoundFileNamed("pong", waitForCompletion: false)
public let overSound           = SKAction.playSoundFileNamed("over", waitForCompletion: false)
public let wallSound           = SKAction.playSoundFileNamed("wall", waitForCompletion: false)

// Create images by inverting the colors of the template images (this reduces file size as less images need to be included in the playground)
public var playImage:          UIImage { return UIImage(named: "play.png")!.invert()! }
public var pauseImage:         UIImage { return UIImage(named: "pause.png")!.invert()! }
public var mutedImage:         UIImage { return UIImage(named: "muted.png")!.invert()! }
public var touchImage:         UIImage { return UIImage(named: "touch.png")!.invert()! }
public var motionImage:        UIImage { return UIImage(named: "motion.png")!.invert()! }
public var restartImage:       UIImage { return UIImage(named: "restart.png")!.invert()! }
public var unmutedImage:       UIImage { return UIImage(named: "unmuted.png")!.invert()! }

// Return a random number inside a range
public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}

// Add an extension to Array to allow Array.random()
public extension Array {
    func random() -> Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

// Add an RGB init to NSColor
public extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    public convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

// Allow easy storage of NSColors in UserDefaults
public extension UserDefaults {
    public func getColor(key: String) -> UIColor? {
        var color: UIColor?
        if let data = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
        }
        return color
    }
    public func setColor(_ color: UIColor?, forKey key: String) {
        var data: NSData?
        if let color = color {
            data = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(data, forKey: key)
    }
}

// Add NSImage extension to quickly invert colors on an image
public extension UIImage {
    public func invert() -> UIImage? {
        let cgImage = self.cgImage
        let ciImage = CoreImage.CIImage(cgImage: cgImage!)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputImageCopy)
    }
}
/*
extension UIImage {
    func invert() -> UIImage? {
        let img = CoreImage.CIImage(CGImage: self.CGImage!)
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setDefaults()
        filter.setValue(img, forKey: "inputImage")
        let context = CIContext(options:nil)
        let cgimg = context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent())
        return UIImage(CGImage: cgimg)
    }
}*/

// Creates a SKSpriteNode with a SKPhysicsBody
public extension SKNode {
    public func createNode(color: UIColor, size: CGSize, name: String, dynamic: Bool, friction: CGFloat, restitution: CGFloat, cBM: UInt32, cTBM: UInt32?, position: CGPoint? = nil) -> SKSpriteNode {
        let node                                    = SKSpriteNode(color: color, size: size)
        node.name                                   = name
        node.physicsBody                            = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.isDynamic                 = dynamic
        node.physicsBody!.friction                  = friction
        node.physicsBody!.restitution               = restitution
        node.physicsBody!.categoryBitMask           = cBM
        if (cTBM != nil) {
            node.physicsBody!.contactTestBitMask    = cTBM!
        }
        if (position != nil) {
            node.position                           = position!
        }
        return node
    }
}

public extension SKScene {
    // Adds multiple childs at once
    public func addChilds(_ childs: SKNode...){
        for child in childs { self.addChild(child) }
    }
    
    // Removes multiple childs at once
    public func removeChilds(_ childs: SKNode...){
        for child in childs { child.removeFromParent() }
    }
    
    // Adds multiple subviews at once
    public func addSubviews(_ views: UIView...){
        for view in views { self.view?.addSubview(view) }
    }
    
    // Removes multiple subviews at once
    public func removeSubviews(_ views: UIView...){
        for view in views { view.removeFromSuperview() }
    }
    
    //
    public func createButton(title: String = "Empty", size: Int = 18, color: UIColor = UIColor.clear, image: UIImage? = nil, action: Selector, transparent: Bool = true, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, hidden: Bool = false, radius: Int = 0) -> UIButton {
        let button                      = UIButton()
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor                    = .white
        button.isHidden                     = hidden
        button.frame                        = CGRect(x: x, y: y, width: width, height: height)
        if (title != "Empty") {
            button.setTitle(title, for: .normal)
            button.clipsToBounds            = true
            button.layer.cornerRadius       = CGFloat(radius)
            button.backgroundColor          = color
        } else { button.setImage(image, for: .normal) }
        return button
    }
    
    //
    public func updateButton(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
    }
    
    // Quickly creates a UILabel with all needed options
    public func createLabel(title: String, align: Int = 2, size: CGFloat, color: UIColor, hidden: Bool = false, bold: Bool = false, x: Double? = nil, y: Double? = nil, width: Double? = nil, height: Double? = nil) -> UILabel {
        let label               = UILabel()
        label.font              = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
        label.isHidden          = hidden
        label.textColor         = color
        label.textAlignment     = align == 2 ? .center : (align == 3 ? .right : .left)
        label.text              = title
        if (x != nil && y != nil) {
            if (width != nil && height != nil) {
                label.frame = CGRect(x: x!, y: y!, width: width!, height: height!)
            } else {
                label.sizeToFit()
                label.frame.origin = CGPoint(x: x!, y: y!)
            }
        } else {
            label.sizeToFit()
        }
        return label
    }
}

