import SwiftUI
import AppKit

/// A reusable “shell” around any SwiftData `Widget` that
/// provides moving, resizing, selection-and-edit tapping behavior.
struct WidgetEditContainer<W: Widget & Observable, Content: View>: View {
    @Bindable var widget: W
    let slideScale: CGFloat
    let isSelected: Bool
    let isEditing: Bool
    let onSelect: () -> Void
    let onBeginEditing: () -> Void
    @ViewBuilder let content: () -> Content

    // Internal state for dragging & resizing
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false

    // Track last translation per handle so drags don't jump
    @State private var lastTranslation: [FrameResizePosition: CGSize] = [:]

    private let handleSize: CGFloat = 10

    var body: some View {
        ZStack {
            content()
                .frame(width: widget.width, height: widget.height, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(handleSize)
                .overlay(selectionOverlay)
        }
        .contentShape(Rectangle())
        .position(
            x: widget.x + dragOffset.width,
            y: widget.y + dragOffset.height
        )
        .onTapGesture(perform: handleTap)
        .gesture(moveGesture)
    }

    private func handleTap() {
        guard !isEditing else { return }
        if isSelected { onBeginEditing() }
        else           { onSelect()      }
    }

    // MARK: — Selection & Handles

    private var selectionOverlay: some View {
        ZStack {
            // — Frame border for each state —
            if isEditing {
                // gray border when editable
                Rectangle()
                    .inset(by: handleSize / 2)
                    .stroke(Color.gray, lineWidth: 1)
            }
            else if isSelected {
                // blue border when selected (including dragging)
                Rectangle()
                    .inset(by: handleSize / 2)
                    .stroke(Color.blue, lineWidth: 1)
            }

            // — Handles or crosshairs based on state —
            if isEditing {
                // no handles when in edit mode
                EmptyView()
            }
            else if isDragging {
                // narrow crosshair handles while dragging
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let length = handleSize
                    let thickness: CGFloat = 3

                    ForEach(Array(widget.allowedResizePositions), id: \.self) { pos in
                        let cx = xPos(for: pos, in: w)
                        let cy = yPos(for: pos, in: h)

                        let (tickW, tickH, angle): (CGFloat, CGFloat, Angle) = {
                            switch pos {
                            case .top, .bottom:
                                return (thickness, length, .degrees(0))
                            case .leading, .trailing:
                                return (length, thickness, .degrees(0))
                            case .topLeading, .bottomTrailing:
                                return (length, thickness, .degrees(45))
                            case .topTrailing, .bottomLeading:
                                return (length, thickness, .degrees(-45))
                            }
                        }()

                        Rectangle()
                            .fill(Color.white)
                            .frame(width: tickW, height: tickH)
                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                            .rotationEffect(angle)
                            .position(x: cx, y: cy)
                    }
                }
            }
            else if isSelected {
                // normal square handles when selected (not dragging/editing)
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ForEach(Array(widget.allowedResizePositions), id: \.self) { pos in
                        handleView(pos)
                            .position(
                                x: xPos(for: pos, in: w),
                                y: yPos(for: pos, in: h)
                            )
                    }
                }
            }
        }
    }

    private func xPos(for pos: FrameResizePosition, in width: CGFloat) -> CGFloat {
        let half = handleSize / 2
        switch pos {
        case .leading, .topLeading, .bottomLeading:
            return half
        case .trailing, .topTrailing, .bottomTrailing:
            return width - half
        case .top, .bottom:
            return width / 2
        }
    }

    private func yPos(for pos: FrameResizePosition, in height: CGFloat) -> CGFloat {
        let half = handleSize / 2
        switch pos {
        case .top, .topLeading, .topTrailing:
            return half
        case .bottom, .bottomLeading, .bottomTrailing:
            return height - half
        case .leading, .trailing:
            return height / 2
        }
    }

    private func handleView(_ position: FrameResizePosition) -> some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
            .pointerStyle(.frameResize(position: position))
            .highPriorityGesture(resizeGesture(for: position))
    }

    // MARK: – Move Gesture

    private var moveGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard !isEditing else { return }
                if !isSelected { onSelect() }
                isDragging = true
                dragOffset = CGSize(
                    width:  value.translation.width  / slideScale,
                    height: value.translation.height / slideScale
                )
            }
            .onEnded { value in
                guard !isEditing else {
                    isDragging = false
                    dragOffset = .zero
                    return
                }
                widget.x += value.translation.width  / slideScale
                widget.y += value.translation.height / slideScale
                isDragging = false
                dragOffset = .zero
            }
    }

    // MARK: – Resize Gesture

    private func resizeGesture(for pos: FrameResizePosition) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                let prev = lastTranslation[pos] ?? .zero
                let rawDelta = CGSize(
                    width:  value.translation.width  - prev.width,
                    height: value.translation.height - prev.height
                )
                lastTranslation[pos] = value.translation

                let optionDown = NSEvent.modifierFlags.contains(.option)
                var newW = widget.width
                var newH = widget.height
                var newX = widget.x
                var newY = widget.y

                // horizontal?
                if pos.isHorizontal {
                    let signX: CGFloat = pos.isTrailing ? 1 : -1
                    let dx = rawDelta.width / slideScale
                    let dW = optionDown ? 2 * signX * dx : signX * dx
                    newW = max(widget.width + dW, handleSize * 2)
                    if !optionDown {
                        newX += signX * (newW - widget.width) / 2
                    }
                }

                // vertical?
                if pos.isVertical {
                    let signY: CGFloat = pos.isBottom ? 1 : -1
                    let dy = rawDelta.height / slideScale
                    let dH = optionDown ? 2 * signY * dy : signY * dy
                    newH = max(widget.height + dH, handleSize * 2)
                    if !optionDown {
                        newY += signY * (newH - widget.height) / 2
                    }
                }

                widget.width  = newW
                widget.height = newH
                widget.x      = newX
                widget.y      = newY
            }
            .onEnded { _ in
                lastTranslation[pos] = .zero
            }
    }
}

private extension FrameResizePosition {
    var isHorizontal: Bool {
        switch self {
        case .leading, .trailing, .topLeading, .topTrailing,
             .bottomLeading, .bottomTrailing:
            return true
        default: return false
        }
    }
    var isVertical: Bool {
        switch self {
        case .top, .bottom, .topLeading, .topTrailing,
             .bottomLeading, .bottomTrailing:
            return true
        default: return false
        }
    }
    var isTrailing: Bool {
        switch self {
        case .trailing, .topTrailing, .bottomTrailing:
            return true
        default: return false
        }
    }
    var isBottom: Bool {
        switch self {
        case .bottom, .bottomLeading, .bottomTrailing:
            return true
        default: return false
        }
    }
}
