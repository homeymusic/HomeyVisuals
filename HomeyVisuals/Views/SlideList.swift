// SlideList.swift

import SwiftUI
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers
import HomeyMusicKit

struct SlideList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContext.self) var appContext
    @Query(sort: [SortDescriptor(\Slide.position)]) private var slides: [Slide]

    var onAddSlide: (Slide.ID?) -> Void
    var onDeleteSlide: () -> Void

    var body: some View {
        @Bindable var bindableSelections = appContext

        ScrollViewReader { proxy in
            List(selection: $bindableSelections.slideSelections) {
                ForEach(slides) { slide in
                    NavigationLink(value: slide.id) {
                        HStack(spacing: 3) {
                            // slide index badge
                            VStack {
                                Spacer()
                                Text("\(slide.position)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            // live, vector thumbnail
                            SlideDetail(slide: slide, isThumbnail: true)
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
            .onChange(of: appContext.slideSelections) { _, new in
                guard let first = new.first else { return }
                withAnimation { proxy.scrollTo(first, anchor: .center) }
            }
        }
    }

    // MARK: – Clipboard Helpers

    private func copyRecords() -> [SlideRecord] {
        slides.filter { appContext.slideSelections.contains($0.id) }
              .map(\.record)
    }

    private func performCutAndReturnRecords() -> [SlideRecord] {
        let recs = copyRecords()
        onDeleteSlide()
        appContext.slideSelections.removeAll()
        return recs
    }

    private func performPaste(_ records: [SlideRecord]) {
        var reordered = slides
        let insertAt = slides.firstIndex(where: { appContext.slideSelections.contains($0.id) })
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
        appContext.slideSelections.removeAll()
        if let pick = lastID {
            appContext.slideSelections.insert(pick)
        }
    }

    // MARK: – Reordering

    private func moveSlides(fromOffsets source: IndexSet, toOffset destination: Int) {
        withAnimation {
            var reordered = slides
            let moved = source.map { slides[$0] }
            reordered.move(fromOffsets: source, toOffset: destination)
            Slide.updatePositions(reordered)
            if let first = moved.first {
                appContext.slideSelections = [ first.id ]
            }
        }
    }
}
