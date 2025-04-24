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
    public var relativeX: Double
    /// 0…1 fraction of slide height
    public var relativeY: Double
    /// 0…1 fraction of slide width
    public var relativeWidth: Double
    /// 0…1 fraction of slide height
    public var relativeHeight: Double

    // MARK: — Content
    public var instrumentChoice: InstrumentChoice

    // MARK: — Init
    public init(
        slide: Slide,
        relativeX: Double = 0.5,
        relativeY: Double = 0.5,
        z: Int,
        relativeWidth: Double = 0.25,
        relativeHeight: Double = 0.25,
        instrumentChoice: InstrumentChoice = .piano
    ) {
        self.id             = UUID()
        self.slide          = slide
        self.relativeX      = relativeX
        self.relativeY      = relativeY
        self.z              = z
        self.relativeWidth  = relativeWidth
        self.relativeHeight = relativeHeight
        self.instrumentChoice     = instrumentChoice
    }

    public convenience init(slide: Slide) {
        self.init(
            slide: slide,
            z: slide.highestZ + 1
        )
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

