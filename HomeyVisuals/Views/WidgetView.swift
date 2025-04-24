// WidgetView.swift

import SwiftUI
import AppKit

/// A reusable view that encapsulates move, resize, selection, and edit-mode
/// behavior for any SwiftData model conforming to `Widget`.
struct WidgetView<W: Widget & Observable, Content: View>: View {
    @Bindable var widget: W
    let slideScale: CGFloat
    let isSelected: Bool
    let isEditing: Bool
    let onSelect: () -> Void
    let onBeginEditing: () -> Void
    @ViewBuilder let content: () -> Content

    // MARK: — Internal state for dragging & resizing
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var lastLeadingTranslation: CGFloat = 0
    @State private var lastTrailingTranslation: CGFloat = 0
    private let handleSize: CGFloat = 10

    var body: some View {
        ZStack {
            content()
                .frame(width: widget.width, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(handleSize)
                .overlay(selectionOverlay)
        }
        .contentShape(Rectangle())
        .position(
            x: widget.x + dragOffset.width,
            y: widget.y + dragOffset.height
        )
        .onTapGesture {
            // if already editing, don’t re-enter edit mode
            guard !isEditing else { return }

            if isSelected {
                onBeginEditing()
            } else {
                onSelect()
            }
        }
        .gesture(moveGesture)
    }

    private var selectionOverlay: some View {
        ZStack {
            Rectangle()
                .inset(by: handleSize)
                .stroke(
                    isDragging ? Color.gray :
                    (isSelected ? .blue : .clear),
                    lineWidth: 1
                )

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
            .pointerStyle(
                .frameResize(position:
                    anchor == .leading ? .leading : .trailing
                )
            )
            .highPriorityGesture(resizeGesture(anchor: anchor))
    }

    // MARK: — Move Gesture (global coords → slide-space)
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

    // MARK: — Resize Gesture (global coords → slide-space)
    private func resizeGesture(anchor: ResizeAnchor) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                let prev = (anchor == .leading
                            ? lastLeadingTranslation
                            : lastTrailingTranslation)
                let rawDelta = value.translation.width - prev

                if anchor == .leading {
                    lastLeadingTranslation = value.translation.width
                } else {
                    lastTrailingTranslation = value.translation.width
                }

                let delta = rawDelta / slideScale
                let optionDown = NSEvent.modifierFlags.contains(.option)
                let sign: CGFloat = (anchor == .trailing ? 1 : -1)

                if optionDown {
                    // symmetric resize
                    let newW = max(widget.width + 2 * sign * delta,
                                   handleSize * 2)
                    widget.width = newW
                } else {
                    // one-sided resize
                    let old = widget.width
                    let nw  = max(old + sign * delta, handleSize * 2)
                    let dw  = nw - old
                    widget.width = nw
                    widget.x    += sign * (dw / 2)
                }
            }
            .onEnded { _ in
                lastLeadingTranslation = 0
                lastTrailingTranslation = 0
            }
    }
}

private enum ResizeAnchor { case leading, trailing }
