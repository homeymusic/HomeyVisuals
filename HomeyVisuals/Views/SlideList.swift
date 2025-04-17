import SwiftUI
import SwiftData

struct SlideList: View {
    @Bindable var presentation: Presentation
    @Binding   var selection: Slide.ID?
    var onAddSlide: (Slide.ID?) -> Void          // injected from ContentView
    
    private let dateStyle = Date.FormatStyle(date: .numeric, time: .shortened)
    
    var body: some View {
        List(selection: $selection) {
            // • Enumerate to get the index for numbering
            ForEach(Array(presentation.slides.enumerated()), id: \.element.id) { index, slide in
                NavigationLink(value: slide.id) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(index + 1)")
                            .font(.system(.caption2))
                            .foregroundStyle(.secondary)
                        
                        Text("\(slide.id)")
                    }
                }
                .tag(slide.id)
            }
            .onMove { from, to in
                presentation.slides.move(fromOffsets: from, toOffset: to)
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        .toolbar {
            ToolbarItem {
                Button { onAddSlide(selection) } label: {
                    Label("New Slide", systemImage: "plus")
                }
                .keyboardShortcut("n")
            }
        }
    }
}
