import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]
    
    @State private var slideSelection = Set<Slide.ID>()
    
    private var selectedIndex: Int? {
        guard let id = slideSelection.first else { return nil }
        return slides.firstIndex(where: { $0.id == id })
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                SlideList(
                    selection:     $slideSelection,
                    onAddSlide:    addSlide(after:),
                    onDeleteSlide: deleteSelectedSlides
                )
                .navigationSplitViewColumnWidth(
                    min: 170,
                    ideal: 170,
                    max: 340
                )
            } content: {
                if let idx = selectedIndex {
                    SlideEdit(slide: slides[idx])
                        .navigationSplitViewColumnWidth(
                            min: geo.size.width * 0.5,
                            ideal: geo.size.width * 0.8,
                            max: geo.size.width * 0.9
                        )
                } else {
                    ContentUnavailableView(
                        "Would you look at that.",
                        systemImage: "eye"
                    )
                    .navigationSplitViewColumnWidth(
                        min: geo.size.width * 0.5,
                        ideal: geo.size.width * 0.8,
                        max: geo.size.width * 0.9
                    )
                }
            } detail: {
                if let idx = selectedIndex {
                    SlideInspect(slide: slides[idx])
                        .navigationSplitViewColumnWidth(270)
                } else {
                    ContentUnavailableView(
                        "Would you look at that.",
                        systemImage: "eye"
                    )
                    .navigationSplitViewColumnWidth(270)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // — Add Slide —
                    Button {
                        addSlide(after: slideSelection.first)
                    } label: {
                        Image(systemName: "plus.rectangle")
                    }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("n", modifiers: [.shift, .command])
                }
                
                ToolbarItem(placement: .principal) {
                    // — Play —
                    Button(action: launchSlideshow) {
                        Image(systemName: "play.fill")
                    }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("p", modifiers: [.command, .option])
                    .disabled(selectedIndex == nil)
                }
            }
            .onDeleteCommand(perform: deleteSelectedSlides)
            .onAppear {
                AspectRatio.seedSystemAspectRatios(in: modelContext)
                if slideSelection.isEmpty, let first = slides.first {
                    slideSelection = [ first.id ]
                }
            }
            .onChange(of: slides) { _, newSlides in
                if slideSelection.isEmpty, let first = newSlides.first {
                    slideSelection = [ first.id ]
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
        slideSelection = [ newSlide.id ]
    }
    
    // MARK: – Delete all selected slides
    private func deleteSelectedSlides() {
        let toDelete = slides.filter { slideSelection.contains($0.id) }
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
            let remaining = slides.filter { !slideSelection.contains($0.id) }
            Slide.updatePositions(remaining)
            
            slideSelection.removeAll()
            if let keep = nextID {
                slideSelection.insert(keep)
            }
        }
    }
}
