import SpriteKit
import AppKit
import PlaygroundSupport

let scene = Interface()
scene.scaleMode = .aspectFit

let view = NSView(frame:  CGRect(x: 0, y: 0, width: 640, height: 360))

let skView = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 360))
skView.presentScene(scene)
view.addSubview(skView)

PlaygroundPage.current.liveView = view
