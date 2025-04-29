import SwiftUI
import HomeyMusicKit

/// Read-only thumbnail for any widget.
struct WidgetThumbnail: View {
    let widget: any Widget
    let scale: CGFloat

    var body: some View {
        Group {
            switch widget {
            case let textWidget as TextWidget:
                Text(textWidget.text)
                    .font(.system(size: textWidget.fontSize))
                    .foregroundColor(.white)
                    .frame(width: textWidget.width, height: textWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: textWidget.x, y: textWidget.y)

            case let instrumentWidget as InstrumentWidget:
                InstrumentView(instrumentWidget.instrument)
                    .position(x: instrumentWidget.x, y: instrumentWidget.y)
                    .frame(width: instrumentWidget.width, height: instrumentWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

            default:
                EmptyView()
            }
        }
        .allowsHitTesting(false)
    }
}
