import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var presentations: [Presentation]
    @State private var selection:    Slide.ID?
    @State private var presentation: Presentation?

    var body: some View {
        NavigationSplitView {
            if let pres = presentation {
                SlideList(
                    presentation:   pres,
                    selection:      $selection,
                    onAddSlide:     addSlide(after:),
                    onDeleteSlide:  deleteSelectedSlide
                )
                .navigationDestination(for: Slide.ID.self) { id in
                    if let slide = slide(for: id) {
                        SlideEdit(slide: slide)
                    }
                }
            }
        } detail: {
            if let slide = slide(for: selection) {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView("Create a slide",
                                      systemImage: "rectangle.on.rectangle.slash")
            }
        }
        .onDeleteCommand(perform: deleteSelectedSlide)
        .task {
            if presentation == nil {
                presentation = ensurePresentation()
            }
        }
    }

    // MARK: – Bootstrap
    private func ensurePresentation() -> Presentation {
        if let first = presentations.first { return first }
        let fresh = Presentation()
        modelContext.insert(fresh)
        return fresh
    }

    // MARK: – Lookup
    private func slide(for id: Slide.ID?) -> Slide? {
        guard let id = id, let pres = presentation else { return nil }
        return pres.slides.first { $0.id == id }
    }

    private func indexOfSlide(for id: Slide.ID?) -> Int? {
        guard let id = id, let pres = presentation else { return nil }
        return pres.slides.firstIndex { $0.id == id }
    }

    // MARK: – Slide ops
    private func addSlide(after id: Slide.ID?) {
        guard let pres = presentation else { return }
        let newSlide = Slide()
        if let idx = indexOfSlide(for: id) {
            pres.slides.insert(newSlide, at: idx + 1)
        } else {
            pres.slides.append(newSlide)
        }
        selection = newSlide.id
    }

    private func deleteSelectedSlide() {
        guard
            let pres = presentation,
            let idx = indexOfSlide(for: selection)
        else { return }

        withAnimation {
            pres.slides.remove(at: idx)
            selection = nextSelection(afterRemoving: idx, in: pres)
        }
    }

    private func nextSelection(afterRemoving index: Int,
                               in pres: Presentation) -> Slide.ID? {
        if pres.slides.indices.contains(index) {
            return pres.slides[index].id
        } else if index > 0 {
            return pres.slides[index - 1].id
        } else {
            return nil
        }
    }
}
