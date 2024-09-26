import MIDIKitIO
import SwiftUI
import Combine

@main
struct HomeyVisualsApp: App {
    @ObservedObject var midiManager = ObservableMIDIManager(
        clientName: "HomeyVisuals",
        model: "macOS",
        manufacturer: "Homey Music"
    )    
    
    var body: some Scene {
        WindowGroup {
            ContentView(
            )
            .environmentObject(midiManager)
            .environmentObject(MIDIHelper(midiManager: midiManager))
        }
    }
}
