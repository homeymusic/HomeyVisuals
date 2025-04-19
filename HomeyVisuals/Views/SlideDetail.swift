import SwiftUI
import HomeyMusicKit

struct SlideDetail: View {
    let slide: Slide

    var body: some View {
        ZStack {
            ZStack {
                Color(slide.backgroundColor)

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
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        }
    }
}
