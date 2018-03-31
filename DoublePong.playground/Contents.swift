/*:
 # DoublePong
 ### Pong, with even more paddles.
 ---
 ## Paddles
 ### There are 4 paddles, positioned on each edge of the screen. Move your cursor to move the paddles, and try to block the ball from hitting the edges.
 ---
 ## Difficulty
 ### The game will constantly get faster and harder, by add invisible obstacles and reducing the size of the paddles after a while.
 ---
 ## Touch Bar
 ### Use MacBook Pro with Touch Bar for enhanced access to game controls and the current score.
 ---
 ## Customization
 ### Pause the game (press the space bar or press the pause icon) or press the Color Picker icon on the Touch Bar to change the color of the ball and paddles.
 ### Press the volume icon in the game or on the Touch Bar to mute or unmute the game sounds.
 */
// Import main frameworks
import AppKit
import SpriteKit
import PlaygroundSupport

// Scene is initialized in Declarations
scene.scaleMode = .aspectFit

// Create the views for the scene
let view = NSView(frame:  CGRect(x: 0, y: 0, width: 640, height: 360))
let skView = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 360))
skView.presentScene(scene)
view.addSubview(skView)

// Set the playground liveview to the view that was just created
PlaygroundPage.current.liveView = view

// To reset preferences, change resetPreferences to true, run the playground, then run it again to see the updated preferences
var resetPreferences = false
if (resetPreferences) {
    prefs.set(nil, forKey: "isIntro")
    prefs.set(nil, forKey: "topScore")
    prefs.set(nil, forKey: "nextIntro")
    prefs.set(nil, forKey: "customColor")
    prefs.set(nil, forKey: "soundsEnabled")
}
public let randomColor:        NSColor = prefs.getColor(key: "customColor") != nil ? prefs.getColor(key: "customColor") as NSColor : /*NSColor(red: CGFloat((randomIndex! & 0xFF0000) >> 16) / 0xFF, green: CGFloat((randomIndex! & 0x00FF00) >> 8) / 0xFF, blue: CGFloat(randomIndex! & 0x0000FF) / 0xFF, alpha: CGFloat(1.0))*/NSColor(rgb: randomIndex!)
