// TextWidget.swift
import Foundation
import SwiftData

@Model
public class TextWidget: Widget {
    @Attribute(.unique) public var id: UUID = UUID()
    @Attribute public var x: Double
    @Attribute public var y: Double
    @Attribute public var text: String
    
    public var slide: Slide?

    public init(x: Double, y: Double, text: String = "Text", slide: Slide) {
        self.x = x
        self.y = y
        self.text = text
        self.slide = slide
    }

}
