import AppKit
import SpriteKit
import Foundation
import AVFoundation

public extension Scene {
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
