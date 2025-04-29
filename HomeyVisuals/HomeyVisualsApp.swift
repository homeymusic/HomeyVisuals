import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisualsApp: App {
    
    @State private var appContext = AppContext()
    
    var body: some Scene {
        DocumentGroup(
            editing: Slide.self,
            contentType: .visuals
        ) {
            ContentView()
                .environment(appContext)
        }
        .defaultSize(width: 1440, height: 900)
    }
}


