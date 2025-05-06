import SwiftUI
import SwiftData
import HomeyMusicKit

struct MusicalInstrumentWidgetEdit: View {
    @Environment(AppContext.self) private var appContext
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget
    
    private var isEditing: Bool {
        appContext.editingWidgetID == musicalInstrumentWidget.id
    }
    
    var body: some View {
        MusicalInstrumentView(musicalInstrumentWidget.musicalInstrument)
            .allowsHitTesting(isEditing)
    }
}
