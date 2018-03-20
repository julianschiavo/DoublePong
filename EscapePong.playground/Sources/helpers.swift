import AppKit
import SpriteKit
import Foundation

// Initialise variables and constants
public let Ball:               UInt32 = 0x1 << 0
public let Block:              UInt32 = 0x1 << 1
public let topPaddleI:         UInt32 = 0x1 << 2
public let leftPaddleI:        UInt32 = 0x1 << 3
public let rightPaddleI:       UInt32 = 0x1 << 4
public let bottomPaddleI:      UInt32 = 0x1 << 5

// Initialise main variables
public var score               = 0
public var lives               = 5
public let amount              = CGFloat(7)
public var topScore            = 0
public var nextSlide           = 1
public let colorArray          = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
public var gamePaused          = false
public var isOnBoarding        = true
public let verticalRand        = CGFloat(arc4random_uniform(250) + 50)
public let horizontalRand      = CGFloat(arc4random_uniform(600) + 300)

// Initialise NSView variables
public var overLabel           = NSTextField()
public var scoreLabel          = NSTextField()
public var livesLabel          = NSTextField()
public var colorPanel          = NSImageView()
public var colorSlider         = NSSlider()
public var pausedLabel         = NSTextField()
public var pauseButton         = NSButton()
public var tScoreLabel         = NSTextField()
public var onBoardTitle        = NSTextField()
public var onBoardClick        = NSTextField()
public var restartButton       = NSButton()
//public var settingsButton      = NSButton()
public var onBoardDescription  = NSTextField()

// Initialise SKNode variables
public var ball                = SKShapeNode(circleOfRadius: 30)
public var topPaddle           = SKSpriteNode()
public var leftPaddle          = SKSpriteNode()
public var rightPaddle         = SKSpriteNode()
public var bottomPaddle        = SKSpriteNode()


public extension Array {
    func random() -> Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

public extension SKNode {
    // Creates a SKSpriteNode with a SKPhysicsBody
    func createNode(color: NSColor, size: CGSize, name: String, dynamic: Bool, friction: CGFloat, restitution: CGFloat, cBM: UInt32, cTBM: UInt32?) -> SKSpriteNode {
        let node                            = SKSpriteNode(color: color, size: size)
        node.name                           = name
        node.physicsBody                    = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.isDynamic         = dynamic
        node.physicsBody!.friction          = friction
        node.physicsBody!.restitution       = restitution
        node.physicsBody!.categoryBitMask   = cBM
        if (cTBM != nil) {
            node.physicsBody!.contactTestBitMask = cTBM!
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
    func createButton(image: NSImage, action: Selector, transparent: Bool = true, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, hidden: Bool = false) -> NSButton {
        let button                  = NSButton(image: image, target: self, action: action)
        button.isHidden             = hidden
        button.isTransparent        = transparent
        button.frame                = NSRect(x: x, y: y, width: width, height: height)
        
        let buttonCell:NSButtonCell = button.cell as! NSButtonCell
        buttonCell.bezelStyle       = NSButton.BezelStyle.rounded
        return button
    }
    
    // Quickly creates a NSTextField with all needed options
    func createLabel(title: String, size: CGFloat, color: NSColor, hidden: Bool = false, x: Double? = nil, y: Double? = nil, width: Double? = nil, height: Double? = nil) -> NSTextField {
        let label               = NSTextField()
        label.font              = NSFont.systemFont(ofSize: size)
        label.isHidden          = hidden
        label.isBezeled         = false
        label.textColor         = color
        label.alignment         = .center
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
    
    // Sets a label to the specified value, then sizes and positions it perfectly
    func setLabel(label: NSTextField, value: String, which: String?) {
        label.stringValue = value
        label.sizeToFit()
        if (which == "scoreLabel") {
            label.frame.origin = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
        } else if (which == "livesLabel") {
            label.frame.origin = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width - 5, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 12)
        } else if (which == "tScoreLabel") {
            label.frame.origin = CGPoint(x: ((self.view?.frame.width)! / 2) - (label.frame.width / 2), y: (((self.view?.frame.height)! / 2) - 30) - 10)
        }
    }
}
