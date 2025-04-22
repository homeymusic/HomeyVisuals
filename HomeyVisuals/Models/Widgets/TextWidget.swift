// TextWidget.swift
import Foundation
import SwiftData

@Model
public class TextWidget: Widget {
    #Unique<TextWidget>([\.id], [\.slide, \.z])
    
    public var id: UUID
    public var slide: Slide?
    public var x: Double
    public var y: Double
    public var z: Int
    public var width: Double
    public var height: Double
    public var text: String
    
    public init(
        slide: Slide,
        x: Double      = 0.5,
        y: Double      = 0.5,
        z: Int,
        width: Double  = 0.1,
        height: Double = 0.1,
        text: String   = "Text"
    ) {
        self.id     = UUID()
        self.slide  = slide
        self.x      = x
        self.y      = y
        self.z      = z
        self.width  = width
        self.height = height
        self.text   = text
    }
    
    public convenience init(slide: Slide) {
        self.init(
            slide: slide,
            x: 0.5,
            y: 0.5,
            z: slide.highestZ + 1,     // bump z automatically
            width:  0.1,
            height: 0.1,
            text:   "Text"
        )
    }

}
