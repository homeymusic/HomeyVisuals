import SwiftUI
import SwiftData
import HomeyMusicKit

struct TonalityInstrumentWidgetEdit: View {
    @Environment(AppContext.self) private var appContext

    @Bindable var tonalityInstrumentWidget: TonalityInstrumentWidget
    let slideScale: CGFloat
    
    private var isSelected: Bool {
        appContext.widgetSelections.contains(tonalityInstrumentWidget.id)
    }
    
    private var isEditing: Bool {
        appContext.editingWidgetID == tonalityInstrumentWidget.id
    }
    
    var body: some View {
        TonalityInstrumentView(tonalityInstrumentWidget.tonalityInstrument)
            .allowsHitTesting(isEditing)
    }
}
