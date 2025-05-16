import SwiftUI
import SwiftData
import HomeyMusicKit

struct MIDIMonitorWidgetShow: View {
    @Bindable var midiMonitorWidget: MIDIMonitorWidget

    var body: some View {
        MIDIMonitorView(midiMonitorWidget.tonalityInstrument)
            .frame(width: midiMonitorWidget.width, height: midiMonitorWidget.height, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .position(x: midiMonitorWidget.x, y: midiMonitorWidget.y)
            .allowsHitTesting(true)
    }
}

