// SlideWidgetsOverlay.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

/// Renders *all* of a slide’s widgets in z-order, using the right widget view,
/// and automatically stays up to date as SwiftData changes your model.
struct WidgetList: View {
    @Bindable var slide: Slide
    let scale: CGFloat
    let widgetViewStyle: WidgetViewStyle

    @Query private var textWidgets: [TextWidget]
    @Query private var instrumentWidgets: [InstrumentWidget]

    private var allWidgets: [any Widget] {
      (textWidgets as [any Widget] + instrumentWidgets as [any Widget])
        .sorted { $0.z < $1.z }
    }

    init(slide: Slide, scale: CGFloat, widgetViewStyle: WidgetViewStyle) {
      self.slide = slide
      self.scale = scale
      self.widgetViewStyle = widgetViewStyle

     let slideID: PersistentIdentifier = slide.persistentModelID
        
      // Compare relationship directly:
      _textWidgets = Query(
        filter:    #Predicate<TextWidget> { textWidget in
            textWidget.slide?.persistentModelID == slideID
        },
        sort:      [SortDescriptor(\.z)],
        animation: .default
      )
      _instrumentWidgets = Query(
        filter:    #Predicate<InstrumentWidget> { instrumentWidget in
            instrumentWidget.slide?.persistentModelID == slideID
        },
        sort:      [SortDescriptor(\.z)],
        animation: .default
      )
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(allWidgets, id: \.id) { widget in
                switch widgetViewStyle {
                case .thumbnail:
                    WidgetThumbnail(widget: widget, scale: scale)
                case .edit:
                    WidgetEdit(widget: widget, scale: scale)
                case .show:
                    WidgetShow(widget: widget, scale: scale)
                }
            }
        }
    }
}

enum WidgetViewStyle {
    case thumbnail
    case edit
    case show
}
