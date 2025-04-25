// SlideWidgetsOverlay.swift

import SwiftUI
import HomeyMusicKit

/// Renders *all* of a slide’s widgets in z-order, using the right widget view,
/// and optionally allows interaction (hit-testing).
struct WidgetList: View {
    let slide: Slide
    let scale: CGFloat
    let widgetViewStyle: WidgetViewStyle
    
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentalContext.self) private var instrumentalContext

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(slide.widgets, id: \.id) { widget in
                switch widgetViewStyle {
                case .thumbnail:
                    WidgetThumbnail(widget: widget, scale: scale)
                        .allowsHitTesting(false)
                case .edit:
                    WidgetEdit(widget: widget, scale: scale)
                        .allowsHitTesting(true)
                }
            }
        }
    }
}

enum WidgetViewStyle {
    case thumbnail
    case edit
}
