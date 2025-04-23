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
                    if !focused {
                        selections.editingWidgetID = nil
                    }
                }
                .onExitCommand {
                    selections.editingWidgetID = nil
                }

            } else {
                let handleSize: CGFloat = 13
                let slideW = slideSize.width

                // Render content with a width driven by textWidget.width
                TextWidgetContent(textWidget: textWidget, slideSize: slideSize)
                    .frame(width: textWidget.width * slideW, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, handleSize / 2)
                    .contentShape(Rectangle())
                    .overlay(
                        ZStack {
                            // Outline border
                            Rectangle()
                                .inset(by: handleSize / 2)
                                .stroke(
                                    isDragging ? Color.gray : (isSelected ? Color(.systemBlue) : .clear),
                                    lineWidth: 1
                                )

                            // Resize handles when selected
                            if isSelected && !isDragging {
                                GeometryReader { geo in
                                    let yCenter = geo.size.height / 2
                                    let minWidth: CGFloat = handleSize * 2

                                    // Leading handle: drag to resize left edge, keep right fixed
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: handleSize, height: handleSize)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .position(x: handleSize / 2, y: yCenter)
                                        .pointerStyle(.frameResize(position: .leading))
                                        .highPriorityGesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let initialWidthPts  = resizingInitialWidth!
                                                    let initialCenterPts = resizingInitialX! * slideW
                                                    let initialRightPts  = initialCenterPts + initialWidthPts/2
                                                    let initialLeftPts   = initialCenterPts - initialWidthPts/2

                                                    let rawNewLeftPts = initialLeftPts + value.translation.width
                                                    var newWidthPts   = initialRightPts - rawNewLeftPts
                                                    newWidthPts       = max(newWidthPts, minWidth)
                                                    let newCenterPts  = rawNewLeftPts + newWidthPts/2

                                                    textWidget.width = newWidthPts / slideW
                                                    textWidget.x     = newCenterPts / slideW
                                                }
                                                .onEnded { _ in
                                                    resizingInitialWidth = nil
                                                    resizingInitialX     = nil
                                                }
                                        )

                                    // Trailing handle: drag to resize right edge, keep left fixed
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: handleSize, height: handleSize)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .position(x: geo.size.width - handleSize/2, y: yCenter)
                                        .pointerStyle(.frameResize(position: .trailing))
                                        .highPriorityGesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    if resizingInitialWidth == nil {
                                                        resizingInitialWidth = textWidget.width * slideW
                                                        resizingInitialX     = textWidget.x
                                                    }
                                                    let initialWidthPts  = resizingInitialWidth!
                                                    let initialCenterPts = resizingInitialX! * slideW
                                                    let initialLeftPts   = initialCenterPts - initialWidthPts/2

                                                    let rawNewRightPts = initialLeftPts + initialWidthPts + value.translation.width
                                                    var newWidthPts    = rawNewRightPts - initialLeftPts
                                                    newWidthPts        = max(newWidthPts, minWidth)
                                                    let newCenterPts   = initialLeftPts + newWidthPts/2

                                                    textWidget.width = newWidthPts / slideW
                                                    textWidget.x     = newCenterPts / slideW
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
            if isSelected {
                selections.editingWidgetID = textWidget.id
            } else {
                selections.textWidgetSelections = [textWidget.id]
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !isEditing else { return }
                    if !isSelected {
                        selections.textWidgetSelections = [textWidget.id]
                    }
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { value in
                    guard !isEditing else {
                        isDragging = false
                        dragOffset = .zero
                        return
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
