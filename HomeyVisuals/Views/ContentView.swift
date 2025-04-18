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
        } detail: {
            if let slide = selectedSlide {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView(
                    "Would you look at that.",
                    systemImage: "eye"
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
        // 1) create & insert
        let newSlide = Slide()
        modelContext.insert(newSlide)

        // 2) snapshot the current slides
        var reordered = slides

        // 3) pick the insert index
        let insertIndex: Int
        if
          let targetID = id,
          let targetSlide = slide(for: targetID),
          let targetIndex = reordered.firstIndex(of: targetSlide)
        {
          insertIndex = targetIndex + 1
        } else {
          insertIndex = reordered.count
        }

        // 4) insert the new slide
        reordered.insert(newSlide, at: insertIndex)

        // 5) recompute positions for *all* slides
        Slide.updatePositions(reordered)

        // 6) finally, drive the UI
        selection = newSlide.id
    }
    
    private func deleteSelectedSlide() {
        guard let currentlySelectedSlide = selectedSlide,
              let currentlySelectedIndex = slides.firstIndex(of: currentlySelectedSlide) else { return }
        
        // Figure out what should be selected after deletion
        let nextID: Slide.ID? = {
            let afterIndex = currentlySelectedIndex + 1
            return slides.indices.contains(afterIndex)
                ? slides[afterIndex].id
            : slides.last(where: { $0.id != currentlySelectedSlide.id })?.id
        }()
        
        withAnimation {
            modelContext.delete(currentlySelectedSlide)
            // Shift down all positions after the removed slide
            for slide in slides.dropFirst(currentlySelectedIndex + 1) {
                slide.position -= 1
            }
            selection = nextID
        }
    }

}
