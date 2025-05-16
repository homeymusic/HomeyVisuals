import SwiftUI
import SwiftData
import HomeyMusicKit

struct MIDIMonitorWidgetEdit: View {
    @Environment(AppContext.self) private var appContext

    @Bindable var midiMonitorWidget: MIDIMonitorWidget
    
    private var isEditing: Bool {
        appContext.editingWidgetID == midiMonitorWidget.id
    }
    
    var body: some View {
        MIDIMonitorView(midiMonitorWidget.tonalityInstrument)
            .allowsHitTesting(isEditing)
    }
}
