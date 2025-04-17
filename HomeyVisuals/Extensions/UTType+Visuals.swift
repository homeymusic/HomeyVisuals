// UTType+Visuals.swift
import UniformTypeIdentifiers

extension UTType {
    /// Homey Visuals presentation package  (.visuals)
    static var visuals: UTType {
        // “exportedAs:” must match UTTypeIdentifier in Info.plist
        UTType(exportedAs: "com.homeymusic.visuals")
    }
}
