// WidgetEdit.swift

import SwiftUI
import HomeyMusicKit

/// Editable wrapper for any Widget: moves, resizes, selects, edits.
struct WidgetEdit: View {
    let widget: any Widget
    let scale: CGFloat

    @Environment(AppContext.self)            private var appContext
    @Environment(InstrumentalContext.self)   private var instrumentalContext

    var body: some View {
        switch widget {
        case let text as TextWidget:
            TextWidgetView(
                textWidget: text,
                slideScale: scale
            )
        case let inst as InstrumentWidget:
            InstrumentWidgetView(
                instrumentWidget: inst,
                slideScale: scale
            )
        default:
            EmptyView()
        }
    }
}
