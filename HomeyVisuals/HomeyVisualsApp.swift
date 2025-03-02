import MIDIKitIO
import SwiftUI
import Combine

import HomeyMusicKit

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
        TonalContext.configure(
            clientName: "HomeyVisuals",
            model: "Homey Visuals macOS",
            manufacturer: "Homey Music"
        )
        
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
                    TonalContext.shared.pitchDirection = .upward
                    midiHelper.reset()
                }
                .keyboardShortcut(".", modifiers: [])
                
                Button("Downward Pitch Contours") {
                    TonalContext.shared.pitchDirection = .downward
                    midiHelper.reset()
                }
                .keyboardShortcut(",", modifiers: [])
            }
        }
    }
}

