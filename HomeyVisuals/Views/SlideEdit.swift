import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: click to select, drag to move, double-click to edit, tap off to deselect or exit edit-mode.
struct SlideEdit: View {
    @Environment(Selections.self) private var selections
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var body: some View {
        if let slide = selections.selectedSlide(in: slides) {
            SlideContainer(slide: slide, isThumbnail: false) {
                ZStack {
                    // 1) Tap anywhere empty to clear selection AND exit edit-mode
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selections.textWidgetSelections = []
                            selections.editingWidgetID = nil
                        }

                    // 2) Render each text widget in z-order
                    ForEach(
                        slide.textWidgets.indices
                            .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z },
                        id: \.self
                    ) { index in
                        let textWidget = slide.textWidgets[index]
                        TextWidgetView(
                            textWidget: textWidget
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
