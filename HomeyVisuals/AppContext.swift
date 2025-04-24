import SwiftUI

@MainActor
@Observable
public final class AppContext {
    // Only one selection set now, for *any* widget ID
    public var slideSelections      = Set<Slide.ID>()
    public var widgetSelections     = Set<UUID>()
    public var editingWidgetID: UUID? = nil

    /// Which slide is selected?
    public func selectedSlide(in slides: [Slide]) -> Slide? {
        guard let id = slideSelections.first else { return nil }
        return slides.first { $0.id == id }
    }

    /// Which widget (text or instrument) is selected?
    public func selectedWidget(in slides: [Slide]) -> (any Widget)? {
        guard let slide   = selectedSlide(in: slides),
              let widgetID = widgetSelections.first
        else { return nil }
        return slide.widgets.first { $0.id == widgetID }
    }
}
