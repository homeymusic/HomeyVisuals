// Models/AspectRatio.swift

import Foundation
import SwiftData

@Model
public final class AspectRatio: Identifiable {
    @Attribute(.unique) public var id: UUID = UUID()
    @Attribute(.unique) public var systemIdentifier: String?
    public var name:     String
    public var width:    Int
    public var height:   Int
    public var position: Int

    public var ratio: Double {
        Double(width) / Double(height)
    }

    // still @MainActor, so default init is actor‑isolated
    @MainActor
    public init(
        systemIdentifier: String? = nil,
        name: String,
        width: Int,
        height: Int,
        position: Int
    ) {
        self.systemIdentifier = systemIdentifier
        self.name             = name
        self.width            = width
        self.height           = height
        self.position         = position
    }
}
extension AspectRatio {
    public var isSystemRatio: Bool {
        systemIdentifier != nil
    }
}
