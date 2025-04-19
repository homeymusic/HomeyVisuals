import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        // Exactly the same layout, but with an editable TextField:
        ZStack {
            Color(slide.backgroundColor)

            TextField("Title", text: $slide.testString)
                .font(.largeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
    }
}
