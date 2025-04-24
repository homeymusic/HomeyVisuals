import SwiftUI
import SwiftData
import HomeyMusicKit

/// View for a single TextWidget: select to edit text, drag to move, drag handles to resize.
/// Holding Option while dragging resizes symmetrically around the center.
struct TextWidgetView: View {
    @Environment(Selections.self) private var selections
    @Bindable var textWidget: TextWidget

    @FocusState private var fieldIsFocused: Bool
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var lastLeadingTranslation: CGFloat = 0
    @State private var lastTrailingTranslation: CGFloat = 0
    @State private var lastSymTranslation: CGFloat = 0

    private let handleSize: CGFloat = 10

    private var isSelected: Bool { selections.textWidgetSelections.contains(textWidget.id) }
    private var isEditing:  Bool { selections.editingWidgetID == textWidget.id }

    var body: some View {
        ZStack {
            if isEditing { editor }
            else        { display }
        }
        .contentShape(Rectangle())
        .position(x: textWidget.x + dragOffset.width,
                  y: textWidget.y + dragOffset.height)
        .onTapGesture { handleTap() }
        .gesture(moveGesture)
    }

    // MARK: Display
    private var display: some View {
        TextWidgetContent(textWidget: textWidget)
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, handleSize)
            .overlay(resizeOverlay)
    }

    private var resizeOverlay: some View {
        ZStack {
            Rectangle()
                .inset(by: handleSize)
                .stroke(isDragging ? Color.gray : (isSelected ? .blue : .clear), lineWidth: 1)
            if isSelected && !isDragging {
                GeometryReader { geo in
                    let yC = geo.size.height/2
                    handleView(anchor: .leading)
                        .position(x: handleSize, y: yC)
                    handleView(anchor: .trailing)
                        .position(x: geo.size.width - handleSize, y: yC)
                }
            }
        }
    }

    private func handleView(anchor: ResizeAnchor) -> some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
            .pointerStyle(.frameResize(position: anchor == .leading ? .leading : .trailing))
            .gesture(nonSymResizeGesture(anchor: anchor))
            .highPriorityGesture(symResizeGesture(anchor: anchor))
    }

    // MARK: Editor
    private var editor: some View {
        TextEditor(text: $textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, handleSize)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
            .focused($fieldIsFocused)
            .onAppear { fieldIsFocused = true }
            .onChange(of: fieldIsFocused) { _, f in if !f { selections.editingWidgetID = nil } }
            .onExitCommand { selections.editingWidgetID = nil }
    }

    // MARK: Move
    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                guard !isEditing else { return }
                if !isSelected { selections.textWidgetSelections = [textWidget.id] }
                isDragging = true
                dragOffset = v.translation
            }
            .onEnded { v in
                guard !isEditing else { isDragging = false; dragOffset = .zero; return }
                textWidget.x += v.translation.width
                textWidget.y += v.translation.height
                isDragging = false
                dragOffset = .zero
            }
    }

    // MARK: Non-symmetric resize (drag handle without Option)
    private func nonSymResizeGesture(anchor: ResizeAnchor) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { v in
                let prev = (anchor == .leading ? lastLeadingTranslation : lastTrailingTranslation)
                let delta = v.translation.width - prev
                if anchor == .leading { lastLeadingTranslation = v.translation.width }
                else                  { lastTrailingTranslation = v.translation.width }
                let sign: CGFloat = (anchor == .trailing ? 1 : -1)
                let currentW = textWidget.width
                let newW = max(currentW + sign * delta, handleSize*2)
                textWidget.width = newW
                // shift center by half the width change
                textWidget.x += sign * ((newW - currentW)/2.0)
            }
            .onEnded { _ in lastLeadingTranslation = 0; lastTrailingTranslation = 0 }
    }

    // MARK: Symmetric resize (Option + drag handle)
    private func symResizeGesture(anchor: ResizeAnchor) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .modifiers(.option)
            .onChanged { v in
                let delta = v.translation.width - lastSymTranslation
                lastSymTranslation = v.translation.width
                let sign: CGFloat = (anchor == .trailing ? 1 : -1)
                let newW = max(textWidget.width + sign * delta, handleSize*2)
                textWidget.width = newW
            }
            .onEnded { _ in lastSymTranslation = 0 }
    }

    // MARK: Helpers
    private func handleTap() {
        guard !isEditing else { return }
        if isSelected { selections.editingWidgetID = textWidget.id }
        else          { selections.textWidgetSelections = [ textWidget.id ] }
    }
}

private enum ResizeAnchor { case leading, trailing }

