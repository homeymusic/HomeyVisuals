import Foundation
import SwiftData
import CoreGraphics
import HomeyMusicKit

@Model
public final class MusicalInstrumentWidget: Widget {
    #Unique<MusicalInstrumentWidget>([\.id], [\.slide, \.z])
    
    // MARK: — Identity & Z-order
    public var id: UUID
    public var slide: Slide?
    public var z: Int

    // MARK: — Stored (relative, persisted)
    public var relativeX: Double = 0.5
    public var relativeY: Double = 0.5
    public var relativeWidth: Double = 1.0 / HomeyMusicKit.goldenRatio
    public var relativeHeight: Double = 1.0 / (2.0 * HomeyMusicKit.goldenRatio)

    // MARK: — Content type
    public var musicalInstrumentType: MusicalInstrumentType

    // MARK: — One-to-one persisted instrument relationships
    @Relationship(deleteRule: .cascade) public var tonnetz: Tonnetz?
    @Relationship(deleteRule: .cascade) public var linear: Linear?
    @Relationship(deleteRule: .cascade) public var diamanti: Diamanti?
    @Relationship(deleteRule: .cascade) public var piano: Piano?
    @Relationship(deleteRule: .cascade) public var violin: Violin?
    @Relationship(deleteRule: .cascade) public var cello: Cello?
    @Relationship(deleteRule: .cascade) public var bass: Bass?
    @Relationship(deleteRule: .cascade) public var banjo: Banjo?
    @Relationship(deleteRule: .cascade) public var guitar: Guitar?

    // MARK: — Private designated init
    private init(
        forSlide slide: Slide,
        zIndex: Int,
        musicalInstrumentType: MusicalInstrumentType
    ) {
        self.id               = UUID()
        self.slide            = slide
        self.z                = zIndex
        self.musicalInstrumentType = musicalInstrumentType
    }

    // MARK: — Static factory for creation + persistence
    @MainActor
    public static func create(
        forSlide slide: Slide,
        withType type: MusicalInstrumentType,
        in modelContext: ModelContext
    ) -> MusicalInstrumentWidget {
        let widget = MusicalInstrumentWidget(
            forSlide: slide,
            zIndex:   slide.highestZ + 1,
            musicalInstrumentType: type
        )
        modelContext.insert(widget)

        switch type {
        case .tonnetz:
            let i = Tonnetz(tonality: slide.tonality);      modelContext.insert(i); widget.tonnetz      = i
        case .linear:
            let i = Linear(tonality: slide.tonality);       modelContext.insert(i); widget.linear       = i
        case .diamanti:
            let i = Diamanti(tonality: slide.tonality);     modelContext.insert(i); widget.diamanti     = i
        case .piano:
            let i = Piano(tonality: slide.tonality);        modelContext.insert(i); widget.piano        = i
        case .violin:
            let i = Violin(tonality: slide.tonality);       modelContext.insert(i); widget.violin       = i
        case .cello:
            let i = Cello(tonality: slide.tonality);        modelContext.insert(i); widget.cello        = i
        case .bass:
            let i = Bass(tonality: slide.tonality);         modelContext.insert(i); widget.bass         = i
        case .banjo:
            let i = Banjo(tonality: slide.tonality);        modelContext.insert(i); widget.banjo        = i
        case .guitar:
            let i = Guitar(tonality: slide.tonality);       modelContext.insert(i); widget.guitar       = i
        }
        
        return widget
    }

    public var musicalInstrument: any MusicalInstrument {
        let musicalInstrument: any MusicalInstrument = {
          switch musicalInstrumentType {
            case .tonnetz:      return tonnetz!
            case .linear:       return linear!
            case .diamanti:     return diamanti!
            case .piano:        return piano!
            case .violin:       return violin!
            case .cello:        return cello!
            case .bass:         return bass!
            case .banjo:        return banjo!
            case .guitar:       return guitar!
          }
        }()

        return musicalInstrument
      }
}

extension MusicalInstrumentWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(musicalInstrumentType))
        return AnyHashable(arr)
    }
}
