// HomeyVisuals/Views/SlideShow.swift

import SwiftUI
import HomeyMusicKit

struct SlideShow: View {
    let slide: Slide

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1) fill the entire window behind the letterbox:
                Color(slide.backgroundColor)
                    .ignoresSafeArea()

                // 2) center the letter‑boxed slide content:
                Text(slide.testString)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(
                        width: geo.size.width,
                        height: geo.size.width / CGFloat(slide.aspectRatio.ratio)
                    )
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2
                    )
            }
        }
    }
}
