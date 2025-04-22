import SwiftUI
import SwiftData

struct TextWidgetView: View {
    @Bindable var widget: TextWidget
    let slideSize: CGSize

    // Capture the widget’s original coords when a drag starts
    @State private var dragAnchor: (x: Double, y: Double)?

    var body: some View {
        Text(widget.text)
            .foregroundColor(.white)
            .position(x: positionX, y: positionY)
            .gesture(dragGesture)
    }

    private var positionX: CGFloat {
        CGFloat(widget.x) * slideSize.width
    }
    private var positionY: CGFloat {
        CGFloat(widget.y) * slideSize.height
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // first event: remember where we started
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
                // optional: clamp into [0…1]
                widget.x = min(max(widget.x, 0), 1)
                widget.y = min(max(widget.y, 0), 1)
            }
    }
}
