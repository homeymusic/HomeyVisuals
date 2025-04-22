// ContentView.swift

import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    @State private var slideSelection   = Set<Slide.ID>()
    @State private var selectedWidgetID: UUID?

    private var selectedIndex: Int? {
        guard let id = slideSelection.first else { return nil }
        return slides.firstIndex(where: { $0.id == id })
    }
    private var selectedSlide: Slide? {
        guard let idx = selectedIndex, slides.indices.contains(idx) else { return nil }
        return slides[idx]
    }
    private var selectedWidget: TextWidget? {
        guard
            let slide = selectedSlide,
            let wid   = selectedWidgetID
        else { return nil }
        return slide.textWidgets.first { $0.id == wid }
    }

    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                // Sidebar: list of slides
                SlideList(
                    selection:     $slideSelection,
                    onAddSlide:    addSlide(after:),
                    onDeleteSlide: deleteSelectedSlides
                )
                .navigationSplitViewColumnWidth(min: 170, ideal: 170, max: 340)
            } content: {
                // Main canvas / editor
                if let slide = selectedSlide {
                    SlideEdit(
                        slide: slide,
                        selectedWidgetID: $selectedWidgetID
                    )
                    .navigationSplitViewColumnWidth(
                        min: geo.size.width * 0.5,
                        ideal: geo.size.width * 0.8,
                        max: geo.size.width * 0.9
                    )
                } else {
                    ContentUnavailableView("Would you look at that.", systemImage: "eye")
                        .navigationSplitViewColumnWidth(
                            min: geo.size.width * 0.5,
                            ideal: geo.size.width * 0.8,
                            max: geo.size.width * 0.9
                        )
                }
            } detail: {
                // Inspector: widget first, else slide
                if let widget = selectedWidget {
                    WidgetInspect(widget: widget)
                        .navigationSplitViewColumnWidth(270)
                } else if let slide = selectedSlide {
                    SlideInspect(slide: slide)
                        .navigationSplitViewColumnWidth(270)
                } else {
                    ContentUnavailableView("Would you look at that.", systemImage: "eye")
                        .navigationSplitViewColumnWidth(270)
                }
            }
            .toolbar {
                // — New Slide —
                ToolbarItem(placement: .principal) {
                    Button {
                        addSlide(after: slideSelection.first)
                    } label: {
                        Label("Add Slide", systemImage: "plus.rectangle")
                    }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("n", modifiers: [.shift, .command])
                }

                // — New Text Widget —
                ToolbarItem(placement: .principal) {
                    Button(action: addTextWidget) {
                        Label("Text Box", systemImage: "character.textbox")
                    }
                    .buttonStyle(.borderless)
                    .disabled(selectedIndex == nil)
                }

                // — Play Slideshow —
                ToolbarItem(placement: .primaryAction) {
                    Button(action: launchSlideshow) {
                        Label("Play", systemImage: "play.fill")
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
            .onChange(of: slideSelection) { _, _ in
                selectedWidgetID = nil
            }
        }
    }

    // MARK: – Actions

    private func launchSlideshow() {
        guard let idx = selectedIndex else { return }
        Slideshow.present(slides: slides, startIndex: idx)
    }

    private func addTextWidget() {
        guard let slide = selectedSlide else { return }
        let widget = TextWidget(slide: slide)
        withAnimation {
            slide.textWidgets.append(widget)
        }
        selectedWidgetID = widget.id
    }

    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide.create(in: modelContext)
        var reordered = slides
        let insertIndex: Int
        if let target = id,
           let pos    = reordered.firstIndex(where: { $0.id == target })
        {
            insertIndex = pos + 1
        } else {
            insertIndex = reordered.count
        }
        reordered.insert(newSlide, at: insertIndex)
        Slide.updatePositions(reordered)
        slideSelection = [ newSlide.id ]
        selectedWidgetID = nil
    }

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
            selectedWidgetID = nil
            if let keep = nextID {
                slideSelection.insert(keep)
            }
        }
    }
}
