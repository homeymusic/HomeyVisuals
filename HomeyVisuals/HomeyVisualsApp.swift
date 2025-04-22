import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct HomeyVisualsApp: App {
    
    @State private var selections = Selections()
    
    var body: some Scene {
        DocumentGroup(
            editing: Slide.self,
            contentType: .visuals
        ) {
            ContentView()
                .environment(selections)
        }
        .defaultSize(width: 1440, height: 900)
    }
}
