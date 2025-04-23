import SwiftUI

@MainActor
@Observable
public final class Selections {
    var slideSelections      = Set<Slide.ID>()
    var textWidgetSelections = Set<TextWidget.ID>()
    var editingWidgetID: TextWidget.ID? = nil
    
    func selectedSlide(in slides: [Slide]) -> Slide? {
        guard let id = slideSelections.first else { return nil }
        return slides.first { $0.id == id }
    }

    func selectedTextWidget(in slides: [Slide]) -> TextWidget? {
        guard
          let slide      = selectedSlide(in: slides),
          let widgetID   = textWidgetSelections.first
        else { return nil }
        return slide.textWidgets.first { $0.id == widgetID }
    }
}
