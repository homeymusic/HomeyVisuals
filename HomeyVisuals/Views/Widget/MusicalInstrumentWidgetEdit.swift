import SwiftUI
import SwiftData
import HomeyMusicKit

struct MusicalInstrumentWidgetEdit: View {
    @Environment(AppContext.self) private var appContext

    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget
    let slideScale: CGFloat
    
    private var isSelected: Bool {
        appContext.widgetSelections.contains(musicalInstrumentWidget.id)
    }
    private var isEditing: Bool {
        appContext.editingWidgetID == musicalInstrumentWidget.id
    }
    
    var body: some View {
        MusicalInstrumentView(musicalInstrumentWidget.musicalInstrument)
            .allowsHitTesting(isEditing)
    }
}
