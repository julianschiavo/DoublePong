import SpriteKit
import AppKit
import PlaygroundSupport

class Scene: SKScene, SKPhysicsContactDelegate {
    let Ball: UInt32 = 0x1 << 0
    let Block: UInt32 = 0x1 << 1
    let topStickI: UInt32 = 0x1 << 2
    let leftStickI: UInt32 = 0x1 << 3
    let rightStickI: UInt32 = 0x1 << 4
    let bottomStickI: UInt32 = 0x1 << 5
    
    // Initialise all the main variables and constants.
    var score = 0
    var lives = 5
    var nextSlide = 1
    var isOnBoarding = true
    var disableMouseMove = false
    let verticalRand: CGFloat = CGFloat(arc4random_uniform(250) + 50)
    let horizontalRand: CGFloat = CGFloat(arc4random_uniform(600) + 300)
    
    var overLabel = NSTextField()
    var scoreLabel = NSTextField()
    var livesLabel = NSTextField()
    var onBoardTitle = NSTextField()
    var onBoardDescription = NSTextField()
    var onBoardClick = NSTextField()
    
    var ball = SKShapeNode(circleOfRadius: 30)
    var topStick = SKSpriteNode()
    var leftStick = SKSpriteNode()
    var rightStick = SKSpriteNode()
    var bottomStick = SKSpriteNode()
    var restartButton: NSButton?
    
    // Adds multiple childs at once
    func addChilds(_ childs: SKNode...) {
        for child in childs { self.addChild(child) }
    }
    
    // Removes multiple childs at once
    func removeChilds(_ childs: SKNode...) {
        for child in childs { child.removeFromParent() }
    }
    
    // Adds multiple subviews at once
    func addSubviews(_ views: NSView...) {
        for view in views { self.view?.addSubview(view) }
    }
    
    // Removes multiple subviews at once
    func removeSubviews(_ views: NSView...) {
        for view in views { view.removeFromSuperview() }
    }
    
