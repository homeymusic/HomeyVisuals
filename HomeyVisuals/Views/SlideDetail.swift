// SlideDetail.swift

import SwiftUI
import HomeyMusicKit

/// Live slide renderer used in both list-thumbnails and slideshow/edit modes.
struct SlideDetail: View {
    let slide: Slide
    let isThumbnail: Bool
    
    init(slide: Slide, isThumbnail: Bool) {
        self.slide       = slide
        self.isThumbnail = isThumbnail
    }
    
    var body: some View {
        SlideContainer(slide: slide, isThumbnail: isThumbnail) {
            ForEach(slide.textWidgets, id: \.id) { textWidget in
                TextWidgetContent(textWidget: textWidget)
                    .position(
                        x: textWidget.x,
                        y: textWidget.y
                    )
                
            }
            ForEach(slide.instrumentWidgets, id: \.id) { instrumentWidget in
                InstrumentWidgetContent(instrumentWidget: instrumentWidget)
                    .position(
                        x: instrumentWidget.x,
                        y: instrumentWidget.y
                    )
            }
        }
    }
}
