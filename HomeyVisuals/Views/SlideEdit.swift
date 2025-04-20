import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: renders either a solid color or live camera feed background,
/// with a TextField overlay for the slide title.
struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        ZStack {
            switch slide.backgroundType {
            case .color:
                slide.backgroundColor
                    .ignoresSafeArea()

            case .cameraFeed:
                if let device = CameraView.device(for: slide.cameraDeviceID) {
                    CameraView(device: device)
                        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fill)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    Color.black
                        .ignoresSafeArea()
                }
            }

            TextField("Title", text: $slide.testString)
                .font(.largeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding()
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
    }
}

