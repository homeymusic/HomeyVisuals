// SlideWidgetsOverlay.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Renders *all* of a slide’s widgets in z-order, using the right widget view,
/// and automatically stays up to date as SwiftData changes your model.
struct WidgetList: View {
    @Bindable var slide: Slide
    let scale: CGFloat
    let widgetViewStyle: WidgetViewStyle


    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(slide.widgets, id: \.id) { widget in
                switch widgetViewStyle {
                case .thumbnail:
                    WidgetThumbnail(widget: widget, scale: scale)
                case .edit:
                    WidgetEdit(widget: widget, scale: scale)
                case .show:
                    WidgetShow(widget: widget, scale: scale)
                }
            }
        }
    }
}

enum WidgetViewStyle {
    case thumbnail
    case edit
    case show
}
