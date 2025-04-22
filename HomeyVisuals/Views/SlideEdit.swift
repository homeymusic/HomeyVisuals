// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: renders either a solid color or live camera feed background,
/// and lets the user click‑select and drag TextWidgets around.
struct SlideEdit: View {
    @Bindable var slide: Slide
    @Binding var selectedWidgetID: UUID?

    /// Compute each widget’s index sorted by its `z`‑order.
    private var sortedWidgetIndices: [Int] {
        slide.textWidgets
            .indices
            .sorted { a, b in
                slide.textWidgets[a].z < slide.textWidgets[b].z
            }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: Background
                switch slide.backgroundType {
                case .color:
                    slide.backgroundColor
                case .cameraFeed:
                    CameraFeed(slide: slide, isThumbnail: false)
                }

                // MARK: Draggable TextWidgets
                ForEach(sortedWidgetIndices, id: \.self) { idx in
                    let widget = slide.textWidgets[idx]

                    TextWidgetView(
                        widget:    widget,
                        slideSize: geo.size
                    )
                    // make the full frame tappable
                    .contentShape(Rectangle())
                    // tap to select this widget
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                selectedWidgetID = widget.id
                            }
                    )
                }
            }
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
    }
}
