import AppKit
import SpriteKit
import Foundation
import AVFoundation

// Prepare the pong, game over, and wall sounds with SKAction
public let pongSound           = SKAction.playSoundFileNamed("pong", waitForCompletion: false)
public let overSound           = SKAction.playSoundFileNamed("over", waitForCompletion: false)
public let wallSound           = SKAction.playSoundFileNamed("wall", waitForCompletion: false)

// Add NSImage extension to quickly invert colors on an image
public extension NSImage {
    public func invert() -> NSImage? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let ciImage = CoreImage.CIImage(cgImage: cgImage!)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return NSImage(cgImage: outputImageCopy, size: NSSize(width:outputImageCopy.width, height:outputImageCopy.height))
        
    }
}

// Cretae the images used for the game by inverting the colors of the template images (this reduces file size as less images need to be included in the playground)
public extension Scene {
    public var playImage:      NSImage { return NSImage(named: NSImage.Name.touchBarPlayTemplate)!.invert()! }
    public var pauseImage:     NSImage { return NSImage(named: NSImage.Name.touchBarPauseTemplate)!.invert()! }
    public var replayImage:    NSImage { return NSImage(named: NSImage.Name.touchBarRefreshTemplate)!.invert()! }
    public var mutedImage:     NSImage { return NSImage(named: NSImage.Name.touchBarAudioOutputMuteTemplate)!.invert()! }
    public var unmutedImage:   NSImage { return NSImage(named: NSImage.Name.touchBarVolumeUpTemplate)!.invert()! }
}
