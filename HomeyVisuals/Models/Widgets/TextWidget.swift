import Foundation
import SwiftData
import CoreGraphics

@Model
public final class TextWidget: Widget {
    #Unique<TextWidget>([\.id], [\.slide, \.z])

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
    public var text: String

    @Attribute
    public var fontSize: Double = 150.0

    // MARK: — Init
    public init(
        slide: Slide,
        relativeX: Double = 0.5,
        relativeY: Double = 0.5,
        z: Int,
        relativeWidth: Double = 0.25,
        relativeHeight: Double = 0.25,
        text: String = "Text",
        fontSize: Double = 150.0
    ) {
        self.id             = UUID()
        self.slide          = slide
        self.relativeX      = relativeX
        self.relativeY      = relativeY
        self.z              = z
        self.relativeWidth  = relativeWidth
        self.relativeHeight = relativeHeight
        self.text           = text
        self.fontSize       = fontSize
    }

    public convenience init(slide: Slide) {
        self.init(
            slide: slide,
            z: slide.highestZ + 1
        )
    }

    @MainActor
    public convenience init(record: TextWidgetRecord, slide: Slide) {
        self.init(
            slide: slide,
            relativeX: record.x,
            relativeY: record.y,
            z: record.z,
            relativeWidth: record.width,
            relativeHeight: record.height,
            text: record.text,
            fontSize: record.fontSize
        )
        self.id = record.id
    }

    // MARK: — Record mapping
    public var record: TextWidgetRecord {
        TextWidgetRecord(
            id:         id,
            x:          relativeX,
            y:          relativeY,
            z:          z,
            width:      relativeWidth,
            height:     relativeHeight,
            text:       text,
            fontSize:   fontSize
        )
    }
}

extension TextWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(text))
        arr.append(AnyHashable(fontSize))
        return AnyHashable(arr)
    }
}

