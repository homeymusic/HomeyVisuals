import SwiftUI

@MainActor
@Observable
public final class AppContext {
    /// Current zoom factor mapping slide‐space to screen‐space
    public var slideScale: CGFloat = 1.0

    var slideSelections      = Set<Slide.ID>()
    var textWidgetSelections = Set<TextWidget.ID>()
    var instrumentWidgetSelections = Set<InstrumentWidget.ID>()
    var editingTextWidgetID: TextWidget.ID? = nil
    var editingInstrumentWidgetID: InstrumentWidget.ID? = nil

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
    
    func selectedInstrumentWidget(in slides: [Slide]) -> InstrumentWidget? {
        guard
          let slide      = selectedSlide(in: slides),
          let widgetID   = instrumentWidgetSelections.first
        else { return nil }
        return slide.instrumentWidgets.first { $0.id == widgetID }
    }

}
