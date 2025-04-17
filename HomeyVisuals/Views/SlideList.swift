import SwiftData
import SwiftUI

struct SlideList: View {
    @Bindable var presentation: Presentation
    @Binding  var selection: Slide.ID?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(presentation.slides) { slide in
                NavigationLink(value: slide.id) {
                    Text("Item at \(slide.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                }
            }
            .onMove { from, to in
                presentation.slides.move(fromOffsets: from, toOffset: to)
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .toolbar {
            ToolbarItem {
                Button {
                    addSlide()
                } label: {
                    Label("New Slide", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
    private func addSlide() {
        withAnimation {
            let newSlide = Slide()

            if let id = selection,
               let index = presentation.slides.firstIndex(where: { $0.id == id }) {
                presentation.slides.insert(newSlide, at: index + 1)
            } else {
                presentation.slides.append(newSlide)
            }
            selection = newSlide.id                 // highlight the new slide
        }
    }
}
