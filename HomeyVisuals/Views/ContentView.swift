// ContentView.swift

import SwiftUI
import SwiftData
import HomeyMusicKit
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContext.self) var appContext
    @Environment(MusicalInstrumentCache.self)  private var musicalInstrumentCache
    @Environment(TonalityCache.self) private var tonalityCache
    @Environment(MIDIConductor.self)  private var midiConductor
    @Environment(SynthConductor.self)  private var synthConductor

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
                if let slide = appContext.selectedSlide(in: slides) {
                    SlideEdit(slide: slide)
                } else {
                    ContentUnavailableView("Nothing to edit", systemImage: "eye")
                }
            } detail: {
                Group {
                    if let widget = appContext.selectedWidget(in: slides) {
                        // Show the correct inspector based on widget type:
                        switch widget {
                        case let textWidget as TextWidget:
                            TextWidgetInspect(textWidget: textWidget)
                        case let cameraWidget as CameraWidget:
                            CameraWidgetInspect(cameraWidget: cameraWidget)
                        case let musicalInstrumentWidget as MusicalInstrumentWidget:
                            MusicalInstrumentWidgetInspect(musicalInstrumentWidget: musicalInstrumentWidget)
                        case let tonalityInstrumentWidget as TonalityInstrumentWidget:
                            TonalityInstrumentWidgetInspect(tonalityInstrumentWidget: tonalityInstrumentWidget)
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
                .onChange(of: appContext.widgetSelections) {
                    // 1) Try to get the instrument from the now-selected widget (if it’s an InstrumentWidget)
                    let musicalInstrumentFromCurrentlySelectedWidget: (any MusicalInstrument)? = {
                        guard let selectedMusicalInstrumentWidget = appContext.selectedWidget(in: slides) as? MusicalInstrumentWidget
                        else { return nil }
                        return selectedMusicalInstrumentWidget.musicalInstrument
                    }()

                    if let musicalInstrumentChosenByWidgetSelection = musicalInstrumentFromCurrentlySelectedWidget {
                        musicalInstrumentCache.selectMusicalInstrument(musicalInstrumentChosenByWidgetSelection)
                    }
                    // 2) Otherwise, fall back to the very first instrument on the currently selected slide
                    else if let slideThatIsCurrentlySelected = appContext.selectedSlide(in: slides),
                            let firstMusicalInstrumentOnThatSlide = slideThatIsCurrentlySelected.musicalInstruments.first {
                        musicalInstrumentCache.selectMusicalInstrument(firstMusicalInstrumentOnThatSlide)
                    }
                    // 3) If neither yields an instrument, clear the cache’s selection
                    else {
                        musicalInstrumentCache.selectMusicalInstrument(nil)
                    }
                }
            }
            .toolbar { toolbarItems }
            .onDeleteCommand(perform: deleteSelectedSlides)
            .onAppear {
                seedAspectRatios()
                seedColorPalettes()
            }
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
            ForEach(MusicalInstrumentType.allInstruments) { choice in
                Button {
                    addMusicalInstrumentWidget(instrumentType: choice)
                } label: {
                    Label(choice.label.capitalized, systemImage: choice.icon)
                }
                .buttonStyle(.borderless)
                .disabled(appContext.selectedSlide(in: slides) == nil)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Button {
                addTonalityInstrumentWidget()
            } label: {
                Label(TonalityControlType.tonicPicker.label.capitalized, systemImage: TonalityControlType.tonicPicker.icon)
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
        
        ToolbarItem(placement: .principal) {
            Button {
                addPitchDirectionPickerWidget()
            } label: {
                Label(TonalityControlType.pitchDirectionPicker.label.capitalized, systemImage: TonalityControlType.pitchDirectionPicker.icon)
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
        
        ToolbarItem(placement: .principal) {
            Button {
                addOctaveShifterWidget()
            } label: {
                Label(TonalityControlType.octaveShifter.label.capitalized, systemImage: TonalityControlType.octaveShifter.icon)
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
        
        ToolbarItem(placement: .principal) {
            Button(action: addTextWidget) {
                Label("Text Box", systemImage: "character.textbox")
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }
        
        ToolbarItem(placement: .principal) {
            Button(action: addCameraWidget) {
                Label("Camera", systemImage: "video")
            }
            .buttonStyle(.borderless)
            .disabled(appContext.selectedSlide(in: slides) == nil)
        }

        ToolbarItem(placement: .primaryAction) {
            Button(action: presentSlides) {
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
    
    private func seedColorPalettes() {
        IntervalColorPalette.seedSystemIntervalPalettes(modelContext: modelContext)
        PitchColorPalette.seedSystemPitchPalettes(modelContext: modelContext)
    }
    
    private func presentSlides() {
        guard
            let slide = appContext.selectedSlide(in: slides),
            let index = slides.firstIndex(of: slide)
        else { return }
        
        SlidePresentation.present(
            slides:           slides,
            startIndex:       index,
            appContext:       appContext,
            musicalInstrumentCache:  musicalInstrumentCache,
            tonalityCache: tonalityCache,
            synthConductor:   synthConductor,
            midiConductor:    midiConductor
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
    
    private func addCameraWidget() {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = CameraWidget(slide: slide)
        print("addCameraWidget relativeWidth", widget.relativeWidth, "relativeHeight", widget.relativeHeight)

        
        withAnimation {
            slide.cameraWidgets.append(widget)
        }
        // put the new widget’s ID into the selection set
        appContext.widgetSelections = [ widget.id ]
    }
    
    private func addMusicalInstrumentWidget(instrumentType: MusicalInstrumentType) {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = MusicalInstrumentWidget.create(
            slide: slide,
            type: instrumentType,
            in: modelContext
        )
        
        withAnimation {
            slide.musicalInstrumentWidgets.append(widget)
        }
        // select the new widget
        appContext.widgetSelections = [ widget.id ]
    }
    
    private func addTonalityInstrumentWidget() {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = TonalityInstrumentWidget.create(
            slide: slide,
            in: modelContext
        )
        
        withAnimation {
            slide.tonalityInstrumentWidgets.append(widget)
        }
        appContext.widgetSelections = [ widget.id ]
    }
        
    private func addPitchDirectionPickerWidget() {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = TonalityInstrumentWidget.create(
            slide: slide,
            in: modelContext
        )
        
        withAnimation {
            slide.tonalityInstrumentWidgets.append(widget)
        }
        appContext.widgetSelections = [ widget.id ]
    }
    
    private func addOctaveShifterWidget() {
        guard let slide = appContext.selectedSlide(in: slides) else { return }
        let widget = TonalityInstrumentWidget.create(
            slide: slide,
            in: modelContext
        )
        
        withAnimation {
            slide.tonalityInstrumentWidgets.append(widget)
        }
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
