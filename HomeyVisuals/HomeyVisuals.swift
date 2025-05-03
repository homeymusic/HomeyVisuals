import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisuals: App {
    // — all @State props, no inline defaults
    @State private var appContext: AppContext
    @State private var synthConductor: SynthConductor
    @State private var instrumentCache: InstrumentCache
    @State private var midiConductor: MIDIConductor

    let modelContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Slide.self, configurations: config)
    }()

    init() {
        let appContext = AppContext()
        let synthConductor = SynthConductor()
        let instrumentCache = InstrumentCache()
        let midiConductor = MIDIConductor(
            clientName:   "Homey Visuals",
            model:        "Homey Visuals macOS",
            manufacturer: "Homey Music",
            instrumentCache: instrumentCache
        )
        midiConductor.setup()

        _appContext      = State(initialValue: appContext)
        _synthConductor  = State(initialValue: synthConductor)
        _instrumentCache = State(initialValue: instrumentCache)
        _midiConductor   = State(initialValue: midiConductor)
    }
    
    var body: some Scene {
        DocumentGroup(editing: Slide.self, contentType: .visuals) {
            ContentView()
                .environment(appContext)
                .environment(instrumentCache)
                .environment(synthConductor)
                .environment(midiConductor)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 1440, height: 900)
    }
}
