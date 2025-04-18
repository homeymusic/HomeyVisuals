import SwiftUI
import SwiftData
import CoreTransferable

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

    // MARK: - View Builder

    private func makeListView() -> some View {
        List(selection: $selection) {
            ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                NavigationLink(value: slide.id) {
                    HStack(spacing: 6) {
                        Text("\(index + 1)")
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

    // MARK: - Clipboard Actions

    private func copyRecords() -> [SlideRecord] {
        guard let selectedID = selection,
              let slide = slides.first(where: { $0.id == selectedID }) else {
            return []
        }
        return [slide.record]
    }

    private func performCutAndReturnRecords() -> [SlideRecord] {
        guard let selectedID = selection,
              let index = slides.firstIndex(where: { $0.id == selectedID }),
              let record = slides[safe: index]?.record else {
            onDeleteSlide()
            return []
        }

        let nextSelection = slides[safe: index + 1]?.id ?? slides[safe: index - 1]?.id

        onDeleteSlide()
        selection = nextSelection

        return [record]
    }

    private func performPaste(_ records: [SlideRecord]) {
        var reordered = slides
        let insertIndex = slides.firstIndex { $0.id == selection }.map { $0 + 1 } ?? reordered.count

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

    // MARK: - Slide Ordering

    private func moveSlides(fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = slides
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, slide) in reordered.enumerated() {
            slide.position = index
        }
    }
}

// MARK: - Array Safe Indexing

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
