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
