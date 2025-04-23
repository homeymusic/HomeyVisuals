// Slide+Letterbox.swift

import CoreGraphics
import AppKit

extension Slide {
    /// “If I letterbox this slide to fill the main screen, what size do I end up?”
    var letterboxSizeOnScreen: CGSize {
        let screen       = NSScreen.main?.frame.size
                          ?? CGSize(width: 3840, height: 2160)
        let aspect       = CGFloat(aspectRatio.ratio)
        let screenAspect = screen.width / screen.height

        if aspect > screenAspect {
            // slide is wider → full-width letterbox
            let w = screen.width
            return CGSize(width: w, height: w / aspect)
        } else {
            // slide is taller (or equal) → full-height letterbox
            let h = screen.height
            return CGSize(width: h * aspect, height: h)
        }
    }
}
