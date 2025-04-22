// TextWidgetView.swift

import SwiftUI
import SwiftData

struct TextWidgetView: View {
    @Bindable var widget: TextWidget
    let slideSize: CGSize
    @Binding var isSelected: Bool

    var body: some View {
        Text(widget.text)
            .foregroundColor(.white)
            .padding(4)
            .fixedSize()                        // 1) shrink to text+padding
            .overlay(
                Rectangle()
                    .stroke(
                        isSelected ? Color(.systemBlue) : .clear,
                        lineWidth: 0.5
                    )
            )
            .contentShape(Rectangle())          // 2) make only that small area tappable
            .onTapGesture {
                isSelected = true               // 3) tap to select
            }
            .position(                          // 4) move BOTH view & hit‑area
                x: CGFloat(widget.x) * slideSize.width,
                y: CGFloat(widget.y) * slideSize.height
            )
    }
}

private extension Double {
    func clamped(to r: ClosedRange<Double>) -> Double {
        min(max(self, r.lowerBound), r.upperBound)
    }
}
