// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: click widgets to select, drag to move, click off to deselect.
struct SlideEdit: View {
    @Bindable var slide: Slide
    @Binding var selectedWidgetID: UUID?

    private var sortedWidgetIndices: [Int] {
        slide.textWidgets.indices
            .sorted { slide.textWidgets[$0].z < slide.textWidgets[$1].z }
    }

    var body: some View {
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
                        selectedWidgetID = nil
                    }

                // 3) All text widgets, in z‑order
                ForEach(sortedWidgetIndices, id: \.self) { idx in
                    let w = slide.textWidgets[idx]
                    TextWidgetView(
                        widget:    w,
                        slideSize: geo.size,
                        isSelected: Binding(
                            get: { selectedWidgetID == w.id },
                            set: { on in
                                selectedWidgetID = on ? w.id : nil
                            }
                        )
                    )
                }
            }
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
    }
}
