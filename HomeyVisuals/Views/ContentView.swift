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
        guard let idx = slides.firstIndex(where: { $0.id == selection }) else { return }

        withAnimation {
            modelContext.delete(slides[idx])

            for slide in slides.dropFirst(idx + 1) {
                slide.position -= 1
            }

            // pick next or previous
            let next = slides[safe: idx]?.id ?? slides[safe: idx - 1]?.id
            selection = next
        }
    }
}

// safe‑index helper
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
