import AppKit
import SpriteKit
import Foundation

// Initialise touch bar variables, including touch bar items and buttons
public var touchBar            = NSTouchBar()
public var pauseTB             = NSCustomTouchBarItem(identifier: .pause)
public var pauseButtonTB       = NSButton()
public var restartTB           = NSCustomTouchBarItem(identifier: .restart)
public var restartButtonTB     = NSButton()
public var scoreTB             = NSCustomTouchBarItem(identifier: .score)
public var scoreLabelTB        = NSTextField(labelWithString: "0")
public var livesTB             = NSCustomTouchBarItem(identifier: .lives)
public var livesLabelTB        = NSTextField(labelWithString: "❤️❤️❤️❤️❤️")
public let colorList           = createColorList(array: colorArray)
public var colorPickerTB       = NSColorPickerTouchBarItem(identifier: .picker)


// Set the touch bar item identifiers for the pause button, restart button, and color picker
extension NSTouchBarItem.Identifier {
    static let score        = NSTouchBarItem.Identifier("com.js.DoublePong.scoreLabel")
    static let lives        = NSTouchBarItem.Identifier("com.js.DoublePong.livesLabel")
    static let pause        = NSTouchBarItem.Identifier("com.js.DoublePong.pauseButton")
    static let restart      = NSTouchBarItem.Identifier("com.js.DoublePong.restartButton")
    static let picker       = NSTouchBarItem.Identifier("com.js.DoublePong.colorPicker")
}

// Set the touch bar customization identifier
extension NSTouchBar.CustomizationIdentifier {
    static let master       = NSTouchBar.CustomizationIdentifier("com.js.DoublePong.master")
}

// Only run the code below on Touch Bar supported systems
@available(OSX 10.12.2, *)
extension NSView: NSTouchBarDelegate {
    // Call the scene's pauseGame() function when the pause button is tapped
    @objc func pauseAction() {
        scene.pauseGame()
    }
    
    // Call the scene's restartGame() function when the restart button is tapped
    @objc func restartAction() {
        scene.restartGame()
    }
    
    // Send the new color to the scene to set it on all elements
    @objc func colorPickerAction() {
        scene.setColor(color: colorPickerTB.color)
    }
    
    // Initialize the touch bar
    override open func makeTouchBar() -> NSTouchBar? {
        touchBar                            = NSTouchBar()
        touchBar?.delegate                  = self
        touchBar?.defaultItemIdentifiers    = [.fixedSpaceLarge, .score, .fixedSpaceLarge, .lives, .flexibleSpace, .pause, .restart, .picker]
        touchBar?.customizationIdentifier   = .master
        return touchBar
    }
    
    // Initialize the touch bar items
    public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.score:
            scoreTB.view = { return scoreLabelTB }()
            return scoreTB
        case NSTouchBarItem.Identifier.lives:
            livesTB.view = { return livesLabelTB }()
            return livesTB
        case NSTouchBarItem.Identifier.pause:
            pauseTB.view = {
                pauseButtonTB               = NSButton(image: NSImage(named: NSImage.Name.touchBarPauseTemplate)!, target: scene, action: #selector(scene.pauseGame))
                pauseButtonTB.isHidden      = true
                return pauseButtonTB
            }()
            return pauseTB
        case NSTouchBarItem.Identifier.restart:
            restartTB.view = {
                restartButtonTB             = NSButton(image: NSImage(named: NSImage.Name.touchBarRefreshTemplate)!, target: scene, action: #selector(scene.restartGame))
                restartButtonTB.isHidden    = true
                return restartButtonTB
            }()
            return restartTB
        case NSTouchBarItem.Identifier.picker:
            colorPickerTB.action            = #selector(colorPickerAction)
            colorPickerTB.colorList         = colorList
            return colorPickerTB
        default:
            return nil
        }
    }
}
