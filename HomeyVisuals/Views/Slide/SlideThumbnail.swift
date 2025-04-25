// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

struct SlideThumbnail: View {
    let slide: Slide

    init(slide: Slide) {
        self.slide = slide
    }

    var body: some View {
        SlideContainer(slide: slide, isThumbnail: true) { scale in
            WidgetList(
                slide: slide,
                scale: scale,
                widgetViewStyle: .thumbnail
            )
        }
    }
}
