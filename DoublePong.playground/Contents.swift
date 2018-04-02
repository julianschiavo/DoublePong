/*:
 # DoublePong
 ## Pong, with even more paddles.
 ---
 ## Paddles
 ### There are 4 paddles, positioned on each edge of the screen. Move your cursor to move the paddles, and try to block the ball from hitting the edges.
 ---
 ## Difficulty
 ### The game will constantly get faster and harder. Invisible obstacles will be added after 500 points.
 ---
 ## Controls
 ### Pause the game by pressing the space bar (make sure the playground is focused) or the pause button.
 ### Use the volume button to mute or unmute game sounds.
 ### Use the color picker in the pause menu or the Touch Bar to change the color of the paddles and ball.
 ---
 ## Touch Bar
 ### Use MacBook Pro with Touch Bar for enhanced access to game controls and the current score.
 */
// Import main frameworks
import AppKit
import SpriteKit
import PlaygroundSupport

// Use the scene that was initialized in Declarations
scene.scaleMode = .aspectFit

// Create the views for the scene
let view = NSView(frame:  CGRect(x: 0, y: 0, width: 640, height: 360))
let skView = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 360))
skView.presentScene(scene)
view.addSubview(skView)

// Set the playground liveview to the view that was just created
PlaygroundPage.current.liveView = view

// If reset is true (in Declarations.swift), reset all the UserDefaults
if reset {
    prefs.set(nil, forKey: "isIntro")
    prefs.set(nil, forKey: "topScore")
    prefs.set(nil, forKey: "nextIntro")
    prefs.set(nil, forKey: "customColor")
    prefs.set(nil, forKey: "soundsEnabled")
}
