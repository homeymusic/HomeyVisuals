// WidgetShow.swift

import SwiftUI
import HomeyMusicKit

/// Read-only “show” mode for any widget:
/// • Text renders statically (no selection/editing/dragging)
/// • Instruments render playably (always hit-testable)
struct WidgetShow: View {
    let widget: any Widget
    let scale: CGFloat

    @Environment(InstrumentalContext.self) private var instrumentalContext

    var body: some View {
        Group {
            switch widget {
            case let text as TextWidget:
                Text(text.text)
                    .font(.system(size: text.fontSize))
                    .foregroundColor(.white)
                    .frame(width:    text.width,
                           alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: text.x, y: text.y)

            case let instrumentWidget as InstrumentWidget:
                InstrumentView(instrumentWidget.instrument)
                    .frame(width: instrumentWidget.width, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: instrumentWidget.x, y: instrumentWidget.y)

            default:
                EmptyView()
            }
        }
        // only instruments remain interactive in “show” mode
        .allowsHitTesting(widget is InstrumentWidget)
    }
}
