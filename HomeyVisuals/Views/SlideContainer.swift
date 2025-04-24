import SwiftUI
import HomeyMusicKit

/// Wrap any slide content in the proper letterbox→scale logic.
struct SlideContainer<Content: View>: View {
    @Environment(AppContext.self) private var appContext
    
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
            // 1) Compute the scale that fits your slide into the container
            let letterbox = slide.size
            let scale = min(
                geo.size.width  / letterbox.width,
                geo.size.height / letterbox.height
            )

            // 2) Kick the scale into AppContext any time it changes
            ZStack(alignment: .topLeading) {
                SlideBackground(slide: slide, isThumbnail: isThumbnail)
                content()
            }
            .frame(width:  letterbox.width,
                   height: letterbox.height)
            .scaleEffect(scale, anchor: .topLeading)
            .onAppear { appContext.slideScale = scale }
            .onChange(of: scale) {
                appContext.slideScale = scale
            }
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

