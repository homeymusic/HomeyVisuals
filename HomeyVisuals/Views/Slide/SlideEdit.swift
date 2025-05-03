// SlideEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

struct SlideEdit: View {
    @Environment(AppContext.self) private var appContext
    
    @Bindable var slide: Slide
    
    var body: some View {
        ZStack {
            // 1) Catch every tap in the entire editing pane and clear selection/edit‐mode
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    appContext.widgetSelections.removeAll()
                    appContext.editingWidgetID = nil
                }
            // 2) Then draw either the slide editor or a placeholder
            SlideContainer(slide: slide, isThumbnail: false) { scale in
                ZStack(alignment: .topLeading) {
                    // 2a) Also catch taps _inside_ the letterbox to clear
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appContext.widgetSelections.removeAll()
                            appContext.editingWidgetID = nil
                        }
                    
                    // 2b) Your editable widgets
                    WidgetList(
                        slide: slide,
                        scale: scale,
                        widgetViewStyle: .edit
                    )
                }
            }
            .navigationTitle("Edit Slide")
        }
    }
}
