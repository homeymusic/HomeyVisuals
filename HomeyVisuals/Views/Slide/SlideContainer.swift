import SwiftUI
import HomeyMusicKit

/// Wrap any slide content in the proper letterbox→scale logic.
struct SlideContainer<Content: View>: View {
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentCache.self) private var instrumentCache
    
    @Bindable var slide: Slide
    let isThumbnail: Bool
    @ViewBuilder let content: (CGFloat) -> Content
    
    /// You can omit `isThumbnail` when you want full-screen/edit mode.
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
            
            // Guard against zero width or height
            if geo.size.width > 0 && geo.size.height > 0 {
                let scale = min(
                    geo.size.width  / letterbox.width,
                    geo.size.height / letterbox.height
                )
                
                ZStack(alignment: .topLeading) {
                    SlideBackground(slide: slide, isThumbnail: isThumbnail)
                    content(scale)
                }
                .frame(width: letterbox.width, height: letterbox.height)
                .scaleEffect(scale, anchor: .topLeading)
                .coordinateSpace(name: "slideSpace")
                .onAppear {
                    instrumentCache.set(slide.musicalInstruments + slide.tonalityInstruments)
                }
                .onChange(of: slide.reloadTrigger) {
                    instrumentCache.set(slide.musicalInstruments + slide.tonalityInstruments)
                }
                .onDisappear {
                    instrumentCache.set([])
                }
            } else {
                // Render placeholder or empty space initially
                Color.clear
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
            CameraView(cameraDeviceID: slide.cameraDeviceID, isThumbnail: isThumbnail)
                .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fill)
                .clipped()
        }
    }
}

