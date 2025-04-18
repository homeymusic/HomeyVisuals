import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct HomeyVisualsApp: App {
    var body: some Scene {
        DocumentGroup(
            editing: Slide.self,
            contentType: .visuals
        ) {
            ContentView()
        }
    }
}
