import SwiftUI
import HomeyMusicKit

/// Read‑only slide view showing either the solid background color or live camera feed.
struct SlideDetail: View {
    let slide: Slide

    var body: some View {
        ZStack {
            // Background: color or camera
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

            // Foreground content
            Text(slide.testString)
                .font(.largeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding()
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Slide Detail")
    }
}

