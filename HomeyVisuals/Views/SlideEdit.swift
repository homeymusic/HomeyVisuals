import SwiftUI
import SwiftData
import HomeyMusicKit

/// Editable slide view: renders either a solid color or live camera feed background,
/// with a TextField overlay for the slide title.
struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        GeometryReader { geo in
            ZStack {
                switch slide.backgroundType {
                case .color:
                    slide.backgroundColor
                    
                case .cameraFeed:
                    if let device = CameraView.device(for: slide.cameraDeviceID) {
                        CameraView(device: device)
                            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fill)
                            .clipped()
                    } else {
                        VideoIcon()
                    }
                }
                
                TextField("Title", text: $slide.testString)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding()
                
                ForEach($slide.textWidgets, id: \.id) { $widget in
                    TextField("Text", text: $widget.text)
                        .foregroundColor(.white)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                        .position(
                            x: geo.size.width  * widget.x,
                            y: geo.size.height * widget.y
                        )
                }
            }
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
    }
}

