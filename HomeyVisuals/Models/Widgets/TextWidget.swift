// TextWidget.swift
import Foundation
import SwiftData

@Model
public class TextWidget: Widget {
    @Attribute(.unique) public var id: UUID = UUID()
    @Attribute public var x: Double {
        didSet { slide?.bumpVersion() }
      }
    @Attribute public var y: Double {
        didSet { slide?.bumpVersion() }
      }
    @Attribute public var text: String {
        didSet { slide?.bumpVersion() }
      }
    
    public var slide: Slide?

    @MainActor
    public init(x: Double, y: Double, text: String = "Text", slide: Slide) {
        self.x = x
        self.y = y
        self.text = text
        self.slide = slide
        slide.bumpVersion()
    }

}
