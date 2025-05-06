import SwiftUI
import SwiftData
import HomeyMusicKit

struct MusicalInstrumentWidgetShow: View {
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget
    
    var body: some View {
        MusicalInstrumentView(musicalInstrumentWidget.musicalInstrument)
            .frame(width: musicalInstrumentWidget.width, height: musicalInstrumentWidget.height, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .position(x: musicalInstrumentWidget.x, y: musicalInstrumentWidget.y)
            .allowsHitTesting(true)
    }
}


