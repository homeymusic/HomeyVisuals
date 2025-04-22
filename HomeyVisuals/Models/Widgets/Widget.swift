// Widget.swift

import Foundation

/// Base protocol for anything that lives on a Slide and can be hashed for thumbnail invalidation.
protocol Widget: Identifiable {
    var id: UUID       { get }
    var slide: Slide?  { get set }
    var x: Double      { get set }
    var y: Double      { get set }
    var z: Int         { get set }
    var width: Double  { get set }
    var height: Double { get set }

    /// Every concrete Widget *must* supply its own hash snapshot.
    var widgetHash: AnyHashable { get }
}

extension Widget {
    /// Helper to gather the six geometry fields all widgets share.
    static func baseHashElements(of w: Self) -> [AnyHashable] {
        [
            AnyHashable(w.id),
            AnyHashable(w.x),
            AnyHashable(w.y),
            AnyHashable(w.z),
            AnyHashable(w.width),
            AnyHashable(w.height)
        ]
    }

    /// Stub default implementation that forces each conformer to override.
    @available(*, unavailable, message: "Conformers must implement `widgetHash`.")
    var widgetHash: AnyHashable { fatalError("Unreachable") }
}
