// Models/Slide.swift

import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

@Model
final class Slide: Identifiable {
    @Attribute(.unique) var id: UUID
    var testString: String = UUID().uuidString
    var isSkipped: Bool = false

    init() {
        self.id = UUID()
    }
}

extension Slide {
    var record: SlideRecord {
        SlideRecord(isSkipped: isSkipped,
                    testString: testString)
    }

    convenience init(record: SlideRecord) {
        self.init()
        self.isSkipped   = record.isSkipped
        self.testString  = record.testString    // ← make sure you set this!
    }
}
