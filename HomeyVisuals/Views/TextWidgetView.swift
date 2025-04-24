import SwiftUI
import SwiftData
import HomeyMusicKit

/// View for a single TextWidget—click once to select, click again to edit,
/// drag when selected or resize via handles (leading/trailing), with Option for symmetric resizing
struct TextWidgetView: View {
    @Environment(Selections.self) private var selections
    @Bindable var textWidget: TextWidget

    @FocusState private var fieldIsFocused: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var resizingInitialWidth: CGFloat? = nil
    @State private var resizingInitialX: CGFloat? = nil

    /// The inset used around text for resize handles
    private let handleSize: CGFloat = 13

    private var isSelected: Bool {
        selections.textWidgetSelections.contains(textWidget.id)
    }
    private var isEditing: Bool {
        selections.editingWidgetID == textWidget.id
    }

    private enum ResizeAnchor { case leading, trailing }

    var body: some View {
        ZStack {
            if isEditing {
                editor
            } else {
                content
            }
        }
        .contentShape(Rectangle())
        .position(
            x: textWidget.x + dragOffset.width,
            y: textWidget.y + dragOffset.height
        )
        .onTapGesture { handleTap() }
        .gesture(moveGesture)
    }

    // MARK: - Display mode content
    private var content: some View {
        TextWidgetContent(textWidget: textWidget)
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, handleSize / 2)
            .overlay(
                ZStack {
                    Rectangle()
                        .inset(by: handleSize / 2)
                        .stroke(
                            isDragging
                                ? Color.gray
                                : (isSelected ? Color(.systemBlue) : .clear),
                            lineWidth: 2
                        )

                    if isSelected && !isDragging {
                        GeometryReader { geo in
                            let yCenter = geo.size.height / 2

                            // Leading handle
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: handleSize, height: handleSize)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                                .position(x: handleSize / 2, y: yCenter)
                                .pointerStyle(.frameResize(position: .leading))
                                .gesture(resizeGesture(anchor: .leading, symmetric: false))
                                .highPriorityGesture(resizeGesture(anchor: .leading, symmetric: true))

                            // Trailing handle
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: handleSize, height: handleSize)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                                .position(x: geo.size.width - handleSize / 2, y: yCenter)
                                .pointerStyle(.frameResize(position: .trailing))
                                .gesture(resizeGesture(anchor: .trailing, symmetric: false))
                                .highPriorityGesture(resizeGesture(anchor: .trailing, symmetric: true))
                        }
                    }
                }
            )
    }

    // MARK: - Editor mode content
    private var editor: some View {
        TextEditor(text: $textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, handleSize / 2)
            .overlay(Rectangle().stroke(Color.gray, lineWidth: 2))
            .background(Color.clear)
            .focused($fieldIsFocused)
            .onAppear { fieldIsFocused = true }
            .onChange(of: fieldIsFocused) { _, focused in
                if !focused {
                    selections.editingWidgetID = nil
                }
            }
            .onExitCommand { selections.editingWidgetID = nil }
    }

    // MARK: - Move Gesture
    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isEditing else { return }
                if !isSelected {
                    selections.textWidgetSelections = [ textWidget.id ]
                }
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                guard !isEditing else {
                    isDragging = false; dragOffset = .zero; return
                }
                textWidget.x += value.translation.width
                textWidget.y += value.translation.height
                isDragging = false
                dragOffset = .zero
            }
    }

    // MARK: - Resize Gesture
    private func resizeGesture(anchor: ResizeAnchor, symmetric: Bool) -> some Gesture {
        DragGesture()
            .modifiers(symmetric ? .option : [])
            .onChanged { value in
                if resizingInitialWidth == nil {
                    resizingInitialWidth = textWidget.width
                    resizingInitialX     = textWidget.x
                }
                applyResize(delta: value.translation.width, anchor: anchor, symmetric: symmetric)
            }
            .onEnded { _ in clearResizeState() }
    }

    // MARK: - Resize Logic
    private func applyResize(delta: CGFloat, anchor: ResizeAnchor, symmetric: Bool) {
        guard let w0 = resizingInitialWidth,
              let x0 = resizingInitialX else { return }
        let minWidth = handleSize * 2
        let sign: CGFloat = (anchor == .trailing ? 1 : -1)

        if symmetric {
            let newW = max(w0 + sign * delta, minWidth)
            textWidget.width = newW
        } else {
            let newW = max(w0 + sign * delta, minWidth)
            let deltaW = newW - w0
            let newX  = x0 + sign * (deltaW / 2)
            textWidget.width = newW
            textWidget.x     = newX
        }
    }

    private func clearResizeState() {
        resizingInitialWidth = nil
        resizingInitialX     = nil
    }

    // MARK: - Tap Handling
    private func handleTap() {
        guard !isEditing else { return }
        if isSelected {
            selections.editingWidgetID = textWidget.id
        } else {
            selections.textWidgetSelections = [ textWidget.id ]
        }
    }
}

