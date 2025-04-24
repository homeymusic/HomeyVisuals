// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideEdit: View {
    @Environment(AppContext.self) private var appContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var body: some View {
        if let slide = appContext.selectedSlide(in: slides) {
            SlideContainer(slide: slide, isThumbnail: false) { scale in
                ZStack {
                    // tap-off clears selection/editing
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appContext.widgetSelections.removeAll()
                            appContext.editingWidgetID = nil
                        }

                    SlideWidgetsOverlay(
                        slide: slide,
                        scale: scale,
                        allowInteraction: true
                    )
                }
            }
            .navigationTitle("Edit Slide")
        } else {
            ContentUnavailableView("Would you look at that.", systemImage: "eye")
        }
    }
}
