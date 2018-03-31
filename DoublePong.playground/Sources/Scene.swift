import AppKit
import SpriteKit
import Foundation
import AVFoundation

// Create the Scene class
public class Scene: SKScene, SKPhysicsContactDelegate {
    // Set the below variable to true to enable debug mode
    public var debug = false
    
    // Toggle muting or unmuting game sounds
    @objc public func muteSounds() {
        soundsEnabled       = !soundsEnabled
        muteButton.image    = soundsEnabled ? unmutedImage : mutedImage
        muteButtonTB.image  = soundsEnabled ? NSImage(named: NSImage.Name.touchBarVolumeUpTemplate)! : NSImage(named: NSImage.Name.touchBarAudioOutputMuteTemplate)!
        prefs.set(soundsEnabled, forKey: "soundsEnabled")
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
        
        prefs.setColor(color, forKey: "customColor")
    }
    
    // If the space bar is pressed, pause the game
    override public func keyUp(with event: NSEvent) {
        if (isIntro) { return }
        let s: String = String(returnChar(event: event)!)
        switch(s){
        case " ":
            pauseGame()
            break
        default:
            return
        }
    }
    
    // If mouse is moved, move all paddles based on new mouse location
    override public func mouseMoved(with event: NSEvent) {
        if ((nextIntro != 3 && isIntro)) { return }
        let location            = event.location(in: self)
        topPaddle.position.x    = (location.x < 1920 - 65 - topPaddle.size.width / 2 && location.x > topPaddle.size.width / 2 + 65) ? location.x : ((location.x > 1920 - 65 - topPaddle.size.width / 2) ? 1920 - 25 - topPaddle.size.width / 2 : topPaddle.size.width / 2 + 25)
        bottomPaddle.position.x = (location.x < 1920 - 65 - topPaddle.size.width / 2 && location.x > topPaddle.size.width / 2 + 65) ? location.x : ((location.x > 1920 - 65 - bottomPaddle.size.width / 2) ? 1920 - 25 - bottomPaddle.size.width / 2 : bottomPaddle.size.width / 2 + 25)
        leftPaddle.position.y   = (location.y < 1080 - 65 - leftPaddle.size.height / 2 && location.y > leftPaddle.size.height / 2 + 65) ? location.y : ((location.y > 1080 - 65 - leftPaddle.size.height / 2) ? 1080 - 27 - leftPaddle.size.height / 2 : leftPaddle.size.height / 2 + 25)
        rightPaddle.position.y  = (location.y < 1080 - 65 - rightPaddle.size.height / 2 && location.y > rightPaddle.size.height / 2 + 65) ? location.y : ((location.y > 1080 - 65 - rightPaddle.size.height / 2) ? 1080 - 27 - rightPaddle.size.height / 2 : rightPaddle.size.height / 2 + 25)
    }
    
    // Begin game by removing intro screen and adding all the objects
    @objc public func beginGame() {
        if (isIntro) { return }
        view?.showsFPS              = debug ? true : false
        view?.showsDrawCount        = debug ? true : false
        view?.showsNodeCount        = debug ? true : false
        restartButton.frame         = NSRect(x: 28, y: -2, width: 45, height: 45)
        pauseButtonTB.isHidden      = false
        restartButtonTB.isHidden    = false
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        addSubviews(overLabel, scoreLabel, livesLabel, pausedLabel, curScoreLabel, topScoreLabel)
        addSubviews(muteButton, pauseButton, pauseButtonBig, restartButton, restartButtonBig, colorSlider, colorPanel)
        removeSubviews(introTitle, introDescription, introButton, introProgress)
    }
    
    // Toggle the game status when pause button is pressed
    @objc public func pauseGame() {
        if (isIntro || !overLabel.isHidden) { return }
        if (!gamePlaying) {
            addChilds(ball)
        } else if (gamePlaying) {
            removeChilds(ball, randomObstacle)
        }
        gamePlaying             = gamePlaying ? false : true
        pauseButton.image       = gamePlaying ? pauseImage : playImage
        pauseButtonTB.image     = gamePlaying ? NSImage(named: NSImage.Name.touchBarPauseTemplate)! : NSImage(named: NSImage.Name.touchBarPlayTemplate)!
        pauseButtonBig.isHidden = gamePlaying ? true : false
        colorPanel.isHidden     = gamePlaying ? true : false
        colorSlider.isHidden    = gamePlaying ? true : false
        pausedLabel.isHidden    = gamePlaying ? true : false
    }
    
