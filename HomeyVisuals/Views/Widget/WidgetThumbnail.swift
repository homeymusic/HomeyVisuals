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

            case let cameraWidget as CameraWidget:
                CameraView(cameraDeviceID: cameraWidget.cameraDeviceID, isThumbnail: true)
                    .position(x: cameraWidget.x, y: cameraWidget.y)
                    .frame(width: cameraWidget.width, height: cameraWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

            case let musicalInstrumentWidget as MusicalInstrumentWidget:
                MusicalInstrumentView(musicalInstrumentWidget.musicalInstrument)
                    .position(x: musicalInstrumentWidget.x, y: musicalInstrumentWidget.y)
                    .frame(width: musicalInstrumentWidget.width, height: musicalInstrumentWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

            case let tonalityInstrumentWidget as TonalityInstrumentWidget:
                TonalityInstrumentView(tonalityInstrumentWidget.tonalityInstrument)
                    .position(x: tonalityInstrumentWidget.x, y: tonalityInstrumentWidget.y)
                    .frame(width: tonalityInstrumentWidget.width, height: tonalityInstrumentWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

            case let tonicPitchStatusWidget as TonicPitchStatusWidget:
                TonicPitchStatusView(tonicPitchStatusWidget.tonalityInstrument)
                    .position(x: tonicPitchStatusWidget.x, y: tonicPitchStatusWidget.y)
                    .frame(width: tonicPitchStatusWidget.width, height: tonicPitchStatusWidget.height, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
            default:
                EmptyView()
            }
        }
        .allowsHitTesting(false)
    }
}
