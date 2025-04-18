// HomeyVisuals/Views/SlideShow.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Renders one slide *full‑screen* (or full container)
/// — this is exactly what you’ll use in your slideshow mode.
struct SlideShow: View {
  let slide: Slide

  var body: some View {
    ZStack {
      // Background
      if slide.backgroundType == .color {
        Color(slide.backgroundColor)
      } else {
        // TODO: plug in real camera feed
        Color.black.opacity(0.2)
      }

      // Overlay any other slide content here:
      // e.g. Text(slide.testString)
      Text(slide.testString)
        .foregroundColor(.white)
        .font(.largeTitle)
    }
    // Fill its container with the correct ratio
    .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
    .clipped()
  }
}
