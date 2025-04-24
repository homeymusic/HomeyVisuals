import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisualsApp: App {
    
    @State private var appContext = AppContext()
    @State private var orchestrator = Orchestrator().setup()
    
    var body: some Scene {
        DocumentGroup(
            editing: Slide.self,
            contentType: .visuals
        ) {
            ContentView()
                .environment(appContext)
                .environment(orchestrator.tonalContext)
                .environment(orchestrator.instrumentalContext)
                .environment(orchestrator.notationalTonicContext)
                .environment(orchestrator.notationalContext)
        }
        .defaultSize(width: 1440, height: 900)
    }
}


