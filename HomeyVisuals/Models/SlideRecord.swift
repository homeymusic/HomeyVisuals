import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct SlideRecord: Codable, Transferable {
  var isSkipped: Bool
  // add other fields here…

  static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(contentType: .visualsSlide)
  }
}
