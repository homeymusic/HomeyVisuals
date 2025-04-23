// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: click to select, drag to move, tap off to deselect.
struct SlideEdit: View {
    @Environment(Selections.self) var selections
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var body: some View {
        if let slide = selections.selectedSlide(in: slides) {
            // ← remove isThumbnail: true here
            SlideContainer(slide: slide) { box in
                Group {
                    // 1) Tap to deselect
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { selections.textWidgetSelections = [] }

                    // 2) Render each text widget
                    ForEach(
                        slide.textWidgets.indices
                            .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z },
                        id: \.self
                    ) { idx in
                        let w = slide.textWidgets[idx]
                        TextWidgetView(
                            widget:    w,
                            slideSize: box,
                            isSelected: Binding(
                                get: { selections.textWidgetSelections.contains(w.id) },
                                set: { isSel in
                                    if isSel {
                                        selections.textWidgetSelections.insert(w.id)
                                    } else {
                                        selections.textWidgetSelections.remove(w.id)
                                    }
                                }
                            )
                        )
                        // use the same widget.fontSize
                        .font(.system(size: w.fontSize))
                    }
                }
            }
            .navigationTitle("Edit Slide")
        } else {
            ContentUnavailableView("Would you look at that.", systemImage: "eye")
        }
    }
}
