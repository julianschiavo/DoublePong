//
//  GameScene.swift
//  DoublePongMobile
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion
import Foundation
import AVFoundation

// Create the Scene class
public class Scene: SKScene, SKPhysicsContactDelegate {
    // Toggle muting or unmuting game sounds
    @objc public func toggleSounds() {
        soundsEnabled       = !soundsEnabled
        muteButton.setImage(soundsEnabled ? unmutedImage : mutedImage, for: .normal)
        prefs.set(soundsEnabled, forKey: "soundsEnabled")
    }
    
    // Toggle muting or unmuting game sounds
    @objc public func toggleMotion() {
        motionEnabled       = !motionEnabled
        motionButton.setImage(motionEnabled ? motionImage : touchImage, for: .normal)
        prefs.set(motionEnabled, forKey: "motionEnabled")
    }
    
    @objc public func tapColor(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = colorSlider.frame.origin
        let widthOfSlider: CGFloat = colorSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(colorSlider.maximumValue) / widthOfSlider)
        colorSlider.setValue(Float(newValue), animated: false)
        getColor()
    }
    
    // Get the color from the color picker and node colors
    @objc public func getColor() {
        // Use the custom NSColor init to quickly get a NSColor from the RGB
        let newColor = UIColor(rgb: colorArray[Int(colorSlider.value)])
        
        // Send the new color to updateColor() to update all the elements to the new color
        setColor(color: newColor)
    }
    
    // Set all the nodes to the new color and save the color preference
    @objc public func setColor(color: UIColor) {
        ball.fillColor      = color
        ball.strokeColor    = color
        topPaddle.color     = color
        bottomPaddle.color  = color
        leftPaddle.color    = color
        rightPaddle.color   = color
        prefs.setColor(color, forKey: "customColor")
    }

    // If mouse is moved, move all paddles based on new mouse location
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if nextIntro != 3 && isIntro && !motionEnabled { return }           
            let location            = t.location(in: self)
            /*topPaddle.position.x    = (location.x < self.size.width - modifier - topPaddle.size.width / 2 && location.x > topPaddle.size.width / 2 + modifier) ? location.x : ((location.x > self.size.width - modifier - topPaddle.size.width / 2) ? self.size.width - setToH - topPaddle.size.width / 2 : topPaddle.size.width / 2 + setToH)
            bottomPaddle.position.x = (location.x < self.size.width - modifier - topPaddle.size.width / 2 && location.x > topPaddle.size.width / 2 + modifier) ? location.x : ((location.x > self.size.width - modifier - bottomPaddle.size.width / 2) ? self.size.width - setToH - bottomPaddle.size.width / 2 : bottomPaddle.size.width / 2 + setToH)
            leftPaddle.position.y   = (location.y < self.size.height - modifier - leftPaddle.size.height / 2 && location.y > leftPaddle.size.height / 2 + modifier) ? location.y : ((location.y > self.size.height - modifier - leftPaddle.size.height / 2) ? self.size.height - safeTop - setToV - leftPaddle.size.height / 2 : leftPaddle.size.height / 2 + safeBottom + setToV)
            rightPaddle.position.y = (location.y < self.size.height - modifier - rightPaddle.size.height / 2 && location.y > rightPaddle.size.height / 2 + modifier) ? location.y : ((location.y > self.size.height - modifier - rightPaddle.size.height / 2) ? self.size.height - safeTop - setToV - rightPaddle.size.height / 2 : rightPaddle.size.height / 2 + setToV + safeBottom)*/
            positionChanged(location.x, location.y)
        }
    }
    
    public func positionChanged(_ x: CGFloat, _ y: CGFloat) {
        let width = self.size.width
        let height = self.size.height

        let xPosition = (x < width - modifier - topPaddle.frame.width / 2 && x > topPaddle.frame.width / 2 + modifier) ? x : ((x > width - modifier - topPaddle.frame.width / 2) ? width - setToH - topPaddle.frame.width / 2 : topPaddle.frame.width / 2 + setToH)
        topPaddle.position.x = xPosition
        bottomPaddle.position.x = xPosition

        let yPosition = (y < height - modifier - leftPaddle.frame.height / 2 && y > leftPaddle.frame.height / 2 + modifier) ? y : ((y > height - modifier - leftPaddle.frame.height / 2) ? height - setToV - safeTop - leftPaddle.frame.height / 2 : leftPaddle.frame.height / 2 + setToV + safeBottom)
        leftPaddle.position.y = yPosition
        rightPaddle.position.y = yPosition
    }
    
    // Begin game by removing intro screen and adding all the objects
    @objc public func beginGame() {
        if isIntro { return }
        view?.showsFPS              = debug ? true : false
        view?.showsDrawCount        = debug ? true : false
        view?.showsNodeCount        = debug ? true : false
        scoreLabel.isHidden         = false
        livesLabel.isHidden         = false
        muteButton.isHidden         = false
        pauseButton.isHidden        = false
        motionButton.isHidden       = false
        restartButton.isHidden      = false
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        addSubviews(colorSlider, colorPanel)
        removeSubviews(introTitle, introDescription, introButton)
    }
    
    // Toggle the game status when pause button is pressed
    @objc public func pauseGame() {
        if isIntro || !overLabel.isHidden { return }
        if !gamePlaying {
            addChilds(ball)
        } else if gamePlaying {
            removeChilds(ball, randomObstacle)
        }
        gamePlaying             = gamePlaying ? false : true
        pauseButton.setImage(gamePlaying ? pauseImage : playImage, for: .normal)
        pauseButtonBig.isHidden = gamePlaying ? true : false
        colorPanel.isHidden     = gamePlaying ? true : false
        colorSlider.isHidden    = gamePlaying ? true : false
        pausedLabel.isHidden    = gamePlaying ? true : false
    }
    
    // Restart the game when restart button is pressed, also resets ball position/velocity
    @objc public func restartGame () {
        if isIntro { return }
        if !gamePlaying { pauseGame() }
        if overLabel.isHidden {
            removeChilds(ball)
           // removeSubviews(scoreLabel)
        }
        
        score                       = 0
        lives                       = 5
        overLabel.isHidden          = true
        livesLabel.isHidden         = false
        scoreLabel.isHidden         = false
        curScoreLabel.isHidden      = true
        topScoreLabel.isHidden      = true
        livesLabel.text             = String(repeating: "❤️", count: lives)
        scoreLabel.text             = String(score)
        
        pauseButton.isHidden        = false
        restartButton.isHidden      = false
        restartButtonBig.isHidden   = true
        
       // ball.position               = CGPoint(x: CGFloat(randomNumber(inRange: 325...1595)), y: CGFloat(randomNumber(inRange: 325...755)))
        ball.position               = CGPoint(x: CGFloat(randomNumber(inRange: Int(self.size.width / 6)...Int(self.size.width / 1.2))), y: CGFloat(randomNumber(inRange: Int(self.size.height / 3)...Int(self.size.height / 1.2))))
        ball.physicsBody!.velocity  = CGVector(dx: self.size.height / 2.3, dy: self.size.height / 2.3)
        
       // addSubviews(scoreLabel)
        addChilds(ball)
    }
    
    // Initialise different elements, paddles, labels, and buttons, then show intro screen
    override public func didMove(to view: SKView) {
        // Create a border of the view to keep the ball inside
        /*if #available(iOS 11.0, *) {
            self.size                               = CGSize(width: (self.view?.frame.width)! - (self.view?.safeAreaInsets.left)! - (self.view?.safeAreaInsets.right)!, height: (self.view?.frame.height)! - (self.view?.safeAreaInsets.top)! - (self.view?.safeAreaInsets.bottom)!)
            print(self.view?.safeAreaInsets.left)
        } else {
            self.size                               = CGSize(width: view.frame.width, height: view.frame.height)
        }*/
        
        self.physicsWorld.gravity               = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate       = self
        
        // Set the ball's position, color, and gravity settings
        ball.name                               = "ball"
        //ball.position = CGPoint(x: self.size.height / 2.3, y: self.size.height / 2.3)
        ball.position                           = CGPoint(x: CGFloat(randomNumber(inRange: Int(self.size.width / 6)...Int(self.size.width / 1.2))), y: CGFloat(randomNumber(inRange: Int(self.size.height / 3)...Int(self.size.height / 1.2))))
        ball.fillColor                          = randomColor
        ball.strokeColor                        = randomColor
        ball.physicsBody                        = SKPhysicsBody(circleOfRadius: 12)
        ball.physicsBody!.velocity              = CGVector(dx: 200, dy: 200)
        ball.physicsBody!.friction              = 0
        ball.physicsBody!.restitution           = 1
        ball.physicsBody!.linearDamping         = 0
        ball.physicsBody!.allowsRotation        = false
        ball.physicsBody!.categoryBitMask       = Ball
        ball.physicsBody!.contactTestBitMask    = randomObstacleI
        ball.physicsBody!.usesPreciseCollisionDetection = true
        
        // Create all the paddles using createNode()
        topPaddle                   = SKSpriteNode(color: randomColor, size: CGSize(width: 170, height: 18), name: "topPaddle", dynamic: false, friction: 0, restitution: 1, cBM: topPaddleI, cTBM: Ball, position: CGPoint(x: horizontalRan, y: frame.maxY - 20))
        bottomPaddle                = SKSpriteNode(color: randomColor, size: CGSize(width: 170, height: 18), name: "bottomPaddle", dynamic: false, friction: 0, restitution: 1, cBM: bottomPaddleI, cTBM: Ball, position: CGPoint(x: horizontalRan, y: frame.minY + 20))
        leftPaddle                  = SKSpriteNode(color: randomColor, size: CGSize(width: 18, height: 170), name: "leftPaddle", dynamic: false, friction: 0, restitution: 1, cBM: leftPaddleI, cTBM: Ball, position: CGPoint(x: frame.minX + 20, y: 300))
        rightPaddle                 = SKSpriteNode(color: randomColor, size: CGSize(width: 18, height: 170), name: "rightPaddle", dynamic: false, friction: 0, restitution: 1, cBM: rightPaddleI, cTBM: Ball, position: CGPoint(x: frame.maxX - 20, y: 300))
        
        // Create all the labels using createLabel()
        scoreLabel                  = UILabel(title: String(score), align: 1, size: 20.0, color: UIColor.white, hidden: true, width: 50, height: 24, topAnchorConstant: 7, leftAnchorConstant: 9)
        curScoreLabel               = UILabel(title: "Score: " + String(topScore), size: 25.0, color: UIColor.white, hidden: true, width: 520, height: 60, centerXConstant: 0, centerYConstant: 0)
        topScoreLabel               = UILabel(title: "High Score: " + String(topScore), size: 25.0, color: UIColor.white, hidden: true, width: 520, height: 60, centerXConstant: 0, centerYConstant: 35)
        livesLabel                  = UILabel(title: String(repeating: "❤️", count: lives), align: 3, size: 15.0, color: UIColor.white, hidden: true, width: 113, height: 19, topAnchorConstant: 7, rightAnchorConstant: -9)
        overLabel                   = UILabel(title: "Game Over", size: 60.0, color: UIColor.red, hidden: true, bold: true, width: 500, height: 100, centerXConstant: 0, centerYConstant: -50)
        pausedLabel                 = UILabel(title: "Game Paused", size: 60.0, color: UIColor.orange, hidden: true, bold: true, width: 500, height: 100, centerXConstant: 0, centerYConstant: -50)
        
        // Create all the buttons using createButton()
        muteButton                  = UIButton(image: soundsEnabled ? unmutedImage : mutedImage, action: #selector(self.toggleSounds), transparent: true, hidden: true, width: 30, height: 30, rightAnchorConstant: -7, bottomAnchorConstant: -7)
        pauseButton                 = UIButton(image: pauseImage, action: #selector(self.pauseGame), transparent: true, hidden: true, width: 30, height: 30, leftAnchorConstant: 7, bottomAnchorConstant: -7)
        pauseButtonBig              = UIButton(title: "Play", color: UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.pauseGame), transparent: false, hidden: true, radius: 18, width: 280, height: 45, centerXConstant: 0, centerYConstant: 80)
        motionButton                = UIButton(image: motionEnabled ? motionImage : touchImage, action: #selector(self.toggleMotion), transparent: true, hidden: true, width: 30, height: 30, rightAnchorConstant: -41, bottomAnchorConstant: -7)
        //UIButton(image: motionEnabled ? motionImage : touchImage, action: #selector(self.toggleMotion), transparent: true, x: ((self.view?.frame.width)! - 71), y: view.frame.height - 37, width: 30, height: 30)
        restartButton               = UIButton(image: restartImage, action: #selector(self.restartGame), transparent: true, hidden: true, width: 30, height: 30, leftAnchorConstant: 41, bottomAnchorConstant: -7)
        restartButtonBig            = UIButton(title: "Restart", color: UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0), image: nil, action: #selector(self.restartGame), transparent: false, hidden: true, radius: 18, width: 280, height: 45, centerXConstant: 0, centerYConstant: 80)
        
        // Create the color panel (available in the pause menu)
        colorPanel.image                    = UIImage(named: "colors.png")!
        colorPanel.frame                    = CGRect(x: ((self.view?.frame.width)! / 2) - 210, y: ((self.view?.frame.height)! / 2) + 5, width: 420, height: 30)
        colorPanel.isHidden                 = true
        colorPanel.layer.cornerRadius       = 6.0
        colorPanel.clipsToBounds            = true
        
        colorSlider                         = UISlider(frame: CGRect(x: ((self.view?.frame.width)! / 2) - 210, y: ((self.view?.frame.height)! / 2) + 5, width: 420, height: 30))
        colorSlider.isHidden                = true
        colorSlider.minimumValue            = 0.5
        colorSlider.maximumValue            = 13.5
        colorSlider.setValue(0.5, animated: false)
        colorSlider.addTarget(self, action: #selector(getColor), for: ([.touchUpInside,.touchUpOutside,.valueChanged]))
        
        let tapGestureRecognizer            = UITapGestureRecognizer(target: self, action: #selector(tapColor(gestureRecognizer:)))
        colorSlider.addGestureRecognizer(tapGestureRecognizer)

        // Show the intro screen
        introGame()
    }
    
    
    // Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen
    public func didBegin(_ contact: SKPhysicsContact) {
        // The ball has hit one of the paddles
        if ((contact.bodyA.node?.name == "topPaddle" || contact.bodyA.node?.name == "bottomPaddle" || contact.bodyA.node?.name == "leftPaddle" || contact.bodyA.node?.name == "rightPaddle") && contact.bodyB.node?.name == "ball") {
            // Play the pong sound if sounds are enabled
            if soundsEnabled { run(pongSound) }
            
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This increases amount of awarded points as ball speeds up
            score = score + abs(Int((ball.physicsBody?.velocity.dy)!/40))
            scoreLabel.text = String(score)
            
            // Add random obstacles after 500 points to break patterns and make the gameplay better
           /* if score > 5 {
                removeChilds(randomObstacle)
                let size = CGSize(width: CGFloat(randomNumber(inRange: 30...500)), height: CGFloat(randomNumber(inRange: 5...20)))
                randomObstacle = SKSpriteNode(color: UIColor.yellow, size: size, name: "obstacle", dynamic: false, friction: 0, restitution: 1, cBM: randomObstacleI, cTBM: Ball, position: CGPoint(x: CGFloat(randomNumber(inRange: 100...Int(frame.maxX - size.width - 100))), y: CGFloat(randomNumber(inRange: 100...Int(frame.maxY - size.height - 100)))))
                addChilds(randomObstacle)
            }*/
            
            /*
             // Uncomment the code below to decrease paddle size after 1000 points
             if score > 1000 && topPaddle.size.width == 550 {
             // Animate the size change to make it smooth
             NSAnimationContext.runAnimationGroup({(context) in
             context.duration = 10.0
             let widthAction = SKAction.resize(toWidth: 500, duration: 10.0)
             let heightAction = SKAction.resize(toHeight: 500, duration: 10.0)
             topPaddle.run(widthAction)
             bottomPaddle.run(widthAction)
             leftPaddle.run(heightAction)
             rightPaddle.run(heightAction)
             })
             }
             */
            
            if (((ball.physicsBody?.velocity.dx)! < CGFloat(100) && (ball.physicsBody?.velocity.dx)! > -CGFloat(100)) || ((ball.physicsBody?.velocity.dy)! < CGFloat(100) && (ball.physicsBody?.velocity.dy)! > -CGFloat(100))) {
                // If the velocity is very low (e.g. slowed down by obstacle), increase it to a normal velocity
                ball.physicsBody?.velocity.dx  += ((ball.physicsBody?.velocity.dx)! < CGFloat(0)) ? -CGFloat(self.size.height / 2.3) : CGFloat(self.size.height / 2.3)
                ball.physicsBody?.velocity.dy  += ((ball.physicsBody?.velocity.dy)! < CGFloat(0)) ? -CGFloat(self.size.height / 2.3) : CGFloat(self.size.height / 2.3)
            } else {
                // Choose a random velocity to increase by
                let increase = CGFloat(randomNumber(inRange: Int(self.size.height/184)...Int(self.size.height/92)))
                
                // Increase the velocity based on whether it's negative or not
                ball.physicsBody?.velocity.dx  += ((ball.physicsBody?.velocity.dx)! < CGFloat(0)) ? -increase : increase
                ball.physicsBody?.velocity.dy  += ((ball.physicsBody?.velocity.dy)! < CGFloat(0)) ? -increase : increase
            }
        }
        // The ball has hit one of the edges of the game
        if (contact.bodyA.node?.name == nil && contact.bodyB.node?.name == "ball") {
            if lives > 1 {
                // Play the wall sound if sounds are enabled
                if soundsEnabled { run(wallSound) }
                
                // Player still has more than 1 life, remove one life and update the label
                lives = lives - 1
                return livesLabel.text = String(repeating: "❤️", count: lives)
            } else if gamePlaying {
                // Play the game over sound if sounds are enabled
                if soundsEnabled { run(overSound) }
                
                // Player doesn't have any lives left
                overLabel.isHidden          = false
                livesLabel.isHidden         = true
                scoreLabel.isHidden         = true
                curScoreLabel.isHidden      = false
                topScoreLabel.isHidden      = false
                pauseButton.isHidden        = true
                restartButton.isHidden      = true
                restartButtonBig.isHidden   = false
                removeChilds(ball)
                
                // Reset paddle size
                topPaddle.size.width = 170
                leftPaddle.size.height = 170
                bottomPaddle.size.width = 170
                rightPaddle.size.height = 170
                
                // Set the new top score, if it's above the previous one
                topScore = score > topScore ? score : topScore
                curScoreLabel.text = "Score: " + String(score)
                topScoreLabel.text = "High Score: " + String(topScore)
                prefs.set(topScore, forKey: "topScore")
                
                // Remove any random obstacles
                removeChilds(randomObstacle, randomObstacle)
            }
        }
    }
}

