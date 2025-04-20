import SwiftUI
import AppKit

/// The size a slide of given aspect ratio will occupy on the actual screen (letterboxed).
public func deviceSlideSize(aspect: CGFloat) -> CGSize {
    let screen = NSScreen.main?.frame.size ?? CGSize(width: 3840, height: 2160)
    let screenAspect = screen.width / screen.height
    if aspect > screenAspect {
        let w = screen.width
        return CGSize(width: w, height: w / aspect)
    } else {
        let h = screen.height
        return CGSize(width: h * aspect, height: h)
    }
}
