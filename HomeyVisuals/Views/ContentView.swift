// HomeyVisuals/Views/ContentView.swift

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
    /// Keep the window controller alive
    @State private var slideshowWC: NSWindowController?
#endif
    
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
#if os(macOS)
                    presentMacSlideShow()
#else
                    isShowingSlideshow = true
#endif
                } label: {
                    Label("Play", systemImage: "play.fill")
                }
                .keyboardShortcut("p", modifiers: [.command])
                .disabled(selectedSlide == nil)
            }
        }
#if os(iOS)
        // iOS: full‑screen cover
        .fullScreenCover(isPresented: $isShowingSlideshow) {
            if let slide = selectedSlide {
                SlideShow(slide: slide)
                    .ignoresSafeArea()
                    .onExitCommand { isShowingSlideshow = false }
            }
        }
#endif
        .onDeleteCommand(perform: deleteSelectedSlides)
        .onAppear {
            AspectRatio.seedSystemAspectRatios(modelContext: modelContext)
        }
    }
    
    // MARK: – Add / Delete
    
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
    
#if os(macOS)
    private func presentMacSlideShow() {
        guard let slide = selectedSlide else { return }
        
        // 1) Build your SlideShow host
        let hosting = NSHostingController(rootView:
                                            SlideShow(slide: slide)
            .ignoresSafeArea()
        )
        
        // 2) Create a standard titled, full‑size window
        let screenFrame = NSScreen.main?.frame ?? .zero
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask:   [
                .titled, .fullSizeContentView,
                .resizable,
                .fullSizeContentView,
                .closable
            ],
            backing:     .buffered,
            defer:       false
        )
        window.collectionBehavior = [.fullScreenPrimary]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.contentViewController = hosting
        
        // 3) Watch for the end of full‑screen so we can close it
        NotificationCenter.default.addObserver(
            forName: NSWindow.willExitFullScreenNotification,
            object: window,
            queue: .main
        ) { _ in
            window.close()
            slideshowWC = nil
        }
        
        // 4) Keep it alive and show it
        let wc = NSWindowController(window: window)
        slideshowWC = wc
        wc.showWindow(nil)
        
        // 5) Enter full‑screen on the next runloop
        DispatchQueue.main.async {
            window.toggleFullScreen(nil)
        }
    }
#endif
}
