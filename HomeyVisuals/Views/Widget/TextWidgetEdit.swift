import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct TextWidgetEdit: View {
    @Environment(AppContext.self) private var appContext
    @Bindable var textWidget: TextWidget

    private var isEditing: Bool {
        appContext.editingWidgetID == textWidget.id
    }

    @FocusState private var fieldIsFocused: Bool
    
    var body: some View {
        if isEditing {
            TextEditor(text: $textWidget.text)
                .font(.system(size: textWidget.fontSize))
                .scrollContentBackground(.hidden)
                .focused($fieldIsFocused)
                .onAppear { fieldIsFocused = true }
                .onChange(of: fieldIsFocused) {
                    if !fieldIsFocused {
                        appContext.editingWidgetID = nil
                    }
                }
                .onExitCommand {
                    appContext.editingWidgetID = nil
                }
        } else {
            Text(textWidget.text)
                .font(.system(size: textWidget.fontSize))
                .foregroundColor(.white)
        }
    }
}
