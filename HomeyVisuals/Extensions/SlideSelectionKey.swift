// SlideSelectionKey.swift
import SwiftUI

private struct SlideSelectionKey: FocusedValueKey {
    typealias Value = Binding<Slide?>
}

extension FocusedValues {
    var slideSelection: Binding<Slide?>? {
        get { self[SlideSelectionKey.self] }
        set { self[SlideSelectionKey.self] = newValue }
    }
}
