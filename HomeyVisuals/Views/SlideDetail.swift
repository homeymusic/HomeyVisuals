// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

struct SlideDetail: View {
    let slide: Slide
    let isThumbnail: Bool

    init(slide: Slide, isThumbnail: Bool = false) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
    }

    var body: some View {
        SlideContainer(slide: slide, isThumbnail: isThumbnail) { scale in
            SlideWidgetsOverlay(
                slide: slide,
                scale: scale,
                allowInteraction: !isThumbnail
            )
        }
    }
}
