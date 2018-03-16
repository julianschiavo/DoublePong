import SpriteKit
import AppKit
import PlaygroundSupport

class Scene: SKScene, SKPhysicsContactDelegate {
    /* Initialise all the main variables and contants.
     */
    let Ball: UInt32 = 0x1 << 0
    let Block: UInt32 = 0x1 << 1
    let topStickI: UInt32 = 0x1 << 2
    let leftStickI: UInt32 = 0x1 << 3
    let rightStickI: UInt32 = 0x1 << 4
    let bottomStickI: UInt32 = 0x1 << 5
    
    var score = 0
    var lives = 6

    var ball = SKShapeNode(circleOfRadius: 30)
    var topStick = SKSpriteNode(color: .green, size: CGSize(width: 400, height: 50))
    var leftStick = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 400))
    var rightStick = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 400))
    var bottomStick = SKSpriteNode(color: .green, size: CGSize(width: 400, height: 50))
    
    let verticalRand: CGFloat = CGFloat(arc4random_uniform(250) + 50)
    let horizontalRand: CGFloat = CGFloat(arc4random_uniform(600) + 300)
    
    var restartButton: NSButton?
    var scoreLabel = NSTextField()
    var livesLabel = NSTextField()
    var overLabel = NSTextField()
    var countDown = NSTextField()
    
    var isOnBoarding = true
    var nextSlide = 1
    var onBoardTitle = NSTextField()
    var onBoardDescription = NSTextField()
    var onBoardClick = NSTextField()
    
    func onBoarding() {
        if (isOnBoarding) {
            onBoardTitle.isBezeled = false;onBoardTitle.isEditable = false;onBoardTitle.drawsBackground = false;onBoardTitle.alignment = .center;onBoardTitle.font = NSFont.systemFont(ofSize: 60.0);onBoardTitle.textColor = NSColor.white
            onBoardTitle.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 150, y: 90 + ((self.view?.frame.height)! / 2) - 36, width: 300, height: 72)
            self.view?.addSubview(onBoardTitle)
        
            onBoardDescription.isBezeled = false;onBoardDescription.isEditable = false;onBoardDescription.drawsBackground = false;onBoardDescription.alignment = .center;onBoardDescription.font = NSFont.systemFont(ofSize: 20.0);onBoardDescription.textColor = NSColor.white;onBoardDescription.sizeToFit()
            onBoardDescription.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 300, y: (((self.view?.frame.height)! / 2) - 50) - 20, width: 600, height: 100)
            self.view?.addSubview(onBoardDescription)

            onBoardClick.isBezeled = false;onBoardClick.isEditable = false;onBoardClick.drawsBackground = false;onBoardClick.alignment = .center;onBoardClick.font = NSFont.systemFont(ofSize: 12.0);onBoardClick.textColor = NSColor.lightGray;onBoardClick.sizeToFit()
            onBoardClick.frame = NSRect(x: ((self.view?.frame.width)! / 2) - 100, y: (((self.view?.frame.height)! / 2) - 8) - 140, width: 200, height: 16)
            self.view?.addSubview(onBoardClick)
            
            if nextSlide == 1 { onBoardTitle.stringValue = "Hello"
                onBoardDescription.stringValue = "Welcome to EscapePong, my 2018 WWDC Scholarship submission.\n\nEscape Pong is a fun, exciting, game based on Pong."
                onBoardClick.stringValue = "press anywhere to continue"
            }
            else if nextSlide == 2 { onBoardTitle.stringValue = "Playing"
                onBoardDescription.stringValue = "Let's go over some quick steps on how to play EscapePong!"
            }
            else if nextSlide == 3 { onBoardTitle.stringValue = "Paddles"
                onBoardDescription.stringValue = "You have 4 paddles, one on each of the four edges. Move your cursor horizontally to move the top and bottom paddles, or vertically to move the left and right paddles!"
                self.addChild(topStick);self.addChild(bottomStick);self.addChild(leftStick);self.addChild(rightStick)
            }
            else if nextSlide == 4 { onBoardTitle.stringValue = "Objective"
                onBoardDescription.stringValue = "Your objective is to use your paddles to block the white ball from touching any of the four sides. You have 5 lives, and you gain 10 points each time a paddle touches the ball."
                self.view?.addSubview(livesLabel);self.view?.addSubview(overLabel);self.view?.addSubview(scoreLabel)
            }
            else if nextSlide == 5 { onBoardTitle.stringValue = "Good Luck"
                onBoardDescription.stringValue = "Oh, one more thing. To make it harder, the white ball will continously get faster!\n\nNow that the tutorial is over... let the game begin!"
                onBoardClick.stringValue = "press anywhere to release ball"
                onBoardClick.textColor = NSColor.red
                livesLabel.removeFromSuperview();overLabel.removeFromSuperview();scoreLabel.removeFromSuperview()
                topStick.removeFromParent();bottomStick.removeFromParent();leftStick.removeFromParent();
                rightStick.removeFromParent()
                isOnBoarding = false
            }
            
            nextSlide += 1
        } else {
            beginGame()
        }
    }
    
    @objc func beginGame() {
        if (isOnBoarding == false) {
            onBoardTitle.removeFromSuperview()
            onBoardClick.removeFromSuperview()
            onBoardDescription.removeFromSuperview()
            self.view?.addSubview(livesLabel)
            self.view?.addSubview(overLabel)
            self.view?.addSubview(scoreLabel)
            self.addChild(topStick)
            self.addChild(bottomStick)
            self.addChild(leftStick)
            self.addChild(rightStick)
            self.addChild(ball)
            restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
            self.view?.addSubview(restartButton!)
        }
    }
    
    @objc func restartGame(event: NSEvent) {
        if (isOnBoarding == false) {
            overLabel.isHidden = true
            livesLabel.isHidden = false
            lives = 6
            score = 0
            ball.position = CGPoint(x: 0.6 * self.size.width, y: 0.6 * self.size.height)
            ball.physicsBody!.velocity = CGVector(dx: 400, dy: 400)
            self.addChild(ball)
            self.addChild(topStick)
            self.addChild(bottomStick)
            self.addChild(leftStick)
            self.addChild(rightStick)
            self.view?.addSubview(scoreLabel)
            restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
        }
    }
    
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
        
        topStick.physicsBody = SKPhysicsBody(rectangleOf: topStick.size)
        topStick.name = "topStick"
        topStick.physicsBody!.categoryBitMask = topStickI
        topStick.physicsBody!.contactTestBitMask = Ball
        topStick.physicsBody!.isDynamic = false
        topStick.physicsBody!.friction = 0
        topStick.physicsBody!.restitution = 1
        topStick.position = CGPoint(x: horizontalRand, y: frame.maxY - topStick.size.height)
        
        bottomStick.physicsBody = SKPhysicsBody(rectangleOf: bottomStick.size)
        bottomStick.name = "bottomStick"
        bottomStick.physicsBody!.contactTestBitMask = Ball
        bottomStick.physicsBody!.categoryBitMask = bottomStickI
        bottomStick.physicsBody!.isDynamic = false
        bottomStick.physicsBody!.friction = 0
        bottomStick.physicsBody!.restitution = 1
        bottomStick.position = CGPoint(x: horizontalRand, y: frame.minY + bottomStick.size.height)
        
        leftStick.physicsBody = SKPhysicsBody(rectangleOf: leftStick.size)
        leftStick.name = "leftStick"
        leftStick.physicsBody!.categoryBitMask = leftStickI
        leftStick.physicsBody!.contactTestBitMask = Ball
        leftStick.physicsBody!.isDynamic = false
        leftStick.physicsBody!.friction = 0
        leftStick.physicsBody!.restitution = 1
        leftStick.position = CGPoint(x: frame.minX + 50, y: frame.maxY - leftStick.size.height - verticalRand)
        
        rightStick.physicsBody = SKPhysicsBody(rectangleOf: rightStick.size)
        rightStick.name = "leftStick"
        rightStick.physicsBody!.categoryBitMask = rightStickI
        rightStick.physicsBody!.contactTestBitMask = Ball
        rightStick.physicsBody!.isDynamic = false
        rightStick.physicsBody!.friction = 0
        rightStick.physicsBody!.restitution = 1
        rightStick.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - rightStick.size.height - verticalRand)
        
        scoreLabel.stringValue = String(score)
        scoreLabel.isEditable = false
        scoreLabel.drawsBackground = false
        scoreLabel.isBezeled = false
        scoreLabel.alignment = .center
        scoreLabel.textColor = .white
        scoreLabel.font = NSFont.systemFont(ofSize: 20.0)
        scoreLabel.sizeToFit()
        scoreLabel.frame.origin = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
        
        livesLabel.stringValue = String(repeating: "❤️", count: lives)
        livesLabel.isEditable = false
        livesLabel.drawsBackground = false
        livesLabel.isBezeled = false
        livesLabel.alignment = .center
        livesLabel.font = NSFont.systemFont(ofSize: 15.0)
        livesLabel.sizeToFit()
        livesLabel.frame.origin = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 9)
        
        overLabel.stringValue = "GAME OVER"
        overLabel.isBezeled = false
        overLabel.isHidden = true
        overLabel.isEditable = false
        overLabel.drawsBackground = false
        overLabel.alignment = .center
        overLabel.font = NSFont.systemFont(ofSize: 60.0)
        overLabel.textColor = NSColor.red
        overLabel.sizeToFit()
        let overLabelHeight = overLabel.frame.height/2
        let overLabelWidth = overLabel.frame.width/2
        overLabel.frame.origin = CGPoint(x: ((self.view?.frame.width)! / 2) - overLabelWidth, y: 30 + ((self.view?.frame.height)! / 2) - overLabelHeight)
        
        restartButton = NSButton(image: NSImage(named: NSImage.Name(rawValue: "restart.png"))!,  target: self, action: #selector(self.restartGame))
        restartButton?.isTransparent = true
        restartButton?.frame = NSRect(x: -2, y: -2, width: 45, height: 45)
        let buttonCell:NSButtonCell = restartButton!.cell as! NSButtonCell
        buttonCell.bezelStyle = NSButton.BezelStyle.rounded
        
        onBoarding()
    }
    
    override func mouseDown(with event: NSEvent) {
        if (isOnBoarding) {
            onBoarding()
        } else {
            beginGame()
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        let tLocation = event.location(in: self)
        topStick.position.x = tLocation.x
        bottomStick.position.x = tLocation.x
        leftStick.position.y = tLocation.y
        rightStick.position.y = tLocation.y
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "topStick" || contact.bodyA.node?.name == "bottomStick" || contact.bodyA.node?.name == "leftStick" || contact.bodyA.node?.name == "rightStick") && contact.bodyB.node?.name == "ball") {
            score = score + 10
            scoreLabel.stringValue = String(score)
            scoreLabel.sizeToFit()
            scoreLabel.frame.origin = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
            let amount = CGFloat(15)
            if (ball.physicsBody?.velocity.dx)! < CGFloat(0) { ball.physicsBody?.velocity.dx = (ball.physicsBody?.velocity.dx)! - amount }
            else if (ball.physicsBody?.velocity.dx)! > CGFloat(0) { ball.physicsBody?.velocity.dx = (ball.physicsBody?.velocity.dx)! + amount }
            if (ball.physicsBody?.velocity.dy)! < CGFloat(0) { ball.physicsBody?.velocity.dy = (ball.physicsBody?.velocity.dy)! - amount }
            else if (ball.physicsBody?.velocity.dy)! > CGFloat(0) { ball.physicsBody?.velocity.dy = (ball.physicsBody?.velocity.dy)! + amount }
        }
        if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball") {
            if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball" && lives > 1) {
                lives = lives - 1
                (livesLabel.stringValue = String(repeating: "❤️", count: lives))
                livesLabel.sizeToFit()
                return livesLabel.frame.origin = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width - 5, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 12)
            }
            livesLabel.isHidden = true
            childNode(withName: "ball")?.removeFromParent()
            topStick.removeFromParent()
            leftStick.removeFromParent()
            rightStick.removeFromParent()
            bottomStick.removeFromParent()
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
