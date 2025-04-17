import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

@Model
final class Slide: Identifiable {
    @Attribute(.unique) var id: UUID
    var isSkipped: Bool = false
    
    init() {
        self.id        = UUID()
    }
}

extension Slide {
  var record: SlideRecord {
    SlideRecord(isSkipped: isSkipped)
  }

  convenience init(record: SlideRecord) {
    self.init()
    self.isSkipped = record.isSkipped
  }
}
