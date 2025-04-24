import SwiftUI
import HomeyMusicKit

/// Wrap any slide content in the proper letterbox→scale logic.
struct SlideContainer<Content: View>: View {
    let slide: Slide
    let isThumbnail: Bool
    @ViewBuilder let content: () -> Content

    /// You can omit `isThumbnail` when you want full-screen/edit mode.
    init(
        slide: Slide,
        isThumbnail: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
        self.content     = content
    }

    var body: some View {
        GeometryReader { geo in
            let containerSize = geo.size
            // compute scale to fit that letterbox into whatever container we have
            let scale = min(
                containerSize.width  / slide.size.width,
                containerSize.height / slide.size.height
            )

            ZStack(alignment: .topLeading) {
                SlideBackground(slide: slide, isThumbnail: isThumbnail)
                content()
            }
            .frame(width:  slide.size.width,
                   height: slide.size.height)
            .scaleEffect(scale, anchor: .topLeading)
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
    let textWidget: TextWidget

    var body: some View {
        Text(textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .foregroundColor(.white)
    }
}

