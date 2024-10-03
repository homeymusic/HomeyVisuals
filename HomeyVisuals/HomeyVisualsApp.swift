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
            .environmentObject(midiManager)
            .environmentObject(midiHelper)
        }
        .commands {
            CommandMenu("Musical Context") {
                Button("Clear Notes") {
                    midiHelper.reset()
                }
                .keyboardShortcut("r", modifiers: [])

                Button("Upward Pitch Contours") {
                    midiHelper.upwardPitchDirection = true
                    midiHelper.reset()
                }
                .keyboardShortcut(".", modifiers: [])
                
                Button("Downward Pitch Contours") {
                    midiHelper.upwardPitchDirection = false
                    midiHelper.reset()
                }
                .keyboardShortcut(",", modifiers: []) 
            }
        }
    }
}

