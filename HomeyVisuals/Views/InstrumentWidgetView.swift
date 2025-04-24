import SwiftUI
import SwiftData
import HomeyMusicKit

/// Wraps an InstrumentWidget in generic WidgetView for move/resize/select behavior.
struct InstrumentWidgetView: View {
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentalContext.self) private var instrumentalContext
    @Bindable var instrumentWidget: InstrumentWidget
    let slideScale: CGFloat

    private var isSelected: Bool {
        appContext.instrumentWidgetSelections.contains(instrumentWidget.id)
    }
    private var isEditing: Bool {
        appContext.editingInstrumentWidgetID == instrumentWidget.id
    }

    var body: some View {
        WidgetView(
            widget: instrumentWidget,
            slideScale: slideScale,
            isSelected: isSelected,
            isEditing: isEditing,
            onSelect: {
                appContext.instrumentWidgetSelections = [ instrumentWidget.id ]
            },
            onBeginEditing: {
                appContext.editingInstrumentWidgetID = instrumentWidget.id
            }
        ) {
            InstrumentView()
                .onAppear {
                    instrumentalContext.instrumentChoice = instrumentWidget.instrumentChoice
                }
        }
    }
}
