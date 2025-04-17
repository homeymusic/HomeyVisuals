import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct SlideRecord: Codable, Transferable {
    var isSkipped: Bool
    var testString: String   // ← NEW

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .visualsSlide)
    }
}
