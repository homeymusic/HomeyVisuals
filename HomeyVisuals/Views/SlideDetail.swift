// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

/// Read‑only slide view showing either the solid background color or live camera feed.
struct SlideDetail: View {
    let slide: Slide
    let isThumbnail: Bool

    init(slide: Slide, isThumbnail: Bool = false) {
        self.slide = slide
        self.isThumbnail = isThumbnail
    }

    var body: some View {
        SlideContainer(slide: slide, isThumbnail: isThumbnail) { size in
            ForEach(slide.textWidgets, id: \.id) { widget in
                Text(widget.text)
                    .foregroundColor(.white)
                    .position(
                        x: size.width  * widget.x,
                        y: size.height * widget.y
                    )
            }
        }
    }
}
