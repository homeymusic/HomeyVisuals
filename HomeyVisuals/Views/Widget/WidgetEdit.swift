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
            else if let cameraWidget = widget as? CameraWidget {
                makeEditableWidgetContainer(for: cameraWidget, allowEditing: false) {
                    CameraWidgetEdit(cameraWidget: cameraWidget)
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
            else if let tonicPitchStatusWidget = widget as? TonicPitchStatusWidget {
                makeEditableWidgetContainer(for: tonicPitchStatusWidget, allowEditing: false) {
                    TonicPitchStatusWidgetEdit(tonicPitchStatusWidget: tonicPitchStatusWidget)
                }
            }
            else if let midiMonitorWidget = widget as? MIDIMonitorWidget {
                makeEditableWidgetContainer(for: midiMonitorWidget) {
                    MIDIMonitorWidgetEdit(midiMonitorWidget: midiMonitorWidget)
                }
            }
            else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func makeEditableWidgetContainer<W: Widget & Observable, Content: View>(
        for w: W,
        allowEditing: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let isSelected = appContext.widgetSelections.contains(w.id)
        // Only consider “editing” if allowEditing is true
        let isEditing  = allowEditing && appContext.editingWidgetID == w.id

        WidgetEditContainer(
            widget: w,
            slideScale: scale,
            isSelected: isSelected,
            isEditing: isEditing,
            onSelect: {
                appContext.widgetSelections = [ w.id ]
                // If we’re not allowing edit, clear any edit state
                if !allowEditing {
                    appContext.editingWidgetID = nil
                }
            },
            onBeginEditing: {
                if allowEditing {
                    appContext.editingWidgetID = w.id
                }
            }
        ) {
            content()
        }
    }
}
