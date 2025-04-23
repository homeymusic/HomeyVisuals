// TextWidgetView.swift

import SwiftUI
import SwiftData

struct TextWidgetView: View {
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize
    @Binding var isSelected: Bool

    var body: some View {
        
        Text(textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .foregroundColor(.white)
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
            .position(                          // 4) move BOTH view & hit‑area
                x: CGFloat(textWidget.x) * slideSize.width,
                y: CGFloat(textWidget.y) * slideSize.height
            )
    }
}

private extension Double {
    func clamped(to r: ClosedRange<Double>) -> Double {
        min(max(self, r.lowerBound), r.upperBound)
    }
}
