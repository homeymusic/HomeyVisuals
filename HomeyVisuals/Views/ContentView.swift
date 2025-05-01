// ContentView.swift

import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContext.self) var appContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]
    
    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                // Sidebar: list of slides
                SlideList(
                    onAddSlide:    addSlide(after:),
                    onDeleteSlide: deleteSelectedSlides
                )
                .navigationSplitViewColumnWidth(min: 170, ideal: 170, max: 340)
            } content: {
                SlideEdit()
                    .navigationSplitViewColumnWidth(
                        min: geo.size.width * 0.5,
                        ideal: geo.size.width * 0.8,
                        max: geo.size.width * 0.9
                    )
            } detail: {
                Group {
                    if let widget = appContext.selectedWidget(in: slides) {
                        // Show the correct inspector based on widget type:
                        switch widget {
                        case let textWidget as TextWidget:
                            TextWidgetInspect(textWidget: textWidget)
                        case let instrumentWidget as InstrumentWidget:
                            InstrumentWidgetInspect(instrumentWidget: instrumentWidget)
                        default:
                            EmptyView()
                        }
                    } else if let slide = appContext.selectedSlide(in: slides) {
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
                if appContext.slideSelections.isEmpty, let first = newSlides.first {
                    appContext.slideSelections = [ first.id ]
                }
            }
            .onChange(of: appContext.slideSelections) { _, _ in
                appContext.widgetSelections.removeAll()
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button { addSlide(after: appContext.slideSelections.first) }
            label: { Label("Add Slide", systemImage: "plus.rectangle") }
                .buttonStyle(.borderless)
                .keyboardShortcut("n", modifiers: [.shift, .command])
        }
        
        ToolbarItemGroup(placement: .principal) {
            ForEach(InstrumentChoice.allInstruments) { choice in
                Button {
                    addInstrument(instrumentChoice: choice)
                } label: {
                    Label(choice.label.capitalized, systemImage: choice.icon)
                }
                .buttonStyle(.borderless)
                .disabled(appContext.selectedSlide(in: slides) == nil)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Button(action: addTextWidget) {
                Label("Text Box", systemImage: "character.textbox")
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
        ToolbarItem(placement: .primaryAction) {
            Button(action: launchSlideshow) {
                Label("Play", systemImage: "play.fill")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("p", modifiers: [.command, .option])
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
    }
    
    private func seedAspectRatios() {
        AspectRatio.seedSystemAspectRatios(in: modelContext)
        if appContext.slideSelections.isEmpty, let first = slides.first {
            appContext.slideSelections = [ first.id ]
        }
    }
    
    private func launchSlideshow() {
        guard
            let slide = appContext.selectedSlide(in: slides),
            let index = slides.firstIndex(of: slide)
        else { return }
        
        SlidePresentation.present(
            slides: slides,
            startIndex: index,
            appContext: appContext
        )
    }
    
    private func addTextWidget() {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = TextWidget(slide: slide)
        
        withAnimation {
            slide.textWidgets.append(widget)
        }
        // put the new widget’s ID into the selection set
        appContext.widgetSelections = [ widget.id ]
    }
    
    private func addInstrument(instrumentChoice: InstrumentChoice) {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = InstrumentWidget.create(
            forSlide: slide,
            withChoice: instrumentChoice,
            in: modelContext
        )
        
        withAnimation {
            slide.instrumentWidgets.append(widget)
        }
        // select the new widget
        appContext.widgetSelections = [ widget.id ]
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
        
        appContext.slideSelections      = [ newSlide.id ]
        appContext.widgetSelections.removeAll()
    }
    
    private func deleteSelectedSlides() {
        let toDelete = slides.filter { appContext.slideSelections.contains($0.id) }
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
            let remaining = slides.filter { !appContext.slideSelections.contains($0.id) }
            Slide.updatePositions(remaining)
            
            appContext.slideSelections.removeAll()
            appContext.widgetSelections.removeAll()
            if let keep = nextID {
                appContext.slideSelections.insert(keep)
            }
        }
    }
}
