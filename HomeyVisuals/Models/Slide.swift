import Foundation
import CoreTransferable
import SwiftData
import UniformTypeIdentifiers
import HomeyMusicKit
import SwiftUI
import CoreGraphics
import AppKit

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
    
    @Relationship(deleteRule: .cascade, inverse: \CameraWidget.slide)
    public var cameraWidgets: [CameraWidget] = []
    
    @Relationship(deleteRule: .cascade, inverse: \MusicalInstrumentWidget.slide)
    public var musicalInstrumentWidgets: [MusicalInstrumentWidget] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TonalityInstrumentWidget.slide)
    public var tonalityInstrumentWidgets: [TonalityInstrumentWidget] = []
    
    @Relationship
    public var tonality: Tonality

    @MainActor
    var musicalInstruments: [any MusicalInstrument] {
      musicalInstrumentWidgets.map { $0.musicalInstrument }
    }
    
    @MainActor
    var tonalityInstruments: [TonalityInstrument] {
      tonalityInstrumentWidgets.map { $0.tonalityInstrument }
    }
    
    @MainActor
    var tonalities: [Tonality] {
        print("tonalityInstrumentWidgets", tonalityInstrumentWidgets)
        let all = musicalInstrumentWidgets.map(\.musicalInstrument.tonality) + tonalityInstrumentWidgets.map(\.tonalityInstrument.tonality)
        var seen = Set<ObjectIdentifier>()
        return all.filter {
            seen.insert(ObjectIdentifier($0)).inserted
        }
    }
    
    public var widgets: [any Widget] {
        (
            (textWidgets as [any Widget]) +
            (cameraWidgets as [any Widget]) +
            (musicalInstrumentWidgets as [any Widget]) +
            (tonalityInstrumentWidgets as [any Widget])
        ).sorted { $0.z < $1.z }
    }
    
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
        isSkipped: Bool = false,
        tonality: Tonality = Tonality()
    ) {
        self.id = UUID()
        self.aspectRatio = aspectRatio
        self.backgroundType = backgroundType
        self.backgroundRGBAColor = backgroundRGBAColor
        self.cameraDeviceID = cameraDeviceID
        self.isSkipped = isSkipped
        self.tonality = tonality
        self.position = 0
    }
    
    // in Slide model
    public var record: SlideRecord {
      SlideRecord(
        isSkipped:       isSkipped,
        backgroundType:  backgroundType,
        backgroundColor: backgroundRGBAColor,
        aspectRatioID:   aspectRatio.id,
        cameraDeviceID:  cameraDeviceID,
        textWidgets:     textWidgets.map(\.record)
      )
    }
    
    @MainActor
    public convenience init(record: SlideRecord, in modelContext: ModelContext) {
      let fetch = AspectRatio.fetchDescriptor(id: record.aspectRatioID)
      let ratio = (try? modelContext.fetch(fetch).first)
                  ?? AspectRatio.wide(in: modelContext)

      self.init(
        aspectRatio:         ratio,
        backgroundType:      record.backgroundType,
        backgroundRGBAColor: record.backgroundColor,
        cameraDeviceID:      record.cameraDeviceID,
        isSkipped:           record.isSkipped
      )

      // re-create all the widgets
      for wRec in record.textWidgets {
        let w = TextWidget(record: wRec, slide: self)
        modelContext.insert(w)
        textWidgets.append(w)
      }
    }
    
    @MainActor
    public static func create(in context: ModelContext) -> Slide {
        let ratio = AspectRatio.wide(in: context)
        let slide = Slide(aspectRatio: ratio)
        context.insert(slide)
        return slide
    }
    
    public static func updatePositions(_ slides: [Slide]) {
        for (index, slide) in slides.enumerated() {
            slide.position = index + 1
        }
    }
    
}

public extension Slide {
    /// Fires whenever any slide-level or widget-level state changes.
    var reloadTrigger: AnyHashable {
        // 1) slide-level bits
        let base: [AnyHashable] = [
            AnyHashable(id),
            AnyHashable(backgroundType.rawValue),
            AnyHashable(backgroundRGBAColor),
            AnyHashable(cameraDeviceID ?? "")
        ]

        // 2) widget-level bits, in stable z-order
        let textHashes = textWidgets
            .sorted { $0.z < $1.z }
            .map { $0.widgetHash }

        let cameraHashes = cameraWidgets
            .sorted { $0.z < $1.z }
            .map { $0.widgetHash }
        
        let musicalInstrumentHashes = musicalInstrumentWidgets
            .sorted { $0.z < $1.z }
            .map { $0.widgetHash }

        let tonalityInstrumentHashes = tonalityInstrumentWidgets
            .sorted { $0.z < $1.z }
            .map { $0.widgetHash }
        
        let allHashes = textHashes + cameraHashes + musicalInstrumentHashes + tonalityInstrumentHashes

        return AnyHashable(base + [ AnyHashable(allHashes) ])
    }

    /// The highest z-value across *all* widgets on this slide.
    var highestZ: Int {
        let textMaxZ       = textWidgets.map(\.z).max() ?? -1
        let musicalInstrumentMaxZ = musicalInstrumentWidgets.map(\.z).max() ?? -1
        let tonalityInstrumentMaxZ = tonalityInstrumentWidgets.map(\.z).max() ?? -1
        return max(textMaxZ, musicalInstrumentMaxZ, tonalityInstrumentMaxZ)
    }
    
    var size: CGSize {
        let screen       = NSScreen.main?.frame.size
                          ?? CGSize(width: 3840, height: 2160)
        let aspect       = CGFloat(aspectRatio.ratio)
        let screenAspect = screen.width / screen.height

        if aspect > screenAspect {
            // slide is wider → full-width letterbox
            let w = screen.width
            return CGSize(width: w, height: w / aspect)
        } else {
            // slide is taller (or equal) → full-height letterbox
            let h = screen.height
            return CGSize(width: h * aspect, height: h)
        }
    }
}
