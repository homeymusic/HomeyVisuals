// Models/Slide.swift

import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@Model
public final class Slide: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var testString:   String
    public var isSkipped:     Bool
    public var position:      Int

    public enum BackgroundType: Int, Codable, Sendable {
        case cameraFeed, color
    }
    public var backgroundType:  BackgroundType
    public var backgroundColor: RGBAColor

    @Relationship(deleteRule: .nullify)
    public var aspectRatio: AspectRatio

    // MARK: — Designated initializer
    @MainActor
    public init(
        aspectRatio: AspectRatio,
        backgroundType: BackgroundType = .color,
        backgroundColor: RGBAColor = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        isSkipped: Bool = false,
        testString: String = UUID().uuidString
    ) {
        self.id              = UUID()
        self.aspectRatio     = aspectRatio
        self.backgroundType  = backgroundType
        self.backgroundColor = backgroundColor
        self.isSkipped       = isSkipped
        self.testString      = testString
        self.position        = 0
    }

    // MARK: — Convenience defaulting to Wide
    @MainActor
    public convenience init() {
        self.init(aspectRatio: AspectRatio.wide)
    }

    // MARK: — Transferable record
    public var record: SlideRecord {
        SlideRecord(
            isSkipped:       isSkipped,
            testString:      testString,
            backgroundType:  backgroundType,
            backgroundColor: backgroundColor,
            aspectRatioID:   aspectRatio.id
        )
    }

    // MARK: — Rehydrate from record
    @MainActor
    public convenience init(record: SlideRecord, in context: ModelContext) {
        // attempt to fetch the stored AspectRatio by ID
        let fetch = FetchDescriptor<AspectRatio>(
            predicate: #Predicate { $0.id == record.aspectRatioID }
        )
        let ratio = (try? context.fetch(fetch).first) ?? AspectRatio.wide

        self.init(
            aspectRatio:     ratio,
            backgroundType:  record.backgroundType,
            backgroundColor: record.backgroundColor,
            isSkipped:       record.isSkipped,
            testString:      record.testString
        )
    }

    // MARK: — Helpers
    public static func updatePositions(_ slides: [Slide]) {
        for (idx, slide) in slides.enumerated() {
            slide.position = idx + 1
        }
    }
}
