import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@main
struct HomeyVisuals: App {
    // — all @State props, no inline defaults
    @State private var appContext: AppContext
    @State private var synthConductor: SynthConductor
    @State private var musicalInstrumentCache: MusicalInstrumentCache
    @State private var tonalityCache: TonalityCache
    @State private var midiConductor: MIDIConductor

    let modelContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Slide.self, configurations: config)
    }()

    init() {
        let appContext = AppContext()
        let synthConductor = SynthConductor()
        let musicalInstrumentCache = MusicalInstrumentCache()
        let tonalityCache = TonalityCache()
        let midiConductor = MIDIConductor(
            clientName:   "Homey Visuals",
            model:        "Homey Visuals macOS",
            manufacturer: "Homey Music",
            musicalInstrumentCache: musicalInstrumentCache,
            tonalityCache: tonalityCache
        )
        midiConductor.setup()

        _appContext      = State(initialValue: appContext)
        _synthConductor  = State(initialValue: synthConductor)
        _musicalInstrumentCache = State(initialValue: musicalInstrumentCache)
        _tonalityCache = State(initialValue: tonalityCache)
        _midiConductor   = State(initialValue: midiConductor)
    }
    
    var body: some Scene {
        DocumentGroup(editing: Slide.self, contentType: .visuals) {
            ContentView()
                .environment(appContext)
                .environment(musicalInstrumentCache)
                .environment(tonalityCache)
                .environment(synthConductor)
                .environment(midiConductor)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 1440, height: 900)
    }
}
