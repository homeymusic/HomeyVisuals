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
