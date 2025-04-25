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
    public var relativeHeight: Double = 0.25

    // MARK: — Content choice
    public var instrumentChoice: InstrumentChoice

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
        instrumentChoice: InstrumentChoice
    ) {
        self.id               = UUID()
        self.slide            = slide
        self.z                = zIndex
        self.instrumentChoice = instrumentChoice
    }

    // MARK: — Static factory for creation + persistence
    @MainActor
    public static func create(
        forSlide slide: Slide,
        withChoice choice: InstrumentChoice,
        in modelContext: ModelContext
    ) -> InstrumentWidget {
        let widget = InstrumentWidget(
            forSlide: slide,
            zIndex:   slide.highestZ + 1,
            instrumentChoice: choice
        )
        modelContext.insert(widget)

        switch choice {
        case .modePicker:
            let inst = ModePicker();   modelContext.insert(inst); widget.modePicker   = inst
        case .tonicPicker:
            let inst = TonicPicker();  modelContext.insert(inst); widget.tonicPicker  = inst
        case .tonnetz:
            let inst = Tonnetz();      modelContext.insert(inst); widget.tonnetz      = inst
        case .linear:
            let inst = Linear();       modelContext.insert(inst); widget.linear       = inst
        case .diamanti:
            let inst = Diamanti();     modelContext.insert(inst); widget.diamanti     = inst
        case .piano:
            let inst = Piano();        modelContext.insert(inst); widget.piano        = inst
        case .violin:
            let inst = Violin();       modelContext.insert(inst); widget.violin       = inst
        case .cello:
            let inst = Cello();        modelContext.insert(inst); widget.cello        = inst
        case .bass:
            let inst = Bass();         modelContext.insert(inst); widget.bass         = inst
        case .banjo:
            let inst = Banjo();        modelContext.insert(inst); widget.banjo        = inst
        case .guitar:
            let inst = Guitar();       modelContext.insert(inst); widget.guitar       = inst
        }

        return widget
    }

    // MARK: — Computed access to the single persisted instrument
    public var instrument: any Instrument {
        switch instrumentChoice {
        case .modePicker: return modePicker!
        case .tonicPicker:return tonicPicker!
        case .tonnetz:    return tonnetz!
        case .linear:     return linear!
        case .diamanti:   return diamanti!
        case .piano:      return piano!
        case .violin:     return violin!
        case .cello:      return cello!
        case .bass:       return bass!
        case .banjo:      return banjo!
        case .guitar:     return guitar!
        }
    }
}

extension InstrumentWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(instrumentChoice))
        return AnyHashable(arr)
    }
}
