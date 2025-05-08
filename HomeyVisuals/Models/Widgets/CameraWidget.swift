import SwiftUI
import SwiftData
import CoreGraphics
import AVFoundation
import HomeyMusicKit

@Model
public final class CameraWidget: Widget {
    // MARK: — Stored (all relative, persisted)
    @Attribute(.unique) public var id: UUID
    public var slide: Slide?
    public var z: Int
    // MARK: — Stored (relative, persisted)
    public var relativeX: Double = 0.5
    public var relativeY: Double = 0.5
    public var relativeWidth: Double = 1.0 / (2.0 * HomeyMusicKit.goldenRatio)
    public var relativeHeight: Double = 1.0 / (2.0 * HomeyMusicKit.goldenRatio)

    /// Which camera to show
    public var cameraDeviceID: String?
    
    // MARK: — Init
    public init(
        slide: Slide? = nil,
        z: Int = 0,
        cameraDeviceID: String? = nil
    ) {
        self.id               = UUID()
        self.slide            = slide
        self.z                = z
        self.cameraDeviceID   = cameraDeviceID
    }
    
}

extension CameraWidget {
    /// Include geometry + content in the hash snapshot.
    public var widgetHash: AnyHashable {
        var arr = Self.baseHashElements(of: self as! Self)
        arr.append(AnyHashable(cameraDeviceID))
        return AnyHashable(arr)
    }
}

