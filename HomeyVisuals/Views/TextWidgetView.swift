import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

/// Wraps a TextWidget in generic WidgetView for move/resize/select/edit behavior,
/// and restores the old focus-on-tap logic so you can start typing immediately.
struct TextWidgetView: View {
    @Environment(AppContext.self) private var appContext
    @Bindable var textWidget: TextWidget
    let slideScale: CGFloat

    @FocusState private var fieldIsFocused: Bool

    private var isSelected: Bool {
        appContext.textWidgetSelections.contains(textWidget.id)
    }
    private var isEditing: Bool {
        appContext.editingTextWidgetID == textWidget.id
    }

    var body: some View {
        WidgetView(
            widget: textWidget,
            slideScale: slideScale,
            isSelected: isSelected,
            isEditing: isEditing,
            onSelect: {
                appContext.textWidgetSelections = [ textWidget.id ]
            },
            onBeginEditing: {
                appContext.editingTextWidgetID = textWidget.id
            }
        ) {
            if isEditing {
                TextEditor(text: $textWidget.text)
                    .font(.system(size: textWidget.fontSize))
                    .scrollContentBackground(.hidden)
                    .focused($fieldIsFocused)
                    .onAppear { fieldIsFocused = true }
                    .onChange(of: fieldIsFocused) {
                        if !fieldIsFocused {
                            appContext.editingTextWidgetID = nil
                        }
                    }
                    .onExitCommand {
                        appContext.editingTextWidgetID = nil
                    }
            } else {
                Text(textWidget.text)
                    .font(.system(size: textWidget.fontSize))
                    .foregroundColor(.white)
            }
        }
    }
}
