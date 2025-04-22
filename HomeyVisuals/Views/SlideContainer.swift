// SlideContainer.swift

import SwiftUI
import HomeyMusicKit

/// A reusable container that handles sizing, background, and aspect ratio for a Slide.
struct SlideContainer<Content: View>: View {
    let slide: Slide
    let isThumbnail: Bool
    @ViewBuilder let content: (_ size: CGSize) -> Content

    init(
        slide: Slide,
        isThumbnail: Bool = false,
        @ViewBuilder content: @escaping (_ size: CGSize) -> Content
    ) {
        self.slide = slide
        self.isThumbnail = isThumbnail
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SlideBackground(slide: slide, isThumbnail: isThumbnail)
                content(geo.size)
            }
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
    }
}

/// Extracted background logic so you only have one switch to maintain.
struct SlideBackground: View {
    let slide: Slide
    let isThumbnail: Bool

    var body: some View {
        switch slide.backgroundType {
        case .color:
            slide.backgroundColor
        case .cameraFeed:
            CameraFeed(slide: slide, isThumbnail: isThumbnail)
        }
    }
}
