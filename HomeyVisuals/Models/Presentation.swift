import Foundation
import SwiftData

@Model
final class Presentation {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade)
    var slides: [Slide]

    init(
        title: String = "Untitled Presentation",
        slides: [Slide] = []
    ) {
        self.id        = UUID()
        self.title     = title
        self.createdAt = .now
        self.slides    = slides
    }
}
