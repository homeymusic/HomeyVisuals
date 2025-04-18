// ContentView.swift

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Slide.position)])
    private var slides: [Slide]

    @Environment(\.modelContext) private var modelContext
    @State private var selection = Set<Slide.ID>()

    /// Show the first selected slide (if any) in the detail.
    private var selectedSlide: Slide? {
        guard let id = selection.first else { return nil }
        return slides.first { $0.id == id }
    }

    var body: some View {
        NavigationSplitView {
            SlideList(
                selection:     $selection,
                onAddSlide:    addSlide(after:),
                onDeleteSlide: deleteSelectedSlides
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
        .onDeleteCommand(perform: deleteSelectedSlides)
    }

    // MARK: – Helpers

    private func addSlide(after id: Slide.ID?) {
        // 1) create & insert
        let newSlide = Slide()
        modelContext.insert(newSlide)

        // 2) build an array to re‑position
        var reordered = slides

        // 3) decide insertion point
        let insertIndex: Int
        if
          let targetID = id,
          let targetSlide = slides.first(where: { $0.id == targetID }),
          let idx = reordered.firstIndex(of: targetSlide)
        {
          insertIndex = idx + 1
        } else {
          insertIndex = reordered.count
        }

        // 4) insert & update positions
        reordered.insert(newSlide, at: insertIndex)
        Slide.updatePositions(reordered)

        // 5) select the new slide
        selection = [ newSlide.id ]
    }

    private func deleteSelectedSlides() {
        let toDelete = slides.filter { selection.contains($0.id) }
        guard !toDelete.isEmpty else { return }

        // figure out indices of deleted slides
        let all = slides
        let deletedIndices = toDelete.compactMap { all.firstIndex(of: $0) }.sorted()

        // choose next selection: after the last deleted or before the first
        let afterIndex = deletedIndices.last! + 1
        let nextID: Slide.ID? = {
            if all.indices.contains(afterIndex) {
                return all[afterIndex].id
            } else {
                let beforeIndex = deletedIndices.first! - 1
                return all.indices.contains(beforeIndex) ? all[beforeIndex].id : nil
            }
        }()

        withAnimation {
            // delete from the model
            for slide in toDelete {
                modelContext.delete(slide)
            }
            // re‑index what remains
            let remaining = slides.filter { !selection.contains($0.id) }
            Slide.updatePositions(remaining)

            // reset selection
            selection.removeAll()
            if let keep = nextID {
                selection.insert(keep)
            }
        }
    }
}
