import Foundation
import SwiftUI
import SwiftData
import CoreGraphics
import HomeyMusicKit

@Model
public final class TonalityInstrumentWidget: Widget {
    #Unique<TonalityInstrumentWidget>([\.id], [\.slide, \.z])
    
    // MARK: — Identity & Z-order
    public var id: UUID
    public var slide: Slide?
    public var z: Int

    // MARK: — Stored (relative, persisted)
    /// 0…1 fraction of slide width
    public var relativeX: Double = 0.5
    /// 0…1 fraction of slide height
    public var relativeY: Double = 0.5
    /// 0…1 fraction of slide width
    public var relativeWidth: Double = 1.0 / (2.0 * HomeyMusicKit.goldenRatio)
    /// 0…1 fraction of slide height
    public var relativeHeight: Double = 1.0 / (8.0 * HomeyMusicKit.goldenRatio)

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
    ) -> TonalityInstrumentWidget {
        let widget = TonalityInstrumentWidget(
            slide: slide,
            zIndex:   slide.highestZ + 1,
            tonalityInstrument: TonalityInstrument(tonality: slide.tonality)
        )
        modelContext.insert(widget)
        widget.tonalityInstrument.midiConductor = midiConductor
        return widget
    }
    
}

extension TonalityInstrumentWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        let arr = Self.baseHashElements(of: self as! Self)
        return AnyHashable(arr)
    }
}
