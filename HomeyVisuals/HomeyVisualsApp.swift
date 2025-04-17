import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct HomeyVisualsApp: App {
    var body: some Scene {
        DocumentGroup(
            editing: Presentation.self,
            contentType: .visuals
        ) {
            ContentView()
        }
    }
}
