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
        SlideContainer(slide: slide, isThumbnail: isThumbnail) { box in
            ForEach(slide.textWidgets, id: \.id) { w in
                Text(w.text)
                    .font(.system(size: w.fontSize))
                    .foregroundColor(.white)
                    .position(
                        x: box.width  * w.x,
                        y: box.height * w.y
                    )
            }
        }
    }
}