    // Restart the game when restart button is pressed, also resets ball position/velocity
    @objc public func restartGame () {
        if (isIntro) { return }
        if (!gamePlaying) { pauseGame() }
        if (overLabel.isHidden) {
            removeChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
            removeSubviews(scoreLabel)
        }
        
        score                       = 0
        lives                       = 5
        
        overLabel.isHidden          = true
        livesLabel.isHidden         = false
        scoreLabel.isHidden         = false
        curScoreLabel.isHidden      = true
        topScoreLabel.isHidden      = true
        livesLabel.stringValue      = String(repeating: "❤️", count: lives)
        scoreLabel.stringValue      = String(score)
        scoreLabelTB.stringValue    = String(score)
        
        pauseButton.isHidden        = false
        pauseButtonTB.isHidden      = false
        restartButton.isHidden      = false
        restartButtonTB.isHidden    = false
        restartButtonBig.isHidden   = true
        
        ball.position               = CGPoint(x: CGFloat(randomNumber(inRange: 325...1595)), y: CGFloat(randomNumber(inRange: 325...755)))
        ball.physicsBody!.velocity  = CGVector(dx: 400, dy: 400)
        
        addSubviews(scoreLabel)
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
    }
    
    // Initialise different elements, paddles, labels, and buttons, then show intro screen
    override public func didMove(to view: SKView) {
        // Track mouse movements and clicks in the view
        let options                             = [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved] as NSTrackingArea.Options
        let trackingArea                        = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
        
        // Create a border of the view to keep the ball inside
        self.size                               = CGSize(width: 1920, height: 1080)
        self.physicsWorld.gravity               = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate       = self
        let sceneBound                          = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 1820, height: 980)))
        sceneBound.friction                     = 0
        sceneBound.restitution                  = 0
        self.physicsBody                        = sceneBound
        
        // Set the ball's position, color, and gravity settings
        ball.name                               = "ball"
        ball.position                           = CGPoint(x: CGFloat(randomNumber(inRange: 325...1595)), y: CGFloat(randomNumber(inRange: 325...755)))
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
        topPaddle                   = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "topPaddle", dynamic: false, friction: 0, restitution: 1, cBM: topPaddleI, cTBM: Ball, position: CGPoint(x: horizontalRan, y: frame.maxY - 50))
        bottomPaddle                = createNode(color: randomColor, size: CGSize(width: 600, height: 50), name: "bottomPaddle", dynamic: false, friction: 0, restitution: 1, cBM: bottomPaddleI, cTBM: Ball, position: CGPoint(x: horizontalRan, y: frame.minY + 50))
        leftPaddle                  = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "leftPaddle", dynamic: false, friction: 0, restitution: 1, cBM: leftPaddleI, cTBM: Ball, position: CGPoint(x: frame.minX + 50, y: verticalRand))
        rightPaddle                 = createNode(color: randomColor, size: CGSize(width: 50, height: 600), name: "rightPaddle", dynamic: false, friction: 0, restitution: 1, cBM: rightPaddleI, cTBM: Ball, position: CGPoint(x: frame.maxX - 50, y: verticalRand))
        
        // Create all the labels using createLabel()
        // These are quite complicated because of positioning and sizing
        scoreLabel                  = createLabel(title: String(score), align: 1, size: 20.0, color: NSColor.white, hidden: false, x: 9, y: Double((self.view?.frame.maxY)! - 24 - 9), width: 100, height: 24)
        curScoreLabel               = createLabel(title: "Score: " + String(topScore), size: 25.0, color: NSColor.white, hidden: true, x: Double((self.view?.frame.width)! / 2 - 260), y: Double((self.view?.frame.height)! / 2 - 65), width: 520, height: 60)
        topScoreLabel               = createLabel(title: "High Score: " + String(topScore), size: 25.0, color: NSColor.white, hidden: true, x: Double((self.view?.frame.width)! / 2 - 260), y: Double((self.view?.frame.height)! / 2 - 100), width: 520, height: 60)
        livesLabel                  = createLabel(title: String(repeating: "❤️", count: lives), align: 3, size: 15.0, color: NSColor.white, hidden: false, x: Double((self.view?.frame.maxX)! - 113 - 9), y: Double((self.view?.frame.maxY)! - 19 - 9), width: 113, height: 19)
        overLabel                   = createLabel(title: "Game Over", size: 60.0, color: NSColor.red, hidden: true, bold: true, x: Double(((self.view?.frame.width)! / 2) - 250), y: Double(30 + ((self.view?.frame.height)! / 2) - 50), width: 500, height: 100)
        pausedLabel                 = createLabel(title: "Game Paused", size: 60.0, color: NSColor.orange, hidden: true, bold: true, x: Double(((self.view?.frame.width)! / 2) - 250), y: 30 + Double(((self.view?.frame.height)! / 2) - 50), width: 500, height: 100)
        
        // Create all the buttons using createButton()
        muteButton                  = createButton(image: soundsEnabled ? unmutedImage : mutedImage, action: #selector(self.muteSounds), transparent: true, x: ((self.view?.frame.width)! - 47), y: -2, width: 45, height: 45)
        pauseButton                 = createButton(image: pauseImage, action: #selector(self.pauseGame), transparent: true, x: -4, y: -4, width: 50, height: 50)
        pauseButtonBig              = createButton(title: "Play", color: NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.pauseGame), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (((self.view?.frame.height)! / 2) - 8) - 130, width: 280, height: 45, hidden: true, radius: 18)
        restartButton               = createButton(image: replayImage, action: #selector(self.restartGame), transparent: true, x: 38, y: -5, width: 50, height: 50)
        restartButtonBig            = createButton(title: "Restart", color: NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.restartGame), transparent: false, x: ((self.view?.frame.width)! / 2) - 140, y: (((self.view?.frame.height)! / 2) - 8) - 130, width: 280, height: 45, hidden: true, radius: 18)
        
        // Create the color panel (available in the pause menu)
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
        
        // Start the intro screen
        introGame()
    }
    
    
    // Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen
    public func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "topPaddle" || contact.bodyA.node?.name == "bottomPaddle" || contact.bodyA.node?.name == "leftPaddle" || contact.bodyA.node?.name == "rightPaddle") && contact.bodyB.node?.name == "ball") {
            // Play the pong sound if sounds are enabled
            if (soundsEnabled) { run(pongSound) }
            
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This increases amount of awarded points as ball speeds up
            score = score + abs(Int((ball.physicsBody?.velocity.dy)!/40))
            scoreLabel.stringValue = String(score)
            scoreLabelTB.stringValue = String(score)
            
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
                // Play the wall sound if sounds are enabled
                if (soundsEnabled) { run(wallSound) }
                
                // Player still has more than 1 life, remove one life and update the label
                lives = lives - 1
                return livesLabel.stringValue = String(repeating: "❤️", count: lives)
            } else if (gamePlaying) {
                // Play the game over sound if sounds are enabled
                if (soundsEnabled) { run(overSound) }
                
                // Player doesn't have any lives left
                overLabel.isHidden          = false
                livesLabel.isHidden         = true
                scoreLabel.isHidden         = true
                curScoreLabel.isHidden      = false
                topScoreLabel.isHidden      = false
                pauseButton.isHidden        = true
                pauseButtonTB.isHidden      = true
                restartButton.isHidden      = true
                restartButtonBig.isHidden   = false
                removeChilds(ball, topPaddle, leftPaddle, rightPaddle, bottomPaddle)
                
                // Reset paddle size
                topPaddle.size.width = 600
                leftPaddle.size.height = 600
                bottomPaddle.size.width = 600
                rightPaddle.size.height = 600
                
                // Set the new top score, if it's above the previous one
                topScore = score > topScore ? score : topScore
                curScoreLabel.stringValue = "Score: " + String(score)
                topScoreLabel.stringValue = "High Score: " + String(topScore)
                prefs.set(topScore, forKey: "topScore")
                
                // Remove any random obstacles
                removeChilds(randomObstacle, randomObstacle)
            }
        }
    }
}
