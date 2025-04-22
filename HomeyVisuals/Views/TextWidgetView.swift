import SwiftUI
import SwiftData

struct TextWidgetView: View {
    @Bindable var widget: TextWidget
    let slideSize: CGSize
    @Binding var isSelected: Bool

    // track drag state for stroke color
    @GestureState private var isDragging: Bool = false
    @State private var dragAnchor: (x: Double, y: Double)?

    var body: some View {
        Text(widget.text)
            .foregroundColor(.white)
            .padding(4)
            .background(Color.clear)
            .overlay(selectionOverlay)
            .position(x: positionX, y: positionY)
            .gesture(dragGesture)
    }

    private var selectionOverlay: some View {
        // only render when selected or dragging
        Group {
            if isSelected || isDragging {
                Rectangle()
                    .stroke(isDragging ? Color.white : Color(.systemBlue), lineWidth: 0.5)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDragging) { value, state, _ in
                // only flip into dragging once you’ve actually moved
                let moved = value.translation.width != 0 || value.translation.height != 0
                state = moved
            }
            .onChanged { value in
                if dragAnchor == nil {
                    dragAnchor = (widget.x, widget.y)
                }
                let dx = Double(value.translation.width  / slideSize.width)
                let dy = Double(value.translation.height / slideSize.height)
                if let anchor = dragAnchor {
                    widget.x = anchor.x + dx
                    widget.y = anchor.y + dy
                }
            }
            .onEnded { _ in
                dragAnchor = nil
                widget.x = widget.x.clamped(to: 0...1)
                widget.y = widget.y.clamped(to: 0...1)
            }
    }
    
    private var positionX: CGFloat {
        CGFloat(widget.x) * slideSize.width
    }
    private var positionY: CGFloat {
        CGFloat(widget.y) * slideSize.height
    }
}

// simple Double clamping helper
private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
