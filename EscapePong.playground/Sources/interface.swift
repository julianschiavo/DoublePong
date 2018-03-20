import AppKit
import SpriteKit
import Foundation

public class Interface: SKScene, SKPhysicsContactDelegate {
    // Set the below variable to true to enable debug mode
    public var debug = true
    
    // Begin game by removing onBoarding screen and adding all the elements, especially the ball.
    @objc public func beginGame() {
        if (!isOnBoarding) {
            view?.showsFPS          = debug ? true : false
            view?.showsDrawCount    = debug ? true : false
            view?.showsNodeCount    = debug ? true : false
            restartButton.frame     = NSRect(x: 28, y: -2, width: 45, height: 45)
            addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
            addSubviews(colorSlider, pausedLabel, livesLabel, overLabel, scoreLabel, tScoreLabel, restartButton, pauseButton, colorPanel)
            removeSubviews(onBoardTitle, onBoardDescription, onBoardClick)
        }
    }
    
    // Pause/play the game when pause button is pressed.
    @objc public func pauseGame() {
        if (!isOnBoarding && !gamePaused && overLabel.isHidden) {
            removeChilds(ball)
            gamePaused              = true
            pauseButton.image       = NSImage(named: NSImage.Name(rawValue: "play.png"))!
            colorPanel.isHidden     = false
            colorSlider.isHidden    = false
            pausedLabel.isHidden    = false
        } else if (!isOnBoarding && gamePaused) {
            addChilds(ball)
            gamePaused              = false
            pauseButton.image       = NSImage(named: NSImage.Name(rawValue: "pause.png"))!
            colorPanel.isHidden     = true
            colorSlider.isHidden    = true
            pausedLabel.isHidden    = true
        }
    }
    
    // Restart the game when restart button is pressed. Similar to beginGame(), also resets ball position/velocity.
    @objc public func restartGame () {
        if (!isOnBoarding && !gamePaused) {
            removeChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
            removeSubviews(scoreLabel)
            
            score                       = 1
            lives                       = 5
            overLabel.isHidden          = true
            tScoreLabel.isHidden        = true
            livesLabel.isHidden         = false
            colorPanel.isHidden         = true
            colorSlider.isHidden        = true
            pauseButton.isHidden        = false
            ball.physicsBody!.velocity  = CGVector(dx: 400, dy: 400)
            ball.position               = CGPoint(x: 0.6 * self.size.width, y: 0.6 * self.size.height)
            restartButton.frame         = NSRect(x: 28, y: -2, width: 45, height: 45)
            
            setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
            setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
            addSubviews(scoreLabel)
            addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        }
    }
    
    // If the space bar is pressed, pause the game
    override public func keyUp(with event: NSEvent) {
        let s: String = String(returnChar(event: event)!)
        switch(s){
        case " ":
            pauseGame()
            break
        default:
            return
        }
    }
    
    // If mouse is clicked, show next onBoarding screen, or begin game.
    override public func mouseDown(with event: NSEvent) {
        if (isOnBoarding) {
            onBoarding()
        } else if (nextSlide == 6){
            beginGame()
            nextSlide = 0
        } else if (!overLabel.isHidden) {
            restartGame()
        }
    }
    
    // If mouse is moved, move all paddles based on new mouse location.
    override public func mouseMoved(with event: NSEvent) {
        if (!gamePaused) {
            let tLocation           = event.location(in: self)
            topPaddle.position.x    = tLocation.x
            leftPaddle.position.y   = tLocation.y
            rightPaddle.position.y  = tLocation.y
            bottomPaddle.position.x = tLocation.x
        }
    }
    
    @objc public func updateColor() {
        // Convert slider value to an Int, then convert it to one of the possible colors as a NSColor
        let rgbValue        = colorArray[Int(colorSlider.floatValue)]
        let red             = CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green           = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue            = CGFloat(rgbValue & 0x0000FF) / 0xFF
        let newColor        = NSColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        
        // Set all the nodes to the new color
        ball.fillColor      = newColor
        ball.strokeColor    = newColor
        topPaddle.color     = newColor
        bottomPaddle.color  = newColor
        leftPaddle.color    = newColor
        rightPaddle.color   = newColor
    }
    
