// Models/Slide.swift

import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

@Model
final class Slide: Identifiable {
    @Attribute(.unique) var id: UUID
    var testString: String = UUID().uuidString
    var isSkipped:   Bool   = false

    /// ← give a default value so you get a free `init()`
    var position: Int = 0

    init() {
        self.id = UUID()
    }
}

extension Slide {
    var record: SlideRecord {
        SlideRecord(
            isSkipped:  isSkipped,
            testString: testString
        )
    }
    
    convenience init(record: SlideRecord) {
        self.init()
        self.isSkipped  = record.isSkipped
        self.testString = record.testString
        // no need to set `position` here; your insertion logic will assign it
    }
    
    
    public static func updatePositions(_ slides: [Slide]) {
        for (idx, slide) in slides.enumerated() {
            slide.position = idx + 1
        }
    }
}
