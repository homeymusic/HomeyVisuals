import SwiftUI
import HomeyMusicKit

/// Read‑only slide view showing either the solid background color or live camera feed.
struct SlideDetail: View {
    let slide: Slide
    let isThumbnail: Bool

    init(slide: Slide, isThumbnail: Bool = false) {
      self.slide = slide
      self.isThumbnail = isThumbnail
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background: color or camera
                switch slide.backgroundType {
                case .color:
                    slide.backgroundColor
                case .cameraFeed:
                    CameraFeed(slide: slide, isThumbnail: isThumbnail)
                }

                // Foreground content
                Text(slide.testString)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding()
                
                ForEach(slide.textWidgets, id: \.id) {widget in
                    Text(widget.text)
                        .position(
                            x: geo.size.width  * widget.x,
                            y: geo.size.height * widget.y
                        )
                }
                
            }
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
    }
}

struct CameraFeed: View {
    let slide: Slide
    let isThumbnail: Bool

    var body: some View {
        
        if isThumbnail {
            VideoIcon()
        } else {
            if let device = CameraView.device(for: slide.cameraDeviceID) {
                CameraView(device: device)
                    .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fill)
                    .clipped()
            } else {
                VideoIcon()
            }
        }
    }
}
