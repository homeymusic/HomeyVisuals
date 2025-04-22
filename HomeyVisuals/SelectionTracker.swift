import SwiftUI

@MainActor
@Observable
public final class SelectionTracker {
    public var slideSelection   = Set<Slide.ID>()
    public var selectedWidgetID: UUID?

    public func selectedIndex(slides: [Slide]) -> Int? {
        guard let id = slideSelection.first else { return nil }
        return slides.firstIndex(where: { $0.id == id })
    }
    public func selectedSlide(slides: [Slide]) -> Slide? {
        guard let idx = selectedIndex(slides: slides), slides.indices.contains(idx) else { return nil }
        return slides[idx]
    }
    public func selectedWidget(selectedSlide: Slide?) -> TextWidget? {
        guard
            let slide = selectedSlide,
            let wid   = selectedWidgetID
        else { return nil }
        return slide.textWidgets.first { $0.id == wid }
    }
}
