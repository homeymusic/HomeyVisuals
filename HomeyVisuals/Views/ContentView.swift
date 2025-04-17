import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var presentations: [Presentation]
    @State private var selection: Slide.ID?
    
    /// The only deck in this document; created lazily if needed.
    @State private var presentation: Presentation?
    
    var body: some View {
        NavigationSplitView {
            if let pres = presentation {
                SlideList(
                    presentation: pres,
                    selection: $selection,
                    onAddSlide: addSlide(after:)
                )
            }
        } detail: {
            if let slide = slide(for: selection) {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView("Create a slide",
                                       systemImage: "rectangle.on.rectangle.slash")
            }
        }
        .navigationDestination(for: Slide.ID.self) { id in
            if let slide = slide(for: id) {
                SlideEdit(slide: slide)
            }
        }
        .onDeleteCommand(perform: deleteSelectedSlide)
        .task { if presentation == nil { presentation = ensurePresentation() } }
    }
    
    // MARK: – Bootstrap
    private func ensurePresentation() -> Presentation {
        if let first = presentations.first { return first }
        let fresh = Presentation()
        modelContext.insert(fresh)
        return fresh
    }
    
    // MARK: – Lookup helpers
    private func slide(for id: Slide.ID?) -> Slide? {
        guard
            let id,
            let pres = presentation
        else { return nil }
        return pres.slides.first { $0.id == id }
    }
    
    private func indexOfSlide(for id: Slide.ID?) -> Int? {
        guard
            let id,
            let pres = presentation
        else { return nil }
        return pres.slides.firstIndex { $0.id == id }
    }
    
    // MARK: – Slide operations
    private func addSlide(after id: Slide.ID?) {
        guard let pres = presentation else { return }
        let newSlide = Slide()
        
        if let index = indexOfSlide(for: id) {
            pres.slides.insert(newSlide, at: index + 1)          // insert after current
        } else {
            pres.slides.append(newSlide)                         // append at end
        }
        selection = newSlide.id                                   // highlight it
    }
    
    private func deleteSelectedSlide() {
        guard
            let pres = presentation,
            let index = indexOfSlide(for: selection)
        else { return }
        
        withAnimation {
            pres.slides.remove(at: index)
            selection = nextSelection(afterRemoving: index, in: pres)
        }
    }
    
    private func nextSelection(afterRemoving index: Int,
                               in pres: Presentation) -> Slide.ID? {
        if pres.slides.indices.contains(index) {            // next slide exists
            return pres.slides[index].id
        } else if index > 0 {                               // deleted last slide
            return pres.slides[index - 1].id
        } else {
            return nil                                      // list now empty
        }
    }
}
