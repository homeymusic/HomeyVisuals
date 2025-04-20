// SlideDetail.swift
import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct SlideDetail: View {
    @Bindable var slide: Slide

    var body: some View {
        GeometryReader { geo in
            let aspect = CGFloat(slide.aspectRatio.ratio)
            let devSize = deviceSlideSize(aspect: aspect)
            let scale   = min(geo.size.width  / devSize.width,
                              geo.size.height / devSize.height)
            let displaySize = CGSize(width:  devSize.width  * scale,
                                     height: devSize.height * scale)
            let offsetX = (geo.size.width  - displaySize.width)  / 2
            let offsetY = (geo.size.height - displaySize.height) / 2

            ZStack {
                // Background
                switch slide.backgroundType {
                case .color:
                    slide.backgroundColor
                        .ignoresSafeArea()
                case .cameraFeed:
                    if let device = CameraView.device(for: slide.cameraDeviceID) {
                        CameraView(device: device)
                            .aspectRatio(aspect, contentMode: .fill)
                            .clipped()
                    } else {
                        Color.black
                    }
                }

                // Title
                Text(slide.testString)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(width: displaySize.width,
                           height: displaySize.height,
                           alignment: .center)

                // Widgets
                ForEach(slide.textWidgets) { widget in
                    Text(widget.text)
                        .font(.body)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(4)
                        .position(
                            x: offsetX + displaySize.width  * widget.x,
                            y: offsetY + displaySize.height * widget.y
                        )
                }
            }
            .frame(width: displaySize.width,
                   height: displaySize.height)
            .position(x: geo.size.width/2,
                      y: geo.size.height/2)
        }
        .navigationTitle("Slide Detail")
    }
}
