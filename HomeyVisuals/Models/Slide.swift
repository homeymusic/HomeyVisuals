import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit
import SwiftUI

@Model
public final class Slide: Identifiable {
    @Attribute(.unique) public var id: UUID
    @Attribute public private(set) var version: Int = 0
    
    public var isSkipped: Bool
    public var position: Int
    
    public enum BackgroundType: Int, Codable, Sendable {
        case cameraFeed, color
    }
    public var backgroundType: BackgroundType
    /// Stored RGBA color for persistence
    public var backgroundRGBAColor: RGBAColor
    
    /// Stored selected camera device unique ID
    public var cameraDeviceID: String?
    
    @Relationship(deleteRule: .nullify)
    public var aspectRatio: AspectRatio
    
    @Relationship(deleteRule: .cascade, inverse: \TextWidget.slide)
    public var textWidgets: [TextWidget] = []
    
    /// SwiftUI-friendly color binding
    public var backgroundColor: Color {
        get { Color(backgroundRGBAColor) }
        set { backgroundRGBAColor = RGBAColor(newValue) }
    }
    
    @MainActor
    public init(
        aspectRatio: AspectRatio,
        backgroundType: BackgroundType = .color,
        backgroundRGBAColor: RGBAColor = .init(red: 0, green: 0, blue: 0, alpha: 1),
        cameraDeviceID: String? = nil,
        isSkipped: Bool = false
    ) {
        self.id = UUID()
        self.aspectRatio = aspectRatio
        self.backgroundType = backgroundType
        self.backgroundRGBAColor = backgroundRGBAColor
        self.cameraDeviceID = cameraDeviceID
        self.isSkipped = isSkipped
        self.position = 0
    }
    
    public var record: SlideRecord {
        SlideRecord(
            isSkipped:       isSkipped,
            backgroundType:  backgroundType,
            backgroundColor: backgroundRGBAColor,
            aspectRatioID:   aspectRatio.id
            // TODO: include cameraDeviceID once SlideRecord is updated
        )
    }
    
    @MainActor
    public convenience init(record: SlideRecord, in context: ModelContext) {
        let fetch = AspectRatio.fetchDescriptor(id: record.aspectRatioID)
        let ratio = (try? context.fetch(fetch).first)
        ?? AspectRatio.wide(in: context)
        self.init(
            aspectRatio:         ratio,
            backgroundType:      record.backgroundType,
            backgroundRGBAColor: record.backgroundColor,
            cameraDeviceID:      nil, // TODO: read from record once updated
            isSkipped:           record.isSkipped
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

public extension Slide {
    /// Fires whenever any slide-level or widget-level state changes.
    var thumbnailReloadTrigger: AnyHashable {
        // 1) slide-level bits
        let base: [AnyHashable] = [
            AnyHashable(id),
            AnyHashable(backgroundType.rawValue),
            AnyHashable(backgroundRGBAColor),
            AnyHashable(cameraDeviceID ?? "")
        ]

        // 2) widget-level bits, in stable order
        let widgetHashes = textWidgets
            .sorted { $0.z < $1.z }
            .map { $0.widgetHash }

        return AnyHashable(base + [ AnyHashable(widgetHashes) ])
    }

    var highestZ: Int {
        textWidgets.map(\.z).max() ?? -1
    }
}