    // Show onBoarding (instruction/initial) screens, and set the different titles and descriptions.
    public func onBoarding() {
        if (isOnBoarding) {
            if nextSlide == 1 {
                onBoardTitle                    = createLabel(title: "Hello", size: 60.0, color: NSColor.white, hidden: false)
                onBoardTitle.frame              = NSRect(x: ((self.view?.frame.width)! / 2) - 150, y: 90 + ((self.view?.frame.height)! / 2) - 36, width: 300, height: 72)
                onBoardDescription              = createLabel(title: "Welcome to DoublePong, my 2018 WWDC Scholarship submission.\n\nDoublePong is Pong - with double the amount of paddles!", size: 20.0, color: NSColor.white, hidden: false)
                onBoardDescription.frame        = NSRect(x: ((self.view?.frame.width)! / 2) - 275, y: (((self.view?.frame.height)! / 2) - 50) - 20, width: 550, height: 100)
                onBoardClick                    = createLabel(title: "press anywhere to continue", size: 12.0, color: NSColor.lightGray, hidden: false)
                onBoardClick.frame              = NSRect(x: ((self.view?.frame.width)! / 2) - 100, y: (((self.view?.frame.height)! / 2) - 8) - 140, width: 200, height: 16)
                addSubviews(onBoardTitle, onBoardDescription, onBoardClick)
            } else if nextSlide == 2 { onBoardTitle.stringValue = "Playing"
                onBoardDescription.stringValue  = "Let's quickly learn the basics of DoublePong!"
            } else if nextSlide == 3 { onBoardTitle.stringValue = "Paddles"
                onBoardDescription.stringValue  = "You have 4 paddles, one on each of the four sides of the screen. Move your cursor horizontally to move the top and bottom paddles, or vertically to move the left and right paddles!"
                addChilds(topPaddle, bottomPaddle, leftPaddle, rightPaddle)
            } else if nextSlide == 4 { onBoardTitle.stringValue = "Objective"
                onBoardDescription.stringValue  = "Your objective is to block the white ball from touching the edges of the screen. The ball will continously become faster, and the faster it is, the more points you get when it touches a paddle."
                addSubviews(livesLabel, overLabel, scoreLabel)
            } else if nextSlide == 5 { onBoardTitle.stringValue = "Good Luck"
                onBoardDescription.stringValue  = "Now that the tutorial is over... let the game begin!"
                onBoardClick.stringValue        = "press anywhere to release ball"
                onBoardClick.textColor          = NSColor.red
                removeChilds(topPaddle, bottomPaddle, leftPaddle, rightPaddle)
                removeSubviews(livesLabel, overLabel, scoreLabel)
                isOnBoarding                    = false
            }
            nextSlide                           += 1
        } else {
            beginGame()
        }
    }
    
