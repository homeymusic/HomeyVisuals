import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisuals: App {
    
    @State public var appContext = AppContext()
    public static let synthConductor = SynthConductor()
    public private(set) static var midiConductor: MIDIConductor!
    
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
    
    @MainActor
    public static func setupMIDIConductor(modelContext: ModelContext, homeyMusicAppContext: HomeyMusicAppContext) {
        guard midiConductor == nil else { return }
        let c = MIDIConductor(
            clientName:   "Homey Visuals",
            model:        "Homey Pad macOS",
            manufacturer: "Homey Music",
            modelContext: modelContext,
            homeyMusicAppContext: homeyMusicAppContext
        )
        c.setup()
        midiConductor = c
    }

}


