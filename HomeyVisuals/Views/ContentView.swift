import SwiftUI
import SwiftData

struct ContentView: View {
    // ① Live query of all slides, sorted by position
    @Query(sort: [SortDescriptor(\Slide.position)])
    private var slides: [Slide]
    
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Slide.ID?
    
    var body: some View {
        NavigationSplitView {
            SlideList(
                selection:      $selection,
                onAddSlide:     addSlide(after:),
                onDeleteSlide:  deleteSelectedSlide
            )
            .frame(minWidth: 200)
            .navigationDestination(for: Slide.ID.self) { id in
                if let slide = slides.first(where: { $0.id == id }) {
                    SlideEdit(slide: slide)
                }
            }
        } detail: {
            if let slide = slides.first(where: { $0.id == selection }) {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView("Create a slide",
                                       systemImage: "rectangle.on.rectangle.slash")
            }
        }
        
        .onDeleteCommand(perform: deleteSelectedSlide)
    }
    
    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide()
        modelContext.insert(newSlide)
        
        // compute insertion position
        let insertPos: Int
        if let selID = id,
           let sel = slides.first(where: { $0.id == selID }) {
            insertPos = sel.position + 1
        } else {
            insertPos = (slides.map(\Slide.position).max() ?? -1) + 1
        }
        
        // bump existing slides
        for slide in slides where slide.position >= insertPos {
            slide.position += 1
        }
        
        newSlide.position = insertPos
        selection = newSlide.id
    }
    
    private func deleteSelectedSlide() {
        // 1️⃣ Find index of current selection in the live `slides` array
        guard let idx = slides.firstIndex(where: { $0.id == selection }) else { return }
        
        // 2️⃣ Capture the ID of the slide immediately after it (might be nil)
        let nextID = slides[safe: idx + 1]?.id
        
        withAnimation {
            // 3️⃣ Delete the selected slide
            modelContext.delete(slides[idx])
            
            // 4️⃣ Renumber the remaining slides
            for slide in slides.dropFirst(idx + 1) {
                slide.position -= 1
            }
            
            // 5️⃣ Set selection:
            //    • if there was a slide after the deleted one, pick that
            //    • otherwise (we deleted the last), pick the new last slide
            if let nid = nextID {
                selection = nid
            } else {
                selection = slides.last?.id
            }
        }
    }
}

// safe‑index helper
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
