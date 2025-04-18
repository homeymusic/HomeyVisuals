import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        VStack {
            // — Preview at the top —
            Color(slide.backgroundColor)
                .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
                .cornerRadius(8)
                .padding()

            // — Details underneath —
            Form {
                Section("Content") {
                    Text("Test string:")
                    TextField("Test", text: $slide.testString)
                }

                Section("Metadata") {
                    Text("Slide ID: \(slide.id.uuidString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Edit Slide")
    }
}
