import SwiftUI
import SwiftData
import HomeyMusicKit

/// View for a single TextWidget—selection on first click, edit on second click
struct TextWidgetView: View {
    @Environment(Selections.self) private var selections
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize

    @FocusState private var fieldIsFocused: Bool

    /// computed from `selections.textWidgetSelections`
    private var isSelected: Bool {
        selections.textWidgetSelections.contains(textWidget.id)
    }
    /// computed from `selections.editingWidgetID`
    private var isEditing: Bool {
        selections.editingWidgetID == textWidget.id
    }

    var body: some View {
        ZStack {
            if isEditing {
                // Inline text editor when editing
                TextField("", text: $textWidget.text, onCommit: {
                    selections.editingWidgetID = nil
                })
                .font(.system(size: textWidget.fontSize))
                .textFieldStyle(.plain)
                .fixedSize()
                .overlay(
                    Rectangle()
                        .stroke(Color.gray, lineWidth: 1 / HomeyMusicKit.goldenRatio)
                )
                .focused($fieldIsFocused)
                .onAppear { fieldIsFocused = true }
                .onChange(of: fieldIsFocused) { _, focused in
                    if !focused {
                        selections.editingWidgetID = nil
                    }
                }
                .onExitCommand {
                    selections.editingWidgetID = nil
                }

            } else {
                // Normal display
                TextWidgetContent(textWidget: textWidget, slideSize: slideSize)
                    .fixedSize()
                    .overlay(
                        Rectangle()
                            .stroke(
                                isSelected ? Color(.systemBlue) : .clear,
                                lineWidth: 1 / HomeyMusicKit.goldenRatio
                            )
                    )
            }
        }
        .contentShape(Rectangle())
        .position(
            x: slideSize.width  * textWidget.x,
            y: slideSize.height * textWidget.y
        )
        // First click selects, second click (if already selected) enters edit-mode
        .onTapGesture {
            guard !isEditing else { return }

            if isSelected {
                selections.editingWidgetID = textWidget.id
            } else {
                selections.textWidgetSelections = [textWidget.id]
            }
        }
    }
}
