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
    }
    
    private var listWithClipboard: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ForEach(slides) { slide in
                    NavigationLink(value: slide.id) {
                        HStack(spacing: 3) {
                            VStack {
                                Spacer()
                                Text("\(slide.position)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Thumbnail(
                              content: SlideDetail(slide: slide, isThumbnail: true),
                              reloadTrigger: slide.thumbnailReloadTrigger
                            )
                            .frame(maxWidth: .infinity)
                            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
                        }
                    }
                    .tag(slide.id)
                    .id(slide.id)
                }
                .onMove(perform: moveSlides)
            }
            .copyable(copyRecords())
            .cuttable(for: SlideRecord.self) { performCutAndReturnRecords() }
            .pasteDestination(for: SlideRecord.self) { performPaste($0) }
            .onChange(of: selection) { _, newSelection in
                guard let first = newSelection.first else { return }
                withAnimation {
                    proxy.scrollTo(first, anchor: .center)
                }
            }
        }
    }

    private func copyRecords() -> [SlideRecord] {
        slides.filter { selection.contains($0.id) }.map(\.record)
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

