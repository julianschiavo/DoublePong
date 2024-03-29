//
//  TouchBar.swift
//  DoublePong
//
//  Created by Julian Schiavo on 2/4/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import AppKit
import SpriteKit
import Foundation

// Initialise touch bar variables, including touch bar items and buttons
public var touchBar            = NSTouchBar()
public var muteTB              = NSCustomTouchBarItem(identifier: .mute)
public var muteButtonTB        = NSButton()
public var pauseTB             = NSCustomTouchBarItem(identifier: .pause)
public var pauseButtonTB       = NSButton()
public var restartTB           = NSCustomTouchBarItem(identifier: .restart)
public var restartButtonTB     = NSButton()
public var scoreTB             = NSCustomTouchBarItem(identifier: .score)
public var scoreLabelTB        = NSTextField(labelWithString: "0")
public let colorList           = createColorList(array: colorArray)
public var colorPickerTB       = NSColorPickerTouchBarItem(identifier: .picker)

// Set the touch bar item identifiers for the pause button, restart button, and color picker
extension NSTouchBarItem.Identifier {
    static let mute         = NSTouchBarItem.Identifier("com.js.DoublePong.muteButton")
    static let score        = NSTouchBarItem.Identifier("com.js.DoublePong.scoreLabel")
    static let pause        = NSTouchBarItem.Identifier("com.js.DoublePong.pauseButton")
    static let restart      = NSTouchBarItem.Identifier("com.js.DoublePong.restartButton")
    static let picker       = NSTouchBarItem.Identifier("com.js.DoublePong.colorPicker")
}

// Set the touch bar customization identifier
extension NSTouchBar.CustomizationIdentifier {
    static let master       = NSTouchBar.CustomizationIdentifier("com.js.DoublePong.master")
}

// Create a custom touch bar, and add a pause button, mute button, restart button, and color picker
@available(OSX 10.12.2, *)
extension NSView: NSTouchBarDelegate {
    // Send the new color to the scene to set it on all elements
    @objc func colorPickerAction() {
        scene.setColor(color: colorPickerTB.color)
    }
    
    // Initialize the touch bar
    override open func makeTouchBar() -> NSTouchBar? {
        touchBar                            = NSTouchBar()
        touchBar?.delegate                  = self
        touchBar?.defaultItemIdentifiers    = [.fixedSpaceLarge, .score, .flexibleSpace, .pause, .restart, .mute, .picker]
        touchBar?.customizationIdentifier   = .master
        return touchBar
    }
    
    // Initialize the touch bar items
    public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.score:
            scoreTB.view = { return scoreLabelTB }()
            return scoreTB
        case NSTouchBarItem.Identifier.mute:
            muteTB.view = {
                muteButtonTB                = NSButton(image: NSImage(named: NSImage.Name.touchBarVolumeUpTemplate)!, target: scene, action: #selector(scene.muteSounds))
                return muteButtonTB
            }()
            return muteTB
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
