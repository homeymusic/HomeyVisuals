import SwiftUI
import SwiftData
import HomeyMusicKit

struct InstrumentWidgetEdit: View {
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentalContext.self) private var instrumentalContext
    @Bindable var instrumentWidget: InstrumentWidget
    let slideScale: CGFloat
    
    private var isSelected: Bool {
        appContext.widgetSelections.contains(instrumentWidget.id)
    }
    private var isEditing: Bool {
        appContext.editingWidgetID == instrumentWidget.id
    }
    
    var body: some View {
        InstrumentView(instrumentWidget.instrument)
            .allowsHitTesting(isEditing)
    }
}
