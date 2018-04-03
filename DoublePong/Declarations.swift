//
//  Declarations.swift
//  DoublePong
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import AppKit
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
public let randomColor:        NSColor = (!reset && prefs.getColor(key: "customColor") != nil) ? (prefs.getColor(key: "customColor"))! : NSColor(rgb: randomIndex!)

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
public var soundsEnabled:      Bool = (!reset && prefs.object(forKey: "soundsEnabled") != nil) ? prefs.object(forKey: "soundsEnabled") as! Bool : true

// Initialise buttons
public var muteButton          = NSButton()
public var pauseButton         = NSButton()
public var restartButton       = NSButton()
public var pauseButtonBig      = NSButton()
public var restartButtonBig    = NSButton()

// Initialise text fields and other controls
public var overLabel           = NSTextField()
public var scoreLabel          = NSTextField()
public var livesLabel          = NSTextField()
public var pausedLabel         = NSTextField()
public var curScoreLabel       = NSTextField()
public var topScoreLabel       = NSTextField()
public var colorPanel          = NSImageView()
public var colorSlider         = NSSlider()

// Prepare the sounds with SKAction
public let pongSound           = SKAction.playSoundFileNamed("pong", waitForCompletion: false)
public let overSound           = SKAction.playSoundFileNamed("over", waitForCompletion: false)
public let wallSound           = SKAction.playSoundFileNamed("wall", waitForCompletion: false)

// Create images by inverting the colors of the template images (this reduces file size as less images need to be included in the playground)
public var playImage:          NSImage { return NSImage(named: NSImage.Name.touchBarPlayTemplate)!.invert()! }
public var pauseImage:         NSImage { return NSImage(named: NSImage.Name.touchBarPauseTemplate)!.invert()! }
public var mutedImage:         NSImage { return NSImage(named: NSImage.Name.touchBarAudioOutputMuteTemplate)!.invert()! }
public var replayImage:        NSImage { return NSImage(named: NSImage.Name.touchBarRefreshTemplate)!.invert()! }
public var unmutedImage:       NSImage { return NSImage(named: NSImage.Name.touchBarVolumeUpTemplate)!.invert()! }

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
public extension NSColor {
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
    public func getColor(key: String) -> NSColor? {
        var color: NSColor?
        if let data = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor
        }
        return color
    }
    public func setColor(_ color: NSColor?, forKey key: String) {
        var data: NSData?
        if let color = color {
            data = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(data, forKey: key)
    }
}

// Create a color list with an array of RGB colors
public func createColorList(array: [Int]) -> NSColorList {
    let newColorList = NSColorList()
    for (i, color) in array.enumerated() {
        newColorList.insertColor(NSColor(rgb: color), key: NSColor.Name(String(color)), at: i)
    }
    return newColorList
}

// Add NSImage extension to quickly invert colors on an image
public extension NSImage {
    public func invert() -> NSImage? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let ciImage = CoreImage.CIImage(cgImage: cgImage!)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return NSImage(cgImage: outputImageCopy, size: NSSize(width:outputImageCopy.width, height:outputImageCopy.height))
    }
}

// Creates a SKSpriteNode with a SKPhysicsBody
public extension SKNode {
    public func createNode(color: NSColor, size: CGSize, name: String, dynamic: Bool, friction: CGFloat, restitution: CGFloat, cBM: UInt32, cTBM: UInt32?, position: CGPoint? = nil) -> SKSpriteNode {
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
    public func addSubviews(_ views: NSView...){
        for view in views { self.view?.addSubview(view) }
    }
    
    // Removes multiple subviews at once
    public func removeSubviews(_ views: NSView...){
        for view in views { view.removeFromSuperview() }
    }
    
    // Return the character pressed on the keyboard
    public func returnChar(event: NSEvent) -> Character?{
        let s: String = event.characters!
        for char in s{
            return char
        }
        return nil
    }
    
    // Creates a NSButton with a NSButtonCell
    public func createButton(title: String = "Empty", size: Int = 18, color: NSColor = NSColor.clear, image: NSImage? = nil, action: Selector, transparent: Bool = true, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, hidden: Bool = false, radius: Int = 0) -> NSButton {
        let button                      = image != nil ? NSButton(image: (image)!, target: self, action: action) : NSButton(title: title, target: self, action: action)
        button.isHidden                 = hidden
        button.isTransparent            = transparent
        button.frame                    = NSRect(x: x, y: y, width: width, height: height)
        if (title != "Empty") {
            button.wantsLayer               = true
            button.isBordered               = false
            button.layer?.cornerRadius      = CGFloat(radius)
            button.layer?.masksToBounds     = true
            button.layer?.backgroundColor   = color.cgColor
            if let mutableAttributedTitle   = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: mutableAttributedTitle.length))
                mutableAttributedTitle.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(size)), range: NSRange(location: 0, length: mutableAttributedTitle.length))
                button.attributedTitle      = mutableAttributedTitle
            }
        }
        let buttonCell:NSButtonCell     = button.cell as! NSButtonCell
        buttonCell.bezelStyle           = NSButton.BezelStyle.rounded
        return button
    }
    
    // Creates a NSButton with a NSButtonCell
    public func updateButton(button: NSButton, title: String, size: Int = 18) {
        button.title = title
        if let mutableAttributedTitle   = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: mutableAttributedTitle.length))
            mutableAttributedTitle.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(size)), range: NSRange(location: 0, length: mutableAttributedTitle.length))
            button.attributedTitle      = mutableAttributedTitle
        }
    }
    
    // Quickly creates a NSTextField with all needed options
    public func createLabel(title: String, align: Int = 2, size: CGFloat, color: NSColor, hidden: Bool = false, bold: Bool = false, x: Double? = nil, y: Double? = nil, width: Double? = nil, height: Double? = nil) -> NSTextField {
        let label               = NSTextField()
        label.font              = bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size)
        label.isHidden          = hidden
        label.isBezeled         = false
        label.textColor         = color
        label.alignment         = align == 2 ? .center : (align == 3 ? .right : .left)
        label.isEditable        = false
        label.stringValue       = title
        label.drawsBackground   = false
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

