import SwiftUI
import SwiftData

struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        Form {
            Text("Test string:")
            TextField("Test", text: $slide.testString)
            Divider()
            Text("Slide ID: \(slide.id.uuidString)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Edit Slide")
    }
}
