import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Slide.position)])
    private var slides: [Slide]
    
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Slide.ID?
    
    /// The currently selected slide (if any).
    private var selectedSlide: Slide? {
        slide(for: selection)
    }
    
    var body: some View {
        NavigationSplitView {
            SlideList(
                selection:     $selection,
                onAddSlide:    addSlide(after:),
                onDeleteSlide: deleteSelectedSlide
            )
            .frame(minWidth: 200)
            .navigationDestination(for: Slide.ID.self) { id in
                if let slide = slide(for: id) {
                    SlideEdit(slide: slide)
                }
            }
        } detail: {
            if let slide = selectedSlide {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView(
                    "Create a slide",
                    systemImage: "rectangle.on.rectangle.slash"
                )
            }
        }
        .onDeleteCommand(perform: deleteSelectedSlide)
    }
    
    // MARK: – Helpers
    
    /// Look up a Slide by ID.
    private func slide(for id: Slide.ID?) -> Slide? {
        guard let id = id else { return nil }
        return slides.first { $0.id == id }
    }
    
    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide()
        modelContext.insert(newSlide)
        
        // Determine insertion index in the `slides` array
        let insertIndex: Int
        if let selID = id,
           let current = slide(for: selID),
           let idx = slides.firstIndex(of: current) {
            insertIndex = idx + 1
        } else {
            insertIndex = slides.count
        }
        
        // Shift all positions ≥ insertIndex
        for slide in slides.dropFirst(insertIndex) {
            slide.position += 1
        }
        
        newSlide.position = insertIndex
        selection = newSlide.id
    }
    
    private func deleteSelectedSlide() {
        guard let sel = selectedSlide,
              let idx = slides.firstIndex(of: sel) else { return }
        
        // Figure out what should be selected after deletion
        let nextID: Slide.ID? = {
            let after = idx + 1
            return slides.indices.contains(after)
                ? slides[after].id
            : slides.last(where: { $0.id != sel.id })?.id
        }()
        
        withAnimation {
            modelContext.delete(sel)
            // Shift down all positions after the removed slide
            for slide in slides.dropFirst(idx + 1) {
                slide.position -= 1
            }
            selection = nextID
        }
    }
}
