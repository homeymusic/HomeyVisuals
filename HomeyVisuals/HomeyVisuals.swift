import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisuals: App {
    
    @State public var appContext = AppContext()
    public static let synthConductor = SynthConductor()
    public static let instrumentCache = InstrumentCache()
    public static let midiConductor =  {
        let midiConductor = MIDIConductor(
            clientName:   "Homey Visuals",
            model:        "Homey Pad macOS",
            manufacturer: "Homey Music",
            instrumentCache: HomeyVisuals.instrumentCache
        )
        midiConductor.setup()
        return midiConductor
    }()
    
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


