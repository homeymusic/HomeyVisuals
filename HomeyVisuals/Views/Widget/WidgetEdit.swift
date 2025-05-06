// WidgetEdit.swift

import SwiftUI
import HomeyMusicKit

/// Editable wrapper for any Widget: moves, resizes, selects, edits.
struct WidgetEdit: View {
    let widget: any Widget
    let scale: CGFloat
    
    @Environment(AppContext.self)          private var appContext
    
    var body: some View {
        Group {
            if let textWidget = widget as? TextWidget {
                makeEditableWidgetContainer(for: textWidget) {
                    TextWidgetEdit(textWidget: textWidget)
                }
            }
            else if let musicalInstrumentWidget = widget as? MusicalInstrumentWidget {
                makeEditableWidgetContainer(for: musicalInstrumentWidget) {
                    MusicalInstrumentWidgetEdit(musicalInstrumentWidget: musicalInstrumentWidget)
                }
            }
            else if let tonalityInstrumentWidget = widget as? TonalityInstrumentWidget {
                makeEditableWidgetContainer(for: tonalityInstrumentWidget) {
                    TonalityInstrumentWidgetEdit(tonalityInstrumentWidget: tonalityInstrumentWidget)
                }
            }
            else {
                EmptyView()
            }
        }
    }
    
    /// Builds the WidgetContainer for any concrete Widget type,
    /// wiring up selection/editing state in one place.
    @ViewBuilder
    private func makeEditableWidgetContainer<W: Widget & Observable, Content: View>(
        for w: W,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let isSelected = appContext.widgetSelections.contains(w.id)
        let isEditing  = appContext.editingWidgetID == w.id
        
        EditableWidgetContainer(
            widget: w,
            slideScale: scale,
            isSelected: isSelected,
            isEditing: isEditing,
            onSelect: {
                appContext.widgetSelections = [ w.id ]
                appContext.editingWidgetID  = nil
            },
            onBeginEditing: {
                appContext.editingWidgetID  = w.id
            }
        ) {
            content()
        }
    }
}
