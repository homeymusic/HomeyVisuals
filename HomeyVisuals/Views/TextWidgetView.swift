import SwiftUI
import SwiftData
import HomeyMusicKit

/// View for a single TextWidget—click once to select, click again to edit,
/// drag when selected or resize via either handle (leading or trailing)
struct TextWidgetView: View {
    @Environment(Selections.self) private var selections
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize

    @FocusState private var fieldIsFocused: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var resizingInitialWidth: CGFloat? = nil
    @State private var resizingInitialX: CGFloat? = nil

    private var isSelected: Bool {
        selections.textWidgetSelections.contains(textWidget.id)
    }
    private var isEditing: Bool {
        selections.editingWidgetID == textWidget.id
    }

    var body: some View {
        ZStack {
            if isEditing {
                // Inline text editor
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
                    if !focused { selections.editingWidgetID = nil }
                }
                .onExitCommand { selections.editingWidgetID = nil }

            } else {
                let handleSize: CGFloat = 13
                let slideW = slideSize.width

                // Main content with dynamic width
                TextWidgetContent(textWidget: textWidget, slideSize: slideSize)
                    .frame(width: textWidget.width * slideW, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, handleSize / 2)
                    .contentShape(Rectangle())
                    .overlay(
                        ZStack {
                            // Outline when selected or dragging
                            Rectangle()
                                .inset(by: handleSize / 2)
                                .stroke(
                                    isDragging ? Color.gray : (isSelected ? Color(.systemBlue) : .clear),
                                    lineWidth: 1
                                )

                            if isSelected && !isDragging {
                                GeometryReader { geo in
                                    let yCenter = geo.size.height / 2
                                    let minWidth: CGFloat = handleSize * 2

                                    // --- Leading handle (resize left edge) ---
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: handleSize, height: handleSize)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .position(x: handleSize / 2, y: yCenter)
                                        .pointerStyle(.frameResize(position: .leading))
                                        // Option+drag: symmetric around center
                                        .highPriorityGesture(
                                            DragGesture()
                                                .modifiers(.option)
                                                .onChanged { value in
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let w0    = resizingInitialWidth!
                                                    let x0    = resizingInitialX!
                                                    let delta = -value.translation.width
                                                    let newW  = max(w0 + delta, minWidth)
                                                    textWidget.width = newW / slideW
                                                    textWidget.x     = x0
                                                }
                                                .onEnded { _ in
                                                    resizingInitialWidth = nil
                                                    resizingInitialX     = nil
                                                }
                                        )
                                        // Normal leading drag
                                        .gesture(
                                            DragGesture()
                                                .modifiers([])
                                                .onChanged { value in
                                                    let dx = value.translation.width
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let w0 = resizingInitialWidth!
                                                    let x0 = resizingInitialX! * slideW
                                                    let rightEdge = x0 + w0/2
                                                    let left0     = x0 - w0/2
                                                    let newLeft   = left0 + dx
                                                    let wPts      = max(rightEdge - newLeft, minWidth)
                                                    let centerPts = newLeft + wPts/2
                                                    textWidget.width = wPts / slideW
                                                    textWidget.x     = centerPts / slideW
                                                }
                                                .onEnded { _ in
                                                    resizingInitialWidth = nil
                                                    resizingInitialX     = nil
                                                }
                                        )

                                    // --- Trailing handle (resize right edge) ---
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: handleSize, height: handleSize)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .position(x: geo.size.width - handleSize/2, y: yCenter)
                                        .pointerStyle(.frameResize(position: .trailing))
                                        // Option+drag: symmetric around center
                                        .highPriorityGesture(
                                            DragGesture()
                                                .modifiers(.option)
                                                .onChanged { value in
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let w0    = resizingInitialWidth!
                                                    let x0    = resizingInitialX!
                                                    let delta = value.translation.width
                                                    let newW  = max(w0 + delta, minWidth)
                                                    textWidget.width = newW / slideW
                                                    textWidget.x     = x0
                                                }
                                                .onEnded { _ in
                                                    resizingInitialWidth = nil
                                                    resizingInitialX     = nil
                                                }
                                        )
                                        // Normal trailing drag
                                        .gesture(
                                            DragGesture()
                                                .modifiers([])
                                                .onChanged { value in
                                                    let dx = value.translation.width
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let w0  = resizingInitialWidth!
                                                    let x0  = resizingInitialX! * slideW
                                                    let leftEdge = x0 - w0/2
                                                    let newR     = leftEdge + w0 + dx
                                                    let wPts     = max(newR - leftEdge, minWidth)
                                                    let centerPts = leftEdge + wPts/2
                                                    textWidget.width = wPts / slideW
                                                    textWidget.x     = centerPts / slideW
                                                }
                                                .onEnded { _ in
                                                    resizingInitialWidth = nil
                                                    resizingInitialX     = nil
                                                }
                                        )
                                }
                            }
                        }
                    )
            }
        }
        .contentShape(Rectangle())
        // Position & drag-to-move gesture
        .position(
            x: slideSize.width * textWidget.x + dragOffset.width,
            y: slideSize.height * textWidget.y + dragOffset.height
        )
        .onTapGesture {
            guard !isEditing else { return }
            if isSelected { selections.editingWidgetID = textWidget.id }
            else { selections.textWidgetSelections = [textWidget.id] }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !isEditing else { return }
                    if !isSelected { selections.textWidgetSelections = [textWidget.id] }
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { value in
                    guard !isEditing else {
                        isDragging = false; dragOffset = .zero; return
                    }
                    let dx = value.translation.width / slideSize.width
                    let dy = value.translation.height / slideSize.height
                    textWidget.x = (textWidget.x + dx).clamped(to: 0...1)
                    textWidget.y = (textWidget.y + dy).clamped(to: 0...1)
                    isDragging  = false
                    dragOffset  = .zero
                }
        )
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

