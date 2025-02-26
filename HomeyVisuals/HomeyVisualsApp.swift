import MIDIKitIO
import SwiftUI
import Combine

@main
struct HomeyVisualsApp: App {
    @State var midiManager = ObservableMIDIManager(
        clientName: "HomeyVisuals",
        model: "macOS",
        manufacturer: "Homey Music"
    )
    
    @ObservedObject var midiHelper = MIDIHelper()
    
    @AppStorage(MIDIHelper.PrefKeys.midiInID)
    var midiInSelectedID: MIDIIdentifier?
    
    @AppStorage(MIDIHelper.PrefKeys.midiInDisplayName)
    var midiInSelectedDisplayName: String?
    
    init() {
        midiHelper.setup(midiManager: midiManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                midiInSelectedID: $midiInSelectedID,
                midiInSelectedDisplayName: $midiInSelectedDisplayName
            )
            .environment(midiManager)
            .environmentObject(midiHelper)
        }
        .commands {
            CommandMenu("Musical Context") {
                Button("Clear Notes") {
                    midiHelper.reset()
                }
                .keyboardShortcut("r", modifiers: [])

                Button("Upward Pitch Contours") {
                    midiHelper.pitchDirection = .upward
                    midiHelper.reset()
                }
                .keyboardShortcut(".", modifiers: [])
                
                Button("Mixed Pitch Contours") {
                    midiHelper.pitchDirection = .mixed
                    midiHelper.reset()
                }
                .keyboardShortcut("=", modifiers: [])

                Button("Downward Pitch Contours") {
                    midiHelper.pitchDirection = .downward
                    midiHelper.reset()
                }
                .keyboardShortcut(",", modifiers: []) 
            }
        }
    }
}

