// HomeyVisuals/Views/SlideList.swift

import SwiftUI
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers
import HomeyMusicKit

struct SlideList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    @Binding var selection: Set<Slide.ID>
    var onAddSlide: (Slide.ID?) -> Void
    var onDeleteSlide: () -> Void

    var body: some View {
        listWithClipboard
            .toolbar {
                ToolbarItem {
                    Button {
                        onAddSlide(selection.first)
                    } label: {
                        Label("New Slide", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: [.shift, .command])
                }
            }
    }

    private var listWithClipboard: some View {
        List(selection: $selection) {
            ForEach(slides) { slide in
                NavigationLink(value: slide.id) {
                    // Replace Text(...) with a real thumbnail of SlideShow:
                    if #available(iOS 16, macOS 13, *) {
                        ViewThumbnail(
                            content: SlideShow(slide: slide),
                            displaySize: CGSize(
                              width: 100,
                              height: 100 / CGFloat(slide.aspectRatio.ratio)
                            ),
                            reloadTrigger: AnyHashable("\(slide.id)-\(slide.testString)")
                        )
                        .overlay(
                            Text("\(slide.position)")
                              .font(.caption2)
                              .foregroundStyle(.secondary)
                              .padding(4),
                            alignment: .bottomLeading
                        )
                        .cornerRadius(4)
                    } else {
                        // fallback simple view if no ImageRenderer
                        ZStack(alignment: .bottomLeading) {
                            Color(slide.backgroundColor)
                                .aspectRatio(
                                    CGFloat(slide.aspectRatio.ratio),
                                    contentMode: .fit
                                )
                            Text("\(slide.position)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(4)
                        }
                        .cornerRadius(4)
                    }
                }
                .tag(slide.id)
            }
            .onMove(perform: moveSlides)
        }
        .copyable(copyRecords())
        .cuttable(for: SlideRecord.self) {
            performCutAndReturnRecords()
        }
        .pasteDestination(for: SlideRecord.self) { performPaste($0) }
    }

    // MARK: – Clipboard Actions

    private func copyRecords() -> [SlideRecord] {
        slides
            .filter { selection.contains($0.id) }
            .map(\.record)
    }

    private func performCutAndReturnRecords() -> [SlideRecord] {
        let recs = copyRecords()
        onDeleteSlide()
        selection.removeAll()
        return recs
    }

    private func performPaste(_ records: [SlideRecord]) {
        var reordered = slides
        let insertAt = slides.firstIndex(where: { selection.contains($0.id) })
                      .map { $0 + 1 } ?? reordered.count

        var cursor = insertAt
        var lastID: Slide.ID?

        for rec in records {
            let newSlide = Slide(record: rec, in: modelContext)
            modelContext.insert(newSlide)
            reordered.insert(newSlide, at: min(cursor, reordered.count))
            lastID = newSlide.id
            cursor += 1
        }

        Slide.updatePositions(reordered)
        selection.removeAll()
        if let pick = lastID {
            selection.insert(pick)
        }
    }

    // MARK: – Reordering

    private func moveSlides(fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = slides
        let moved = source.map { slides[$0] }
        reordered.move(fromOffsets: source, toOffset: destination)
        Slide.updatePositions(reordered)
        if let first = moved.first {
            selection = [ first.id ]
        }
    }
}

// MARK: – Array Safe Indexing

private extension Array {
    subscript(safe idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}
