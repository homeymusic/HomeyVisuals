// Models/SlideRecord.swift

import Foundation
import CoreTransferable
import UniformTypeIdentifiers
import HomeyMusicKit

public struct SlideRecord: Codable, Transferable {
    var isSkipped:       Bool
    var testString:      String
    var backgroundType:  Slide.BackgroundType
    var backgroundColor: RGBAColor
    var aspectRatioID: UUID

    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .visualsSlide)
    }
}
