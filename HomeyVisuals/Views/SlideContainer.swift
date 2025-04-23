// SlideContainer.swift

import SwiftUI
import HomeyMusicKit

/// Wrap any slide content in the proper letterbox→scale logic.
struct SlideContainer<Content: View>: View {
    let slide: Slide
    let isThumbnail: Bool
    @ViewBuilder let content: (_ letterbox: CGSize) -> Content

    /// You can omit `isThumbnail` when you want full-screen/edit mode.
    init(
        slide: Slide,
        isThumbnail: Bool = false,
        @ViewBuilder content: @escaping (_ letterbox: CGSize) -> Content
    ) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
        self.content     = content
    }

    var body: some View {
        GeometryReader { geo in
            let containerSize = geo.size
            // pick the “box” we lay out into:
            // – full-screen letterbox for slideshow/edit
            // – real-screen letterbox for thumbnails
            let box = isThumbnail
                ? slide.letterboxSizeOnScreen
                : containerSize

            // compute scale to fit that box *into* the container
            let scale = min(
                containerSize.width  / box.width,
                containerSize.height / box.height
            )

            ZStack {
                SlideBackground(slide: slide, isThumbnail: isThumbnail)
                content(box)
            }
            .frame(width: box.width, height: box.height)
            .scaleEffect(isThumbnail ? scale : 1, anchor: .topLeading)
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
    }
}

/// Centralized background logic (color vs. camera).
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

/// The shared drawing logic for any TextWidget.
struct TextWidgetContent: View {
  let widget: TextWidget
  let slideSize: CGSize

  var body: some View {
    Text(widget.text)
      .font(.system(size: widget.fontSize))
      .foregroundColor(.white)
      .position(
        x: slideSize.width  * widget.x,
        y: slideSize.height * widget.y
      )
  }
}
