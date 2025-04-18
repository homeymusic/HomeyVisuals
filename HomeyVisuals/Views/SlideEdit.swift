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
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(16)
        }
        .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
        .navigationTitle("Edit Slide")
        .padding()
    }
}
