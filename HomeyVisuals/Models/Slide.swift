import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

@Model
final class Slide: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var isSkipped: Bool = false
    
    init(
        title: String = "New Slide",
        body: String  = ""
    ) {
        self.id        = UUID()
        self.title     = title
        self.body      = body
        self.createdAt = .now
    }
}
