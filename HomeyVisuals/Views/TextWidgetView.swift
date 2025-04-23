import SwiftUI
import SwiftData
import HomeyMusicKit

struct TextWidgetView: View {
    @Bindable var textWidget: TextWidget
    let slideSize: CGSize
    @Binding var isSelected: Bool

    var body: some View {
        
        TextWidgetContent(textWidget: textWidget, slideSize: slideSize)
            .fixedSize()
            .overlay(
                Rectangle()
                    .stroke(
                        isSelected ? Color(.systemBlue) : .clear,
                        lineWidth: 1 / HomeyMusicKit.goldenRatio
                    )
            )
            .contentShape(Rectangle())          // 2) make only that small area tappable
            .onTapGesture {
                isSelected.toggle()
            }
            .position(
                x: slideSize.width  * textWidget.x,
                y: slideSize.height * textWidget.y
            )
    }
}

private extension Double {
    func clamped(to r: ClosedRange<Double>) -> Double {
        min(max(self, r.lowerBound), r.upperBound)
    }
}
