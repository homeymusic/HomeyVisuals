import SwiftUI
import SwiftData
import HomeyMusicKit
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    @State private var selection = Set<Slide.ID>()
    @State private var isShowingSlideshow = false

    #if os(macOS)
    /// keep the window controller alive
    @State private var slideshowWC: NSWindowController?
    #endif

    private var selectedIndex: Int? {
        guard
            let id = selection.first,
            let idx = slides.firstIndex(where: { $0.id == id })
        else { return nil }
        return idx
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
            if let idx = selectedIndex {
                SlideDetail(slide: slides[idx])
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
        #if os(iOS)
        .fullScreenCover(isPresented: $isShowingSlideshow) {
            if let start = selectedIndex {
                Slideshow(
                    slides: slides,
                    startIndex: start,
                    isPresented: $isShowingSlideshow
                )
                .ignoresSafeArea()
            }
        }
        #endif
        .onDeleteCommand(perform: deleteSelectedSlides)
        .onAppear {
            AspectRatio.seedSystemAspectRatios(modelContext: modelContext)
        }
    }

    private func launchSlideshow() {
        guard let start = selectedIndex else { return }
        #if os(macOS)
        Slideshow.present(slides: slides, startIndex: start)
        #else
        isShowingSlideshow = true
        #endif
    }

    // ———————————
    // MARK: Add / Delete
    // ———————————

    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide()
        modelContext.insert(newSlide)

        var reordered = slides
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
        reordered.insert(newSlide, at: insertIndex)
        Slide.updatePositions(reordered)
        selection = [ newSlide.id ]
    }

    private func deleteSelectedSlides() {
        let toDelete = slides.filter { selection.contains($0.id) }
        guard !toDelete.isEmpty else { return }

        let all = slides
        let deletedIndices = toDelete
            .compactMap { all.firstIndex(of: $0) }
            .sorted()

        let afterIndex = deletedIndices.last! + 1
        let nextID: Slide.ID? = {
            if all.indices.contains(afterIndex) {
                return all[afterIndex].id
            } else {
                let beforeIndex = deletedIndices.first! - 1
                return all.indices.contains(beforeIndex)
                    ? all[beforeIndex].id
                    : nil
            }
        }()

        withAnimation {
            for slide in toDelete {
                modelContext.delete(slide)
            }
            let remaining = slides.filter { !selection.contains($0.id) }
            Slide.updatePositions(remaining)

            selection.removeAll()
            if let keep = nextID {
                selection.insert(keep)
            }
        }
    }
}
