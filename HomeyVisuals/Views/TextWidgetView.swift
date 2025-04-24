import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

/// View for a single TextWidget: select to edit text, drag to move, drag handles to resize.
/// Holding Option while dragging switches between one-sided and symmetric resizing.
struct TextWidgetView: View {
    @Environment(AppContext.self) private var appContext
    @Bindable var textWidget: TextWidget

    @FocusState private var fieldIsFocused: Bool
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var lastLeadingTranslation: CGFloat = 0
    @State private var lastTrailingTranslation: CGFloat = 0

    private let handleSize: CGFloat = 10

    private var isSelected: Bool { appContext.textWidgetSelections.contains(textWidget.id) }
    private var isEditing:  Bool { appContext.editingWidgetID == textWidget.id }

    var body: some View {
        ZStack {
            if isEditing { editor }
            else        { display }
        }
        .contentShape(Rectangle())
        .position(
            x: textWidget.x + dragOffset.width,
            y: textWidget.y + dragOffset.height
        )
        .onTapGesture { handleTap() }
        .gesture(moveGesture)
    }

    // MARK: Display
    private var display: some View {
        TextWidgetContent(textWidget: textWidget)
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(handleSize)
            .overlay(selectionOverlay)
    }

    private var selectionOverlay: some View {
        ZStack {
            Rectangle()
                .inset(by: handleSize)
                .stroke(isDragging ? Color.gray : (isSelected ? .blue : .clear), lineWidth: 1)
            if isSelected && !isDragging {
                GeometryReader { geo in
                    let centerY = geo.size.height / 2
                    handleView(anchor: .leading)
                        .position(x: handleSize, y: centerY)
                    handleView(anchor: .trailing)
                        .position(x: geo.size.width - handleSize, y: centerY)
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
            .gesture(resizeGesture(anchor: anchor))
    }

    // MARK: Editor
    private var editor: some View {
        TextEditor(text: $textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .multilineTextAlignment(.leading)
            .frame(width: textWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(handleSize)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
            .focused($fieldIsFocused)
            .onAppear { fieldIsFocused = true }
            .onChange(of: fieldIsFocused) { _, focused in
                if !focused { appContext.editingWidgetID = nil }
            }
            .onExitCommand { appContext.editingWidgetID = nil }
    }

    // MARK: Move Gesture
    private var moveGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard !isEditing else { return }
                if !isSelected { appContext.textWidgetSelections = [textWidget.id] }
                isDragging = true
                let dx = value.translation.width / appContext.slideScale
                let dy = value.translation.height / appContext.slideScale
                dragOffset = CGSize(width: dx, height: dy)
            }
            .onEnded { value in
                guard !isEditing else {
                    isDragging = false; dragOffset = .zero; return
                }
                textWidget.x += value.translation.width  / appContext.slideScale
                textWidget.y += value.translation.height / appContext.slideScale
                isDragging = false
                dragOffset = .zero
            }
    }

    // MARK: Combined Resize Gesture
    private func resizeGesture(anchor: ResizeAnchor) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                // track incremental translation per handle
                let prev = (anchor == .leading ? lastLeadingTranslation : lastTrailingTranslation)
                let rawDelta = value.translation.width - prev
                if anchor == .leading {
                    lastLeadingTranslation = value.translation.width
                } else {
                    lastTrailingTranslation = value.translation.width
                }
                // map screen-space → slide-space
                let delta = rawDelta / appContext.slideScale
                // detect Option key
                let optionDown = NSEvent.modifierFlags.contains(.option)
                let sign: CGFloat = (anchor == .trailing ? 1 : -1)
                if optionDown {
                    // symmetric resize around center
                    let newW = max(textWidget.width + 2 * sign * delta, handleSize * 2)
                    textWidget.width = newW
                } else {
                    // one-sided resize
                    let currentW = textWidget.width
                    let newW = max(currentW + sign * delta, handleSize * 2)
                    let deltaW = newW - currentW
                    textWidget.width = newW
                    textWidget.x += sign * (deltaW / 2)
                }
            }
            .onEnded { _ in
                lastLeadingTranslation = 0
                lastTrailingTranslation = 0
            }
    }

    // MARK: Helpers
    private func handleTap() {
        guard !isEditing else { return }
        if isSelected {
            appContext.editingWidgetID = textWidget.id
        } else {
            appContext.textWidgetSelections = [textWidget.id]
        }
    }
}

private enum ResizeAnchor { case leading, trailing }