    // Most main functions - initialise different elements, paddles, labels, and buttons, then show onBoarding screen.
    override public func didMove(to view: SKView) {
        let options                             = [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved] as NSTrackingArea.Options
        let trackingArea                        = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
        
        self.size                               = CGSize(width: 1920, height: 1080)
        self.physicsWorld.gravity               = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate       = self
        let sceneBound                          = SKPhysicsBody(edgeLoopFrom: self.frame)
        sceneBound.friction                     = 0
        sceneBound.restitution                  = 0
        self.physicsBody                        = sceneBound
        
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
        ball.physicsBody!.contactTestBitMask    = Block
        
        // Create all the paddles using createNode()
        topPaddle                   = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "topPaddle", dynamic: false, friction: 0, restitution: 1, cBM: topPaddleI, cTBM: Ball)
        topPaddle.position          = CGPoint(x: horizontalRand, y: frame.maxY - topPaddle.size.height)
        bottomPaddle                = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "bottomPaddle", dynamic: false, friction: 0, restitution: 1, cBM: bottomPaddleI, cTBM: Ball)
        bottomPaddle.position       = CGPoint(x: horizontalRand, y: frame.minY + bottomPaddle.size.height)
        leftPaddle                  = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "leftPaddle", dynamic: false, friction: 0, restitution: 1, cBM: leftPaddleI, cTBM: Ball)
        leftPaddle.position         = CGPoint(x: frame.minX + 50, y: frame.maxY - leftPaddle.size.height - verticalRand)
        rightPaddle                 = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "rightPaddle", dynamic: false, friction: 0, restitution: 1, cBM: rightPaddleI, cTBM: Ball)
        rightPaddle.position        = CGPoint(x: frame.maxX - 50, y: frame.maxY - rightPaddle.size.height - verticalRand)
        
        // Create all the labels using createLabel()
        scoreLabel                  = createLabel(title: String(score), size: 20.0, color: NSColor.white, hidden: false)
        scoreLabel.frame.origin     = CGPoint(x: 9, y: (self.view?.frame.maxY)! - scoreLabel.frame.height - 9)
        tScoreLabel                 = createLabel(title: "High Score: " + String(topScore), size: 25.0, color: NSColor.white, hidden: true)
        tScoreLabel.frame.origin    = CGPoint(x: ((self.view?.frame.width)! / 2) - (tScoreLabel.frame.width / 2), y: (((self.view?.frame.height)! / 2) - 30) - 10)
        livesLabel                  = createLabel(title: String(repeating: "❤️", count: lives), size: 15.0, color: NSColor.white, hidden: false)
        livesLabel.frame.origin     = CGPoint(x: (self.view?.frame.maxX)! - livesLabel.frame.width, y: (self.view?.frame.maxY)! - livesLabel.frame.height - 9)
        overLabel                   = createLabel(title: "GAME OVER", size: 60.0, color: NSColor.red, hidden: true)
        overLabel.frame.origin      = CGPoint(x: ((self.view?.frame.width)! / 2) - overLabel.frame.width/2, y: 30 + ((self.view?.frame.height)! / 2) - overLabel.frame.height/2)
        pausedLabel                 = createLabel(title: "GAME PAUSED", size: 60.0, color: NSColor.orange, hidden: true)
        pausedLabel.frame.origin    = CGPoint(x: ((self.view?.frame.width)! / 2) - pausedLabel.frame.width/2, y: 30 + ((self.view?.frame.height)! / 2) - pausedLabel.frame.height/2)
        
        // Create all the buttons using createButton()
        pauseButton                 = createButton(image: NSImage(named: NSImage.Name(rawValue: "pause.png"))!, action: #selector(self.pauseGame), transparent: true, x: -2, y: -2, width: 45, height: 45)
        restartButton               = createButton(image: NSImage(named: NSImage.Name(rawValue: "restart.png"))!, action: #selector(self.restartGame), transparent: true, x: 28, y: -2, width: 45, height: 45)
        //settingsButton              = createButton(image: NSImage(named: NSImage.Name(rawValue: "gear.png"))!, action: #selector(self.showSettings), transparent: true, x: ((self.view?.frame.width)! - 43), y: -2, width: 45, height: 45)
        
        colorPanel.image                    = NSImage(named: NSImage.Name(rawValue: "colors.png"))!
        colorPanel.frame                    = NSRect(x: ((self.view?.frame.width)! / 2) - 175, y: ((self.view?.frame.height)! / 2) - 40, width: 350, height: 25)
        colorPanel.isHidden                 = true
        colorPanel.wantsLayer               = true
        colorPanel.layer?.cornerRadius      = 6.0
        colorPanel.layer?.masksToBounds     = true
        colorPanel.canDrawSubviewsIntoLayer = true
        
        colorSlider                         = NSSlider(value: 0.5, minValue: 0.5, maxValue: 13.5, target: self, action: #selector(updateColor))
        colorSlider.frame                   = NSRect(x: ((self.view?.frame.width)! / 2) - 175, y: ((self.view?.frame.height)! / 2) - 40, width: 350, height: 25 )
        colorSlider.isHidden                = true
        
        // Start the onBoarding screen
        onBoarding()
    }
    
    
    
    // Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen.
    public func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "topPaddle" || contact.bodyA.node?.name == "bottomPaddle" || contact.bodyA.node?.name == "leftPaddle" || contact.bodyA.node?.name == "rightPaddle") && contact.bodyB.node?.name == "ball") {
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This increases amount of awarded points as ball speeds up
            score = score + abs(Int((ball.physicsBody?.velocity.dy)!/40))
            setLabel(label: scoreLabel, value: String(score), which: "scoreLabel")
            
            if (score > 700) {
                topPaddle.size.width = 500
                leftPaddle.size.height = 500
                bottomPaddle.size.width = 500
                rightPaddle.size.height = 500
            }
            
            // If the velocity is negative, remove the amount, otherwise, add it
            ball.physicsBody?.velocity.dx  += ((ball.physicsBody?.velocity.dx)! < CGFloat(0)) ? -amount : amount
            ball.physicsBody?.velocity.dy  += ((ball.physicsBody?.velocity.dy)! < CGFloat(0)) ? -amount : amount
        }
        if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball") {
            if (lives > 1) {
                // Player still has more than 1 life
                lives = lives - 1
                return setLabel(label: livesLabel, value: String(repeating: "❤️", count: lives), which: "livesLabel")
            } else if (!gamePaused) {
                // Player doesn't have any lives left
                overLabel.isHidden          = false
                livesLabel.isHidden         = true
                tScoreLabel.isHidden        = false
                pauseButton.isHidden        = true
                restartButton.frame         = NSRect(x: ((self.view?.frame.width)! / 2) - 30, y: (((self.view?.frame.height)! / 2) - 30) - 70, width: 60, height: 60)
                removeChilds(ball, topPaddle, leftPaddle, rightPaddle, bottomPaddle)
                
                // Set the new top score, if it's above the previous one
                topScore = score > topScore ? score : topScore
                setLabel(label: tScoreLabel, value: "High Score: " + String(topScore), which: "tScoreLabel")
            }
        }
    }
}
