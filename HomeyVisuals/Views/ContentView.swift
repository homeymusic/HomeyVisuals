import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    @State private var selection = Set<Slide.ID>()

    private var selectedIndex: Int? {
        guard let id = selection.first else { return nil }
        return slides.firstIndex(where: { $0.id == id })
    }

    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                SlideList(
                    selection:     $selection,
                    onAddSlide:    addSlide(after:),
                    onDeleteSlide: deleteSelectedSlides
                )
                .frame(
                    minWidth: 200,
                    idealWidth: geo.size.width * 0.25,
                    maxWidth: geo.size.width * 0.5
                )
            } detail: {
                if let idx = selectedIndex {
                    SlideEdit(slide: slides[idx])
                } else {
                    ContentUnavailableView(
                        "Would you look at that.",
                        systemImage: "eye"
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: launchSlideshow) {
                        Label("Play", systemImage: "play.fill")
                    }
                    .keyboardShortcut("p", modifiers: [.command, .option])
                    .disabled(selectedIndex == nil)
                }
            }
            .onDeleteCommand(perform: deleteSelectedSlides)
            .onAppear {
                AspectRatio.seedSystemAspectRatios(in: modelContext)
                if selection.isEmpty, let first = slides.first {
                    selection = [ first.id ]
                }
            }
            .onChange(of: slides) { _, newSlides in
                if selection.isEmpty, let first = newSlides.first {
                    selection = [ first.id ]
                }
            }
        }
    }

    private func launchSlideshow() {
        guard let idx = selectedIndex else { return }
        Slideshow.present(slides: slides, startIndex: idx)
    }

    // MARK: – Add a new slide immediately after the given ID
    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide.create(in: modelContext)

        var reordered = slides
        let insertIndex: Int
        if
            let target = id,
            let pos = reordered.firstIndex(where: { $0.id == target })
        {
            insertIndex = pos + 1
        } else {
            insertIndex = reordered.count
        }
        reordered.insert(newSlide, at: insertIndex)
        Slide.updatePositions(reordered)
        selection = [ newSlide.id ]
    }

    // MARK: – Delete all selected slides
    private func deleteSelectedSlides() {
        let toDelete = slides.filter { selection.contains($0.id) }
        guard !toDelete.isEmpty else { return }

        let all        = slides
        let deletedIdx = toDelete.compactMap { all.firstIndex(of: $0) }.sorted()
        let afterIdx   = deletedIdx.last! + 1
        let nextID: Slide.ID? = {
            if all.indices.contains(afterIdx) {
                return all[afterIdx].id
            } else {
                let before = deletedIdx.first! - 1
                return all.indices.contains(before) ? all[before].id : nil
            }
        }()

        withAnimation {
            toDelete.forEach(modelContext.delete)
            let remaining = slides.filter { !selection.contains($0.id) }
            Slide.updatePositions(remaining)

            selection.removeAll()
            if let keep = nextID {
                selection.insert(keep)
            }
        }
    }
}
