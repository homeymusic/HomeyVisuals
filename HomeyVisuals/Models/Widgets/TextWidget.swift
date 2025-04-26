import Foundation
import SwiftUI
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
    public var relativeX: Double = 0.5
    /// 0…1 fraction of slide height
    public var relativeY: Double = 0.5
    /// 0…1 fraction of slide width
    public var relativeWidth: Double = 0.25
    /// 0…1 fraction of slide height
    public var relativeHeight: Double = 0.25

    // MARK: — Content
    public var text: String = "Text"

    public var fontSize: Double = 150.0

    // MARK: — Init
    public init(
        slide: Slide,
        z: Int,
    ) {
        self.id             = UUID()
        self.slide          = slide
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
            z: record.z
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
    
    public var allowedResizePositions: Set<FrameResizePosition> {
        [.leading, .trailing]
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

