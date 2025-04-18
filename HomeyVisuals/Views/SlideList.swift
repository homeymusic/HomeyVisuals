import SwiftUI
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

struct SlideList: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\Slide.position)])
    private var slides: [Slide]
    
    @Binding var selection: Slide.ID?
    var onAddSlide: (Slide.ID?) -> Void
    var onDeleteSlide: () -> Void
    
    var body: some View {
        makeListView()
            .copyable(copyRecords())
            .cuttable(for: SlideRecord.self) {
                performCutAndReturnRecords()
            }
            .pasteDestination(for: SlideRecord.self, action: performPaste)
            .toolbar {
                ToolbarItem {
                    Button(action: { onAddSlide(selection) }) {
                        Label("New Slide", systemImage: "plus")
                    }
                    .keyboardShortcut("n")
                }
            }
    }
    
    // MARK: – List Construction
    
    private func makeListView() -> some View {
        List(selection: $selection) {
            ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                NavigationLink /*(value: slide.id)*/ {
                    HStack(spacing: 6) {
                        Text("\(index + 1)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(slide.testString)
                    }
                } label: {
                    Text(slide.testString)
                        .draggable(slide.record) {
                            let printMe = print(".draggable")
                            
                            HStack(spacing: 6) {
                                Image(systemName: "square.on.square")
                                Text(slide.testString)
                            }
                        }
                }
                .tag(slide.id)
            }
//            .onMove(perform: moveSlides)
        }
        .contentShape(Rectangle())
        .dropDestination(for: SlideRecord.self) { records, _ in
            let printMe = print(".dropDestination")
            performDrop(records: records)
            return true
        }
        //        .onDrop(of: [UTType.visualsSlide.identifier], isTargeted: nil) { providers in
        .onDrop(of: [UTType.data.identifier],
                isTargeted: nil) { providers in
            let printMe = print(".onDrop")
            for provider in providers {
                let printMe = print("‣ registered types:", provider.registeredTypeIdentifiers)
                if provider.hasItemConformingToTypeIdentifier(UTType.visualsSlide.identifier) {
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.visualsSlide.identifier) { data, _ in
                        guard let data else { return }
                        do {
                            let record = try JSONDecoder().decode(SlideRecord.self, from: data)
                            Task { @MainActor in
                                performDrop(records: [record])
                            }
                        } catch {
                            print("Failed to decode SlideRecord from drop data: \(error)")
                        }
                    }
                }
            }
            return true
        }
    }
    
    // MARK: – Drop Handling
    
    private func performDrop(records: [SlideRecord]) {
        var reordered = slides
        let baseIndex = slides.firstIndex(where: { $0.id == selection })
            .map { $0 + 1 } ?? reordered.count
        var insertAt = baseIndex
        var lastInsertedID: Slide.ID?
        
        for record in records {
            let slide = Slide(record: record)
            modelContext.insert(slide)
            reordered.insert(slide, at: min(insertAt, reordered.count))
            lastInsertedID = slide.id
            insertAt += 1
        }
        
        for (i, slide) in reordered.enumerated() {
            slide.position = i
        }
        
        if let newSelection = lastInsertedID {
            selection = newSelection
        }
    }
    
    // MARK: – Clipboard Actions
    
    private func copyRecords() -> [SlideRecord] {
        guard let selectedID = selection,
              let slide = slides.first(where: { $0.id == selectedID })
        else { return [] }
        return [slide.record]
    }
    
    private func performCutAndReturnRecords() -> [SlideRecord] {
        guard let selectedID = selection,
              let index = slides.firstIndex(where: { $0.id == selectedID }),
              let record = slides[safe: index]?.record
        else {
            onDeleteSlide()
            return []
        }
        
        let nextSel = slides[safe: index + 1]?.id
        ?? slides[safe: index - 1]?.id
        
        onDeleteSlide()
        selection = nextSel
        return [record]
    }
    
    private func performPaste(_ records: [SlideRecord]) {
        var reordered = slides
        let insertIndex = slides.firstIndex(where: { $0.id == selection })
            .map { $0 + 1 } ?? reordered.count
        
        var insertAt = insertIndex
        var lastInsertedID: Slide.ID?
        
        for record in records {
            let slide = Slide(record: record)
            modelContext.insert(slide)
            reordered.insert(slide, at: min(insertAt, reordered.count))
            lastInsertedID = slide.id
            insertAt += 1
        }
        
        for (i, slide) in reordered.enumerated() {
            slide.position = i
        }
        
        if let newSelection = lastInsertedID {
            selection = newSelection
        }
    }
    
    // MARK: – Reordering
    
    private func moveSlides(fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = slides
        let movedSlides = source.map { slides[$0] }
        
        reordered.move(fromOffsets: source, toOffset: destination)
        
        for (i, slide) in reordered.enumerated() {
            slide.position = i
        }
        
        if let firstMoved = movedSlides.first {
            selection = firstMoved.id
        }
    }
}

// MARK: – Array Safe Indexing

private extension Array {
    subscript(safe idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}

