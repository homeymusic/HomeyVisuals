// TextWidgetView.swift

import SwiftUI
import SwiftData

struct TextWidgetView: View {
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize
    @Binding var isSelected: Bool

    var body: some View {
        
        TextWidgetContent(widget: textWidget, slideSize: slideSize)
            .overlay(
                Rectangle()
                    .stroke(
                        isSelected ? Color(.systemBlue) : .clear,
                        lineWidth: 0.5
                    )
            )
            .contentShape(Rectangle())          // 2) make only that small area tappable
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

private extension Double {
    func clamped(to r: ClosedRange<Double>) -> Double {
        min(max(self, r.lowerBound), r.upperBound)
    }
}
