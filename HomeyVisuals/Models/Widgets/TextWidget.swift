// TextWidget.swift

import Foundation
import SwiftData

@Model
public final class TextWidget: Widget {
    #Unique<TextWidget>([\.id], [\.slide, \.z])

    public var id: UUID
    public var slide: Slide?
    public var x: Double
    public var y: Double
    public var z: Int
    public var width: Double
    public var height: Double
    public var text: String
    public var fontSize: Double
    
    public init(
        slide: Slide,
        x: Double      = 0.5,
        y: Double      = 0.5,
        z: Int,
        width: Double  = 0.1,
        height: Double = 0.1,
        text: String   = "Text",
        fontSize: Double = 150
    ) {
        self.id     = UUID()
        self.slide  = slide
        self.x      = x
        self.y      = y
        self.z      = z
        self.width  = width
        self.height = height
        self.text   = text
        self.fontSize = fontSize
    }

    public convenience init(slide: Slide) {
        self.init(
            slide: slide,
            x: 0.5,
            y: 0.5,
            z: slide.highestZ + 1,
            width:  0.1,
            height: 0.1,
            text:   "Text",
            fontSize: 150
        )
    }
}

extension TextWidget {
    /// Include both geometry *and* `text` in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(text))
        arr.append(AnyHashable(fontSize))
        return AnyHashable(arr)
    }
}
