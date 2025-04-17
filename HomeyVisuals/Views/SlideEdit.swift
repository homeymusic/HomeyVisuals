import SwiftUI
import SwiftData

struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        let slideLabel = "id: \(slide.id)"
        Form {
            Text(slideLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .navigationTitle(slideLabel)
    }
}
