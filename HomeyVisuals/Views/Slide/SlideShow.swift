// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

struct SlideShow: View {
    let slide: Slide

    init(slide: Slide) {
        self.slide = slide
    }

    var body: some View {
        SlideContainer(slide: slide, isThumbnail: false) { scale in
            WidgetList(
                slide: slide,
                scale: scale,
                widgetViewStyle: .show
            )
        }
        .clipped()
    }
}
