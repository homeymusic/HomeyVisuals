import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit

@Model
public final class Slide: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var testString: String
    public var isSkipped:  Bool
    public var position:   Int

    public enum BackgroundType: Int, Codable, Sendable {
        case cameraFeed, color
    }
    public var backgroundType:  BackgroundType
    public var backgroundColor: RGBAColor

    @Relationship(deleteRule: .nullify)
    public var aspectRatio: AspectRatio

    @MainActor
    public init(
        aspectRatio: AspectRatio,
        backgroundType: BackgroundType = .color,
        backgroundColor: RGBAColor = .init(red: 0, green: 0, blue: 0, alpha: 1),
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

    public var record: SlideRecord {
        SlideRecord(
            isSkipped:       isSkipped,
            testString:      testString,
            backgroundType:  backgroundType,
            backgroundColor: backgroundColor,
            aspectRatioID:   aspectRatio.id
        )
    }

    @MainActor
    public convenience init(record: SlideRecord, in context: ModelContext) {
        let fetch = AspectRatio.fetchDescriptor(id: record.aspectRatioID)
        let ratio = (try? context.fetch(fetch).first)
                  ?? AspectRatio.wide(in: context)
        self.init(
            aspectRatio:     ratio,
            backgroundType:  record.backgroundType,
            backgroundColor: record.backgroundColor,
            isSkipped:       record.isSkipped,
            testString:      record.testString
        )
    }

    @MainActor
    public static func create(in context: ModelContext) -> Slide {
        let ratio = AspectRatio.wide(in: context)
        let slide = Slide(aspectRatio: ratio)
        context.insert(slide)
        return slide
    }

    public static func updatePositions(_ slides: [Slide]) {
        for (idx, slide) in slides.enumerated() {
            slide.position = idx + 1
        }
    }
}