    // Quickly creates a NSTextField with all needed options
    func createLabel(title: String, size: CGFloat, color: NSColor, x: Double?, y: Double?, width: Double?, height: Double?, hidden: Bool) -> NSTextField {
        let label = NSTextField()
        label.stringValue = title
        label.isEditable = false
        label.drawsBackground = false
        label.isBezeled = false
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: size)
        label.textColor = color
        if (hidden) {
            label.isHidden = true
        }
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
        }
    }
    
    // Creates a SKSpriteNode with a SKPhysicsBody
    func createNode(color: NSColor, size: CGSize, name: String, dynamic: Bool, friction: CGFloat, restitution: CGFloat, cBM: UInt32, cTBM: UInt32?) -> SKSpriteNode {
        let node = SKSpriteNode(color: color, size: size)
        node.name = name
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.isDynamic = dynamic
        node.physicsBody!.friction = friction
        node.physicsBody!.restitution = restitution
        node.physicsBody!.categoryBitMask = cBM
        if (cTBM != nil) {
            node.physicsBody!.contactTestBitMask = cTBM!
        }
        return node
    }
    
    // Begin game by removing onBoarding screen and adding all the elements, especially the ball.
    @objc func beginGame() {
        if (!isOnBoarding) {
            restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
            addChilds(ball, topStick, bottomStick, leftStick, rightStick)
            addSubviews(livesLabel, overLabel, scoreLabel, restartButton!)
            removeSubviews(onBoardTitle, onBoardDescription, onBoardClick)
        }
    }
    
    // Restart the game when restart button is pressed. Similar to beginGame(), also resets ball position/velocity.
    @objc func restartGame(event: NSEvent) {
        if (isOnBoarding == false) {
            removeChilds(ball, topStick, bottomStick, leftStick, rightStick)
            removeSubviews(livesLabel, overLabel, scoreLabel, restartButton!)
            
            score = 1
            lives = 5
            overLabel.isHidden = true
            livesLabel.isHidden = false
            ball.physicsBody!.velocity = CGVector(dx: 400, dy: 400)
            setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
            setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
            
            restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
            addSubviews(scoreLabel)
            addChilds(ball, topStick, bottomStick, leftStick, rightStick)
        }
    }
    
    // If mouse is clicked, show next onBoarding screen, or begin game.
    override func mouseDown(with event: NSEvent) {
        if (isOnBoarding) {
            onBoarding()
        } else if (nextSlide == 6){
            beginGame()
            nextSlide = 0
        }
    }
    
    // If mouse is moved, move all paddles based on new mouse location.
    override func mouseMoved(with event: NSEvent) {
        let tLocation = event.location(in: self)
        topStick.position.x = tLocation.x
        bottomStick.position.x = tLocation.x
        leftStick.position.y = tLocation.y
        rightStick.position.y = tLocation.y
    }
    
    // Show onBoarding (instruction/initial) screens, and set the different titles and descriptions.
    func onBoarding() {
        if (isOnBoarding) {
            if nextSlide == 1 {
                onBoardTitle = createLabel(title: "Hello", size: 60.0, color: NSColor.white, x: nil, y: nil, width: nil, height: nil, hidden: false)
                onBoardTitle.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 150, y: 90 + ((self.view?.frame.height)! / 2) - 36, width: 300, height: 72)
                onBoardDescription = createLabel(title: "Welcome to DoublePong, my 2018 WWDC Scholarship submission.\n\nDoublePong is Pong - with double the amount of paddles!", size: 20.0, color: NSColor.white, x: nil, y: nil, width: nil, height: nil, hidden: false)
                onBoardDescription.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 275, y: (((self.view?.frame.height)! / 2) - 50) - 20, width: 550, height: 100)
                onBoardClick = createLabel(title: "press anywhere to continue", size: 12.0, color: NSColor.lightGray, x: nil, y: nil, width: nil, height: nil, hidden: false)
                onBoardClick.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 100, y: (((self.view?.frame.height)! / 2) - 8) - 140, width: 200, height: 16)
                addSubviews(onBoardTitle, onBoardDescription, onBoardClick)
            } else if nextSlide == 2 { onBoardTitle.stringValue = "Playing"
                onBoardDescription.stringValue = "Let's quickly learn the basics of DoublePong!"
            } else if nextSlide == 3 { onBoardTitle.stringValue = "Paddles"
                onBoardDescription.stringValue = "You have 4 paddles, one on each of the four sides of the screen. Move your cursor horizontally to move the top and bottom paddles, or vertically to move the left and right paddles!"
                addChilds(topStick, bottomStick, leftStick, rightStick)
            } else if nextSlide == 4 { onBoardTitle.stringValue = "Objective"
                onBoardDescription.stringValue = "Your objective is to block the white ball from touching the edges of the screen. The ball will continously become faster, and the faster it is, the more points you get when it touches a paddle."
                addSubviews(livesLabel, overLabel, scoreLabel)
            } else if nextSlide == 5 { onBoardTitle.stringValue = "Good Luck"
                onBoardDescription.stringValue = "Now that the tutorial is over... let the game begin!"
                onBoardClick.stringValue = "press anywhere to release ball"
                onBoardClick.textColor = NSColor.red
                removeChilds(topStick, bottomStick, leftStick, rightStick)
                removeSubviews(livesLabel, overLabel, scoreLabel)
                isOnBoarding = false
            }
            
            nextSlide += 1
        } else {
            beginGame()
            disableMouseMove = true
        }
    }
    
    // Most main functions - initialise different elements, paddles, labels, and buttons, then show onBoarding screen.
    override func didMove(to view: SKView) {
        let options = [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved] as NSTrackingArea.Options
        let trackingArea = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
        
        self.size = CGSize(width: 1920, height: 1080)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let sceneBound = SKPhysicsBody(edgeLoopFrom: self.frame)
        sceneBound.friction = 0
        sceneBound.restitution = 0
        self.physicsBody = sceneBound
 
        ball.fillColor = .white
        ball.name = "ball"
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.categoryBitMask = Ball
        ball.physicsBody!.contactTestBitMask = Block
        ball.physicsBody!.friction = 0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.velocity = CGVector(dx: 400, dy: 400)
        ball.position = CGPoint(x: 0.6 * self.size.width, y: 0.6 * self.size.height)
        
        topStick = createNode(color: NSColor.green, size: CGSize(width: 400, height: 50), name: "topStick", dynamic: false, friction: 0, restitution: 1, cBM: topStickI, cTBM: Ball)
        topStick.position = CGPoint(x: horizontalRand, y: frame.maxY - topStick.size.height)
        
        bottomStick = createNode(color: NSColor.green, size: CGSize(width: 400, height: 50), name: "bottomStick", dynamic: false, friction: 0, restitution: 1, cBM: bottomStickI, cTBM: Ball)
        bottomStick.position = CGPoint(x: horizontalRand, y: frame.minY + bottomStick.size.height)
        
        leftStick = createNode(color: NSColor.green, size: CGSize(width: 50, height: 400), name: "leftStick", dynamic: false, friction: 0, restitution: 1, cBM: leftStickI, cTBM: Ball)
        leftStick.position = CGPoint(x: frame.minX + 50, y: frame.maxY - leftStick.size.height - verticalRand)
        
        rightStick = createNode(color: NSColor.green, size: CGSize(width: 50, height: 400), name: "rightStick", dynamic: false, friction: 0, restitution: 1, cBM: rightStickI, cTBM: Ball)
        rightStick.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - rightStick.size.height - verticalRand)
        
        scoreLabel = createLabel(title: String(score), size: 20.0, color: NSColor.white, x: nil, y: nil, width: nil, height: nil, hidden: false)
        scoreLabel.frame.origin = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
        
        livesLabel = createLabel(title: String(repeating: "❤️", count: lives), size: 15.0, color: NSColor.white, x: nil, y: nil, width: nil, height: nil, hidden: false)
        livesLabel.frame.origin = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 9)
        
        overLabel = createLabel(title: "GAME OVER", size: 60.0, color: NSColor.red, x: nil, y: nil, width: nil, height: nil, hidden: true)
        overLabel.frame.origin = CGPoint(x: ((self.view?.frame.width)! / 2) - overLabel.frame.width/2, y: 30 + ((self.view?.frame.height)! / 2) - overLabel.frame.height/2)
        
        restartButton = NSButton(image: NSImage(named: NSImage.Name(rawValue: "restart.png"))!,  target: self, action: #selector(self.restartGame))
        restartButton?.isTransparent = true
        restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
        let buttonCell:NSButtonCell = restartButton!.cell as! NSButtonCell
        buttonCell.bezelStyle = NSButton.BezelStyle.rounded
        
        onBoarding()
    }
    
    
    
    // Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen.
    func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "topStick" || contact.bodyA.node?.name == "bottomStick" || contact.bodyA.node?.name == "leftStick" || contact.bodyA.node?.name == "rightStick") && contact.bodyB.node?.name == "ball") {
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This means as the ball gets quicker, you earn more points for continuing to survive
            score = score + abs(Int((ball.physicsBody?.velocity.dy)!/40))
            setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
            let amount = CGFloat(10)
            if (ball.physicsBody?.velocity.dx)! < CGFloat(0) { ball.physicsBody?.velocity.dx = (ball.physicsBody?.velocity.dx)! - amount }
            else if (ball.physicsBody?.velocity.dx)! > CGFloat(0) { ball.physicsBody?.velocity.dx = (ball.physicsBody?.velocity.dx)! + amount }
            if (ball.physicsBody?.velocity.dy)! < CGFloat(0) { ball.physicsBody?.velocity.dy = (ball.physicsBody?.velocity.dy)! - amount }
            else if (ball.physicsBody?.velocity.dy)! > CGFloat(0) { ball.physicsBody?.velocity.dy = (ball.physicsBody?.velocity.dy)! + amount }
        }
        if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball") {
            if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball" && lives > 1) {
                lives = lives - 1
                return setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
            }
            livesLabel.isHidden = true
            removeChilds(ball, topStick, leftStick, rightStick, bottomStick)
            overLabel.isHidden = false
            restartButton?.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 30, y: (((self.view?.frame.height)! / 2) - 30) - 30, width: 60, height: 60)
        }
    }
}


let scene = Scene()
scene.scaleMode = .aspectFit
let view = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 360))
view.presentScene(scene)
PlaygroundPage.current.liveView = view
