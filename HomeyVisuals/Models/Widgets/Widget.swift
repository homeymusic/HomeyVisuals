import Foundation
import CoreGraphics

/// Base protocol for anything that lives on a Slide and can be hashed for thumbnail invalidation.
public protocol Widget: AnyObject, Identifiable, Observable {
    // MARK: — Identity & Z-order
    var id: UUID { get }
    var slide: Slide? { get set }
    var z: Int { get set }

    // MARK: — Stored (all relative, persisted)
    /// 0…1 fraction of slide width
    var relativeX: Double { get set }
    /// 0…1 fraction of slide height
    var relativeY: Double { get set }
    /// 0…1 fraction of slide width
    var relativeWidth: Double { get set }
    /// 0…1 fraction of slide height
    var relativeHeight: Double { get set }

    // MARK: — Computed (absolute, derived via slide.size)
    /// Absolute X in points
    var x: CGFloat { get set }
    /// Absolute Y in points
    var y: CGFloat { get set }
    /// Absolute width in points
    var width: CGFloat { get set }
    /// Absolute height in points
    var height: CGFloat { get set }

    /// Every concrete Widget must supply a hash snapshot that includes any content beyond geometry.
    var widgetHash: AnyHashable { get }
}

extension Widget {
    // MARK: — Helper: resolved slide size (nil → zero)
    private var slideSize: CGSize {
        slide?.size ?? .zero
    }

    // MARK: — Default computed property implementations
    public var x: CGFloat {
        get { CGFloat(relativeX) * slideSize.width }
        set {
            guard slideSize.width > 0 else { return }
            relativeX = (Double(newValue) / Double(slideSize.width)).clamped(to: 0...1)
        }
    }

    public var y: CGFloat {
        get { CGFloat(relativeY) * slideSize.height }
        set {
            guard slideSize.height > 0 else { return }
            relativeY = (Double(newValue) / Double(slideSize.height)).clamped(to: 0...1)
        }
    }

    public var width: CGFloat {
        get { CGFloat(relativeWidth) * slideSize.width }
        set {
            guard slideSize.width > 0 else { return }
            relativeWidth = (Double(newValue) / Double(slideSize.width)).clamped(to: 0...1)
        }
    }

    public var height: CGFloat {
        get { CGFloat(relativeHeight) * slideSize.height }
        set {
            guard slideSize.height > 0 else { return }
            relativeHeight = (Double(newValue) / Double(slideSize.height)).clamped(to: 0...1)
        }
    }

    // MARK: — Geometry hashing helper
    /// Gather geometry fields for thumbnail invalidation
    static func baseHashElements(of w: Self) -> [AnyHashable] {
        [
            AnyHashable(w.id),
            AnyHashable(w.relativeX),
            AnyHashable(w.relativeY),
            AnyHashable(w.z),
            AnyHashable(w.relativeWidth),
            AnyHashable(w.relativeHeight)
        ]
    }
}

// MARK: — Utility for clamping any Comparable
private extension Comparable {
    /// Clamp this value into the given closed range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

