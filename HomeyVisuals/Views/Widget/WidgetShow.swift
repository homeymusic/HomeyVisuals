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
                Text(textWidget.text)
                    .font(.system(size: textWidget.fontSize))
                    .foregroundColor(.white)
                    .frame(width:    textWidget.width,
                           height: textWidget.height,
                           alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: textWidget.x, y: textWidget.y)

            case let musicalInstrumentWidget as MusicalInstrumentWidget:
                MusicalInstrumentView(musicalInstrumentWidget.musicalInstrument)
                    .frame(width: musicalInstrumentWidget.width, height: musicalInstrumentWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: musicalInstrumentWidget.x, y: musicalInstrumentWidget.y)

            case let tonalityInstrumentWidget as TonalityInstrumentWidget:
                TonalityInstrumentView(tonalityInstrumentWidget.tonalityInstrument)
                    .frame(width: tonalityInstrumentWidget.width, height: tonalityInstrumentWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: tonalityInstrumentWidget.x, y: tonalityInstrumentWidget.y)
                
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
