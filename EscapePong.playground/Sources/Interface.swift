import AppKit
import SpriteKit
import Foundation
import AVFoundation

// Create the SKScene class
public class Scene: SKScene, SKPhysicsContactDelegate {
    // Set the below variable to true to enable debug mode
    public var debug = false
    
    // Begin game by removing onBoarding screen and adding all the elements, especially the ball
    @objc public func beginGame() {
        if (isOnBoarding) { return }
        view?.showsFPS              = debug ? true : false
        view?.showsDrawCount        = debug ? true : false
        view?.showsNodeCount        = debug ? true : false
        restartButton.frame         = NSRect(x: 28, y: -2, width: 45, height: 45)
        pauseButtonTB.isHidden      = false
        restartButtonTB.isHidden    = false
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        addSubviews(colorSlider, pausedLabel, livesLabel, overLabel, scoreLabel, tScoreLabel, restartButton, restartButtonBig, pauseButton, colorPanel)
        removeSubviews(onBoardTitle, onBoardDescription, onBoardClick)
    }
    
    // Pause/play the game when pause button is pressed
    @objc public func pauseGame() {
        if (isOnBoarding || !overLabel.isHidden) { return }
        gamePlaying             = gamePlaying ? false : true
        if (gamePlaying && overLabel.isHidden) {
            addChilds(ball)
        } else if (!gamePlaying) {
            removeChilds(ball, randomObstacle)
        }
        pauseButton.image       = gamePlaying ? NSImage(named: NSImage.Name(rawValue: "pause.png"))! : NSImage(named: NSImage.Name(rawValue: "play.png"))!
        pauseButtonTB.image     = gamePlaying ? NSImage(named: NSImage.Name.touchBarPauseTemplate)! : NSImage(named: NSImage.Name.touchBarPlayTemplate)!
        colorPanel.isHidden     = gamePlaying ? true : false
        colorSlider.isHidden    = gamePlaying ? true : false
        pausedLabel.isHidden    = gamePlaying ? true : false
    }
    
    // Restart the game when restart button is pressed. Similar to beginGame(), also resets ball position/velocity
    @objc public func restartGame () {
        if (isOnBoarding || !gamePlaying) { return }
        removeChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        removeSubviews(scoreLabel)
        
        score                       = 0
        lives                       = 5
        overLabel.isHidden          = true
        tScoreLabel.isHidden        = true
        livesLabel.isHidden         = false
        colorPanel.isHidden         = true
        colorSlider.isHidden        = true
        pauseButton.isHidden        = false
        pauseButtonTB.isHidden      = false
        restartButton.isHidden    = false
        restartButtonTB.isHidden    = false
        restartButtonBig.isHidden   = true
        pausedLabel.isHidden        = true
        ball.physicsBody!.velocity  = CGVector(dx: 400, dy: 400)
        ball.position               = CGPoint(x: 0.6 * self.size.width, y: 0.6 * self.size.height)
        //restartButton.frame         = NSRect(x: 28, y: -2, width: 45, height: 45)
        
        setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
        setLabel(label: scoreLabelTB, value: String(score))
        setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
        setLabel(label: livesLabelTB, value: String(repeating: "❤️", count: lives))
        addSubviews(scoreLabel)
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
    }
    
    // If the space bar is pressed, pause the game
    override public func keyUp(with event: NSEvent) {
        if (isOnBoarding) { return }
        let s: String = String(returnChar(event: event)!)
        switch(s){
        case " ":
            pauseGame()
            break
        default:
            return
        }
    }
    
    // If mouse is clicked, show next onBoarding screen, or begin game
    @objc public func changeSlide() {
        if (isOnBoarding) {
            onBoarding()
        } else if (nextSlide == 4){
            beginGame()
            nextSlide = 0
        } else if (!overLabel.isHidden) {
            restartGame()
        }
    }
    
    // If mouse is clicked, show next onBoarding screen, or begin game
    override public func mouseDown(with event: NSEvent) {
        if (!overLabel.isHidden && nextSlide == 5) {
            restartGame()
        }
    }
    
    // If mouse is moved, move all paddles based on new mouse location
    override public func mouseMoved(with event: NSEvent) {
        if ((nextSlide != 3 && isOnBoarding) || !gamePlaying) { return }
        let location            = event.location(in: self)
        topPaddle.position.x    = location.x
        leftPaddle.position.y   = location.y
        rightPaddle.position.y  = location.y
        bottomPaddle.position.x = location.x
    }
    
