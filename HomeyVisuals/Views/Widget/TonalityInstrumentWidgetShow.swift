import SwiftUI
import SwiftData
import HomeyMusicKit

struct TonalityInstrumentWidgetShow: View {
    @Bindable var tonalityInstrumentWidget: TonalityInstrumentWidget
    
    var body: some View {
        TonalityInstrumentView(tonalityInstrumentWidget.tonalityInstrument)
            .frame(width: tonalityInstrumentWidget.width, height: tonalityInstrumentWidget.height, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .position(x: tonalityInstrumentWidget.x, y: tonalityInstrumentWidget.y)
            .allowsHitTesting(true)
    }
}

