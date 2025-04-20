import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideInspect: View {
    @Bindable var slide: Slide
    
    var body: some View {
        Text("Hi")
            .navigationTitle("Inspect Slide")
    }
}
