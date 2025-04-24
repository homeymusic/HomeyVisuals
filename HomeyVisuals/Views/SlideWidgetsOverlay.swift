// SlideWidgetsOverlay.swift

import SwiftUI
import HomeyMusicKit

/// Renders *all* of a slide’s widgets in z-order, using the right widget view,
/// and optionally allows interaction (hit-testing).
struct SlideWidgetsOverlay: View {
    let slide: Slide
    let scale: CGFloat
    let allowInteraction: Bool

    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentalContext.self) private var instrumentalContext

    var body: some View {
        ZStack {
            ForEach(slide.widgets, id: \.id) { widget in
                switch widget {
                case let text as TextWidget:
                    TextWidgetView(
                        textWidget: text,
                        slideScale: scale
                    )
                    .allowsHitTesting(allowInteraction)

                case let inst as InstrumentWidget:
                    InstrumentWidgetView(
                        instrumentWidget: inst,
                        slideScale: scale
                    )
                    .allowsHitTesting(allowInteraction)

                default:
                    EmptyView()
                }
            }
        }
    }
}