    @objc public func getColor() {
        // Use the custom NSColor init to quickly get a NSColor from the RGB
        let newColor = NSColor(rgb: colorArray[Int(colorSlider.floatValue)])
        
        // Send the new color to updateColor() to update all the elements to the new color
        setColor(color: newColor)
    }
    
    @objc public func setColor(color: NSColor) {
        // Set all the nodes to the new color
        ball.fillColor      = color
        ball.strokeColor    = color
        topPaddle.color     = color
        bottomPaddle.color  = color
        leftPaddle.color    = color
        rightPaddle.color   = color
    }
    
    // Show onBoarding (instruction/initial) screens, and set the different titles and descriptions
    public func onBoarding() {
        if (isOnBoarding) {
            if nextSlide == 1 {
                onBoardTitle                    = createLabel(title: "Welcome", size: 60.0, color: NSColor.white, hidden: false, bold: true)
                onBoardTitle.frame              = NSRect(x: ((self.view?.frame.width)! / 2) - 200, y: 90 + ((self.view?.frame.height)! / 2) - 36, width: 400, height: 72)
                onBoardDescription              = createLabel(title: "Welcome to DoublePong, Pong - with even more paddles!", size: 20.0, color: NSColor.white, hidden: false)
                onBoardDescription.frame        = NSRect(x: ((self.view?.frame.width)! / 2) - 275, y: (((self.view?.frame.height)! / 2) - 50) - 20, width: 550, height: 100)
                onBoardClick                    = createButton(title: "Continue", color: NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.changeSlide), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (((self.view?.frame.height)! / 2) - 8) - 130, width: 280, height: 45, radius: 18)
                //onBoardClick.frame              = NSRect(x: ((self.view?.frame.width)! / 2) - 100, y: (((self.view?.frame.height)! / 2) - 8) - 140, width: 200, height: 16)
                addSubviews(onBoardTitle, onBoardDescription, onBoardClick)
            } else if nextSlide == 2 { onBoardTitle.stringValue = "Paddles"
                onBoardDescription.stringValue  = "There are 4 paddles, positioned on each edge of the screen. Move your cursor to move the paddles, and try to block the ball from hitting the edges."
            } else if nextSlide == 3 { onBoardTitle.stringValue = "Difficulty"
                onBoardDescription.stringValue  = "The game will continously get faster and harder, by adding invisible obstacles and making the paddles smaller after a while."
                updateButton(button: onBoardClick, title: "Play")
                isOnBoarding                    = false
            }
            nextSlide                           += 1
        } else {
            beginGame()
        }
    }
    
    // Most main functions - initialise different elements, paddles, labels, and buttons, then show onBoarding screen.
    override public func didMove(to view: SKView) {
        // Track mouse movements and clicks in the view
        let options                             = [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved] as NSTrackingArea.Options
        let trackingArea                        = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
        
        // Create a border of the view to keep the ball inside
        self.size                               = CGSize(width: 1920, height: 1080)
        self.physicsWorld.gravity               = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate       = self
        let sceneBound                          = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 1860, height: 1020)))
        sceneBound.friction                     = 0
        sceneBound.restitution                  = 0
        self.physicsBody                        = sceneBound
        
        // Pick a random color for the initial paddle/ball color
        let randomIndex                         = colorArray.random()
        let randomColor                         = NSColor(red: CGFloat((randomIndex! & 0xFF0000) >> 16) / 0xFF, green: CGFloat((randomIndex! & 0x00FF00) >> 8) / 0xFF, blue: CGFloat(randomIndex! & 0x0000FF) / 0xFF, alpha: CGFloat(1.0))
        
        // Set the ball's position, color, and gravity settings
        ball.name                               = "ball"
        ball.position                           = CGPoint(x: 0.6 * self.size.width, y: 0.6 * self.size.height)
        ball.fillColor                          = randomColor
        ball.strokeColor                        = randomColor
        ball.physicsBody                        = SKPhysicsBody(circleOfRadius: 30)
        ball.physicsBody!.velocity              = CGVector(dx: 400, dy: 400)
        ball.physicsBody!.friction              = 0
        ball.physicsBody!.restitution           = 1
        ball.physicsBody!.linearDamping         = 0
        ball.physicsBody!.allowsRotation        = false
        ball.physicsBody!.categoryBitMask       = Ball
        ball.physicsBody!.contactTestBitMask    = randomObstacleI
        
        // Create all the paddles using createNode()
        topPaddle                   = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "topPaddle", dynamic: false, friction: 0, restitution: 1, cBM: topPaddleI, cTBM: Ball)
        topPaddle.position          = CGPoint(x: horizontalRand, y: frame.maxY - topPaddle.size.height)
        bottomPaddle                = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "bottomPaddle", dynamic: false, friction: 0, restitution: 1, cBM: bottomPaddleI, cTBM: Ball)
        bottomPaddle.position       = CGPoint(x: horizontalRand, y: frame.minY + bottomPaddle.size.height)
        leftPaddle                  = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "leftPaddle", dynamic: false, friction: 0, restitution: 1, cBM: leftPaddleI, cTBM: Ball)
        leftPaddle.position         = CGPoint(x: frame.minX + leftPaddle.size.width, y: frame.maxY - leftPaddle.size.height - verticalRand)
        rightPaddle                 = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "rightPaddle", dynamic: false, friction: 0, restitution: 1, cBM: rightPaddleI, cTBM: Ball)
        rightPaddle.position        = CGPoint(x: frame.maxX - rightPaddle.size.width, y: frame.maxY - rightPaddle.size.height - verticalRand)
        
        // Create all the labels using createLabel()
        scoreLabel                  = createLabel(title: String(score), size: 20.0, color: NSColor.white, hidden: false)
        scoreLabel.frame.origin     = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
        tScoreLabel                 = createLabel(title: "High Score: " + String(topScore), size: 25.0, color: NSColor.white, hidden: true)
        tScoreLabel.frame.origin    = CGPoint(x: ((self.view?.frame.width)! / 2) - (tScoreLabel.frame.width / 2), y: (((self.view?.frame.height)! / 2) - 30) - 10)
        livesLabel                  = createLabel(title: String(repeating: "❤️", count: lives), size: 15.0, color: NSColor.white, hidden: false)
        livesLabel.frame.origin     = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 9)
        overLabel                   = createLabel(title: "Game Over", size: 60.0, color: NSColor.red, hidden: true, bold: true)
        overLabel.frame.origin      = CGPoint(x: ((self.view?.frame.width)! / 2) - overLabel.frame.width/2, y: 30 + ((self.view?.frame.height)! / 2) - overLabel.frame.height/2)
        pausedLabel                 = createLabel(title: "Game Paused", size: 60.0, color: NSColor.orange, hidden: true, bold: true)
        pausedLabel.frame.origin    = CGPoint(x: ((self.view?.frame.width)! / 2) - pausedLabel.frame.width/2, y: 30 + ((self.view?.frame.height)! / 2) - pausedLabel.frame.height/2)
        
        // Create all the buttons using createButton()
        pauseButton                 = createButton(image: NSImage(named: NSImage.Name(rawValue: "pause.png"))!, action: #selector(self.pauseGame), transparent: true, x: -2, y: -2, width: 45, height: 45)
        restartButton               = createButton(image: NSImage(named: NSImage.Name(rawValue: "restart.png"))!, action: #selector(self.restartGame), transparent: true, x: 28, y: -2, width: 45, height: 45)
        restartButtonBig            = createButton(title: "Restart", color: NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.restartGame), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (((self.view?.frame.height)! / 2) - 8) - 130, width: 280, height: 45, hidden: true, radius: 18)
        //settingsButton              = createButton(image: NSImage(named: NSImage.Name(rawValue: "gear.png"))!, action: #selector(self.showSettings), transparent: true, x: ((self.view?.frame.width)! - 43), y: -2, width: 45, height: 45)
        
        // Create the color panel available in the pause menu
        colorPanel.image                    = NSImage(named: NSImage.Name(rawValue: "colors.png"))!
        colorPanel.frame                    = NSRect(x: ((self.view?.frame.width)! / 2) - 175, y: ((self.view?.frame.height)! / 2) - 40, width: 350, height: 25)
        colorPanel.isHidden                 = true
        colorPanel.wantsLayer               = true
        colorPanel.layer?.cornerRadius      = 6.0
        colorPanel.layer?.masksToBounds     = true
        colorPanel.canDrawSubviewsIntoLayer = true
        colorSlider                         = NSSlider(value: 0.5, minValue: 0.5, maxValue: 13.5, target: self, action: #selector(getColor))
        colorSlider.frame                   = NSRect(x: ((self.view?.frame.width)! / 2) - 175, y: ((self.view?.frame.height)! / 2) - 40, width: 350, height: 25 )
        colorSlider.isHidden                = true
        
        // Start the onBoarding screen
        onBoarding()
    }
    
    
    
    // Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen.
    public func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "topPaddle" || contact.bodyA.node?.name == "bottomPaddle" || contact.bodyA.node?.name == "leftPaddle" || contact.bodyA.node?.name == "rightPaddle") && contact.bodyB.node?.name == "ball") {
            // Play the pong sound
            run(pongSound)
            
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This increases amount of awarded points as ball speeds up
            score = score + abs(Int((ball.physicsBody?.velocity.dy)!/40))
            setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
            setLabel(label: scoreLabelTB, value: String(score), which: "scoreLabel")
            
            // Add random obstacles after 500 points to break patterns and make the gameplay better
            if (score > 500) {
                removeChilds(randomObstacle)
                let size = CGSize(width: CGFloat(randomNumber(inRange: 100...400)), height: CGFloat(randomNumber(inRange: 30...70)))
                randomObstacle = createNode(color: NSColor.clear, size: size, name: "obstacle", dynamic: false, friction: 0, restitution: 1, cBM: randomObstacleI, cTBM: Ball, position: CGPoint(x: CGFloat(randomNumber(inRange: 100...Int(frame.maxX - size.width - 100))), y: CGFloat(randomNumber(inRange: 100...Int(frame.maxY - size.height - 100)))))
                addChilds(randomObstacle)
            }
            
            // Decrease paddle size after 700 points
            if (score > 700 && topPaddle.size.width == 600) {
                // Animate the size change to make it smooth
                NSAnimationContext.runAnimationGroup({(context) in
                    context.duration = 5.0
                    let widthAction = SKAction.resize(toWidth: 550, duration: 5.0)
                    let heightAction = SKAction.resize(toHeight: 550, duration: 5.0)
                    topPaddle.run(widthAction)
                    bottomPaddle.run(widthAction)
                    leftPaddle.run(heightAction)
                    rightPaddle.run(heightAction)
                })
            }
            
            if (((ball.physicsBody?.velocity.dx)! < CGFloat(100) && (ball.physicsBody?.velocity.dx)! > -CGFloat(100)) || ((ball.physicsBody?.velocity.dy)! < CGFloat(100) && (ball.physicsBody?.velocity.dy)! > -CGFloat(100))) {
                // If the velocity is very low (e.g. slowed down by obstacle), increase it to a normal velocity
                ball.physicsBody?.velocity.dx  += ((ball.physicsBody?.velocity.dx)! < CGFloat(0)) ? -CGFloat(300) : CGFloat(300)
                ball.physicsBody?.velocity.dy  += ((ball.physicsBody?.velocity.dy)! < CGFloat(0)) ? -CGFloat(300) : CGFloat(300)
            } else {
                // Choose a random velocity to increase by300
                let increase = CGFloat(randomNumber(inRange: 4...10))
                
                // Increase the velocity based on whether it's negative or not
                ball.physicsBody?.velocity.dx  += ((ball.physicsBody?.velocity.dx)! < CGFloat(0)) ? -increase : increase
                ball.physicsBody?.velocity.dy  += ((ball.physicsBody?.velocity.dy)! < CGFloat(0)) ? -increase : increase
            }
        }
        if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball") {
            if (lives > 1) {
                // Play the wall sound
                run(wallSound)
                
                // Player still has more than 1 life, remove one life and update the label
                lives = lives - 1
                setLabel(label: livesLabelTB, value: String(repeating: "❤️", count: lives))
                return setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
            } else if (gamePlaying) {
                // Play the game over sound
                run(overSound)
                
                // Player doesn't have any lives left
                overLabel.isHidden          = false
                livesLabel.isHidden         = true
                tScoreLabel.isHidden        = false
                pauseButton.isHidden        = true
                pauseButtonTB.isHidden      = true
                restartButton.isHidden      = true
                restartButtonBig.isHidden   = false
                //restartButton.frame         = NSRect(x: ((self.view?.frame.width)! / 2) - 30, y: (((self.view?.frame.height)! / 2) - 30) - 70, width: 60, height: 60)
                removeChilds(ball, topPaddle, leftPaddle, rightPaddle, bottomPaddle)
                
                // Reset paddle size
                topPaddle.size.width = 600
                leftPaddle.size.height = 600
                bottomPaddle.size.width = 600
                rightPaddle.size.height = 600
                
                // Set the new top score, if it's above the previous one
                topScore = score > topScore ? score : topScore
                setLabel(label: tScoreLabel, value: "High Score: " + String(topScore), which: "tScoreLabel")
                
                // Remove any random obstacles
                removeChilds(randomObstacle, randomObstacle)
            }
        }
    }
}
