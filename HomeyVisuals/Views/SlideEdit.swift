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
            GeometryReader { geo in
                ZStack {
                    // 1) Background
                    switch slide.backgroundType {
                    case .color:
                        slide.backgroundColor
                    case .cameraFeed:
                        CameraFeed(slide: slide, isThumbnail: false)
                    }
                    
                    // 2) Full‑screen clear tappable layer → deselect
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selections.textWidgetSelections = []
                        }
                    
                    // 3) All text widgets, in z‑order
                    ForEach(slide.textWidgets.indices
                        .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z }, id: \.self) { idx in
                            let w = slide.textWidgets[idx]
                            TextWidgetView(
                                widget:    w,
                                slideSize: geo.size,
                                isSelected: Binding(
                                    get: { selections.textWidgetSelections.contains(w.id) },
                                    set: { isSelected in
                                        if isSelected {
                                            selections.textWidgetSelections.insert(w.id)
                                        } else {
                                            selections.textWidgetSelections.remove(w.id)
                                        }
                                    }
                                )
                            )
                        }
                }
            }
            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
            .navigationTitle("Edit Slide")
        } else {
            ContentUnavailableView("Would you look at that.", systemImage: "eye")
        }
    }
}
