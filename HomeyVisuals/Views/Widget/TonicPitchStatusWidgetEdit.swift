import SwiftUI
import SwiftData
import HomeyMusicKit

struct TonicPitchStatusWidgetEdit: View {
    @Environment(AppContext.self) private var appContext

    @Bindable var tonicPitchStatusWidget: TonicPitchStatusWidget
    
    private var isEditing: Bool {
        appContext.editingWidgetID == tonicPitchStatusWidget.id
    }
    
    var body: some View {
        TonicPitchStatusView(tonicPitchStatusWidget.tonalityInstrument)
            .allowsHitTesting(false)
    }
}
