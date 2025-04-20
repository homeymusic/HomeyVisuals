import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideInspect: View {
    @Bindable var slide: Slide

    var body: some View {
        Form {
            Section("Appearance") {
                ColorPicker("Background", selection: $slide.backgroundColor)
            }
        }
        .navigationTitle("Inspect Slide")
        .padding()
    }
}
