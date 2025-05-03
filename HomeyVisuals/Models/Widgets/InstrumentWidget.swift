import Foundation
import SwiftData
import CoreGraphics
import HomeyMusicKit

@Model
public final class InstrumentWidget: Widget {
    #Unique<InstrumentWidget>([\.id], [\.slide, \.z])
    
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
    public var relativeWidth: Double = 0.25
    /// 0…1 fraction of slide height
    public var relativeHeight: Double = 0.25 / 2.0

    // MARK: — Content type
    public var instrumentType: InstrumentType

    // MARK: — One-to-one persisted instrument relationships
    @Relationship(deleteRule: .cascade) public var modePicker: ModePicker?
    @Relationship(deleteRule: .cascade) public var tonicPicker: TonicPicker?
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
        instrumentType: InstrumentType
    ) {
        self.id               = UUID()
        self.slide            = slide
        self.z                = zIndex
        self.instrumentType = instrumentType
    }

    // MARK: — Static factory for creation + persistence
    @MainActor
    public static func create(
        forSlide slide: Slide,
        withType type: InstrumentType,
        in modelContext: ModelContext
    ) -> InstrumentWidget {
        let widget = InstrumentWidget(
            forSlide: slide,
            zIndex:   slide.highestZ + 1,
            instrumentType: type
        )
        modelContext.insert(widget)

        switch type {
        case .modePicker:
            let i = ModePicker();   modelContext.insert(i); widget.modePicker   = i
        case .tonicPicker:
            let i = TonicPicker();  modelContext.insert(i); widget.tonicPicker  = i
        case .tonnetz:
            let i = Tonnetz();      modelContext.insert(i); widget.tonnetz      = i
        case .linear:
            let i = Linear();       modelContext.insert(i); widget.linear       = i
        case .diamanti:
            let i = Diamanti();     modelContext.insert(i); widget.diamanti     = i
        case .piano:
            let i = Piano();        modelContext.insert(i); widget.piano        = i
        case .violin:
            let i = Violin();       modelContext.insert(i); widget.violin       = i
        case .cello:
            let i = Cello();        modelContext.insert(i); widget.cello        = i
        case .bass:
            let i = Bass();         modelContext.insert(i); widget.bass         = i
        case .banjo:
            let i = Banjo();        modelContext.insert(i); widget.banjo        = i
        case .guitar:
            let i = Guitar();       modelContext.insert(i); widget.guitar       = i
        }
        
        return widget
    }

    // MARK: — Computed access to the single persisted instrument
    public var instrument: any MusicalInstrument {
        let instrument: any MusicalInstrument = {
          switch instrumentType {
            case .modePicker:   return modePicker!
            case .tonicPicker:  return tonicPicker!
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

        return instrument
      }
}

extension InstrumentWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(instrumentType))
        return AnyHashable(arr)
    }
}
