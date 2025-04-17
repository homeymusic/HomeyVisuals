import SwiftUI
import SwiftData

struct SlideList: View {
    @Bindable var presentation: Presentation
    @Binding   var selection: Slide.ID?
    var onAddSlide: (Slide.ID?) -> Void               // callback from parent

    private let dateStyle = Date.FormatStyle(date: .numeric, time: .shortened)

    var body: some View {
        List(selection: $selection) {
            ForEach(presentation.slides) { slide in
                NavigationLink(value: slide.id) {
                    Text("\(slide.title)  —  \(slide.createdAt)")
                }
                .tag(slide.id)                       // participate in selection
            }
            .onMove { from, to in
                presentation.slides.move(fromOffsets: from, toOffset: to)
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .toolbar {
            ToolbarItem {
                Button { onAddSlide(selection) }
                label: {
                    Label("New Slide", systemImage: "plus")
                }
                .keyboardShortcut("n")
            }
        }
    }
}
