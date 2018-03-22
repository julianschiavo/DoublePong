import AppKit
import SpriteKit
import Foundation

// Create a NSColorList for the touch bar color picker
public let colorList        = createColorList(array: colorArray)

// Set the touch bar item identifiers for the pause button, restart button, and color picker
extension NSTouchBarItem.Identifier {
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
    // Send the new color to the scene to set it on all elements
    @objc func pauseAction() {
        scene.pauseGame()
    }
    
    // Send the new color to the scene to set it on all elements
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
        touchBar?.defaultItemIdentifiers    = [.pause, .restart, .picker]
        touchBar?.customizationIdentifier   = .master
        return touchBar
    }
    
    // Initialize the touch bar items (pause button, restart button, and color picker)
    public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.pause:
            pauseTB.view = {
                pauseButtonTB               = NSButton(image: NSImage(named: NSImage.Name.touchBarPauseTemplate)!, target: self, action: #selector(pauseAction))
                pauseButtonTB.isHidden      = true
                return pauseButtonTB
            }()
            return pauseTB
        case NSTouchBarItem.Identifier.restart:
            restartTB.view = {
                restartButtonTB             = NSButton(image: NSImage(named: NSImage.Name.touchBarRefreshTemplate)!, target: self, action: #selector(restartAction))
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
