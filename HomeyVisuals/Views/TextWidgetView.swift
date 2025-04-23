import SwiftUI
import SwiftData
import HomeyMusicKit

/// View for a single TextWidget—click once to select, click again to edit, drag when selected
struct TextWidgetView: View {
    @Environment(Selections.self) private var selections
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize

    @FocusState private var fieldIsFocused: Bool

    /// Temporary drag offset (in points) while dragging
    @State private var dragOffset: CGSize = .zero

    /// computed from `selections.textWidgetSelections`
    private var isSelected: Bool {
        selections.textWidgetSelections.contains(textWidget.id)
    }
    /// computed from `selections.editingWidgetID`
    private var isEditing: Bool {
        selections.editingWidgetID == textWidget.id
    }
    
    @State private var isDragging = false

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
                          isDragging
                            ? Color.gray
                            : (isSelected ? Color(.systemBlue) : .clear),
                          lineWidth: 1 / HomeyMusicKit.goldenRatio
                        )
                    )
            }
        }
        .contentShape(Rectangle())
        // position uses stored x/y plus any live drag offset
        .position(
            x: slideSize.width  * textWidget.x + dragOffset.width,
            y: slideSize.height * textWidget.y + dragOffset.height
        )
        // toggle selection or enter edit-mode on click
        .onTapGesture {
            guard !isEditing else { return }
            if isSelected {
                // second click → edit
                selections.editingWidgetID = textWidget.id
            } else {
                // first click → select
                selections.textWidgetSelections = [textWidget.id]
            }
        }
        // allow dragging when selected & not editing
        .gesture(
          DragGesture()
            .onChanged { value in
              guard !isEditing else { return }
              // 1) if this widget wasn’t selected yet, select it immediately
              if !isSelected {
                selections.textWidgetSelections = [textWidget.id]
              }
              // 2) kick off the drag
              isDragging = true
              dragOffset = value.translation
            }
            .onEnded { value in
              guard !isEditing else {
                isDragging = false
                dragOffset = .zero
                return
              }
              // commit the final normalized position
              let dx = value.translation.width  / slideSize.width
              let dy = value.translation.height / slideSize.height
              textWidget.x = (textWidget.x + dx).clamped(to: 0...1)
              textWidget.y = (textWidget.y + dy).clamped(to: 0...1)
              isDragging = false
              dragOffset = .zero
            }
        )
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
