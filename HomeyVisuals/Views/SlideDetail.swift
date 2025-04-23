// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

/// Live slide renderer used in both list-thumbnails and slideshow/edit modes.
struct SlideDetail: View {
    let slide: Slide
    let isThumbnail: Bool

    init(slide: Slide, isThumbnail: Bool = false) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
    }

    var body: some View {
        SlideContainer(slide: slide, isThumbnail: isThumbnail) { slideSize in
            ForEach(slide.textWidgets, id: \.id) { textWidget in
                Text(textWidget.text)
                    .font(.system(size: textWidget.fontSize))
                    .foregroundColor(.white)
                    .position(
                        x: slideSize.width  * textWidget.x,
                        y: slideSize.height * textWidget.y
                    )
            }
        }
    }
}
