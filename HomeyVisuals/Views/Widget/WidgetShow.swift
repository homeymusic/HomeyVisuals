// WidgetShow.swift

import SwiftUI
import HomeyMusicKit

/// Read-only “show” mode for any widget:
/// • Text renders statically (no selection/editing/dragging)
/// • Instruments render playably (always hit-testable)
struct WidgetShow: View {
    let widget: any Widget
    let scale: CGFloat

    var body: some View {
        Group {
            switch widget {
            case let textWidget as TextWidget:
                TextWidgetShow(textWidget: textWidget)

            case let musicalInstrumentWidget as MusicalInstrumentWidget:
                MusicalInstrumentWidgetShow(musicalInstrumentWidget: musicalInstrumentWidget)

            case let tonalityInstrumentWidget as TonalityInstrumentWidget:
                TonalityInstrumentWidgetShow(tonalityInstrumentWidget: tonalityInstrumentWidget)
                
            default:
                EmptyView()
            }
        }
        .allowsHitTesting(
            widget is MusicalInstrumentWidget ||
            widget is TonalityInstrumentWidget
        )
    }
}
