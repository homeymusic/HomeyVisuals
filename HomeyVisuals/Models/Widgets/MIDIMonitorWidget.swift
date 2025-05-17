import Foundation
import SwiftUI
import SwiftData
import CoreGraphics
import HomeyMusicKit

@Model
public final class MIDIMonitorWidget: Widget {
    #Unique<MIDIMonitorWidget>([\.id], [\.slide, \.z])
    
    // MARK: — Identity & Z-order
    public var id: UUID
    public var slide: Slide?
    public var z: Int

    public var relativeX: Double = 0.5
    public var relativeY: Double = 0.5
    public var relativeWidth: Double = 0.5
    public var relativeHeight: Double = 0.5

    // MARK: — One-to-one persisted instrument relationships
    @Relationship(deleteRule: .cascade) public var tonalityInstrument: TonalityInstrument

    // MARK: — Private designated init
    private init(
        slide: Slide,
        zIndex: Int,
        tonalityInstrument: TonalityInstrument
    ) {
        self.id                 = UUID()
        self.slide              = slide
        self.z                  = zIndex
        self.tonalityInstrument = tonalityInstrument
    }

    // MARK: — Static factory for creation + persistence
    @MainActor
    public static func create(
        slide: Slide,
        midiConductor: MIDIConductor,
        in modelContext: ModelContext
    ) -> MIDIMonitorWidget {
        let widget = MIDIMonitorWidget(
            slide: slide,
            zIndex:   slide.highestZ + 1,
            tonalityInstrument: TonalityInstrument(
                tonality: slide.tonality,
            )
        )
        modelContext.insert(widget)
        modelContext.ensureColorPalette(on: widget.tonalityInstrument)
        widget.tonalityInstrument.midiConductor = midiConductor
        widget.tonalityInstrument.pitchLabelTypes = [ .letter, .octave]
        widget.tonalityInstrument.intervalLabelTypes = [ .symbol ]
        return widget
    }
    
}

extension MIDIMonitorWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        let arr = Self.baseHashElements(of: self as! Self)
        return AnyHashable(arr)
    }
}
