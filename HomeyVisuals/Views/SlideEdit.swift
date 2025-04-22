// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: click widgets to select, drag to move, click off to deselect.
struct SlideEdit: View {
    @Environment(Selections.self) var selections
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var body: some View {
        if let slide = selections.selectedSlide(in: slides) {
            SlideContainer(slide: slide) { size in
                // 1) Deselect on tapping empty space
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { selections.textWidgetSelections = [] }

                // 2) All text widgets in ascending z-order
                ForEach(
                    slide.textWidgets.indices
                        .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z },
                    id: \.self
                ) { idx in
                    let w = slide.textWidgets[idx]
                    TextWidgetView(
                        widget: w,
                        slideSize: size,
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
                }
            }
            .navigationTitle("Edit Slide")
        } else {
            ContentUnavailableView("Would you look at that.", systemImage: "eye")
        }
    }
}
