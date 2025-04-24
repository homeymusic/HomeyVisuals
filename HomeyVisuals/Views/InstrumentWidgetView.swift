import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct InstrumentWidgetView: View {
    @Environment(AppContext.self) private var appContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Bindable var instrumentWidget: InstrumentWidget
    let slideScale: CGFloat

    @FocusState private var fieldIsFocused: Bool
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var lastLeadingTranslation: CGFloat = 0
    @State private var lastTrailingTranslation: CGFloat = 0

    private let handleSize: CGFloat = 10

    private var isSelected: Bool { appContext.instrumentWidgetSelections.contains(instrumentWidget.id) }
    private var isEditing:  Bool { appContext.editingInstrumentWidgetID == instrumentWidget.id }

    var body: some View {
        ZStack {
            display
        }
        .contentShape(Rectangle())
        .position(
            x: instrumentWidget.x + dragOffset.width,
            y: instrumentWidget.y + dragOffset.height
        )
        .onTapGesture { handleTap() }
        .gesture(moveGesture)
    }

    // MARK: Display
    private var display: some View {
        InstrumentWidgetContent(instrumentWidget: instrumentWidget)
            .multilineTextAlignment(.leading)
            .frame(width: instrumentWidget.width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(handleSize)
            .overlay(selectionOverlay)
            .environment(instrumentalContext)
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

    // MARK: Move Gesture
    private var moveGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard !isEditing else { return }
                if !isSelected { appContext.instrumentWidgetSelections = [instrumentWidget.id] }
                isDragging = true
                let dx = value.translation.width / slideScale
                let dy = value.translation.height / slideScale
                dragOffset = CGSize(width: dx, height: dy)
            }
            .onEnded { value in
                guard !isEditing else {
                    isDragging = false; dragOffset = .zero; return
                }
                instrumentWidget.x += value.translation.width  / slideScale
                instrumentWidget.y += value.translation.height / slideScale
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
                let delta = rawDelta / slideScale
                // detect Option key
                let optionDown = NSEvent.modifierFlags.contains(.option)
                let sign: CGFloat = (anchor == .trailing ? 1 : -1)
                if optionDown {
                    // symmetric resize around center
                    let newW = max(instrumentWidget.width + 2 * sign * delta, handleSize * 2)
                    instrumentWidget.width = newW
                } else {
                    // one-sided resize
                    let currentW = instrumentWidget.width
                    let newW = max(currentW + sign * delta, handleSize * 2)
                    let deltaW = newW - currentW
                    instrumentWidget.width = newW
                    instrumentWidget.x += sign * (deltaW / 2)
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
            appContext.editingInstrumentWidgetID = instrumentWidget.id
        } else {
            appContext.instrumentWidgetSelections = [instrumentWidget.id]
        }
    }
}

private enum ResizeAnchor { case leading, trailing }

/// The shared drawing logic for any TextWidget.
struct InstrumentWidgetContent: View {
    let instrumentWidget: InstrumentWidget
    @Environment(InstrumentalContext.self) var instrumentalContext
    
    var body: some View {
        InstrumentView()
            .onAppear {
                instrumentalContext.instrumentChoice = instrumentWidget.instrumentChoice
            }
    }
}

