import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct TextWidgetShow: View {
    @Bindable var textWidget: TextWidget
    
    var body: some View {
        Text(textWidget.text)
            .font(.system(size: textWidget.fontSize))
            .foregroundColor(.white)
            .frame(width:    textWidget.width,
                   height: textWidget.height,
                   alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .position(x: textWidget.x, y: textWidget.y)
    }
}
