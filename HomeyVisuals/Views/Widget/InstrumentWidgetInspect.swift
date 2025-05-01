import SwiftUI

struct InstrumentWidgetInspect: View {
    @Bindable var instrumentWidget: InstrumentWidget

    var body: some View {
        Text("MIDI In: \(instrumentWidget.instrument.midiInChannel.label)")
        Text("MIDI Out: \(instrumentWidget.instrument.midiOutChannel.label)")
    }
}
