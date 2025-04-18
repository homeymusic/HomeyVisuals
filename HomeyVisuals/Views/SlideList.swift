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
                    .keyboardShortcut("n", modifiers: [.shift, .command])
                }
            }
    }

    // MARK: – List Construction

    private func makeListView() -> some View {
        List(selection: $selection) {
            ForEach(slides) { slide in
                NavigationLink(value: slide.id) {
                    HStack(spacing: 6) {
                        Text("\(slide.position)")
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

        Slide.updatePositions(reordered)

        if let newSelection = lastInsertedID {
            selection = newSelection
        }
    }

    // MARK: – Reordering

    private func moveSlides(fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = slides
        let movedSlides = source.map { slides[$0] }

        reordered.move(fromOffsets: source, toOffset: destination)

        Slide.updatePositions(reordered)

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

