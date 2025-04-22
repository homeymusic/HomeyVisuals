// ContentView.swift

import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]
    
    @State private var slideSelection      = Set<Slide.ID>()
    private var selectedSlide: Slide? {
        guard
            let slideID = slideSelection.first
        else { return nil }
        return slides.first { $0.id == slideID }
    }
    
    @State private var textWidgetSelection = Set<TextWidget.ID>()
    private var selectedTextWidget: TextWidget? {
        guard
            let slide = selectedSlide,
            let textWidgetID = textWidgetSelection.first
        else { return nil }
        return slide.textWidgets.first { $0.id == textWidgetID }
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
                Group {
                    if let slide = selectedSlide {
                        SlideEdit(
                            slide:               slide,
                            textWidgetSelection: $textWidgetSelection
                        )
                    } else {
                        ContentUnavailableView("Would you look at that.", systemImage: "eye")
                    }
                }
                .navigationSplitViewColumnWidth(
                    min: geo.size.width * 0.5,
                    ideal: geo.size.width * 0.8,
                    max: geo.size.width * 0.9
                )
            } detail: {
                Group {
                    if let widget = selectedTextWidget {
                        WidgetInspect(widget: widget)
                    } else if let slide = selectedSlide {
                        SlideInspect(slide: slide)
                    } else {
                        ContentUnavailableView("Nothing to inspect", systemImage: "eye")
                    }
                }
                .navigationSplitViewColumnWidth(270)
            }
            .toolbar { toolbarItems }
            .onDeleteCommand(perform: deleteSelectedSlides)
            .onAppear(perform: seedAspectRatios)
            .onChange(of: slides) { _, newSlides in
                if slideSelection.isEmpty, let first = newSlides.first {
                    slideSelection = [ first.id ]
                }
            }
            .onChange(of: slideSelection) { _, _ in
                textWidgetSelection.removeAll()
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button { addSlide(after: slideSelection.first) }
            label: { Label("Add Slide", systemImage: "plus.rectangle") }
                .buttonStyle(.borderless)
                .keyboardShortcut("n", modifiers: [.shift, .command])
        }
        ToolbarItem(placement: .principal) {
            Button(action: addTextWidget) {
                Label("Text Box", systemImage: "character.textbox")
            }
            .buttonStyle(.borderless)
            .disabled(selectedSlide == nil)
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: launchSlideshow) {
                Label("Play", systemImage: "play.fill")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("p", modifiers: [.command, .option])
            .disabled(selectedSlide == nil)
        }
    }
    
    private func seedAspectRatios() {
        AspectRatio.seedSystemAspectRatios(in: modelContext)
        if slideSelection.isEmpty, let first = slides.first {
            slideSelection = [ first.id ]
        }
    }
    
    private func launchSlideshow() {
        guard
            let slide = selectedSlide,
            let idx   = slides.firstIndex(of: slide)
        else { return }
        Slideshow.present(slides: slides, startIndex: idx)
    }
    
    private func addTextWidget() {
        guard let slide = selectedSlide else { return }
        let widget = TextWidget(slide: slide)
        
        withAnimation {
            slide.textWidgets.append(widget)
        }
        // put the new widget’s ID into the selection set
        textWidgetSelection = [ widget.id ]
    }
    
    private func addSlide(after id: Slide.ID?) {
        let newSlide = Slide.create(in: modelContext)
        modelContext.insert(newSlide)
        
        var reordered = slides
        if
            let target = id,
            let pos    = reordered.firstIndex(where: { $0.id == target })
        {
            reordered.insert(newSlide, at: pos + 1)
        } else {
            reordered.append(newSlide)
        }
        Slide.updatePositions(reordered)
        
        slideSelection      = [ newSlide.id ]
        textWidgetSelection.removeAll()
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
            textWidgetSelection.removeAll()
            if let keep = nextID {
                slideSelection.insert(keep)
            }
        }
    }
}
