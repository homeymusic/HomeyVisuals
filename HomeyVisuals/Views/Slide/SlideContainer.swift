import SwiftUI
import HomeyMusicKit

/// Wrap any slide content in the proper letterbox→scale logic,
/// avoiding zero-size transforms in full-screen.
struct SlideContainer<Content: View>: View {
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentCache.self) private var instrumentCache

    @Bindable var slide: Slide
    let isThumbnail: Bool
    @ViewBuilder let content: (CGFloat) -> Content

    init(
        slide: Slide,
        isThumbnail: Bool = false,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
        self.content     = content
    }

    var body: some View {
        GeometryReader { geo in
            let letterbox = slide.size
            // only compute a custom scale if we have a real container size
            let hasValidSize = geo.size.width > 0 && geo.size.height > 0
            let rawScale = min(
                geo.size.width  / letterbox.width,
                geo.size.height / letterbox.height
            )
            // fallback to 1 until we get a non-zero layout
            let scale = hasValidSize ? rawScale : 1

            ZStack(alignment: .topLeading) {
                SlideBackground(slide: slide, isThumbnail: isThumbnail)
                content(scale)
            }
            .frame(width:  letterbox.width,
                   height: letterbox.height)
            .scaleEffect(scale, anchor: .topLeading)
            .coordinateSpace(name: "slideSpace")
            .onAppear {
                instrumentCache.set(slide.musicalInstruments + slide.tonalityInstruments)
            }
            .onChange(of: slide.reloadTrigger) { _ in
                instrumentCache.set(slide.musicalInstruments + slide.tonalityInstruments)
            }
            .onDisappear {
                instrumentCache.set([])
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
            CameraView(
                cameraDeviceID: slide.cameraDeviceID,
                isThumbnail: isThumbnail
            )
            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fill)
            .clipped()
        }
    }
}
