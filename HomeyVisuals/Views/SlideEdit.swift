import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: click to select, drag to move, double-click to edit, tap off to deselect or exit edit-mode.
struct SlideEdit: View {
    @Environment(AppContext.self) private var appContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var body: some View {
        if let slide = appContext.selectedSlide(in: slides) {
            SlideContainer(slide: slide, isThumbnail: false) { scale in
                ZStack {
                    // 1) Tap anywhere empty to clear selection AND exit edit-mode
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appContext.textWidgetSelections = []
                            appContext.editingTextWidgetID = nil
                        }

                    // 2) Render each text widget in z-order
                    ForEach(
                        slide.textWidgets.indices
                            .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z },
                        id: \.self
                    ) { index in
                        let textWidget = slide.textWidgets[index]
                        TextWidgetView(
                            textWidget: textWidget,
                            slideScale: scale
                        )
                    }
                    
                    ForEach(
                        slide.instrumentWidgets.indices
                            .sorted { slide.instrumentWidgets[$0].z < slide.instrumentWidgets[$1].z },
                        id: \.self
                    ) { index in
                        let instrumentWidget = slide.instrumentWidgets[index]
                        InstrumentWidgetView(
                            instrumentWidget: instrumentWidget,
                            slideScale: scale 
                        )
                    }

                }
            }
            .navigationTitle("Edit Slide")
        } else {
            ContentUnavailableView("Would you look at that.", systemImage: "eye")
        }
    }
}
