import SwiftUI
import SwiftData
import CoreTransferable

struct SlideList: View {
    @Environment(\.modelContext) private var modelContext

    // Live query of all slides, sorted by position
    @Query(sort: [SortDescriptor(\Slide.position)])
    private var slides: [Slide]

    @Binding var selection: Slide.ID?
    var onAddSlide:    (Slide.ID?) -> Void
    var onDeleteSlide: () -> Void

    // MARK: – Raw list

    private var rawList: some View {
        List(selection: $selection) {
            ForEach(Array(slides.enumerated()), id: \.element.id) { idx, slide in
                NavigationLink(value: slide.id) {
                    HStack(spacing: 6) {
                        Text("\(idx + 1)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(slide.testString)
                    }
                }
                .tag(slide.id)
            }
            .onMove(perform: moveSlides)
        }
    }

    // MARK: – Copy / Cut

    private func listAfterCopy() -> some View {
        rawList.copyable(copyRecords())
    }

    private func listAfterCut() -> some View {
        listAfterCopy()
            .cuttable(for: SlideRecord.self) {
                let items = copyRecords()
                onDeleteSlide()
                return items
            }
    }

    // MARK: – Paste

    private func listAfterPaste() -> some View {
        listAfterCut()
            .pasteDestination(for: SlideRecord.self) { (records: [SlideRecord]) in
                // build a temp copy
                var reordered = slides

                // compute insert‐after position
                let base = slides.firstIndex { $0.id == selection }.map { $0 + 1 }
                           ?? reordered.count
                var insertAt = base
                var newSel: Slide.ID?

                // insert the pasted slides
                for rec in records {
                    let slide = Slide(record: rec)
                    modelContext.insert(slide)
                    reordered.insert(slide, at: min(insertAt, reordered.count))
                    newSel = slide.id
                    insertAt += 1
                }

                // persist positions
                for (i, slide) in reordered.enumerated() {
                    slide.position = i
                }

                // update selection
                if let sel = newSel {
                    selection = sel
                }
            }
    }
    
    // MARK: – Toolbar

    private func listWithToolbar() -> some View {
        listAfterPaste()
            .toolbar {
                ToolbarItem {
                    Button { onAddSlide(selection) } label: {
                        Label("New Slide", systemImage: "plus")
                    }
                    .keyboardShortcut("n")
                }
            }
    }

    // MARK: – Body

    var body: some View {
        listWithToolbar()
    }

    // MARK: – Helpers

    private func moveSlides(from source: IndexSet, to dest: Int) {
        var reordered = slides
        reordered.move(fromOffsets: source, toOffset: dest)
        for (i, slide) in reordered.enumerated() {
            slide.position = i
        }
    }

    private func copyRecords() -> [SlideRecord] {
        guard
            let idx = slides.firstIndex(where: { $0.id == selection }),
            let slide = slides[safe: idx]
        else { return [] }
        return [slide.record]
    }
}

// safe‑index helper
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
