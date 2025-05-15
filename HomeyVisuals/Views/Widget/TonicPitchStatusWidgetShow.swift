import SwiftUI
import SwiftData
import HomeyMusicKit

struct TonicPitchStatusWidgetShow: View {
    @Bindable var tonicPitchStatusWidget: TonicPitchStatusWidget

    var body: some View {
        TonicPitchStatusView(tonicPitchStatusWidget.tonalityInstrument)
            .frame(width: tonicPitchStatusWidget.width, height: tonicPitchStatusWidget.height, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .position(x: tonicPitchStatusWidget.x, y: tonicPitchStatusWidget.y)
            .allowsHitTesting(true)
    }
}

