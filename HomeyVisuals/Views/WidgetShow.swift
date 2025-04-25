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

            case let inst as InstrumentWidget:
                InstrumentView()
                    .onAppear {
                        instrumentalContext.instrumentChoice = inst.instrumentChoice
                    }
                    .frame(width:    inst.width,
                           alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: inst.x, y: inst.y)

            default:
                EmptyView()
            }
        }
        // only instruments remain interactive in “show” mode
        .allowsHitTesting(widget is InstrumentWidget)
    }
}
